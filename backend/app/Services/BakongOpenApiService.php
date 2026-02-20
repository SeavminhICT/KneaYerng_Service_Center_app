<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;

class BakongOpenApiService
{
    public function checkTransactionByMd5(string $md5): array
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
            $endpoint = str_ends_with($baseUrl, '/v1')
                ? $baseUrl.'/check_transaction_by_md5'
                : $baseUrl.'/v1/check_transaction_by_md5';

            $http = Http::timeout(max(3, $timeoutSeconds))
                ->acceptJson()
                ->withToken($token);

            if ($caBundle !== '') {
                $http = $http->withOptions(['verify' => $caBundle]);
            } elseif (! $verify) {
                $http = $http->withOptions(['verify' => false]);
            }

            $response = $http->post($endpoint, [
                'md5' => $md5,
            ]);
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

        $json = $response->json();
        if (! is_array($json)) {
            return [
                'available' => true,
                'status' => 'PENDING',
                'message' => 'Invalid Bakong response.',
                'raw' => [
                    'status_code' => $response->status(),
                    'body' => $response->body(),
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
}
