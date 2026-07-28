<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class AiDescriptionService
{
    public function isEnabled(): bool
    {
        return filled(config('services.gemini.api_key'));
    }

    /**
     * Ask Gemini for a short e-commerce product description. Returns null when
     * disabled, unconfigured, or on failure — callers should surface a clear
     * error rather than silently falling back.
     */
    public function generateProductDescription(array $attributes): ?string
    {
        if (! $this->isEnabled()) {
            return null;
        }

        $name = trim((string) ($attributes['name'] ?? ''));
        if ($name === '') {
            return null;
        }

        $details = array_filter([
            'Brand' => $attributes['brand'] ?? null,
            'Category' => $attributes['category'] ?? null,
            'Tag' => $attributes['tag'] ?? null,
            'Condition' => $attributes['condition'] ?? null,
        ], fn ($value) => filled($value));

        $detailLine = collect($details)
            ->map(fn ($value, $key) => "{$key}: {$value}")
            ->implode(', ');

        $descriptionFormat = "- One short, exciting intro sentence.\n"
            . "- Then 3-5 key feature highlights, one per line, each starting with a relevant emoji (e.g. \"⚡ Fast Apple A15 Bionic chip\").\n"
            . "- End with one short line starting with an emoji naming ideal use cases (e.g. \"🎯 Perfect for gaming, photography, work, and everyday use\").\n"
            . '  Plain text only, no markdown symbols like ** or #, no headings.';

        $prompt = "Write an engaging e-commerce product description for: \"{$name}\"."
            . ($detailLine !== '' ? " Additional details: {$detailLine}." : '')
            . " Respond in exactly this structure and nothing else, with no extra commentary:\n\n"
            . "[EN]\n"
            . "<English description here, formatted like this:>\n"
            . "{$descriptionFormat}\n\n"
            . "[KM]\n"
            . "<Natural Khmer translation of the same description here, same structure, reusing the same emojis>\n\n"
            . 'Replace the bracketed instructions with the real content — keep the [EN] and [KM] markers on their own line exactly as shown.';

        $model = config('services.gemini.model', 'gemini-flash-latest');
        $url = rtrim(config('services.gemini.base_url'), '/') . "/v1beta/models/{$model}:generateContent";

        try {
            $response = Http::withHeaders([
                'x-goog-api-key' => config('services.gemini.api_key'),
                'content-type' => 'application/json',
            ])
                ->timeout((int) config('services.gemini.timeout', 20))
                ->post($url, [
                    'contents' => [
                        ['parts' => [['text' => $prompt]]],
                    ],
                    'generationConfig' => [
                        // This model spends a large, variable chunk of the budget on hidden
                        // "thinking" tokens before writing the visible answer — too low a
                        // limit here truncates the response before any real text comes out.
                        // The bilingual (EN + KM) response needs extra headroom on top of that.
                        'maxOutputTokens' => 2048,
                    ],
                ]);

            if ($response->successful()) {
                $text = trim((string) $response->json('candidates.0.content.parts.0.text'));

                return $text !== '' ? $this->splitBilingual($text) : null;
            }

            Log::warning('Gemini description request failed.', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);
        } catch (\Throwable $e) {
            Log::warning('Gemini description request error.', ['error' => $e->getMessage()]);
        }

        return null;
    }

    /**
     * The model replies with [EN]/[KM] markers; split on those and join the two
     * halves under a Khmer heading. Falls back to the raw text if the model
     * didn't follow the marker format.
     */
    private function splitBilingual(string $text): string
    {
        if (! preg_match('/\[EN\]\s*(.*?)\s*\[KM\]\s*(.*)/is', $text, $matches)) {
            return $text;
        }

        $english = trim($matches[1]);
        $khmer = trim($matches[2]);

        if ($english === '' || $khmer === '') {
            return $text;
        }

        return $english . "\n\n── ភាសាខ្មែរ (Khmer) ──\n\n" . $khmer;
    }

    /**
     * Ask Gemini for a short push-notification message body from a title.
     * Returns null when disabled, unconfigured, or on failure — callers
     * should surface a clear error rather than silently falling back.
     */
    public function generateNotificationMessage(string $title, ?string $type = null): ?string
    {
        if (! $this->isEnabled()) {
            return null;
        }

        $title = trim($title);
        if ($title === '') {
            return null;
        }

        $prompt = "Write a short push notification message body for a service center / e-commerce mobile app."
            . " The notification title is: \"{$title}\"."
            . ($type ? " Notification type: {$type}." : '')
            . ' Keep it to 1-3 short, friendly, actionable sentences. Plain text only, no markdown symbols like ** or #, no headings.'
            . " Respond in exactly this structure and nothing else, with no extra commentary:\n\n"
            . "[KM]\n"
            . "<Natural Khmer message here>\n\n"
            . "[EN]\n"
            . "<English message here, same meaning>\n\n"
            . 'Replace the bracketed instructions with the real content — keep the [KM] and [EN] markers on their own line exactly as shown.';

        $model = config('services.gemini.model', 'gemini-flash-latest');
        $url = rtrim(config('services.gemini.base_url'), '/') . "/v1beta/models/{$model}:generateContent";

        try {
            $response = Http::withHeaders([
                'x-goog-api-key' => config('services.gemini.api_key'),
                'content-type' => 'application/json',
            ])
                ->timeout((int) config('services.gemini.timeout', 20))
                ->post($url, [
                    'contents' => [
                        ['parts' => [['text' => $prompt]]],
                    ],
                    'generationConfig' => [
                        // See generateProductDescription() for why this needs headroom
                        // beyond the visible bilingual text.
                        'maxOutputTokens' => 1024,
                    ],
                ]);

            if ($response->successful()) {
                $text = trim((string) $response->json('candidates.0.content.parts.0.text'));

                return $text !== '' ? $this->splitBilingualKhmerFirst($text) : null;
            }

            Log::warning('Gemini notification message request failed.', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);
        } catch (\Throwable $e) {
            Log::warning('Gemini notification message request error.', ['error' => $e->getMessage()]);
        }

        return null;
    }

    /**
     * The model replies with [KM]/[EN] markers; split on those and join with
     * Khmer first, English below. Falls back to the raw text if the model
     * didn't follow the marker format.
     */
    private function splitBilingualKhmerFirst(string $text): string
    {
        if (! preg_match('/\[KM\]\s*(.*?)\s*\[EN\]\s*(.*)/is', $text, $matches)) {
            return $text;
        }

        $khmer = trim($matches[1]);
        $english = trim($matches[2]);

        if ($khmer === '' || $english === '') {
            return $text;
        }

        return $khmer . "\n\n── English ──\n\n" . $english;
    }
}
