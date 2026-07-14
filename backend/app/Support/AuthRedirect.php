<?php

namespace App\Support;

use App\Models\User;

class AuthRedirect
{
    public static function destination(?User $user): string
    {
        if ($user && $user->canAccessAdminPanel()) {
            return route('admin.dashboard');
        }

        return route('profile.edit');
    }
}
