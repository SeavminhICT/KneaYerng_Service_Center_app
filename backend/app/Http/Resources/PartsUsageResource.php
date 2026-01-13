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
            'quantity' => $this->quantity,
            'cost' => $this->cost,
            'part' => new PartResource($this->whenLoaded('part')),
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
