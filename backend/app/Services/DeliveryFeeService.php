<?php

namespace App\Services;

class DeliveryFeeService
{
    /**
     * @return array{name: string, lat: float, lng: float}
     */
    public function shopLocation(): array
    {
        return config('orders.shop_location', [
            'name' => 'KneaYerng VIP',
            'lat' => 11.5664368,
            'lng' => 104.8923294,
        ]);
    }

    /**
     * @return list<array{max_km: float, fee: float}>
     */
    public function tiers(): array
    {
        return config('orders.delivery_fee_tiers', [
            ['max_km' => 10, 'fee' => 0],
            ['max_km' => 15, 'fee' => 2],
            ['max_km' => 20, 'fee' => 3],
            ['max_km' => 25, 'fee' => 5],
        ]);
    }

    public function distanceKm(float $lat, float $lng): float
    {
        $shop = $this->shopLocation();

        return $this->haversineKm((float) $shop['lat'], (float) $shop['lng'], $lat, $lng);
    }

    public function feeForDistanceKm(float $distanceKm): float
    {
        $tiers = $this->tiers();

        foreach ($tiers as $tier) {
            if ($distanceKm <= (float) $tier['max_km']) {
                return (float) $tier['fee'];
            }
        }

        $lastTier = end($tiers);

        return $lastTier ? (float) $lastTier['fee'] : (float) config('orders.delivery_fee', 0);
    }

    /**
     * Distance-based fee for a delivery address, or null when coordinates
     * are unavailable (caller should fall back to the flat config fee).
     */
    public function feeForCoordinates(?float $lat, ?float $lng): ?float
    {
        if ($lat === null || $lng === null) {
            return null;
        }

        return $this->feeForDistanceKm($this->distanceKm($lat, $lng));
    }

    private function haversineKm(float $lat1, float $lng1, float $lat2, float $lng2): float
    {
        $earthRadiusKm = 6371.0;
        $latDelta = deg2rad($lat2 - $lat1);
        $lngDelta = deg2rad($lng2 - $lng1);

        $a = sin($latDelta / 2) ** 2
            + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * sin($lngDelta / 2) ** 2;
        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return $earthRadiusKm * $c;
    }
}
