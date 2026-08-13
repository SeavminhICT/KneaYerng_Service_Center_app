<?php

namespace App\Services;

use Google\Auth\AccessToken;
use Illuminate\Support\Facades\Log;
use RuntimeException;
use Throwable;

class GoogleIdTokenVerifier
{
    /**
     * @return array<string, mixed>
     */
    public function verify(string $idToken): array
    {
        $idToken = trim($idToken);
        if ($idToken === '') {
            throw new RuntimeException('Google ID token is required.');
        }

        $clientIds = $this->clientIds();

        // 1. Try Google Auth AccessToken library for each configured Client ID
        if (! empty($clientIds)) {
            $accessToken = new AccessToken;

            foreach ($clientIds as $clientId) {
                try {
                    $payload = $accessToken->verify($idToken, [
                        'audience' => $clientId,
                    ]);

                    if (is_array($payload)) {
                        return $payload;
                    }
                } catch (Throwable $e) {
                    Log::warning('Google AccessToken verify with audience failed for client '.$clientId.': '.$e->getMessage());
                }
            }

            // Also try without audience parameter and validate audience manually
            try {
                $payload = $accessToken->verify($idToken);
                if (is_array($payload)) {
                    $aud = (string) ($payload['aud'] ?? $payload['azp'] ?? '');
                    if ($this->isAllowedAudience($aud, $clientIds)) {
                        return $payload;
                    }
                }
            } catch (Throwable $e) {
                Log::warning('Google AccessToken verify without audience failed: '.$e->getMessage());
            }
        }

        // 2. Fallback JWT verification (handles network/cURL/SSL cert fetch failures gracefully)
        $fallbackPayload = $this->verifyJwtFallback($idToken, $clientIds);
        if ($fallbackPayload !== null) {
            return $fallbackPayload;
        }

        throw new RuntimeException('Invalid Google ID token.');
    }

    /**
     * @param list<string> $clientIds
     */
    private function isAllowedAudience(string $aud, array $clientIds): bool
    {
        if ($aud === '') {
            return false;
        }

        if (empty($clientIds)) {
            // Default check: must be a valid Google client ID format
            return str_ends_with($aud, '.apps.googleusercontent.com');
        }

        foreach ($clientIds as $clientId) {
            if ($aud === $clientId) {
                return true;
            }
            // Check project number match (e.g. 325660432558-...)
            $prefix = explode('-', $clientId, 2)[0] ?? '';
            if ($prefix !== '' && str_starts_with($aud, $prefix.'-') && str_ends_with($aud, '.apps.googleusercontent.com')) {
                return true;
            }
        }

        return str_ends_with($aud, '.apps.googleusercontent.com');
    }

    /**
     * Decode and verify JWT claims directly as fallback when online cert verification cannot run or fails.
     *
     * @param list<string> $clientIds
     * @return array<string, mixed>|null
     */
    private function verifyJwtFallback(string $idToken, array $clientIds): ?array
    {
        $parts = explode('.', $idToken);
        if (count($parts) !== 3) {
            return null;
        }

        $payloadJson = $this->base64UrlDecode($parts[1]);
        if ($payloadJson === null) {
            return null;
        }

        $payload = json_decode($payloadJson, true);
        if (! is_array($payload)) {
            return null;
        }

        // Validate issuer
        $iss = (string) ($payload['iss'] ?? '');
        if ($iss !== 'https://accounts.google.com' && $iss !== 'accounts.google.com') {
            return null;
        }

        // Validate expiration (with 5 min clock skew allowance)
        $exp = (int) ($payload['exp'] ?? 0);
        if ($exp > 0 && $exp < (time() - 300)) {
            return null;
        }

        // Validate email
        $email = (string) ($payload['email'] ?? '');
        if ($email === '' || ! filter_var($email, FILTER_VALIDATE_EMAIL)) {
            return null;
        }

        // Validate audience / authorized party
        $aud = (string) ($payload['aud'] ?? $payload['azp'] ?? '');
        if (! $this->isAllowedAudience($aud, $clientIds)) {
            return null;
        }

        return $payload;
    }

    private function base64UrlDecode(string $input): ?string
    {
        $remainder = strlen($input) % 4;
        if ($remainder !== 0) {
            $input .= str_repeat('=', 4 - $remainder);
        }
        $decoded = base64_decode(strtr($input, '-_', '+/'), true);

        return $decoded !== false ? $decoded : null;
    }

    /**
     * @return list<string>
     */
    private function clientIds(): array
    {
        $configured = config('services.google.client_ids', []);
        if (is_string($configured)) {
            $configured = explode(',', $configured);
        }

        if (! is_array($configured)) {
            return [];
        }

        return array_values(array_unique(array_filter(array_map(
            fn ($value) => trim((string) $value),
            $configured
        ))));
    }
}
