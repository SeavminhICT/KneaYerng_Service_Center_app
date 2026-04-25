<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\KhqrTransaction;
use App\Models\Order;
use App\Models\Payment;
use App\Services\BakongOpenApiService;
use App\Services\KhqrGenerator;
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
        $bakongAccountId = (string) config('services.bakong.account_id', '');
        if ($bakongAccountId === '') {
            return response()->json([
                'message' => 'Bakong account id is not configured.',
            ], 503);
        }
        $merchantId = (string) config('services.bakong.merchant_id', 'DEMO_MERCHANT');
        $merchantName = (string) config('services.bakong.merchant_name', 'KneaYerng Service Center');
        $merchantCity = (string) config('services.bakong.merchant_city', 'Phnom Penh');
        $merchantCategory = (string) config('services.bakong.merchant_category', '5999');
        $countryCode = (string) config('services.bakong.country_code', 'KH');
        $expiresMinutes = (int) config('services.bakong.qr_expires_minutes', 10);
        $expiresMinutes = max(1, min(10, $expiresMinutes));
        $expiresAt = now()->addMinutes($expiresMinutes);

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
            $generator = app(KhqrGenerator::class);
            $generated = $generator->generate([
                'bakong_account_id' => $bakongAccountId,
                'merchant_name' => $merchantName,
                'merchant_city' => $merchantCity,
                'merchant_category_code' => $merchantCategory,
                'country_code' => $countryCode,
                'merchant_id' => $merchantId,
                'currency' => $currency,
                'amount' => $amount,
                'bill_number' => $billNumber,
                'expiration_timestamp' => $expiresAt->getTimestamp() * 1000,
            ]);
        } catch (\Throwable $exception) {
            return response()->json([
                'message' => $exception->getMessage() ?: 'Unable to generate KHQR.',
            ], 422);
        }

        $transactionId = $generated['md5'] ?? null;
        $qrString = $generated['qr'] ?? null;
        if (! $transactionId || ! $qrString) {
            return response()->json([
                'message' => 'Unable to generate KHQR.',
            ], 500);
        }

        $transaction = KhqrTransaction::updateOrCreate(
            ['transaction_id' => $transactionId],
            [
                'order_id' => $order?->id,
                'md5' => $transactionId,
                'full_hash' => null,
                'amount' => $amount,
                'currency' => $currency,
                'qr_string' => $qrString,
                'status' => 'PENDING',
                'expires_at' => $expiresAt,
                'provider_payload' => [
                    'source' => 'bakong_dynamic_khqr',
                    'bill_number' => $billNumber,
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

        $verify = null;
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

        if ($transaction->status === 'PENDING') {
            $bakong = app(BakongOpenApiService::class);
            if ($transaction->full_hash) {
                $verify = $bakong->checkTransactionByHash($transaction->full_hash);
            } else {
                $verify = $bakong->checkTransactionByMd5($transaction->md5 ?? $transaction->transaction_id);
            }

            $payload = $transaction->provider_payload ?? [];
            if (! is_array($payload)) {
                $payload = [];
            }
            $payload['bakong_check'] = $verify;
            $transaction->provider_payload = $payload;

            if (($verify['status'] ?? 'PENDING') === 'SUCCESS') {
                $validation = $this->validateBakongData($transaction, $verify['data'] ?? null);
                $payload['validation'] = $validation;
                $transaction->provider_payload = $payload;

                if (! empty($verify['data']['hash'])) {
                    $transaction->full_hash = (string) $verify['data']['hash'];
                }

                if ($validation['ok']) {
                    $transaction->status = 'SUCCESS';
                    $transaction->paid_at = now();
                } else {
                    $transaction->status = 'FAILED';
                }
            } elseif (($verify['status'] ?? 'PENDING') === 'FAILED') {
                $transaction->status = 'FAILED';
            } elseif (($verify['status'] ?? 'PENDING') === 'NOT_FOUND') {
                $transaction->status = 'PENDING';
            } elseif (($verify['status'] ?? 'PENDING') === 'UNAUTHORIZED') {
                $transaction->status = 'PENDING';
            }
        }

        if (
            $transaction->expires_at &&
            $transaction->expires_at->isPast() &&
            in_array($transaction->status, ['PENDING', 'NOT_FOUND'], true)
        ) {
            $transaction->status = 'TIMEOUT';
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

        if ($transaction->status === 'TIMEOUT') {
            $response = [
                'status' => 'TIMEOUT',
                'message' => 'Payment failed: QR expired.',
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

        app(OrderPaymentService::class)->markOrderPaid($order, 'aba', [
            'transaction_id' => $transaction->transaction_id,
            'provider' => 'bakong',
            'amount' => (float) $transaction->amount,
            'paid_at' => $transaction->paid_at ?? now(),
        ]);

        Log::info('KHQR payment confirmed.', [
            'transaction_id' => $transaction->transaction_id,
            'order_id' => $order->id,
            'payment_id' => $order->payments()->latest()->value('id'),
        ]);
    }

    private function validateBakongData(KhqrTransaction $transaction, mixed $data): array
    {
        if (! is_array($data)) {
            return [
                'ok' => false,
                'message' => 'Bakong response missing transaction data.',
            ];
        }

        $expectedCurrency = $this->normalizeCurrency((string) $transaction->currency);
        $expectedAmount = (float) $transaction->amount;

        $receivedCurrency = $this->normalizeCurrency((string) ($data['currency'] ?? ''));
        $receivedAmount = $data['amount'] ?? null;
        if (is_string($receivedAmount) || is_int($receivedAmount) || is_float($receivedAmount)) {
            $receivedAmount = (float) $receivedAmount;
        } else {
            $receivedAmount = null;
        }

        if ($receivedCurrency === '' || $receivedAmount === null) {
            return [
                'ok' => false,
                'message' => 'Bakong response missing amount or currency.',
                'expected' => [
                    'amount' => $expectedAmount,
                    'currency' => $expectedCurrency,
                ],
                'received' => [
                    'amount' => $receivedAmount,
                    'currency' => $receivedCurrency,
                ],
            ];
        }

        $amountTolerance = $expectedCurrency === 'KHR' ? 0.5 : 0.01;
        $amountMatches = abs($expectedAmount - $receivedAmount) <= $amountTolerance;
        $currencyMatches = $expectedCurrency === $receivedCurrency;

        if (! $amountMatches || ! $currencyMatches) {
            return [
                'ok' => false,
                'message' => 'Payment amount or currency mismatch.',
                'expected' => [
                    'amount' => $expectedAmount,
                    'currency' => $expectedCurrency,
                ],
                'received' => [
                    'amount' => $receivedAmount,
                    'currency' => $receivedCurrency,
                ],
            ];
        }

        return [
            'ok' => true,
            'message' => 'Payment validated.',
        ];
    }

    private function normalizeCurrency(string $currency): string
    {
        $currency = strtoupper(trim($currency));
        if ($currency === '840') {
            return 'USD';
        }
        if ($currency === '116') {
            return 'KHR';
        }
        if ($currency === 'USD' || $currency === 'KHR') {
            return $currency;
        }
        if (ctype_digit($currency)) {
            return $currency;
        }
        return $currency;
    }

}
