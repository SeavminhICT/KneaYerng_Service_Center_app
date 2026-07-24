<?php

use App\Models\OrderTrackingNotification;
use App\Models\SupportConversation;
use App\Models\User;
use App\Services\FirebasePushNotificationService;

it('pushes a notification to the customer when support replies', function () {
    $admin = User::factory()->create([
        'role' => 'admin',
        'is_admin' => true,
    ]);
    $customer = User::factory()->create([
        'role' => 'user',
        'is_admin' => false,
    ]);
    $customer->mobileDeviceTokens()->create([
        'token' => 'fcm-token-support-1',
        'platform' => 'android',
        'last_used_at' => now(),
    ]);

    $conversation = SupportConversation::create([
        'customer_id' => $customer->id,
        'status' => 'waiting_for_support',
        'subject' => 'General support',
    ]);

    $push = Mockery::mock(FirebasePushNotificationService::class);
    $push
        ->shouldReceive('sendStoredNotification')
        ->once()
        ->withArgs(function (User $user, OrderTrackingNotification $notification) use ($customer) {
            return $user->is($customer)
                && $notification->user_id === $customer->id
                && $notification->type === 'support_reply'
                && $notification->title === 'New message from support'
                && $notification->body === 'Your repair is ready for pickup.'
                && ($notification->payload['deep_link'] ?? null) === '/support';
        })
        ->andReturn([
            'device_tokens' => 1,
            'delivered' => 1,
            'failed' => 0,
            'removed_invalid_tokens' => 0,
        ]);
    $this->app->instance(FirebasePushNotificationService::class, $push);

    $response = $this
        ->actingAs($admin)
        ->postJson("/api/admin/support/conversations/{$conversation->id}/messages", [
            'message_type' => 'text',
            'body' => 'Your repair is ready for pickup.',
        ]);

    $response->assertCreated();

    $this->assertDatabaseHas('order_tracking_notifications', [
        'user_id' => $customer->id,
        'type' => 'support_reply',
        'title' => 'New message from support',
        'body' => 'Your repair is ready for pickup.',
    ]);
});

it('does not fail the reply request if push delivery throws', function () {
    $admin = User::factory()->create([
        'role' => 'admin',
        'is_admin' => true,
    ]);
    $customer = User::factory()->create([
        'role' => 'user',
        'is_admin' => false,
    ]);

    $conversation = SupportConversation::create([
        'customer_id' => $customer->id,
        'status' => 'waiting_for_support',
        'subject' => 'General support',
    ]);

    $push = Mockery::mock(FirebasePushNotificationService::class);
    $push->shouldReceive('sendStoredNotification')->once()->andThrow(new RuntimeException('boom'));
    $this->app->instance(FirebasePushNotificationService::class, $push);

    $response = $this
        ->actingAs($admin)
        ->postJson("/api/admin/support/conversations/{$conversation->id}/messages", [
            'message_type' => 'text',
            'body' => 'Hello there.',
        ]);

    $response->assertCreated();
});
