<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class BakongOpenApiService
{
    public function checkTransactionByMd5(string $md5): array
    {
        return $this->check('/check_transaction_by_md5', ['md5' => $md5]);
    }

    public function checkTransactionByHash(string $hash): array
    {
        return $this->check('/check_transaction_by_hash', ['hash' => $hash]);
    }

    private function check(string $path, array $payload): array
    {
        $baseUrl = rtrim((string) config('services.bakong_open.base_url', ''), '/');
        $token = (string) config('services.bakong_open.token', '');
        $timeoutSeconds = (int) config('services.bakong_open.timeout', 12);
        $verify = (bool) config('services.bakong_open.verify', true);
        $caBundle = (string) config('services.bakong_open.ca_bundle', '');

        if ($baseUrl === '' || $token === '') {
            return [
                'available' => false,
                'status' => 'UNAVAILABLE',
                'message' => 'Bakong Open API is not configured.',
                'raw' => null,
            ];
        }

        try {
            $response = $this->post(
                $baseUrl,
                $token,
                $timeoutSeconds,
                $verify,
                $caBundle,
                $path,
                $payload
            );
        } catch (\Throwable $exception) {
            return [
                'available' => true,
                'status' => 'PENDING',
                'message' => 'Unable to reach Bakong gateway.',
                'raw' => [
                    'exception' => $exception->getMessage(),
                ],
            ];
        }

        $statusCode = $response->status();

        if ($statusCode === 401 || $statusCode === 403) {
            Log::warning('Bakong API authentication failed.', [
                'path'        => $path,
                'status_code' => $statusCode,
                'body'        => substr($response->body(), 0, 500),
            ]);
            return [
                'available' => true,
                'status' => 'UNAUTHORIZED',
                'message' => 'Bakong API authentication failed (HTTP '.$statusCode.'). Check BAKONG_TOKEN.',
                'raw' => [
                    'status_code' => $statusCode,
                    'body' => substr($response->body(), 0, 500),
                ],
            ];
        }

        $json = $response->json();
        if (! is_array($json)) {
            Log::warning('Bakong returned non-JSON response.', [
                'path'        => $path,
                'status_code' => $statusCode,
                'body'        => substr($response->body(), 0, 500),
            ]);
            return [
                'available' => true,
                'status' => 'PENDING',
                'message' => 'Invalid Bakong response (HTTP '.$statusCode.').',
                'raw' => [
                    'status_code' => $statusCode,
                    'body' => substr($response->body(), 0, 500),
                ],
            ];
        }

        $responseCode = (int) ($json['responseCode'] ?? 1);
        $errorCode = $json['errorCode'] ?? null;
        $message = (string) ($json['responseMessage'] ?? $json['message'] ?? 'No message from Bakong.');
        $data = [];
        if (isset($json['data']) && is_array($json['data'])) {
            $data = $json['data'];
        }

        if ($responseCode === 0) {
            return [
                'available' => true,
                'status' => 'SUCCESS',
                'message' => $message,
                'data' => $data,
                'response_code' => $responseCode,
                'error_code' => $errorCode,
                'raw' => $json,
            ];
        }

        if ((int) $errorCode === 3) {
            return [
                'available' => true,
                'status' => 'FAILED',
                'message' => $message,
                'data' => $data,
                'response_code' => $responseCode,
                'error_code' => $errorCode,
                'raw' => $json,
            ];
        }

        if ((int) $errorCode === 1) {
            return [
                'available' => true,
                'status' => 'NOT_FOUND',
                'message' => $message,
                'data' => $data,
                'response_code' => $responseCode,
                'error_code' => $errorCode,
                'raw' => $json,
            ];
        }

        if ((int) $errorCode === 2) {
            return [
                'available' => true,
                'status' => 'UNAUTHORIZED',
                'message' => $message,
                'data' => $data,
                'response_code' => $responseCode,
                'error_code' => $errorCode,
                'raw' => $json,
            ];
        }

        return [
            'available' => true,
            'status' => 'PENDING',
            'message' => $message,
            'data' => $data,
            'response_code' => $responseCode,
            'error_code' => $errorCode,
            'raw' => $json,
        ];
    }

    private function post(
        string $baseUrl,
        string $token,
        int $timeoutSeconds,
        bool $verify,
        string $caBundle,
        string $path,
        array $payload
    ) {
        $endpoint = str_ends_with($baseUrl, '/v1')
            ? $baseUrl.$path
            : $baseUrl.'/v1'.$path;

        $http = Http::timeout(max(3, $timeoutSeconds))
            ->acceptJson()
            ->asJson()
            ->withToken($token);

        if ($caBundle !== '') {
            $http = $http->withOptions(['verify' => $caBundle]);
        } elseif (! $verify) {
            $http = $http->withOptions(['verify' => false]);
        }

        return $http->post($endpoint, $payload);
    }
}
