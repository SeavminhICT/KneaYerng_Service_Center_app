<?php

use App\Jobs\SendAdminNotificationCampaign;
use App\Models\AdminNotificationCampaign;
use App\Models\KhqrTransaction;
use App\Models\Order;
use App\Models\Payment;
use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Artisan::command('khqr:expire', function () {
    $now = now();
    $expiredCount = 0;

    KhqrTransaction::query()
        ->whereIn('status', ['PENDING', 'NOT_FOUND'])
        ->whereNotNull('expires_at')
        ->where('expires_at', '<', $now)
        ->orderBy('id')
        ->chunkById(100, function ($transactions) use (&$expiredCount, $now) {
            foreach ($transactions as $transaction) {
                $transaction->status = 'TIMEOUT';
                $transaction->checked_at = $now;
                $transaction->save();

                $payment = Payment::where('transaction_id', $transaction->transaction_id)
                    ->latest()
                    ->first();
                if ($payment && in_array($payment->status, ['pending', 'processing'], true)) {
                    $payment->status = 'failed';
                    $payment->paid_at = null;
                    $payment->save();
                }

                if ($transaction->order_id) {
                    $order = Order::find($transaction->order_id);
                    if ($order && $order->payment_status !== 'paid') {
                        $order->payment_status = 'failed';
                        $order->payment_method = $order->payment_method ?: 'aba';
                        $order->save();
                    }
                }

                $expiredCount += 1;
            }
        });

    if ($expiredCount > 0) {
        Log::info('KHQR transactions expired.', ['count' => $expiredCount]);
    }

    $this->comment("Expired {$expiredCount} KHQR transaction(s).");
})->purpose('Expire stale KHQR transactions');

Artisan::command('notifications:send-due', function () {
    $due = AdminNotificationCampaign::query()
        ->where('status', 'scheduled')
        ->whereNotNull('scheduled_for')
        ->where('scheduled_for', '<=', now())
        ->orderBy('scheduled_for')
        ->limit(50)
        ->get();

    foreach ($due as $campaign) {
        $campaign->status = 'queued';
        $campaign->save();
        SendAdminNotificationCampaign::dispatch($campaign->id);
    }

    if ($due->isNotEmpty()) {
        Log::info('Queued scheduled notification campaigns.', [
            'campaign_ids' => $due->pluck('id')->all(),
        ]);
    }

    $this->comment('Queued '.$due->count().' scheduled campaign(s).');
})->purpose('Queue admin notification campaigns whose schedule time has arrived');

Schedule::command('khqr:expire')->everyMinute();
Schedule::command('notifications:send-due')->everyMinute();
Schedule::command('backup:run')->daily();
