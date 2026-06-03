<?php

namespace App\Services;

use Kreait\Firebase\Auth;
use Kreait\Firebase\Factory;

class FirebaseAuthService
{
    private ?Auth $auth = null;
    private ?string $initError = null;

    public function __construct()
    {
        try {
            $projectId = (string) config('services.firebase.project_id', '');
            $credentials = (string) config('services.firebase.credentials', '');

            $factory = new Factory();
            if ($credentials !== '') {
                $credentialsPath = $this->resolveCredentialsPath($credentials);
                if (file_exists($credentialsPath) && is_readable($credentialsPath)) {
                    $factory = $factory->withServiceAccount($credentialsPath);
                } else {
                    throw new \RuntimeException("Firebase credentials file not found or not readable at: {$credentialsPath}");
                }
            }
            if ($projectId !== '') {
                $factory = $factory->withProjectId($projectId);
            }

            $this->auth = $factory->createAuth();
        } catch (\Throwable $e) {
            $this->initError = $e->getMessage();
            \Illuminate\Support\Facades\Log::warning("Firebase Auth Service initialization failed: " . $e->getMessage());
        }
    }

    public function verifyIdToken(string $idToken): array
    {
        if (!$this->auth) {
            throw new \RuntimeException("Firebase Auth is not properly configured. Initialization error: " . $this->initError);
        }
        $verifiedToken = $this->auth->verifyIdToken($idToken);
        $claims = $verifiedToken->claims();

        return [
            'uid' => $claims->get('sub'),
            'phone_number' => $claims->get('phone_number'),
            'email' => $claims->get('email'),
        ];
    }

    private function resolveCredentialsPath(string $credentials): string
    {
        $trimmed = trim($credentials);
        if ($trimmed === '') {
            return $trimmed;
        }

        $isAbsoluteUnix = str_starts_with($trimmed, DIRECTORY_SEPARATOR);
        $isAbsoluteWindows = (bool) preg_match('/^[A-Za-z]:\\\\/', $trimmed);

        if ($isAbsoluteUnix || $isAbsoluteWindows) {
            return $trimmed;
        }

        return base_path($trimmed);
    }
}
