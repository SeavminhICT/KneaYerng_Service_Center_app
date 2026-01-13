<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Concerns\AuthorizesRepairRequests;
use App\Http\Controllers\Controller;
use App\Http\Resources\ChatMessageResource;
use App\Models\ChatMessage;
use App\Models\RepairRequest;
use App\Services\RepairNotificationService;
use Illuminate\Http\Request;

class RepairChatController extends Controller
{
    use AuthorizesRepairRequests;

    public function index(Request $request, RepairRequest $repair)
    {
        if ($response = $this->ensureRepairAccess($request, $repair)) {
            return $response;
        }

        $messages = $repair->chatMessages()->orderBy('created_at')->get();

        return ChatMessageResource::collection($messages);
    }

    public function store(Request $request, RepairRequest $repair)
    {
        if ($response = $this->ensureRepairAccess($request, $repair)) {
            return $response;
        }

        $validated = $request->validate([
            'message' => ['required', 'string'],
        ]);

        $actor = $request->user() ?? $request->user('sanctum');
        $senderType = $actor && $actor->isAdmin() ? 'admin' : 'customer';

        $message = ChatMessage::create([
            'repair_id' => $repair->id,
            'sender_type' => $senderType,
            'message' => $validated['message'],
        ]);

        if ($senderType === 'admin') {
            RepairNotificationService::notify(
                $repair->customer_id,
                $repair->id,
                'New message from admin',
                $validated['message'],
                'chat'
            );
        } else {
            RepairNotificationService::notifyAdmin(
                $repair->id,
                'New customer message',
                $validated['message'],
                'chat'
            );
        }

        return new ChatMessageResource($message);
    }
}
