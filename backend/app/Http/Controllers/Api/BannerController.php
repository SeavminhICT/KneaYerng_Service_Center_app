<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\BannerResource;
use App\Models\Banner;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;

class BannerController extends Controller
{
    public function publicIndex()
    {
        $banners = Banner::query()
            ->orderByDesc('id')
            ->get();

        return BannerResource::collection($banners);
    }

    public function index()
    {
        $banners = Banner::query()
            ->with('addedBy')
            ->orderByDesc('id')
            ->paginate(12);

        return BannerResource::collection($banners);
    }

    public function store(Request $request)
    {
        $request->validate([
            'image' => ['required', 'image', 'max:5120'],
            'badge_label' => ['nullable', 'string', 'max:100'],
            'title' => ['nullable', 'string', 'max:255'],
            'subtitle' => ['nullable', 'string', 'max:1000'],
            'cta_label' => ['nullable', 'string', 'max:100'],
        ]);

        try {
            $disk = Storage::build(array_merge(config('filesystems.disks.public'), ['throw' => true]));
            $storedPath = $disk->putFile('banners', $request->file('image'));
        } catch (\Throwable $e) {
            Log::error('Banner image upload failed.', ['error' => $e->getMessage()]);
            return response()->json(['message' => 'Image upload failed: '.$e->getMessage()], 500);
        }

        $actor = $request->user() ?? $request->user('sanctum');

        $banner = Banner::create([
            'added_by' => $actor?->id,
            'image' => 'storage/'.$storedPath,
            'badge_label' => $request->string('badge_label')->trim()->toString() ?: null,
            'title' => $request->string('title')->trim()->toString() ?: null,
            'subtitle' => $request->string('subtitle')->trim()->toString() ?: null,
            'cta_label' => $request->string('cta_label')->trim()->toString() ?: null,
        ]);

        return new BannerResource($banner->load('addedBy'));
    }

    public function show(Banner $banner)
    {
        return new BannerResource($banner->load('addedBy'));
    }

    public function update(Request $request, Banner $banner)
    {
        $request->validate([
            'image' => ['nullable', 'image', 'max:5120'],
            'badge_label' => ['nullable', 'string', 'max:100'],
            'title' => ['nullable', 'string', 'max:255'],
            'subtitle' => ['nullable', 'string', 'max:1000'],
            'cta_label' => ['nullable', 'string', 'max:100'],
        ]);

        if ($request->hasFile('image')) {
            if ($banner->image) {
                $oldImagePath = str_replace('storage/', '', $banner->image);
                Storage::disk('public')->delete($oldImagePath);
            }

            try {
                $disk = Storage::build(array_merge(config('filesystems.disks.public'), ['throw' => true]));
                $storedPath = $disk->putFile('banners', $request->file('image'));
                $banner->image = 'storage/'.$storedPath;
            } catch (\Throwable $e) {
                Log::error('Banner image upload failed.', ['error' => $e->getMessage()]);
                return response()->json(['message' => 'Image upload failed: '.$e->getMessage()], 500);
            }
        }

        $banner->badge_label = $request->string('badge_label')->trim()->toString() ?: null;
        $banner->title = $request->string('title')->trim()->toString() ?: null;
        $banner->subtitle = $request->string('subtitle')->trim()->toString() ?: null;
        $banner->cta_label = $request->string('cta_label')->trim()->toString() ?: null;
        $banner->save();

        return new BannerResource($banner->load('addedBy'));
    }

    public function destroy(Banner $banner)
    {
        if ($banner->image) {
            $oldImagePath = str_replace('storage/', '', $banner->image);
            Storage::disk('public')->delete($oldImagePath);
        }

        $banner->delete();

        return response()->noContent();
    }
}
