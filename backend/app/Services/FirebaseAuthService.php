<?php

namespace App\Services;

use Kreait\Firebase\Auth;
use Kreait\Firebase\Factory;

class FirebaseAuthService
{
    private Auth $auth;

    public function __construct()
    {
        $projectId = (string) config('services.firebase.project_id', '');
        $credentials = (string) config('services.firebase.credentials', '');

        $factory = new Factory();
        if ($credentials !== '') {
            $factory = $factory->withServiceAccount($this->resolveCredentialsPath($credentials));
        }
        if ($projectId !== '') {
            $factory = $factory->withProjectId($projectId);
        }

        $this->auth = $factory->createAuth();
    }

    public function verifyIdToken(string $idToken): array
    {
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
