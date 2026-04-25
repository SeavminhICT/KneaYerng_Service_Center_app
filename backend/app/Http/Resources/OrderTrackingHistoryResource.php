<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderTrackingHistoryResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'from_status' => $this->from_status,
            'to_status' => $this->to_status,
            'changed_by_role' => $this->changed_by_role,
            'changed_by_user_id' => $this->changed_by_user_id,
            'changed_by_name' => $this->actor?->name,
            'assigned_staff_id' => $this->assigned_staff_id,
            'assigned_staff_name' => $this->assignedStaff?->name,
            'override_used' => (bool) $this->override_used,
            'note' => $this->note,
            'meta' => $this->meta,
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
