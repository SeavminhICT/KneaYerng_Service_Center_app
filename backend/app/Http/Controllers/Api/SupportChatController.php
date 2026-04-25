<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\SupportConversationResource;
use App\Http\Resources\SupportMessageResource;
use App\Models\SupportConversation;
use App\Models\SupportMessage;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class SupportChatController extends Controller
{
    public function showOrCreateConversation(Request $request)
    {
        $user = $request->user() ?? $request->user('sanctum');

        abort_unless($user, 401);

        $validated = $request->validate([
            'context_type' => ['nullable', 'string', 'max:50'],
            'context_id' => ['nullable', 'integer'],
            'subject' => ['nullable', 'string', 'max:150'],
            'include_messages' => ['nullable', 'boolean'],
        ]);

        $includeMessages = (bool) ($validated['include_messages'] ?? true);

        $conversation = SupportConversation::query()
            ->where('customer_id', $user->id)
            ->where('context_type', $validated['context_type'] ?? null)
            ->where('context_id', $validated['context_id'] ?? null)
            ->whereNotIn('status', ['closed'])
            ->latest('last_message_at')
            ->latest('id')
            ->first();

        if (! $conversation) {
            $conversation = DB::transaction(function () use ($user, $validated) {
                $conversation = SupportConversation::create([
                    'customer_id' => $user->id,
                    'status' => 'new',
                    'context_type' => $validated['context_type'] ?? null,
                    'context_id' => $validated['context_id'] ?? null,
                    'subject' => $validated['subject'] ?? 'General support',
                ]);

                SupportMessage::create([
                    'conversation_id' => $conversation->id,
                    'sender_user_id' => null,
                    'sender_type' => 'support',
                    'message_type' => 'text',
                    'body' => 'Hello, welcome to support. How can we help you today?',
                    'delivery_status' => 'delivered',
                    'seen_at' => now(),
                ]);

                $conversation->forceFill([
                    'status' => 'open',
                    'last_message_at' => now(),
                ])->save();

                return $conversation;
            });
        }

        $this->markConversationRead($conversation, 'customer', $user);

        return new SupportConversationResource(
            $this->freshConversation($conversation, $includeMessages)
        );
    }

    public function storeCustomerMessage(Request $request)
    {
        $user = $request->user() ?? $request->user('sanctum');

        abort_unless($user, 401);

        $validated = $request->validate([
            'conversation_id' => ['required', 'integer', 'exists:support_conversations,id'],
            'message_type' => ['nullable', 'in:text,emoji,voice'],
            'body' => ['nullable', 'string', 'max:5000'],
            'media_url' => ['nullable', 'string', 'max:2048'],
            'media_duration_sec' => ['nullable', 'integer', 'min:1', 'max:600'],
        ]);

        $conversation = SupportConversation::query()
            ->where('id', $validated['conversation_id'])
            ->where('customer_id', $user->id)
            ->firstOrFail();

        $messageType = $validated['message_type'] ?? 'text';
        $this->validateMessagePayload($messageType, $validated);

        $message = DB::transaction(function () use ($conversation, $user, $validated, $messageType) {
            $message = SupportMessage::create([
                'conversation_id' => $conversation->id,
                'sender_user_id' => $user->id,
                'sender_type' => 'customer',
                'message_type' => $messageType,
                'body' => $validated['body'] ?? null,
                'media_url' => $validated['media_url'] ?? null,
                'media_duration_sec' => $validated['media_duration_sec'] ?? null,
                'delivery_status' => 'sent',
            ]);

            $conversation->forceFill([
                'status' => 'waiting_for_support',
                'last_message_at' => $message->created_at ?? now(),
            ])->save();

            return $message;
        });

        return response()->json([
            'message' => 'Message sent.',
            'data' => [
                'conversation' => new SupportConversationResource(
                    $this->freshConversation($conversation, false)
                ),
                'message' => new SupportMessageResource($message->fresh()),
            ],
        ], 201);
    }

    public function markCustomerRead(Request $request)
    {
        $user = $request->user() ?? $request->user('sanctum');

        abort_unless($user, 401);

        $validated = $request->validate([
            'conversation_id' => ['required', 'integer', 'exists:support_conversations,id'],
        ]);

        $conversation = SupportConversation::query()
            ->where('id', $validated['conversation_id'])
            ->where('customer_id', $user->id)
            ->firstOrFail();

        $this->markConversationRead($conversation, 'customer', $user);

        return new SupportConversationResource(
            $this->freshConversation($conversation, false)
        );
    }

    public function customerUnreadCount(Request $request)
    {
        $user = $request->user() ?? $request->user('sanctum');

        abort_unless($user, 401);

        $conversations = SupportConversation::query()
            ->where('customer_id', $user->id)
            ->get();

        $count = $conversations->sum(fn (SupportConversation $conversation) => $conversation->unreadForCustomerCount());

        return response()->json([
            'count' => $count,
        ]);
    }

    public function adminIndex(Request $request)
    {
        $perPage = min((int) $request->integer('per_page', 20), 50);
        $status = trim((string) $request->query('status', ''));
        $unreadOnly = filter_var($request->query('unread_only'), FILTER_VALIDATE_BOOLEAN);

        $query = SupportConversation::query()
            ->with(['customer', 'assignee', 'latestMessage'])
            ->withCount([
                'messages as customer_message_count' => fn ($builder) => $builder->where('sender_type', 'customer'),
                'messages as support_message_count' => fn ($builder) => $builder->where('sender_type', 'support'),
            ])
            ->orderByDesc(DB::raw('COALESCE(last_message_at, created_at)'))
            ->orderByDesc('id');

        if ($status !== '') {
            $query->where('status', $status);
        }

        $conversations = $query->paginate($perPage)->withQueryString();

        if ($unreadOnly) {
            $conversations->setCollection(
                $conversations->getCollection()->filter(
                    fn (SupportConversation $conversation) => $conversation->unreadForSupportCount() > 0
                )->values()
            );
        }

        return SupportConversationResource::collection($conversations);
    }

    public function adminShow(Request $request, SupportConversation $conversation)
    {
        $this->markConversationRead(
            $conversation,
            'support',
            $request->user() ?? $request->user('sanctum')
        );

        return new SupportConversationResource(
            $this->freshConversation($conversation, true)
        );
    }

    public function adminStoreMessage(Request $request, SupportConversation $conversation)
    {
        $user = $request->user() ?? $request->user('sanctum');

        abort_unless($user, 401);

        $validated = $request->validate([
            'message_type' => ['nullable', 'in:text,emoji,voice'],
            'body' => ['nullable', 'string', 'max:5000'],
            'media_url' => ['nullable', 'string', 'max:2048'],
            'media_duration_sec' => ['nullable', 'integer', 'min:1', 'max:600'],
        ]);

        $messageType = $validated['message_type'] ?? 'text';
        $this->validateMessagePayload($messageType, $validated);

        $message = DB::transaction(function () use ($conversation, $user, $validated, $messageType) {
            $message = SupportMessage::create([
                'conversation_id' => $conversation->id,
                'sender_user_id' => $user->id,
                'sender_type' => 'support',
                'message_type' => $messageType,
                'body' => $validated['body'] ?? null,
                'media_url' => $validated['media_url'] ?? null,
                'media_duration_sec' => $validated['media_duration_sec'] ?? null,
                'delivery_status' => 'delivered',
            ]);

            $conversation->forceFill([
                'status' => 'waiting_for_user',
                'last_message_at' => $message->created_at ?? now(),
                'assigned_to' => $conversation->assigned_to ?? $user->id,
            ])->save();

            return $message;
        });

        return response()->json([
            'message' => 'Reply sent.',
            'data' => [
                'conversation' => new SupportConversationResource(
                    $this->freshConversation($conversation, false)
                ),
                'message' => new SupportMessageResource($message->fresh()),
            ],
        ], 201);
    }

    public function adminUpdateStatus(Request $request, SupportConversation $conversation)
    {
        $validated = $request->validate([
            'status' => ['required', 'in:new,open,waiting_for_support,waiting_for_user,resolved,closed'],
        ]);

        $conversation->status = $validated['status'];
        $conversation->resolved_at = in_array($validated['status'], ['resolved', 'closed'], true)
            ? now()
            : null;
        $conversation->save();

        return new SupportConversationResource(
            $this->freshConversation($conversation, false)
        );
    }

    public function adminAssign(Request $request, SupportConversation $conversation)
    {
        $validated = $request->validate([
            'assigned_to' => ['nullable', 'integer', 'exists:users,id'],
        ]);

        if (! empty($validated['assigned_to'])) {
            $assignee = User::query()->findOrFail($validated['assigned_to']);
            abort_unless($assignee->isAdmin() || $assignee->isStaff(), 422, 'Selected user cannot manage support chats.');
        }

        $conversation->assigned_to = $validated['assigned_to'] ?? null;
        $conversation->save();

        return new SupportConversationResource(
            $this->freshConversation($conversation, false)
        );
    }

    protected function freshConversation(SupportConversation $conversation, bool $includeMessages): SupportConversation
    {
        $relations = ['customer', 'assignee'];

        if ($includeMessages) {
            $relations[] = 'messages.sender';
        }

        return $conversation->fresh($relations);
    }

    protected function markConversationRead(
        SupportConversation $conversation,
        string $viewerType,
        ?User $actor = null
    ): void
    {
        $now = Carbon::now();

        if ($viewerType === 'customer') {
            $conversation->forceFill([
                'customer_last_read_at' => $now,
                'status' => $conversation->status === 'new' ? 'open' : $conversation->status,
            ])->save();

            $conversation->messages()
                ->where('sender_type', 'support')
                ->whereNull('seen_at')
                ->update([
                    'seen_at' => $now,
                    'delivery_status' => 'seen',
                ]);

            return;
        }

        $conversation->forceFill([
            'support_last_read_at' => $now,
            'assigned_to' => $conversation->assigned_to ?: $actor?->id,
        ])->save();

        $conversation->messages()
            ->where('sender_type', 'customer')
            ->whereNull('seen_at')
            ->update([
                'seen_at' => $now,
                'delivery_status' => 'seen',
            ]);
    }

    protected function validateMessagePayload(string $messageType, array $payload): void
    {
        if (in_array($messageType, ['text', 'emoji'], true) && blank($payload['body'] ?? null)) {
            throw ValidationException::withMessages([
                'body' => ['Message body is required.'],
            ]);
        }

        if ($messageType === 'voice' && blank($payload['media_url'] ?? null)) {
            throw ValidationException::withMessages([
                'media_url' => ['Voice message media_url is required.'],
            ]);
        }
    }
}
