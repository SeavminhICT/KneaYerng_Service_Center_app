<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SupportConversation extends Model
{
    use HasFactory;

    protected $fillable = [
        'customer_id',
        'assigned_to',
        'status',
        'context_type',
        'context_id',
        'subject',
        'last_message_at',
        'customer_last_read_at',
        'support_last_read_at',
        'resolved_at',
    ];

    protected $casts = [
        'last_message_at' => 'datetime',
        'customer_last_read_at' => 'datetime',
        'support_last_read_at' => 'datetime',
        'resolved_at' => 'datetime',
    ];

    public function customer()
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    public function assignee()
    {
        return $this->belongsTo(User::class, 'assigned_to');
    }

    public function messages()
    {
        return $this->hasMany(SupportMessage::class, 'conversation_id')->orderBy('created_at');
    }

    public function latestMessage()
    {
        return $this->hasOne(SupportMessage::class, 'conversation_id')->latestOfMany();
    }

    public function unreadForCustomerCount(): int
    {
        $readAt = $this->customer_last_read_at;

        return $this->messages()
            ->where('sender_type', 'support')
            ->when($readAt, fn ($query) => $query->where('created_at', '>', $readAt))
            ->count();
    }

    public function unreadForSupportCount(): int
    {
        $readAt = $this->support_last_read_at;

        return $this->messages()
            ->where('sender_type', 'customer')
            ->when($readAt, fn ($query) => $query->where('created_at', '>', $readAt))
            ->count();
    }
}
