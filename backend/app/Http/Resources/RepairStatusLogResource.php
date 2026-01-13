<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RepairStatusLogResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'repair_id' => $this->repair_id,
            'status' => $this->status,
            'updated_by' => $this->updated_by,
            'logged_at' => $this->logged_at?->toISOString(),
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
