<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RepairPaymentResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'invoice_id' => $this->invoice_id,
            'type' => $this->type,
            'method' => $this->method,
            'amount' => $this->amount,
            'status' => $this->status,
            'transaction_ref' => $this->transaction_ref,
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
