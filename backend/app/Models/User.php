<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory, Notifiable, HasApiTokens;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'first_name',
        'last_name',
        'email',
        'phone',
        'password',
        'avatar',
        'role',
        'is_admin',
        'otp_code',
        'otp_expires_at',
        'otp_verified_at',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
        'otp_code',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'otp_expires_at' => 'datetime',
            'otp_verified_at' => 'datetime',
        ];
    }

    protected function name(): Attribute
    {
        return Attribute::make(
            get: fn ($value, $attributes) => trim(
                ($attributes['first_name'] ?? '').' '.($attributes['last_name'] ?? '')
            ),
            set: function ($value) {
                $value = trim((string) $value);

                if ($value === '') {
                    return [
                        'first_name' => '',
                        'last_name' => '',
                    ];
                }

                $parts = preg_split('/\s+/', $value, 2);

                return [
                    'first_name' => $parts[0],
                    'last_name' => $parts[1] ?? '',
                ];
            }
        );
    }

    public function repairRequests()
    {
        return $this->hasMany(RepairRequest::class, 'customer_id');
    }

    public function repairNotifications()
    {
        return $this->hasMany(RepairNotification::class);
    }

    public function isAdmin(): bool
    {
        $adminEmails = (array) config('auth.admin_emails', []);
        $role = $this->role ?? null;
        $isAdmin = (bool) ($this->is_admin ?? false);

        return in_array($this->email, $adminEmails, true) || $role === 'admin' || $isAdmin;
    }
}
