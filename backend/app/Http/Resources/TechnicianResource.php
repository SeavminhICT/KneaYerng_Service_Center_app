<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TechnicianResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'skill_set' => $this->skill_set ?? [],
            'active_jobs_count' => $this->active_repairs_count ?? $this->active_jobs_count,
            'availability_status' => $this->availability_status,
            'email' => $this->user?->email,
            'phone' => $this->user?->phone,
            'has_login' => (bool) $this->user_id,
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
