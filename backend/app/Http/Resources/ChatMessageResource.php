<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ChatMessageResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'repair_id' => $this->repair_id,
            'sender_type' => $this->sender_type,
            'message' => $this->message,
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
