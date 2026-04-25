<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SupportMessageResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'conversation_id' => $this->conversation_id,
            'sender_user_id' => $this->sender_user_id,
            'sender_type' => $this->sender_type,
            'message_type' => $this->message_type,
            'body' => $this->body,
            'media_url' => $this->media_url,
            'media_duration_sec' => $this->media_duration_sec,
            'delivery_status' => $this->delivery_status,
            'seen_at' => $this->seen_at?->toISOString(),
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
