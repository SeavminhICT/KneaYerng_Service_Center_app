<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class QuotationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'repair_id' => $this->repair_id,
            'parts_cost' => $this->parts_cost,
            'labor_cost' => $this->labor_cost,
            'total_cost' => $this->total_cost,
            'status' => $this->status,
            'customer_approved_at' => $this->customer_approved_at?->toISOString(),
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
