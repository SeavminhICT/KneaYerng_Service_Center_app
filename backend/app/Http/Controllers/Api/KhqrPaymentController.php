<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\KhqrTransaction;
use App\Models\Order;
use App\Models\Payment;
use App\Services\BakongOpenApiService;
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
            'transaction_id' => ['nullable', 'string', 'max:64'],
            'qr_string' => ['nullable', 'string'],
        ]);

        $currency = strtoupper((string) $validated['currency']);
        if ($currency !== 'USD') {
            return response()->json([
                'message' => 'Unsupported currency. KHQR supports USD only.',
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
        $merchantId = (string) config('services.bakong.merchant_id', 'DEMO_MERCHANT');
        $merchantName = (string) config('services.bakong.merchant_name', 'KneaYerng Service Center');

        $referenceSeed = implode('|', [
            $merchantId,
            number_format($amount, 2, '.', ''),
            $currency,
            now()->format('YmdHisv'),
            $order?->id ?? 0,
        ]);

        $transactionId = $validated['transaction_id'] ?? md5($referenceSeed);

        $qrString = $validated['qr_string'] ?? $this->buildKhqrLikeString(
                merchantId: $merchantId,
                merchantName: $merchantName,
                amount: $amount,
                currency: $currency,
                transactionId: $transactionId
            );

        $transaction = KhqrTransaction::updateOrCreate(
            ['transaction_id' => $transactionId],
            [
                'order_id' => $order?->id,
                'amount' => $amount,
                'currency' => $currency,
                'qr_string' => $qrString,
                'status' => 'PENDING',
                'expires_at' => now()->addMinutes(15),
                'provider_payload' => [
                    'source' => 'bakong_dynamic_khqr',
                ],
            ]
        );

        if ($order) {
            $payment = $order->payments()->latest()->first();
            if (! $payment) {
                $payment = Payment::create([
                    'order_id' => $order->id,
                    'method' => 'aba',
                    'status' => 'processing',
                    'transaction_id' => $transactionId,
                    'provider' => 'bakong',
                    'amount' => $amount,
                ]);
            } else {
                $payment->method = 'aba';
                $payment->status = in_array($payment->status, ['success', 'failed'], true)
                    ? $payment->status
                    : 'processing';
                $payment->transaction_id = $transactionId;
                $payment->provider = 'bakong';
                $payment->amount = $amount;
                $payment->save();
            }

            if ($order->payment_status !== 'paid') {
                $order->payment_method = 'aba';
                $order->payment_status = 'unpaid';
                $order->save();
            }
        }

        return response()->json([
            'transaction_id' => $transaction->transaction_id,
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

        $verify = null;
        $transactionId = (string) ($validated['md5'] ?? $validated['md'] ?? '');
        if ($transactionId === '') {
            return response()->json([
                'status' => 'INVALID_TRANSACTION',
                'message' => 'md5 is required.',
            ], 422);
        }

        $transaction = KhqrTransaction::where('transaction_id', $transactionId)->first();

        if (! $transaction) {
            return response()->json([
                'status' => 'INVALID_TRANSACTION',
                'message' => 'Transaction id does not exist.',
            ], 404);
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

        if ($transaction->status === 'PENDING') {
            $bakong = app(BakongOpenApiService::class);
            $verify = $bakong->checkTransactionByMd5($transaction->transaction_id);

            $payload = $transaction->provider_payload ?? [];
            if (! is_array($payload)) {
                $payload = [];
            }
            $payload['bakong_check'] = $verify;
            $transaction->provider_payload = $payload;

            if (($verify['status'] ?? 'PENDING') === 'SUCCESS') {
                $transaction->status = 'SUCCESS';
                $transaction->paid_at = now();
            } elseif (($verify['status'] ?? 'PENDING') === 'FAILED') {
                $transaction->status = 'FAILED';
            } elseif (($verify['status'] ?? 'PENDING') === 'NOT_FOUND') {
                $transaction->status = 'NOT_FOUND';
            } elseif (($verify['status'] ?? 'PENDING') === 'UNAUTHORIZED') {
                $transaction->status = 'PENDING';
            }
        }

        if (
            $transaction->expires_at &&
            $transaction->expires_at->isPast() &&
            $transaction->status === 'PENDING'
        ) {
            $transaction->status = 'NOT_FOUND';
        }

        $transaction->checked_at = now();
        $transaction->save();

        $responseData = null;
        if (! empty($verify['data']) && is_array($verify['data'])) {
            $responseData = [
                'bakongHash' => $verify['data']['hash'] ?? null,
                'fromAccountId' => $verify['data']['fromAccountId'] ?? null,
                'toAccountId' => $verify['data']['toAccountId'] ?? null,
                'currency' => $verify['data']['currency'] ?? null,
                'amount' => $verify['data']['amount'] ?? null,
                'paid_at' => $transaction->paid_at?->toISOString(),
            ];
        }

        if ($transaction->status === 'SUCCESS') {
            $this->syncOrderPaymentSuccess($transaction);

            $response = [
                'status' => 'SUCCESS',
                'message' => 'Payment successful',
            ];
            if ($responseData) {
                $response['data'] = $responseData;
            }
            if (config('app.debug') && isset($verify)) {
                $response['debug'] = ['bakong' => $verify];
            }
            return response()->json($response);
        }

        if ($transaction->status === 'FAILED') {
            $response = [
                'status' => 'FAILED',
                'message' => 'Payment failed',
            ];
            if (config('app.debug') && isset($verify)) {
                $response['debug'] = ['bakong' => $verify];
            }
            return response()->json($response);
        }

        if ($transaction->status === 'NOT_FOUND') {
            $response = [
                'status' => 'NOT_FOUND',
                'message' => 'Transaction not found in Bakong. Please check and try again.',
            ];
            if (config('app.debug') && isset($verify)) {
                $response['debug'] = ['bakong' => $verify];
            }
            return response()->json($response);
        }

        $message = $verify['message'] ?? 'Transaction is still pending.';
        $response = [
            'status' => 'PENDING',
            'message' => $message,
        ];
        if ($responseData) {
            $response['data'] = $responseData;
        }
        if (config('app.debug') && isset($verify)) {
            $response['debug'] = ['bakong' => $verify];
        }
        return response()->json($response);
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

        $payment = $order->payments()->latest()->first();
        if (! $payment) {
            $payment = Payment::create([
                'order_id' => $order->id,
                'method' => 'aba',
                'status' => 'success',
                'transaction_id' => $transaction->transaction_id,
                'provider' => 'bakong',
                'amount' => $transaction->amount,
                'paid_at' => now(),
            ]);
        } else {
            $payment->method = 'aba';
            $payment->status = 'success';
            $payment->transaction_id = $transaction->transaction_id;
            $payment->provider = 'bakong';
            $payment->amount = $transaction->amount;
            $payment->paid_at = now();
            $payment->save();
        }

        if ($order->payment_status !== 'paid') {
            $order->payment_method = 'aba';
            $order->payment_status = 'paid';
            $order->save();
        }

        Log::info('KHQR payment confirmed.', [
            'transaction_id' => $transaction->transaction_id,
            'order_id' => $order->id,
            'payment_id' => $payment->id,
        ]);
    }

    private function buildKhqrLikeString(
        string $merchantId,
        string $merchantName,
        float $amount,
        string $currency,
        string $transactionId
    ): string {
        // Keep payload compact to avoid QR capacity overflow on client renderers.
        $payload = implode('|', [
            'KHQR',
            'MID:'.substr(preg_replace('/\s+/', '', strtoupper($merchantId)), 0, 18),
            'MN:'.substr(preg_replace('/\s+/', '', strtoupper($merchantName)), 0, 24),
            'AMT:'.number_format($amount, 2, '.', ''),
            'CCY:'.$currency,
            'REF:'.substr($transactionId, 0, 32),
        ]);

        return $payload;
    }
}
