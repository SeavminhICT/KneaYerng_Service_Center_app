<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PartsUsageResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'repair_id' => $this->repair_id,
            'part_id' => $this->part_id,
            'part_name' => $this->whenLoaded('part', fn () => $this->part?->name),
            'quantity' => $this->quantity,
            'cost' => (float) $this->cost,
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
