<?php

namespace App\Jobs;

use App\Models\AdminNotificationCampaign;
use App\Services\AdminNotificationCampaignSender;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Throwable;

class SendAdminNotificationCampaign implements ShouldQueue
{
    use Dispatchable;
    use InteractsWithQueue;
    use Queueable;
    use SerializesModels;

    public int $tries = 3;

    public int $timeout = 600;

    public function __construct(public int $campaignId)
    {
    }

    /**
     * @return array<int>
     */
    public function backoff(): array
    {
        return [30, 120, 300];
    }

    public function handle(AdminNotificationCampaignSender $sender): void
    {
        $campaign = AdminNotificationCampaign::find($this->campaignId);
        if (! $campaign) {
            return;
        }

        // Only process campaigns waiting to go out; re-processing a campaign
        // that finished (or one still drafted) must be a no-op.
        if (! in_array($campaign->status, ['queued', 'sending'], true)) {
            return;
        }

        $campaign->status = 'sending';
        $campaign->save();

        $summary = $sender->send($campaign);

        Log::info('Admin notification campaign sent.', [
            'campaign_id' => $campaign->id,
            'summary' => $summary,
        ]);
    }

    public function failed(Throwable $exception): void
    {
        AdminNotificationCampaign::query()
            ->whereKey($this->campaignId)
            ->whereIn('status', ['queued', 'sending'])
            ->update(['status' => 'failed']);

        Log::error('Admin notification campaign failed after retries.', [
            'campaign_id' => $this->campaignId,
            'error' => $exception->getMessage(),
        ]);
    }
}
