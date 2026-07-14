@extends('layouts.admin')

@section('title', __('Banners'))
@section('page-title', __('Banners'))

@section('content')
    <div class="space-y-6">
        <div class="flex flex-wrap items-center justify-between gap-4">
            <div>
                <h2 class="text-lg font-semibold text-slate-900 dark:text-white">{{ __('Banner Manager') }}</h2>
                <p class="text-sm text-slate-500">{{ __('Upload banner images for the mobile app carousel.') }}</p>
            </div>
        </div>

        @if (auth()->user()?->hasPermission('create_banner'))
        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <form id="banner-form" class="grid gap-3 md:grid-cols-2">
                <label class="flex h-12 w-full max-w-md cursor-pointer items-center justify-between rounded-xl border border-dashed border-slate-300 bg-slate-50 px-4 text-sm text-slate-500 dark:border-slate-700 dark:bg-slate-900/60 dark:text-slate-300">
                    <span id="banner-file-name">{{ __('Choose banner image') }}</span>
                    <input id="banner-image" name="image" type="file" accept="image/*" class="hidden" required />
                    <span class="rounded-lg bg-white px-3 py-1 text-xs font-semibold text-slate-600 shadow-sm dark:bg-slate-800 dark:text-slate-200">{{ __('Browse') }}</span>
                </label>
                <input id="banner-badge-label" name="badge_label" type="text" placeholder="{{ __('Badge label (e.g. New Arrival)') }}" class="h-12 rounded-xl border border-slate-200 px-4 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-100" />
                <input id="banner-title" name="title" type="text" placeholder="{{ __('Banner title') }}" class="h-12 rounded-xl border border-slate-200 px-4 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-100" />
                <input id="banner-cta-label" name="cta_label" type="text" placeholder="{{ __('CTA label (e.g. Shop Now)') }}" class="h-12 rounded-xl border border-slate-200 px-4 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-100" />
                <textarea id="banner-subtitle" name="subtitle" rows="3" placeholder="{{ __('Banner subtitle') }}" class="md:col-span-2 rounded-xl border border-slate-200 px-4 py-3 text-sm text-slate-700 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-100"></textarea>
                <div class="md:col-span-2">
                    <button type="submit" class="inline-flex h-12 items-center rounded-xl bg-primary-600 px-5 text-sm font-semibold text-white shadow-sm">{{ __('Upload Banner') }}</button>
                </div>
            </form>
            <p id="banner-form-message" class="mt-2 text-sm text-slate-500"></p>
            <div id="banner-preview" class="mt-4 hidden">
                <div class="aspect-[16/7] overflow-hidden rounded-xl border border-slate-200 bg-slate-50 dark:border-slate-800 dark:bg-slate-900/60">
                    <img id="banner-preview-image" alt="{{ __('Banner preview') }}" class="h-full w-full object-cover" />
                </div>
            </div>
        </div>
        @endif

        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex items-center justify-between">
                <h3 class="text-base font-semibold text-slate-900 dark:text-white">{{ __('Uploaded Banners') }}</h3>
                <div class="flex items-center gap-2">
                    <button id="banner-prev" class="rounded-lg border border-slate-200 px-3 py-1 text-xs text-slate-600 dark:border-slate-800 dark:text-slate-300">{{ __('Previous') }}</button>
                    <button id="banner-next" class="rounded-lg border border-slate-200 bg-slate-100 px-3 py-1 text-xs text-slate-900 dark:border-slate-800 dark:bg-slate-900">{{ __('Next') }}</button>
                </div>
            </div>

            <div id="banner-grid" class="mt-4 grid gap-4 sm:grid-cols-2 lg:grid-cols-3"></div>
            <p id="banner-pagination-info" class="mt-4 text-xs text-slate-500">{{ __('Loading banners...') }}</p>
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
            var badgeInput = document.getElementById('banner-badge-label');
            var titleInput = document.getElementById('banner-title');
            var subtitleInput = document.getElementById('banner-subtitle');
            var ctaInput = document.getElementById('banner-cta-label');
            var grid = document.getElementById('banner-grid');
            var info = document.getElementById('banner-pagination-info');
            var prevButton = document.getElementById('banner-prev');
            var nextButton = document.getElementById('banner-next');

            function firstValidationError(errors) {
                if (!errors || typeof errors !== 'object') {
                    return '';
                }
                var groups = Object.values(errors);
                for (var i = 0; i < groups.length; i += 1) {
                    var group = groups[i];
                    if (Array.isArray(group) && group.length && typeof group[0] === 'string') {
                        return group[0];
                    }
                }
                return '';
            }

            async function resolveApiError(response, fallbackMessage) {
                if (response.status === 419) {
                    return '{{ __('Session expired. Refresh this page and sign in again.') }}';
                }
                if (response.status === 401 || response.status === 403) {
                    return '{{ __('You are not authorized to perform this action.') }}';
                }
                if (response.status === 413) {
                    return '{{ __('The selected image is too large.') }}';
                }

                try {
                    var data = await response.clone().json();
                    var validationMessage = firstValidationError(data.errors);
                    if (validationMessage) {
                        return validationMessage;
                    }
                    if (data && typeof data.message === 'string' && data.message.trim() !== '') {
                        return data.message.trim();
                    }
                } catch (_) {}

                if (response.status >= 400) {
                    return fallbackMessage + ' (HTTP ' + response.status + ')';
                }
                return fallbackMessage;
            }

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
                try {
                    await window.adminApi.ensureCsrfCookie();
                    var response = await window.adminApi.request('/api/admin/banners?page=' + currentPage);
                    if (!response.ok) {
                        var apiError = await resolveApiError(response, '{{ __('Unable to load banners.') }}');
                        grid.innerHTML = '<div class="text-sm text-slate-500">' + apiError + '</div>';
                        info.textContent = apiError;
                        prevButton.disabled = true;
                        nextButton.disabled = true;
                        return;
                    }

                    var data = await response.json();
                    var list = Array.isArray(data.data) ? data.data : [];

                    grid.innerHTML = list.map(function (banner) {
                        var imageUrl = resolveImage(banner.image);
                        return `
                            <div class="rounded-2xl border border-slate-200 p-4 shadow-sm dark:border-slate-800">
                                <div class="aspect-[16/7] overflow-hidden rounded-xl bg-slate-100 dark:bg-slate-800">
                                    ${imageUrl ? `<img src="${imageUrl}" alt="Banner ${banner.id}" class="h-full w-full object-cover" />` : ''}
                                </div>
                                <div class="mt-3 flex items-center justify-between text-xs text-slate-500">
                                    <span>{{ __('ID:') }} ${banner.id} &middot; {{ __('Added By:') }} ${banner.added_by?.name ?? '--'}</span>
                                    ${window.adminCan('delete_banner') ? `<button data-banner-delete="${banner.id}" class="text-xs font-semibold text-danger-600">{{ __('Delete') }}</button>` : ''}
                                </div>
                                <div class="mt-2 space-y-1">
                                    ${banner.badge_label ? `<p class="text-[11px] font-semibold uppercase tracking-wide text-primary-600">${banner.badge_label}</p>` : ''}
                                    ${banner.title ? `<p class="text-sm font-semibold text-slate-900 dark:text-white">${banner.title}</p>` : ''}
                                    ${banner.subtitle ? `<p class="text-xs text-slate-500">${banner.subtitle}</p>` : ''}
                                </div>
                            </div>
                        `;
                    }).join('') || '<div class="text-sm text-slate-500">{{ __('No banners yet.') }}</div>';

                    info.textContent = '{{ __('Showing') }} ' + list.length + ' {{ __('banners') }}';
                    prevButton.disabled = !data.links?.prev;
                    nextButton.disabled = !data.links?.next;
                } catch (_) {
                    grid.innerHTML = '<div class="text-sm text-slate-500">{{ __('Network error. Please try again.') }}</div>';
                    info.textContent = '{{ __('Network error. Please try again.') }}';
                    prevButton.disabled = true;
                    nextButton.disabled = true;
                }
            }

            if (form) form.addEventListener('submit', async function (event) {
                event.preventDefault();
                if (!fileInput.files.length) {
                    formMessage.textContent = '{{ __('Please choose an image file.') }}';
                    if (window.adminSwalError) {
                        window.adminSwalError('{{ __('Upload failed') }}', '{{ __('Please choose an image file.') }}');
                    } else if (window.adminToast) {
                        window.adminToast('{{ __('Please choose an image file.') }}', { type: 'error' });
                    }
                    return;
                }
                var formData = new FormData();
                formData.append('image', fileInput.files[0]);
                formData.append('badge_label', badgeInput.value || '');
                formData.append('title', titleInput.value || '');
                formData.append('subtitle', subtitleInput.value || '');
                formData.append('cta_label', ctaInput.value || '');

                var response;
                try {
                    formMessage.textContent = '{{ __('Uploading...') }}';
                    await window.adminApi.ensureCsrfCookie();
                    response = await window.adminApi.request('/api/admin/banners', {
                        method: 'POST',
                        body: formData
                    });
                } catch (_) {
                    formMessage.textContent = '{{ __('Network error. Please check your connection and try again.') }}';
                    if (window.adminSwalError) {
                        window.adminSwalError('{{ __('Upload failed') }}', '{{ __('Network error. Please check your connection and try again.') }}');
                    } else if (window.adminToast) {
                        window.adminToast('{{ __('Network error. Please check your connection and try again.') }}', { type: 'error' });
                    }
                    return;
                }

                if (!response.ok) {
                    var errorMessage = await resolveApiError(response, '{{ __('Upload failed. Please try again.') }}');
                    formMessage.textContent = errorMessage;
                    if (window.adminSwalError) {
                        window.adminSwalError('{{ __('Upload failed') }}', errorMessage);
                    } else if (window.adminToast) {
                        window.adminToast(errorMessage, { type: 'error' });
                    }
                    return;
                }

                formMessage.textContent = '{{ __('Banner uploaded successfully.') }}';
                if (window.adminSwalSuccess) {
                    await window.adminSwalSuccess('{{ __('Uploaded') }}', '{{ __('Banner uploaded successfully.') }}');
                } else if (window.adminToast) {
                    window.adminToast('{{ __('Banner uploaded successfully.') }}');
                }
                form.reset();
                fileName.textContent = '{{ __('Choose banner image') }}';
                if (previewWrap && previewImage) {
                    previewImage.src = '';
                    previewWrap.classList.add('hidden');
                }
                currentPage = 1;
                loadBanners();
            });

            if (fileInput) fileInput.addEventListener('change', function () {
                var file = fileInput.files[0];
                if (window.adminValidateFileSize && file && !window.adminValidateFileSize(file, '{{ __('Banner image') }}')) {
                    fileInput.value = '';
                    fileName.textContent = '{{ __('Choose banner image') }}';
                    formMessage.textContent = '{{ __('Banner image must be 5MB or smaller.') }}';
                    if (previewWrap && previewImage) {
                        previewImage.src = '';
                        previewWrap.classList.add('hidden');
                    }
                    return;
                }
                fileName.textContent = file ? file.name : '{{ __('Choose banner image') }}';
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
                    var result = await window.adminSwalConfirm('{{ __('Delete banner?') }}', '{{ __('This will remove the banner image.') }}', '{{ __('Yes, delete it') }}');
                    confirmed = result.isConfirmed;
                } else {
                    confirmed = window.confirm('{{ __('Delete this banner?') }}');
                }
                if (!confirmed) {
                    return;
                }
                var response;
                try {
                    await window.adminApi.ensureCsrfCookie();
                    response = await window.adminApi.request('/api/admin/banners/' + bannerId, {
                        method: 'DELETE'
                    });
                } catch (_) {
                    formMessage.textContent = '{{ __('Network error. Please check your connection and try again.') }}';
                    if (window.adminSwalError) {
                        window.adminSwalError('{{ __('Delete failed') }}', '{{ __('Network error. Please check your connection and try again.') }}');
                    } else if (window.adminToast) {
                        window.adminToast('{{ __('Network error. Please check your connection and try again.') }}', { type: 'error' });
                    }
                    return;
                }

                if (!response.ok) {
                    var errorMessage = await resolveApiError(response, '{{ __('Delete failed. Please try again.') }}');
                    formMessage.textContent = errorMessage;
                    if (window.adminSwalError) {
                        window.adminSwalError('{{ __('Delete failed') }}', errorMessage);
                    } else if (window.adminToast) {
                        window.adminToast(errorMessage, { type: 'error' });
                    }
                    return;
                }

                if (window.adminSwalSuccess) {
                    await window.adminSwalSuccess('{{ __('Deleted') }}', '{{ __('Banner deleted successfully.') }}');
                } else if (window.adminToast) {
                    window.adminToast('{{ __('Banner deleted.') }}');
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
