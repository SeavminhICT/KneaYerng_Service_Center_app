<?php

namespace App\Models;

use App\Contracts\PushableNotification;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderTrackingNotification extends Model implements PushableNotification
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'guest_device_id',
        'campaign_id',
        'order_id',
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

    public function order()
    {
        return $this->belongsTo(Order::class);
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
        return $this->body ?? 'Your order tracking status was updated.';
    }

    public function getPushType(): ?string
    {
        return $this->type;
    }

    public function getPushPayload(): array
    {
        $payload = is_array($this->payload) ? $this->payload : [];

        return [
            'order_id' => $this->order_id,
            'order_number' => $payload['order_number'] ?? null,
            'from_status' => $payload['from_status'] ?? null,
            'to_status' => $payload['to_status'] ?? null,
            'deep_link' => $payload['deep_link'] ?? ($this->order_id ? '/orders/'.$this->order_id : null),
            'image_url' => $payload['image_url'] ?? null,
        ];
    }

    public function getPushAndroidChannelId(): string
    {
        return 'order_tracking_updates_v2';
    }

    public function getPushBadgeCount(User $user): int
    {
        return max(1, self::query()->where('user_id', $user->id)->whereNull('read_at')->count());
    }
}
