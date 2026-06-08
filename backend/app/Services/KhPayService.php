<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class KhPayService
{
    protected string $baseUrl;
    protected string $apiKey;
    protected string $webhookSecret;
    protected bool $verifySsl;
    protected bool $testMode;

    public function __construct()
    {
        $this->baseUrl = rtrim((string) config('services.khpay.base_url', 'https://khpay.site/api/v1'), '/');
        $this->apiKey = (string) config('services.khpay.api_key', '');
        $this->webhookSecret = (string) config('services.khpay.webhook_secret', '');
        $this->verifySsl = (bool) config('services.khpay.verify', true);
        $this->testMode = (bool) config('services.khpay.test_mode', true);
    }

    /**
     * Create base request object
     */
    protected function newRequest()
    {
        $http = Http::withToken($this->apiKey)->acceptJson();
        
        if ($this->testMode) {
            $http = $http->withHeaders([
                'X-Test-Mode' => 'true'
            ]);
        }
        
        if (! $this->verifySsl) {
            $http = $http->withoutVerifying();
        }
        
        return $http;
    }

    /**
     * Generate Bakong KHQR QR payment
     */
    public function generateBakongQr(float $amount, string $currency, string $note, array $options = []): array
    {
        $payload = [
            'amount' => $amount,
            'currency' => $currency,
            'note' => $note,
            'type' => $options['type'] ?? 'individual',
            'static' => $options['static'] ?? false,
            'success_url' => $options['success_url'] ?? null,
            'cancel_url' => $options['cancel_url'] ?? null,
            'callback_url' => $options['callback_url'] ?? null,
        ];

        return $this->post('/bakong/generate', $payload);
    }

    /**
     * Generate ABA PayWay QR payment
     */
    public function generateAbaQr(float $amount, string $currency, string $note, array $options = []): array
    {
        $payload = [
            'amount' => $amount,
            'currency' => $currency,
            'note' => $note,
            'success_url' => $options['success_url'] ?? null,
            'cancel_url' => $options['cancel_url'] ?? null,
            'callback_url' => $options['callback_url'] ?? null,
            'metadata' => $options['metadata'] ?? null,
        ];

        return $this->post('/qr/generate', $payload);
    }

    /**
     * Check transaction status.
     * - Bakong (bk_* or 32-char md5): POST /bakong/check  — the authoritative Bakong endpoint
     * - ABA (txn_*):                  GET  /qr/check/{id} — ABA only supports GET
     *
     * @param string $transactionId  KHPAY transaction_id (bk_xxx / txn_xxx)
     * @param string|null $md5       Raw md5 hash of the QR string (Bakong only)
     */
    public function checkTransaction(string $transactionId, ?string $md5 = null): array
    {
        $isBakong = str_starts_with($transactionId, 'bk_') || strlen($transactionId) === 32;

        // ── Bakong: POST /bakong/check is the correct endpoint ─────────────────
        if ($isBakong) {
            $body = $md5 ? ['md5' => $md5] : ['transaction_id' => $transactionId];

            $response = $this->newRequest()
                ->post("{$this->baseUrl}/bakong/check", $body);

            if ($response->successful()) {
                $json = $response->json();
                Log::debug('KHPAY Bakong check response', ['body' => $json]);
                return $json;
            }

            Log::warning('KHPAY POST /bakong/check failed, falling back to GET.', [
                'transaction_id' => $transactionId,
                'md5' => $md5,
                'status' => $response->status(),
                'body' => $response->body(),
            ]);
        }

        // ── ABA / fallback: GET /qr/check/{id} ──────────────────────────────────
        $response = $this->newRequest()
            ->get("{$this->baseUrl}/qr/check/{$transactionId}");

        if ($response->failed()) {
            Log::error('KHPAY GET /qr/check failed.', [
                'transaction_id' => $transactionId,
                'status' => $response->status(),
                'body' => $response->body(),
            ]);

            return [
                'success' => false,
                'paid' => false,
                'status' => 'error',
                'error' => 'Unable to check transaction with KHPAY gateway.',
            ];
        }

        $json = $response->json();
        Log::debug('KHPAY GET /qr/check response', ['body' => $json]);
        return $json;
    }

    /**
     * Expire a transaction
     */
    public function expireTransaction(string $transactionId): array
    {
        $response = $this->newRequest()
            ->post("{$this->baseUrl}/qr/expire/{$transactionId}");

        if ($response->failed()) {
            Log::warning('KHPAY expire transaction failed.', [
                'transaction_id' => $transactionId,
                'status' => $response->status(),
            ]);
            return [
                'success' => false,
                'message' => 'Unable to expire transaction.',
            ];
        }

        return $response->json();
    }

    /**
     * Verify KHPAY Webhook signature
     */
    public function verifyWebhookSignature(string $rawBody, string $signature): bool
    {
        if (empty($this->webhookSecret)) {
            Log::error('KHPAY webhook secret is not configured.');
            return false;
        }

        // Clean signature (remove 'sha256=' prefix if present in the header)
        if (str_starts_with($signature, 'sha256=')) {
            $signature = substr($signature, 7);
        }

        $expected = hash_hmac('sha256', $rawBody, $this->webhookSecret);
        return hash_equals($expected, $signature);
    }

    /**
     * Common POST request helper
     */
    protected function post(string $path, array $payload): array
    {
        if (empty($this->apiKey)) {
            return [
                'success' => false,
                'error' => 'KHPAY API key is not configured.',
                'code' => 'INVALID_API_KEY',
            ];
        }

        try {
            $response = $this->newRequest()
                ->asJson()
                ->post("{$this->baseUrl}{$path}", $payload);

            if ($response->failed()) {
                Log::error("KHPAY POST request to {$path} failed.", [
                    'status' => $response->status(),
                    'body' => $response->body(),
                ]);
                $json = $response->json();
                return $json ?: [
                    'success' => false,
                    'error' => 'API connection failure',
                    'code' => 'GATEWAY_ERROR',
                ];
            }

            return $response->json() ?: [
                'success' => false,
                'error' => 'Empty response from gateway',
            ];
        } catch (\Throwable $e) {
            Log::error("Exception calling KHPAY POST {$path}", [
                'exception' => $e->getMessage(),
            ]);
            return [
                'success' => false,
                'error' => 'KHPAY gateway connection error.',
                'code' => 'CONNECTION_ERROR',
            ];
        }
    }
}
