<?php

it('can fetch api updates and verifies schema', function () {
    $response = $this->getJson('/api/updates');

    $response->assertStatus(200)
        ->assertJsonStructure([
            'data' => [
                'categories',
                'products',
                'banners',
                'accessories',
            ]
        ]);
});

it('handles etag header and returns 304 not modified', function () {
    // 1. First request
    $response = $this->getJson('/api/updates');
    $response->assertStatus(200);

    $etag = $response->headers->get('ETag');
    expect($etag)->not->toBeNull();

    // 2. Second request with If-None-Match
    $conditionalResponse = $this->get('/api/updates', [
        'If-None-Match' => $etag,
    ]);

    $conditionalResponse->assertStatus(304);
});
