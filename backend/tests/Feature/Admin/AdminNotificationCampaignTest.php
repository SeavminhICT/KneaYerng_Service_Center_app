<?php

use App\Jobs\SendAdminNotificationCampaign;
use App\Models\OrderTrackingNotification;
use App\Models\User;
use App\Services\FirebasePushNotificationService;
use Illuminate\Support\Facades\Queue;

it('sends admin notification campaigns immediately for send now requests', function () {
    Queue::fake();

    $admin = User::factory()->create([
        'role' => 'admin',
        'is_admin' => true,
    ]);
    $customer = User::factory()->create([
        'role' => 'user',
        'is_admin' => false,
    ]);
    $customer->mobileDeviceTokens()->create([
        'token' => 'fcm-token-1',
        'platform' => 'android',
        'last_used_at' => now(),
    ]);

    $push = Mockery::mock(FirebasePushNotificationService::class);
    $push
        ->shouldReceive('sendStoredNotification')
        ->once()
        ->withArgs(function (User $user, OrderTrackingNotification $notification) use ($customer) {
            return $user->is($customer)
                && $notification->user_id === $customer->id
                && $notification->title === 'Service update';
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
        ->postJson('/api/admin/notifications/send', [
            'title' => 'Service update',
            'message' => 'Your repair is ready.',
            'type' => 'Announcement',
            'audience' => 'custom',
            'custom_user_ids' => [$customer->id],
            'action' => 'send_now',
        ]);

    $response
        ->assertOk()
        ->assertJsonPath('summary.saved_notifications', 1)
        ->assertJsonPath('summary.device_tokens', 1)
        ->assertJsonPath('summary.delivered', 1)
        ->assertJsonPath('history_item.status', 'sent');

    Queue::assertNotPushed(SendAdminNotificationCampaign::class);

    $this->assertDatabaseHas('admin_notification_campaigns', [
        'title' => 'Service update',
        'status' => 'sent',
    ]);
    $this->assertDatabaseHas('order_tracking_notifications', [
        'user_id' => $customer->id,
        'title' => 'Service update',
        'body' => 'Your repair is ready.',
    ]);
});

it('returns a clear push setup error for placeholder firebase credentials', function () {
    config(['services.firebase.credentials' => '../firebase-credentials.json']);

    $service = new FirebasePushNotificationService;
    $notification = new OrderTrackingNotification([
        'title' => 'Test',
        'body' => 'Body',
        'type' => 'admin_announcement',
        'payload' => [],
    ]);
    $notification->id = 123;

    $summary = $service->sendNotificationToTokens(['fcm-token-1'], $notification);

    expect($summary['device_tokens'])->toBe(1)
        ->and($summary['delivered'])->toBe(0)
        ->and($summary['failed'])->toBe(1)
        ->and($summary['push_disabled'])->toBe(1)
        ->and($summary['push_error'])->toContain('Firebase Admin credentials file is missing')
        ->and($summary['push_error'])->toContain('Do not use google-services.json');
});
