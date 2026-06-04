<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\KhqrTransaction;
use App\Models\Order;
use App\Models\Payment;
use App\Services\KhPayService;
use App\Services\OrderPaymentService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class KhqrPaymentController extends Controller
{
    public function generateQr(Request $request)
    {
        $validated = $request->validate([
            'amount' => ['required', 'numeric', 'min:0.01'],
            'currency' => ['required', 'string', 'max:10'],
            'order_id' => ['nullable', 'integer', 'exists:orders,id'],
        ]);

        $currency = strtoupper((string) $validated['currency']);
        if (! in_array($currency, ['USD', 'KHR'], true)) {
            return response()->json([
                'message' => 'Unsupported currency. KHQR supports USD or KHR.',
            ], 400);
        }

        $actor = $request->user() ?? $request->user('sanctum');
        $order = null;

        if (! empty($validated['order_id'])) {
            $order = Order::find($validated['order_id']);
            if (! $order) {
                return response()->json(['message' => 'Order not found.'], 404);
            }

            if ($actor && method_exists($actor, 'isAdmin') && ! $actor->isAdmin()) {
                if ((int) $order->user_id !== (int) $actor->id) {
                    return response()->json(['message' => 'Forbidden.'], 403);
                }
            }
        }

        $amount = (float) $validated['amount'];
        
        $billNumber = null;
        if ($order?->order_number) {
            $billNumber = $order->order_number;
        } elseif ($order?->id) {
            $billNumber = 'ORD'.$order->id;
        } else {
            $billNumber = 'KH'.now()->format('ymdHis');
        }
        $billNumber = substr(preg_replace('/\s+/', '', $billNumber), 0, 25);

        try {
            $khpay = app(KhPayService::class);
            $response = $khpay->generateBakongQr($amount, $currency, 'Order #' . $billNumber, [
                'callback_url' => url('api/payments/khpay-callback'),
                'success_url' => $order ? url("checkout/success?order_id={$order->id}") : null,
                'cancel_url' => $order ? url("checkout/cancel?order_id={$order->id}") : null,
            ]);

            if (! $response['success']) {
                return response()->json([
                    'message' => $response['error'] ?? 'Unable to generate QR code via KHPAY.',
                ], 422);
            }

            $data = $response['data'];
            $transactionId = $data['transaction_id'] ?? null;
            $qrString = $data['qr'] ?? null;
            $md5 = $data['md5'] ?? md5($qrString);
            $expiresAt = isset($data['expires_at']) ? now()->parse($data['expires_at']) : now()->addMinutes(10);
            
            if (! $transactionId || ! $qrString) {
                return response()->json([
                    'message' => 'KHPAY did not return transaction details.',
                ], 500);
            }
        } catch (\Throwable $exception) {
            Log::error('KHPAY QR generation failed', ['error' => $exception->getMessage()]);
            return response()->json([
                'message' => $exception->getMessage() ?: 'Unable to generate KHQR.',
            ], 422);
        }

        try {
            $transaction = KhqrTransaction::updateOrCreate(
                ['transaction_id' => $transactionId],
                [
                    'order_id' => $order?->id,
                    'md5' => $md5,
                    'full_hash' => null,
                    'amount' => $amount,
                    'currency' => $currency,
                    'qr_string' => $qrString,
                    'status' => 'PENDING',
                    'expires_at' => $expiresAt,
                    'provider_payload' => [
                        'source' => 'khpay_bakong',
                        'payment_url' => $data['payment_url'] ?? null,
                        'download_qr' => $data['download_qr'] ?? null,
                    ],
                ]
            );
        } catch (\Throwable $e) {
            Log::error('Failed to save KHQR transaction record.', [
                'error' => $e->getMessage(),
                'transaction_id' => $transactionId,
            ]);
            return response()->json([
                'message' => 'Unable to save payment record.',
            ], 500);
        }

        if ($order) {
            try {
                $payment = $order->payments()->latest()->first();
                if (! $payment) {
                    $payment = Payment::create([
                        'order_id' => $order->id,
                        'method' => 'aba',
                        'status' => 'processing',
                        'transaction_id' => $transactionId,
                        'provider' => 'khpay',
                        'amount' => $amount,
                    ]);
                } else {
                    $payment->method = 'aba';
                    $payment->status = in_array($payment->status, ['success', 'failed'], true)
                        ? $payment->status
                        : 'processing';
                    $payment->transaction_id = $transactionId;
                    $payment->provider = 'khpay';
                    $payment->amount = $amount;
                    $payment->save();
                }

                if ($order->payment_status !== 'paid') {
                    $order->payment_method = 'aba';
                    $order->payment_status = 'unpaid';
                    $order->save();
                }
            } catch (\Throwable $e) {
                Log::error('Failed to update order payment record for KHQR.', [
                    'error' => $e->getMessage(),
                    'order_id' => $order->id,
                ]);
            }
        }

        return response()->json([
            'transaction_id' => $transaction->transaction_id,
            'md5' => $transaction->md5,
            'qr_string' => $transaction->qr_string,
            'status' => $transaction->status,
            'expires_at' => $transaction->expires_at?->toISOString(),
        ]);
    }

    public function checkTransaction(Request $request)
    {
        $validated = $request->validate([
            'md5' => ['nullable', 'string', 'max:64'],
            'md' => ['nullable', 'string', 'max:64'],
        ]);

        $transactionId = (string) ($validated['md5'] ?? $validated['md'] ?? '');
        if ($transactionId === '') {
            return response()->json([
                'status' => 'INVALID_TRANSACTION',
                'message' => 'md5 is required.',
            ], 422);
        }

        $transaction = KhqrTransaction::where('transaction_id', $transactionId)
            ->orWhere('md5', $transactionId)
            ->first();

        if (! $transaction) {
            return response()->json([
                'status' => 'INVALID_TRANSACTION',
                'message' => 'Transaction id does not exist.',
            ], 404);
        }

        if (! $transaction->md5) {
            $transaction->md5 = $transaction->transaction_id;
        }

        $payment = Payment::where('transaction_id', $transaction->transaction_id)->latest()->first();
        $order = $transaction->order_id ? Order::find($transaction->order_id) : null;
        $orderPayment = $order ? $order->payments()->latest()->first() : null;

        $hasSuccessfulLocalPayment =
            ($payment && $payment->status === 'success') ||
            ($orderPayment && $orderPayment->status === 'success') ||
            ($order && $order->payment_status === 'paid');

        if ($hasSuccessfulLocalPayment && $transaction->status !== 'SUCCESS') {
            $transaction->status = 'SUCCESS';
            $transaction->paid_at = $payment?->paid_at ?? $orderPayment?->paid_at ?? now();
        }

        $verify = null;
        $verifyData = [];
        if (in_array($transaction->status, ['PENDING', 'UNAUTHORIZED', 'UNAVAILABLE'], true)) {
            try {
                $khpay = app(KhPayService::class);
                $verify = $khpay->checkTransaction($transaction->transaction_id);

                $payload = $transaction->provider_payload ?? [];
                if (! is_array($payload)) {
                    $payload = [];
                }
                $payload['khpay_check'] = $verify;
                $transaction->provider_payload = $payload;

                $verifyData = isset($verify['data']) && is_array($verify['data']) ? $verify['data'] : $verify;

                $isPaid = ($verifyData['paid'] ?? false) === true || strtolower($verifyData['status'] ?? '') === 'paid' || strtolower($verifyData['status'] ?? '') === 'success';

                if ($isPaid) {
                    $transaction->status = 'SUCCESS';
                    $transaction->paid_at = now();
                } elseif (isset($verifyData['status']) && in_array(strtolower($verifyData['status']), ['expired', 'timeout'], true)) {
                    $transaction->status = 'TIMEOUT';
                } elseif (isset($verifyData['status']) && in_array(strtolower($verifyData['status']), ['failed', 'canceled', 'rejected'], true)) {
                    $transaction->status = 'FAILED';
                }
            } catch (\Throwable $e) {
                Log::error('Failed to check transaction with KHPAY', [
                    'transaction_id' => $transaction->transaction_id,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        if (
            $transaction->expires_at &&
            $transaction->expires_at->isPast() &&
            in_array($transaction->status, ['PENDING'], true)
        ) {
            $transaction->status = 'TIMEOUT';
        }

        $transaction->checked_at = now();
        $transaction->save();

        $responseData = [
            'bakongHash' => $transaction->transaction_id,
            'fromAccountId' => $verifyData['fromAccountId'] ?? null,
            'toAccountId' => $verifyData['toAccountId'] ?? null,
            'currency' => $verifyData['currency'] ?? $transaction->currency,
            'amount' => $verifyData['amount'] ?? $transaction->amount,
            'paid_at' => $transaction->paid_at?->toISOString(),
        ];

        if ($transaction->status === 'SUCCESS') {
            try {
                $this->syncOrderPaymentSuccess($transaction);
            } catch (\Throwable $e) {
                Log::error('Failed to sync order payment after KHQR success.', [
                    'transaction_id' => $transaction->transaction_id,
                    'order_id'       => $transaction->order_id,
                    'error'          => $e->getMessage(),
                ]);
            }

            return response()->json([
                'status' => 'SUCCESS',
                'message' => 'Payment successful',
                'data' => $responseData,
            ]);
        }

        if ($transaction->status === 'FAILED') {
            return response()->json([
                'status' => 'FAILED',
                'message' => 'Payment failed',
            ]);
        }

        if ($transaction->status === 'TIMEOUT') {
            return response()->json([
                'status' => 'TIMEOUT',
                'message' => 'Payment failed: QR expired.',
            ]);
        }

        return response()->json([
            'status' => 'PENDING',
            'message' => 'Transaction is still pending.',
            'data' => $responseData,
        ]);
    }

    private function syncOrderPaymentSuccess(KhqrTransaction $transaction): void
    {
        if (! $transaction->order_id) {
            return;
        }

        $order = Order::find($transaction->order_id);
        if (! $order) {
            return;
        }

        app(OrderPaymentService::class)->markOrderPaid($order, 'aba', [
            'transaction_id' => $transaction->transaction_id,
            'provider' => 'khpay',
            'amount' => (float) $transaction->amount,
            'paid_at' => $transaction->paid_at ?? now(),
        ]);

        Log::info('KHQR payment confirmed via KHPAY.', [
            'transaction_id' => $transaction->transaction_id,
            'order_id' => $order->id,
            'payment_id' => $order->payments()->latest()->value('id'),
        ]);
    }
}
