<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\RepairNotificationResource;
use App\Models\RepairNotification;
use Illuminate\Http\Request;

class RepairNotificationController extends Controller
{
    public function index(Request $request)
    {
        $actor = $request->user() ?? $request->user('sanctum');
        if (! $actor) {
            return response()->json(['message' => 'Unauthorized.'], 401);
        }

        $query = RepairNotification::query()->orderByDesc('created_at');

        if ($actor->isAdmin()) {
            $query->where(function ($builder) use ($actor) {
                $builder->whereNull('user_id')
                    ->orWhere('user_id', $actor->id);
            });
        } else {
            $query->where('user_id', $actor->id);
        }

        $perPage = (int) $request->input('per_page', 10);
        $perPage = max(1, min(50, $perPage));

        return RepairNotificationResource::collection($query->paginate($perPage)->withQueryString());
    }
}
