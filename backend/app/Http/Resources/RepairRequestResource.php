<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RepairRequestResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'customer_id' => $this->customer_id,
            'technician_id' => $this->technician_id,
            'device_model' => $this->device_model,
            'issue_type' => $this->issue_type,
            'service_type' => $this->service_type,
            'appointment_datetime' => $this->appointment_datetime?->toISOString(),
            'status' => $this->status,
            'customer' => $this->whenLoaded('customer', function () {
                return [
                    'id' => $this->customer?->id,
                    'name' => $this->customer?->name,
                    'email' => $this->customer?->email,
                    'phone' => $this->customer?->phone,
                ];
            }),
            'technician' => new TechnicianResource($this->whenLoaded('technician')),
            'intake' => new IntakeResource($this->whenLoaded('intake')),
            'diagnostic' => new DiagnosticResource($this->whenLoaded('diagnostic')),
            'quotation' => new QuotationResource($this->whenLoaded('quotation')),
            'parts_usages' => PartsUsageResource::collection($this->whenLoaded('partsUsages')),
            'warranty' => new WarrantyResource($this->whenLoaded('warranty')),
            'invoice' => new InvoiceResource($this->whenLoaded('invoice')),
            'status_logs' => RepairStatusLogResource::collection($this->whenLoaded('statusLogs')),
            'chat_messages' => ChatMessageResource::collection($this->whenLoaded('chatMessages')),
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
