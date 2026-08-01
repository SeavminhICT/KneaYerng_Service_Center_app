<?php

namespace App\Models;

use App\Contracts\PushableNotification;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RepairNotification extends Model implements PushableNotification
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'repair_id',
        'type',
        'title',
        'body',
        'payload',
        'read_at',
    ];

    protected $casts = [
        'payload' => 'array',
        'read_at' => 'datetime',
    ];

    public function repair()
    {
        return $this->belongsTo(RepairRequest::class, 'repair_id');
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function getPushTitle(): string
    {
        return $this->title;
    }

    public function getPushBody(): string
    {
        return $this->body ?? 'Your repair status was updated.';
    }

    public function getPushType(): ?string
    {
        return $this->type;
    }

    public function getPushPayload(): array
    {
        $payload = is_array($this->payload) ? $this->payload : [];

        return [
            'repair_id' => $this->repair_id,
            'from_status' => $payload['from_status'] ?? null,
            'to_status' => $payload['to_status'] ?? null,
            'deep_link' => $payload['deep_link'] ?? ($this->repair_id ? '/repairs/'.$this->repair_id : null),
        ];
    }

    public function getPushAndroidChannelId(): string
    {
        return 'repair_tracking_updates_v1';
    }

    public function getPushBadgeCount(User $user): int
    {
        return max(1, self::query()->where('user_id', $user->id)->whereNull('read_at')->count());
    }
}
