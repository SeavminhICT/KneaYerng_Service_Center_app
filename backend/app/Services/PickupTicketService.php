<?php

namespace App\Services;

use App\Models\Order;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Crypt;
use Illuminate\Support\Str;

class PickupTicketService
{
    public function issueForOrder(Order $order): array
    {
        if ($order->order_type !== 'pickup') {
            throw new \RuntimeException('Pickup tickets are only available for pickup orders.');
        }

        if ($order->payment_status !== 'paid') {
            throw new \RuntimeException('Pickup ticket requires a successful payment.');
        }

        if ($order->pickup_qr_token && $order->pickup_qr_generated_at && ! $order->pickup_verified_at) {
            $existingExpiresAt = $order->pickup_qr_expires_at
                ? $order->pickup_qr_expires_at->copy()
                : $order->pickup_qr_generated_at->copy()->addHours(24);

            if ($existingExpiresAt->isFuture()) {
                // Backfill short code for orders issued before this feature existed.
                if (! $order->pickup_qr_short_code) {
                    $order->pickup_qr_short_code = $this->generateShortCode();
                    $order->save();
                }
                if (! $order->pickup_qr_expires_at) {
                    $order->pickup_qr_expires_at = $existingExpiresAt;
                    $order->save();
                }

                return [
                    'token'     => $order->pickup_qr_token,
                    'qr_code'   => $order->pickup_qr_short_code,
                    'ticket_id' => $this->ticketIdFor($order),
                    'issued_at' => $order->pickup_qr_generated_at,
                    'expires_at' => $existingExpiresAt,
                ];
            }
        }

        $issuedAt  = Carbon::now();
        $expiresAt = $issuedAt->copy()->addHours(24);
        $ticketId  = $this->ticketIdFor($order);

        $payload = [
            'order_id'       => $order->id,
            'ticket_id'      => $ticketId,
            'payment_status' => $order->payment_status,
            'issued_at'      => $issuedAt->toISOString(),
            'expires_at'     => $expiresAt->timestamp,
            'nonce'          => Str::random(16),
        ];

        $token     = Crypt::encryptString(json_encode($payload));
        $shortCode = $this->generateShortCode();

        $order->pickup_qr_token      = $token;
        $order->pickup_qr_short_code = $shortCode;
        $order->pickup_qr_generated_at = $issuedAt;
        $order->pickup_qr_expires_at   = $expiresAt;
        $order->save();

        return [
            'token'     => $token,
            'qr_code'   => $shortCode,
            'ticket_id' => $ticketId,
            'issued_at' => $issuedAt,
            'expires_at' => $expiresAt,
        ];
    }

    public function ticketIdFor(Order $order): string
    {
        if ($order->order_number) {
            return 'TCK-'.$order->order_number;
        }

        return 'TCK-'.$order->id;
    }

    private function generateShortCode(): string
    {
        // 12 uppercase alphanumeric characters — produces a version-1 QR code
        // (21×21 modules) that any camera can scan in under a second.
        $chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        $code  = '';
        for ($i = 0; $i < 12; $i++) {
            $code .= $chars[random_int(0, strlen($chars) - 1)];
        }

        return $code;
    }
}
