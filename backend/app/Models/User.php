<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use App\Models\Order;
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
        'status',
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
            'is_admin' => 'boolean',
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

    protected function avatar(): Attribute
    {
        return Attribute::make(
            get: function ($value) {
                if (! $value) {
                    return null;
                }

                // External URL (e.g. Google profile picture) — return as-is
                if (str_starts_with($value, 'http://') || str_starts_with($value, 'https://')) {
                    $parsedPath = parse_url($value, PHP_URL_PATH);
                    if (! is_string($parsedPath) ||
                        (! str_contains($parsedPath, '/api/media/') &&
                         ! str_contains($parsedPath, '/storage/') &&
                         ! str_contains($parsedPath, '/public/storage/'))) {
                        return $value;
                    }

                    $value = $parsedPath;
                }

                // Strip any known storage prefix so we always get the bare key
                $path = ltrim(str_replace('\\', '/', $value), '/');
                if (str_starts_with($path, 'public/storage/')) {
                    $path = substr($path, strlen('public/storage/'));
                } elseif (str_starts_with($path, 'storage/')) {
                    $path = substr($path, strlen('storage/'));
                } elseif (str_starts_with($path, 'api/media/')) {
                    $path = substr($path, strlen('api/media/'));
                }

                $baseUrl = '';
                if (app()->bound('request')) {
                    try {
                        $baseUrl = request()->getSchemeAndHttpHost();
                    } catch (\Throwable) {
                        $baseUrl = '';
                    }
                }

                if ($baseUrl === '') {
                    $baseUrl = (string) config('app.url', '');
                }

                return rtrim($baseUrl, '/') . '/api/media/' . $path;
            }
        );
    }

    public function repairRequests()
    {
        return $this->hasMany(RepairRequest::class, 'customer_id');
    }

    public function orders()
    {
        return $this->hasMany(Order::class);
    }

    public function assignedOrders()
    {
        return $this->hasMany(Order::class, 'assigned_staff_id');
    }

    public function orderTrackingNotifications()
    {
        return $this->hasMany(OrderTrackingNotification::class);
    }

    public function mobileDeviceTokens()
    {
        return $this->hasMany(MobileDeviceToken::class);
    }

    public function repairNotifications()
    {
        return $this->hasMany(RepairNotification::class);
    }

    public function supportConversations()
    {
        return $this->hasMany(SupportConversation::class, 'customer_id');
    }

    public function assignedSupportConversations()
    {
        return $this->hasMany(SupportConversation::class, 'assigned_to');
    }

    public function isAdmin(): bool
    {
        $adminEmails = (array) config('auth.admin_emails', []);
        $role = $this->role ?? null;
        $isAdmin = (bool) ($this->is_admin ?? false);

        return in_array($this->email, $adminEmails, true) || $role === 'admin' || $isAdmin;
    }

    public function isStaff(): bool
    {
        return in_array($this->role, ['staff', 'technician'], true);
    }

    public function roles()
    {
        return $this->belongsToMany(Role::class, 'user_roles');
    }

    public function hasRole(string $roleName): bool
    {
        return $this->roles()->where('name', $roleName)->exists();
    }

    /**
     * Cached list of permission names granted through the user's roles.
     *
     * @var list<string>|null
     */
    protected ?array $cachedPermissionNames = null;

    /**
     * @return list<string>
     */
    public function permissionNames(): array
    {
        if ($this->cachedPermissionNames === null) {
            $this->cachedPermissionNames = Permission::query()
                ->whereHas('roles.users', fn ($query) => $query->where('users.id', $this->id))
                ->pluck('name')
                ->all();
        }

        return $this->cachedPermissionNames;
    }

    public function hasPermission(string $permissionName): bool
    {
        if ($this->isAdmin()) {
            return true;
        }

        return in_array($permissionName, $this->permissionNames(), true);
    }

    public function hasAnyPermission(string ...$permissionNames): bool
    {
        if ($this->isAdmin()) {
            return true;
        }

        return array_intersect($permissionNames, $this->permissionNames()) !== [];
    }

    /**
     * Web admin panel access: super admins always, otherwise any user that
     * has been assigned a role from User Management.
     */
    public function canAccessAdminPanel(): bool
    {
        return $this->isAdmin() || $this->roles()->exists();
    }
}
