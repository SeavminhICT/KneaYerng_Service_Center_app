<?php

namespace App\Support;

use App\Models\User;
use App\Models\Technician;

class AuthRedirect
{
    public static function destination(?User $user): string
    {
        if ($user && $user->canAccessAdminPanel()) {
            return route('admin.dashboard');
        }

        if ($user && $user->isTechnician() && Technician::where('user_id', $user->id)->exists()) {
            return route('technician.jobs');
        }

        return route('profile.edit');
    }
}
