<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\BannerResource;
use App\Models\Banner;
use Illuminate\Http\Request;
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
            ->orderByDesc('id')
            ->paginate(12);

        return BannerResource::collection($banners);
    }

    public function store(Request $request)
    {
        $request->validate([
            'image' => ['required', 'image', 'max:5120'],
        ]);

        $storedPath = $request->file('image')->store('banners', 'public');

        $banner = Banner::create([
            'image' => 'storage/'.$storedPath,
        ]);

        return new BannerResource($banner);
    }

    public function show(Banner $banner)
    {
        return new BannerResource($banner);
    }

    public function update(Request $request, Banner $banner)
    {
        $request->validate([
            'image' => ['required', 'image', 'max:5120'],
        ]);

        if ($banner->image) {
            $oldImagePath = str_replace('storage/', '', $banner->image);
            Storage::disk('public')->delete($oldImagePath);
        }

        $storedPath = $request->file('image')->store('banners', 'public');
        $banner->image = 'storage/'.$storedPath;
        $banner->save();

        return new BannerResource($banner);
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
