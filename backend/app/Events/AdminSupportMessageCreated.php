<?php

namespace App\Events;

use App\Models\SupportConversation;
use App\Models\SupportMessage;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class AdminSupportMessageCreated implements ShouldBroadcastNow
{
    use Dispatchable, SerializesModels;

    public array $conversation;
    public array $message;

    public function __construct(SupportConversation $conversation, SupportMessage $message)
    {
        $customerName = $conversation->customer?->name ?: 'Customer';
        $messagePreview = $this->messagePreview($message);

        $this->conversation = [
            'id' => $conversation->id,
            'status' => $conversation->status,
            'customer' => [
                'id' => $conversation->customer?->id,
                'name' => $customerName,
                'email' => $conversation->customer?->email,
            ],
            'subject' => $conversation->subject,
            'last_message_at' => $conversation->last_message_at?->toISOString(),
        ];

        $this->message = [
            'id' => $message->id,
            'conversation_id' => $message->conversation_id,
            'sender_type' => $message->sender_type,
            'message_type' => $message->message_type,
            'body' => $message->body,
            'media_url' => $message->media_url,
            'created_at' => $message->created_at?->toISOString(),
            'preview' => $messagePreview,
            'message' => "New support message from {$customerName}: {$messagePreview}",
        ];
    }

    public function broadcastOn(): array
    {
        return [new PrivateChannel('admin.notifications')];
    }

    public function broadcastAs(): string
    {
        return 'admin.support.message.created';
    }

    private function messagePreview(SupportMessage $message): string
    {
        if ($message->message_type === 'voice') {
            return 'Sent a voice message';
        }

        $body = trim((string) $message->body);
        if ($body === '') {
            return 'Sent a message';
        }

        if (mb_strlen($body) > 90) {
            return mb_substr($body, 0, 87).'...';
        }

        return $body;
    }
}
