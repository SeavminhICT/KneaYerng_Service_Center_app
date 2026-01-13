<?php

namespace App\Http\Controllers\Api\Concerns;

use App\Models\RepairRequest;
use Illuminate\Http\Request;

trait AuthorizesRepairRequests
{
    protected function ensureRepairAccess(Request $request, RepairRequest $repair): ?\Illuminate\Http\JsonResponse
    {
        $actor = $request->user() ?? $request->user('sanctum');

        if ($actor && method_exists($actor, 'isAdmin') && $actor->isAdmin()) {
            return null;
        }

        if (! $actor || (int) $repair->customer_id !== (int) $actor->id) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        return null;
    }
}
