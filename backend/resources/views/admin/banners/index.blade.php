@extends('layouts.admin')

@section('title', 'Banners')
@section('page-title', 'Banners')

@section('content')
    <div class="space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-4">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Banner Manager</h2>
                <p class="text-sm text-slate-500">Upload banner images for the mobile app carousel.</p>
            </div>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <form id="banner-form" class="flex flex-wrap items-center gap-3">
                <label class="flex h-12 w-full max-w-md cursor-pointer items-center justify-between rounded-xl border border-dashed border-slate-300 bg-slate-50 px-4 text-sm text-slate-500 dark:border-slate-700 dark:bg-slate-900/60 dark:text-slate-300">
                    <span id="banner-file-name">Choose banner image</span>
                    <input id="banner-image" name="image" type="file" accept="image/*" class="hidden" required />
                    <span class="rounded-lg bg-white px-3 py-1 text-xs font-semibold text-slate-600 shadow-sm dark:bg-slate-800 dark:text-slate-200">Browse</span>
                </label>
                <button type="submit" class="inline-flex h-12 items-center rounded-xl bg-primary-600 px-5 text-sm font-semibold text-white shadow-sm">Upload Banner</button>
            </form>
            <p id="banner-form-message" class="mt-2 text-sm text-slate-500"></p>
            <div id="banner-preview" class="mt-4 hidden">
                <div class="aspect-[16/7] overflow-hidden rounded-xl border border-slate-200 bg-slate-50 dark:border-slate-800 dark:bg-slate-900/60">
                    <img id="banner-preview-image" alt="Banner preview" class="h-full w-full object-cover" />
                </div>
            </div>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex items-center justify-between">
                <h3 class="text-base font-semibold text-slate-900 dark:text-white">Uploaded Banners</h3>
                <div class="flex items-center gap-2">
                    <button id="banner-prev" class="rounded-lg border border-slate-200 px-3 py-1 text-xs text-slate-600 dark:border-slate-800 dark:text-slate-300">Previous</button>
                    <button id="banner-next" class="rounded-lg border border-slate-200 bg-slate-100 px-3 py-1 text-xs text-slate-900 dark:border-slate-800 dark:bg-slate-900">Next</button>
                </div>
            </div>

            <div id="banner-grid" class="mt-4 grid gap-4 sm:grid-cols-2 lg:grid-cols-3"></div>
            <p id="banner-pagination-info" class="mt-4 text-xs text-slate-500">Loading banners...</p>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var currentPage = 1;

            var form = document.getElementById('banner-form');
            var fileInput = document.getElementById('banner-image');
            var fileName = document.getElementById('banner-file-name');
            var formMessage = document.getElementById('banner-form-message');
            var previewWrap = document.getElementById('banner-preview');
            var previewImage = document.getElementById('banner-preview-image');
            var grid = document.getElementById('banner-grid');
            var info = document.getElementById('banner-pagination-info');
            var prevButton = document.getElementById('banner-prev');
            var nextButton = document.getElementById('banner-next');

            function resolveImage(path) {
                if (!path) {
                    return '';
                }
                if (path.startsWith('http')) {
                    return path;
                }
                if (path.startsWith('/')) {
                    return path;
                }
                return '/' + path;
            }

            async function loadBanners() {
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/admin/banners?page=' + currentPage);
                if (!response.ok) {
                    grid.innerHTML = '<div class="text-sm text-slate-500">Unable to load banners.</div>';
                    info.textContent = 'Unable to load banners.';
                    return;
                }

                var data = await response.json();
                var list = data.data || [];

                grid.innerHTML = list.map(function (banner) {
                    var imageUrl = resolveImage(banner.image);
                    return `
                        <div class="rounded-2xl border border-slate-200 p-4 shadow-sm dark:border-slate-800">
                            <div class="aspect-[16/7] overflow-hidden rounded-xl bg-slate-100 dark:bg-slate-800">
                                ${imageUrl ? `<img src="${imageUrl}" alt="Banner ${banner.id}" class="h-full w-full object-cover" />` : ''}
                            </div>
                            <div class="mt-3 flex items-center justify-between text-xs text-slate-500">
                                <span>ID: ${banner.id}</span>
                                <button data-banner-delete="${banner.id}" class="text-xs font-semibold text-danger-600">Delete</button>
                            </div>
                        </div>
                    `;
                }).join('') || '<div class="text-sm text-slate-500">No banners yet.</div>';

                info.textContent = 'Showing ' + list.length + ' banners';
                prevButton.disabled = !data.links?.prev;
                nextButton.disabled = !data.links?.next;
            }

            form.addEventListener('submit', async function (event) {
                event.preventDefault();
                if (!fileInput.files.length) {
                    formMessage.textContent = 'Please choose an image file.';
                    if (window.adminSwalError) {
                        window.adminSwalError('Upload failed', 'Please choose an image file.');
                    } else if (window.adminToast) {
                        window.adminToast('Please choose an image file.', { type: 'error' });
                    }
                    return;
                }
                var formData = new FormData();
                formData.append('image', fileInput.files[0]);

                formMessage.textContent = 'Uploading...';
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/admin/banners', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    formMessage.textContent = 'Upload failed. Please try again.';
                    if (window.adminSwalError) {
                        window.adminSwalError('Upload failed', 'Please try again.');
                    } else if (window.adminToast) {
                        window.adminToast('Upload failed. Please try again.', { type: 'error' });
                    }
                    return;
                }

                formMessage.textContent = 'Banner uploaded successfully.';
                if (window.adminSwalSuccess) {
                    await window.adminSwalSuccess('Uploaded', 'Banner uploaded successfully.');
                } else if (window.adminToast) {
                    window.adminToast('Banner uploaded successfully.');
                }
                form.reset();
                fileName.textContent = 'Choose banner image';
                if (previewWrap && previewImage) {
                    previewImage.src = '';
                    previewWrap.classList.add('hidden');
                }
                currentPage = 1;
                loadBanners();
            });

            fileInput.addEventListener('change', function () {
                var file = fileInput.files[0];
                if (window.adminValidateFileSize && file && !window.adminValidateFileSize(file, 'Banner image')) {
                    fileInput.value = '';
                    fileName.textContent = 'Choose banner image';
                    formMessage.textContent = 'Banner image must be 5MB or smaller.';
                    if (previewWrap && previewImage) {
                        previewImage.src = '';
                        previewWrap.classList.add('hidden');
                    }
                    return;
                }
                fileName.textContent = file ? file.name : 'Choose banner image';
                if (file) {
                    formMessage.textContent = '';
                }
                if (previewWrap && previewImage) {
                    if (!file) {
                        previewImage.src = '';
                        previewWrap.classList.add('hidden');
                        return;
                    }

                    var reader = new FileReader();
                    reader.onload = function (event) {
                        previewImage.src = event.target.result;
                        previewWrap.classList.remove('hidden');
                    };
                    reader.readAsDataURL(file);
                }
            });

            grid.addEventListener('click', async function (event) {
                var target = event.target;
                if (!target.dataset.bannerDelete) {
                    return;
                }

                var bannerId = target.dataset.bannerDelete;
                var confirmed = true;
                if (window.adminSwalConfirm) {
                    var result = await window.adminSwalConfirm('Delete banner?', 'This will remove the banner image.', 'Yes, delete it');
                    confirmed = result.isConfirmed;
                } else {
                    confirmed = window.confirm('Delete this banner?');
                }
                if (!confirmed) {
                    return;
                }
                await window.adminApi.ensureCsrfCookie();
                var response = await window.adminApi.request('/api/admin/banners/' + bannerId, {
                    method: 'DELETE'
                });

                if (!response.ok) {
                    formMessage.textContent = 'Delete failed. Please try again.';
                    if (window.adminSwalError) {
                        window.adminSwalError('Delete failed', 'Please try again.');
                    } else if (window.adminToast) {
                        window.adminToast('Delete failed. Please try again.', { type: 'error' });
                    }
                    return;
                }

                if (window.adminSwalSuccess) {
                    await window.adminSwalSuccess('Deleted', 'Banner deleted successfully.');
                } else if (window.adminToast) {
                    window.adminToast('Banner deleted.');
                }
                loadBanners();
            });

            prevButton.addEventListener('click', function () {
                if (currentPage > 1) {
                    currentPage -= 1;
                    loadBanners();
                }
            });

            nextButton.addEventListener('click', function () {
                currentPage += 1;
                loadBanners();
            });

            loadBanners();
        });
    </script>
@endsection
