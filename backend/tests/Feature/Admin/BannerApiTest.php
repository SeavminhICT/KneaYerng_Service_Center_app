<?php

use App\Models\Banner;
use App\Models\User;

it('allows admin web session to load admin banners api', function () {
    $admin = User::factory()->create([
        'role' => 'admin',
        'is_admin' => true,
    ]);

    Banner::query()->create([
        'image' => 'storage/banners/test.jpg',
        'badge_label' => 'New',
        'title' => 'Banner Test',
        'subtitle' => 'Subtitle',
        'cta_label' => 'Shop',
    ]);

    $response = $this
        ->actingAs($admin)
        ->getJson('/api/admin/banners');

    $response
        ->assertOk()
        ->assertJsonStructure([
            'data' => [
                ['id', 'image', 'title'],
            ],
        ]);
});
