@extends('layouts.admin')

@section('title', 'Categories')
@section('page-title', 'Categories')

@section('content')

{{-- ═══════════════════════════════════════════════════════════════════════
     INLINE STYLES — scoped to this page only
═══════════════════════════════════════════════════════════════════════ --}}
<style>
/* ── Edit-modal custom styles ─────────────────────────────────────── */
/* Simple edit modal styles */
#edit-category-modal { font-family: 'Inter', sans-serif; }
#ecm-backdrop {
    background: rgba(15,23,42,.38)!important;
    backdrop-filter: none!important;
}
#ecm-panel {
    max-width: 460px!important;
    border-radius: 12px!important;
    box-shadow: 0 18px 40px rgba(15,23,42,.2)!important;
}
#ecm-header-bar {
    background: #fff!important;
    border-bottom: 1px solid #e2e8f0!important;
    padding: 18px 20px!important;
}
#ecm-title {
    color: #0f172a!important;
    font-size: 16px!important;
}
#ecm-header-bar p {
    color: #64748b!important;
}
#ecm-close-btn {
    background: transparent!important;
    border: 1px solid #e2e8f0!important;
    color: #64748b!important;
    border-radius: 8px!important;
}
#ecm-close-btn:hover {
    background: #f8fafc!important;
}
#ecm-header-bar + div {
    padding: 20px!important;
    gap: 14px!important;
}
.ecm-label {
    color: #475569!important;
    font-size: 13px!important;
    font-weight: 600!important;
    letter-spacing: 0!important;
    text-transform: none!important;
}
.ecm-input {
    background: #fff!important;
    border: 1px solid #cbd5e1!important;
    border-radius: 8px!important;
    color: #0f172a!important;
    font-size: 14px!important;
    padding: 9px 12px!important;
}
.ecm-input:focus {
    border-color: #64748b!important;
    box-shadow: 0 0 0 2px rgba(100,116,139,.12)!important;
}
.ecm-input:disabled {
    background: #f8fafc!important;
    color: #64748b!important;
}
.ecm-select {
    appearance: auto!important;
    background-image: none!important;
    padding-right: 12px!important;
}
#ecm-dropzone {
    background: #fff!important;
    border: 1px solid #cbd5e1!important;
    border-radius: 8px!important;
    min-height: auto!important;
    padding: 12px!important;
}
#ecm-dropzone.dragover {
    background: #f8fafc!important;
    border-color: #64748b!important;
    box-shadow: none!important;
}
#ecm-img-circle {
    width: 56px!important;
    height: 56px!important;
    border-radius: 8px!important;
    background: #f8fafc!important;
    border: 1px solid #e2e8f0!important;
}
#ecm-img-icon {
    stroke: #94a3b8!important;
}
#ecm-dropzone p {
    color: #64748b!important;
}
#ecm-dropzone p:first-child {
    color: #334155!important;
}
#ecm-file-btn,
#ecm-cancel-btn,
#ecm-save-btn {
    height: 38px!important;
    border-radius: 8px!important;
    box-shadow: none!important;
    font-size: 13px!important;
    font-weight: 600!important;
    letter-spacing: 0!important;
    transform: none!important;
}
#ecm-file-btn {
    background: #f8fafc!important;
    border: 1px solid #cbd5e1!important;
    color: #334155!important;
    padding: 0 14px!important;
}
#ecm-file-btn:hover,
#ecm-cancel-btn:hover {
    background: #f1f5f9!important;
    border-color: #94a3b8!important;
}
#ecm-cancel-btn {
    background: #fff!important;
    border: 1px solid #cbd5e1!important;
    color: #475569!important;
    padding: 0 16px!important;
}
#ecm-save-btn {
    background: #1e293b!important;
    border: 1px solid #1e293b!important;
    color: #fff!important;
    padding: 0 18px!important;
}
#ecm-save-btn:hover:not(:disabled) {
    background: #334155!important;
    border-color: #334155!important;
    box-shadow: none!important;
}
#ecm-remove-img {
    background: #fff!important;
    border: 1px solid #fecaca!important;
    border-radius: 6px!important;
    color: #dc2626!important;
}
#ecm-footer {
    background: #fff!important;
    border-top: 1px solid #e2e8f0!important;
    padding: 14px 20px!important;
}
#ecm-form-error {
    border-radius: 8px!important;
}
html.dark #ecm-panel,
html.dark #ecm-header-bar,
html.dark #ecm-footer {
    background: #0f172a!important;
    border-color: #1e293b!important;
}
html.dark #ecm-title {
    color: #f8fafc!important;
}
html.dark #ecm-header-bar p,
html.dark .ecm-label {
    color: #94a3b8!important;
}
html.dark .ecm-input,
html.dark #ecm-dropzone {
    background: #111827!important;
    border-color: #334155!important;
    color: #e5e7eb!important;
}
html.dark .ecm-input:disabled,
html.dark #ecm-img-circle {
    background: #0b1120!important;
    color: #64748b!important;
}
html.dark #ecm-file-btn,
html.dark #ecm-cancel-btn,
html.dark #ecm-close-btn {
    background: #111827!important;
    border-color: #334155!important;
    color: #cbd5e1!important;
}
html.dark #ecm-save-btn {
    background: #e5e7eb!important;
    border-color: #e5e7eb!important;
    color: #0f172a!important;
}
</style>

{{-- ═══════════════════════════════════════════════════════════════════════
     PAGE CONTENT
═══════════════════════════════════════════════════════════════════════ --}}
<div class="space-y-6">
    <div class="flex flex-wrap items-center justify-between gap-4">
        <div>
            <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Category List</h2>
            <p class="text-sm text-slate-500">Organize product collections for the app catalog.</p>
        </div>
        @if (auth()->user()?->hasPermission('create_category'))
        <div class="flex items-center gap-3">
            <a href="{{ route('admin.categories.create') }}"
               class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm hover:bg-primary-700 transition-colors">
                + Add Category
            </a>
        </div>
        @endif
    </div>

    <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
        <div class="flex flex-wrap items-center justify-between gap-3">
            <div class="flex w-60 flex-wrap items-center gap-3 sm:w-auto">
                <select class="h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 sm:w-40 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-300">
                    <option>Bulk actions</option>
                    <option>Activate</option>
                    <option>Deactivate</option>
                    <option>Delete</option>
                </select>
                <button class="h-10 w-full rounded-xl border border-slate-200 bg-white px-4 text-sm font-semibold text-slate-600 sm:w-auto dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300">Apply</button>
            </div>
            <div class="relative">
                <input type="text" placeholder="Search categories"
                       class="h-10 w-60 rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                <svg class="absolute right-3 top-3 h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35m1.6-5.15a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
            </div>
        </div>

        <div class="mt-5 overflow-x-auto">
            <table class="w-full text-left text-sm">
                <thead class="text-xs uppercase tracking-widest text-slate-400">
                    <tr>
                        <th class="px-4 py-3"><input type="checkbox" class="rounded border-slate-300 text-primary-600 focus:ring-primary-500" /></th>
                        <th class="px-4 py-3">Image</th>
                        <th class="px-4 py-3">
                            <button class="inline-flex items-center gap-1 text-xs font-semibold uppercase tracking-widest text-slate-400">
                                Category
                                <svg class="h-3 w-3" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M8 9l4-4 4 4M16 15l-4 4-4-4" />
                                </svg>
                            </button>
                        </th>
                        <th class="px-4 py-3">Slug</th>
                        <th class="px-4 py-3">
                            <button class="inline-flex items-center gap-1 text-xs font-semibold uppercase tracking-widest text-slate-400">
                                Products
                                <svg class="h-3 w-3" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M8 9l4-4 4 4M16 15l-4 4-4-4" />
                                </svg>
                            </button>
                        </th>
                        <th class="px-4 py-3">Status</th>
                        <th class="px-4 py-3">Added By</th>
                        <th class="px-4 py-3 text-right">Action</th>
                    </tr>
                </thead>
                <tbody id="category-rows" class="divide-y divide-slate-200 text-slate-600 dark:divide-slate-800 dark:text-slate-300"></tbody>
            </table>
        </div>

        <div class="mt-4 flex items-center justify-between text-xs text-slate-500">
            <p id="category-pagination-info">Loading categories...</p>
            <div class="flex items-center gap-2">
                <button id="category-prev" class="rounded-lg border border-slate-200 px-3 py-1 text-slate-600 dark:border-slate-800 dark:text-slate-300">Previous</button>
                <button id="category-next" class="rounded-lg border border-slate-200 bg-slate-100 px-3 py-1 text-slate-900 dark:border-slate-800 dark:bg-slate-900">Next</button>
            </div>
        </div>
    </div>
</div>

{{-- ═══════════════════════════════════════════════════════════════════════
     EDIT CATEGORY MODAL
═══════════════════════════════════════════════════════════════════════ --}}
<div id="edit-category-modal"
     role="dialog" aria-modal="true" aria-labelledby="ecm-title"
     style="display:none; position:fixed; inset:0; z-index:9999; align-items:center; justify-content:center; padding:16px;">

    {{-- Backdrop --}}
    <div id="ecm-backdrop"
         style="position:absolute; inset:0; background:rgba(15,23,42,.38);
                opacity:0; transition:opacity .16s ease;"></div>

    {{-- Panel --}}
    <div id="ecm-panel"
         style="position:relative; width:100%; max-width:460px; border-radius:12px;
                background:#fff; border:1px solid #e2e8f0; overflow:hidden;
                box-shadow:0 18px 40px rgba(15,23,42,.2);
                opacity:0; transform:translateY(10px);
                transition:opacity .16s ease, transform .16s ease;">

        {{-- Header --}}
        <div id="ecm-header-bar" style="padding:18px 20px; border-bottom:1px solid #e2e8f0;">

            <div style="display:flex; align-items:flex-start; justify-content:space-between; position:relative;">
                <div>
                    <h3 id="ecm-title" style="font-size:16px;font-weight:700;color:#0f172a;margin:0;">Edit Category</h3>
                    <p style="font-size:12px;color:#64748b;margin:0;">Update category details.</p>
                </div>
                {{-- Close X --}}
                <button id="ecm-close-btn" aria-label="Close"
                        style="width:32px;height:32px;border-radius:8px;background:#fff;border:1px solid #e2e8f0;cursor:pointer;display:flex;align-items:center;justify-content:center;color:#64748b;transition:background .18s;flex-shrink:0;margin-top:2px;">
                    <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/>
                    </svg>
                </button>
            </div>
        </div>

        {{-- ── Body ─────────────────────────────────────────────────── --}}
        <div style="padding:24px; display:flex; flex-direction:column; gap:20px; max-height:68vh; overflow-y:auto;">

            {{-- Image drop-zone --}}
            <div>
                <label class="ecm-label">Category Image</label>
                <div id="ecm-dropzone"
                     style="position:relative; border:1px solid #cbd5e1; border-radius:8px; background:#fff;
                            padding:12px; display:flex; align-items:center; gap:16px;
                            cursor:pointer; transition:all .2s;"
                     onclick="document.getElementById('ecm-file-input').click()"
                     ondragover="event.preventDefault();this.classList.add('dragover')"
                     ondragleave="this.classList.remove('dragover')"
                     ondrop="ecmHandleDrop(event)">

                    {{-- Preview / placeholder --}}
                    <div id="ecm-img-circle"
                         style="width:56px;height:56px;border-radius:8px;overflow:hidden;flex-shrink:0;
                                background:#f8fafc;
                                display:flex;align-items:center;justify-content:center;
                                border:1px solid #e2e8f0;">
                        <img id="ecm-preview-img" src="" alt="" style="width:100%;height:100%;object-fit:cover;display:none;" />
                        <svg id="ecm-img-icon" width="28" height="28" fill="none" stroke="#94a3b8" stroke-width="1.5" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                        </svg>
                    </div>

                    <div style="flex:1; min-width:0;">
                        <p style="font-size:13px;font-weight:600;color:#334155;margin:0 0 3px;">
                            Click or drag &amp; drop to upload
                        </p>
                        <p id="ecm-file-name" style="font-size:11px;color:#94a3b8;margin:0 0 10px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                            PNG, JPG, WEBP - max 5 MB
                        </p>
                        <button id="ecm-file-btn" type="button"
                                onclick="event.stopPropagation();document.getElementById('ecm-file-input').click()">
                            Choose File
                        </button>
                        <input id="ecm-file-input" type="file" accept="image/*"
                               style="display:none;" />
                    </div>

                    {{-- Remove image --}}
                    <button id="ecm-remove-img" type="button"
                            style="display:none; position:absolute; top:10px; right:10px;
                                   width:26px;height:26px;border-radius:50%;background:#ef4444;
                                   border:none;cursor:pointer;color:#fff;font-size:14px;
                                   align-items:center;justify-content:center;"
                            title="Remove image">x</button>
                </div>
                <p id="ecm-image-error" class="ecm-error" style="display:none;">
                    <svg width="12" height="12" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/></svg>
                    <span id="ecm-image-error-text"></span>
                </p>
            </div>

            {{-- Name --}}
            <div>
                <label class="ecm-label" for="ecm-name-input">Category Name</label>
                <input id="ecm-name-input" type="text" placeholder="e.g. Fresh Beverages" class="ecm-input" autocomplete="off" />
                <p id="ecm-name-error" class="ecm-error" style="display:none;">
                    <svg width="12" height="12" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/></svg>
                    <span id="ecm-name-error-text"></span>
                </p>
            </div>

            {{-- Slug (readonly) --}}
            <div>
                <label class="ecm-label" for="ecm-slug-input">
                    Slug
                    <span style="font-size:10px;font-weight:500;color:#64748b;margin-left:6px;text-transform:none;letter-spacing:0;">auto-generated</span>
                </label>
                <div style="position:relative;">
                    <input id="ecm-slug-input" type="text" disabled class="ecm-input"
                           style="padding-left:40px;" />
                    <svg style="position:absolute;left:13px;top:50%;transform:translateY(-50%);color:#94a3b8;"
                         width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"/>
                    </svg>
                </div>
            </div>

            {{-- Status --}}
            <div>
                <label class="ecm-label" for="ecm-status-select">Status</label>
                <div style="position:relative;">
                    <select id="ecm-status-select" class="ecm-input ecm-select">
                        <option value="active">Active</option>
                        <option value="inactive">Inactive</option>
                    </select>
                </div>
            </div>

            {{-- General error --}}
            <div id="ecm-form-error"
                 style="display:none; background:#fef2f2; border:1px solid #fecaca; border-radius:10px;
                        padding:10px 14px; font-size:12px; color:#dc2626; display:none; align-items:center; gap:8px;">
                <svg width="15" height="15" fill="currentColor" viewBox="0 0 20 20" style="flex-shrink:0;">
                    <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
                </svg>
                <span id="ecm-form-error-text"></span>
            </div>
        </div>

        {{-- ── Footer ───────────────────────────────────────────────── --}}
        <div id="ecm-footer"
             style="display:flex; align-items:center; justify-content:flex-end; gap:10px;
                    padding:14px 20px; background:#fff;
                    border-top:1px solid #e2e8f0;">
            <button id="ecm-cancel-btn">Cancel</button>
            <button id="ecm-save-btn">
                <svg id="ecm-spinner"
                     style="display:none; width:15px;height:15px;animation:spin .7s linear infinite;"
                     fill="none" viewBox="0 0 24 24">
                    <circle style="opacity:.25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path style="opacity:.8" fill="currentColor" d="M4 12a8 8 0 018-8v8z"></path>
                </svg>
                Save Changes
            </button>
        </div>
    </div>
</div>

<style>
@keyframes spin { to { transform: rotate(360deg); } }
</style>

{{-- ═══════════════════════════════════════════════════════════════════════
     JAVASCRIPT
═══════════════════════════════════════════════════════════════════════ --}}
<script>
document.addEventListener('DOMContentLoaded', function () {

    /* ── Pagination state ──────────────────────────────────────────── */
    var currentPage  = 1;
    var currentQuery = '';

    var searchInput = document.querySelector('input[placeholder="Search categories"]');
    var prevButton  = document.getElementById('category-prev');
    var nextButton  = document.getElementById('category-next');
    var info        = document.getElementById('category-pagination-info');
    var rows        = document.getElementById('category-rows');

    /* ── Modal elements ────────────────────────────────────────────── */
    var modal        = document.getElementById('edit-category-modal');
    var backdrop     = document.getElementById('ecm-backdrop');
    var panel        = document.getElementById('ecm-panel');
    var nameInput    = document.getElementById('ecm-name-input');
    var slugInput    = document.getElementById('ecm-slug-input');
    var statusSel    = document.getElementById('ecm-status-select');
    var fileInput    = document.getElementById('ecm-file-input');
    var previewImg   = document.getElementById('ecm-preview-img');
    var imgIcon      = document.getElementById('ecm-img-icon');
    var fileName     = document.getElementById('ecm-file-name');
    var removeImgBtn = document.getElementById('ecm-remove-img');
    var nameErr      = document.getElementById('ecm-name-error');
    var nameErrTxt   = document.getElementById('ecm-name-error-text');
    var imageErr     = document.getElementById('ecm-image-error');
    var imageErrTxt  = document.getElementById('ecm-image-error-text');
    var formErr      = document.getElementById('ecm-form-error');
    var formErrTxt   = document.getElementById('ecm-form-error-text');
    var saveBtn      = document.getElementById('ecm-save-btn');
    var spinner      = document.getElementById('ecm-spinner');
    var closeBtn     = document.getElementById('ecm-close-btn');
    var cancelBtn    = document.getElementById('ecm-cancel-btn');

    var editingId         = null;
    var existingImageUrl  = '';

    /* ── Helpers ───────────────────────────────────────────────────── */
    function resolveImage(path) {
        if (!path) return '';
        if (path.startsWith('http') || path.startsWith('/')) return path;
        return '/' + path;
    }

    function statusBadge(status) {
        var map = {
            active:   'bg-success-50 text-success-700 dark:bg-success-500/10 dark:text-success-100',
            inactive: 'bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-300',
        };
        return '<span class="rounded-full px-2 py-1 text-xs font-semibold ' + (map[status] || map.inactive) + '">' + status + '</span>';
    }

    /* ── Error helpers ─────────────────────────────────────────────── */
    function clearErrors() {
        nameErr.style.display    = 'none';  nameErrTxt.textContent  = '';
        imageErr.style.display   = 'none';  imageErrTxt.textContent = '';
        formErr.style.display    = 'none';  formErrTxt.textContent  = '';
    }
    function showNameErr(msg)  { nameErrTxt.textContent  = msg; nameErr.style.display  = 'flex'; }
    function showImageErr(msg) { imageErrTxt.textContent = msg; imageErr.style.display = 'flex'; }
    function showFormErr(msg)  { formErrTxt.textContent  = msg; formErr.style.display  = 'flex'; }

    /* ── Image preview ─────────────────────────────────────────────── */
    function setPreview(src, label) {
        previewImg.src = src;
        previewImg.style.display = 'block';
        imgIcon.style.display    = 'none';
        fileName.textContent     = label || 'Image selected';
        removeImgBtn.style.display = 'flex';
    }
    function clearPreview() {
        previewImg.src = '';
        previewImg.style.display = 'none';
        imgIcon.style.display    = 'block';
        fileName.textContent     = 'PNG, JPG, WEBP - max 5 MB';
        removeImgBtn.style.display = 'none';
        fileInput.value = '';
        existingImageUrl = '';
    }

    fileInput.addEventListener('change', function (e) {
        var file = e.target.files[0];
        if (!file) return;
        if (file.size > 5 * 1024 * 1024) {
            showImageErr('Image must be 5 MB or smaller.');
            fileInput.value = '';
            return;
        }
        clearErrors();
        var reader = new FileReader();
        reader.onload = function (ev) { setPreview(ev.target.result, file.name); };
        reader.readAsDataURL(file);
    });

    removeImgBtn.addEventListener('click', function (e) {
        e.stopPropagation();
        clearPreview();
    });

    /* Global drag-drop handler (called from inline ondrop) */
    window.ecmHandleDrop = function (e) {
        e.preventDefault();
        document.getElementById('ecm-dropzone').classList.remove('dragover');
        var file = e.dataTransfer.files[0];
        if (!file || !file.type.startsWith('image/')) return;
        if (file.size > 5 * 1024 * 1024) { showImageErr('Image must be 5 MB or smaller.'); return; }
        clearErrors();
        var dt = new DataTransfer();
        dt.items.add(file);
        fileInput.files = dt.files;
        var reader = new FileReader();
        reader.onload = function (ev) { setPreview(ev.target.result, file.name); };
        reader.readAsDataURL(file);
    };

    /* ── Modal open / close ────────────────────────────────────────── */
    function openModal() {
        modal.style.display = 'flex';
        document.body.style.overflow = 'hidden';
        requestAnimationFrame(function () { requestAnimationFrame(function () {
            backdrop.style.opacity  = '1';
            panel.style.opacity     = '1';
            panel.style.transform   = 'translateY(0)';
        }); });
    }

    function closeModal() {
        backdrop.style.opacity  = '0';
        panel.style.opacity     = '0';
        panel.style.transform   = 'translateY(10px)';
        setTimeout(function () {
            modal.style.display  = 'none';
            document.body.style.overflow = '';
            editingId = null;
            nameInput.value = '';
            slugInput.value = '';
            clearPreview();
            clearErrors();
        }, 180);
    }

    closeBtn.addEventListener('click',  closeModal);
    cancelBtn.addEventListener('click', closeModal);
    backdrop.addEventListener('click',  closeModal);
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape' && modal.style.display === 'flex') closeModal();
    });

    /* ── Load category into modal ──────────────────────────────────── */
    async function openEditModal(id) {
        editingId = id;
        clearErrors();
        nameInput.value = '';
        slugInput.value = '';
        clearPreview();
        openModal();

        saveBtn.disabled = true;
        spinner.style.display = 'block';

        try {
            await window.adminApi.ensureCsrfCookie();
            var res = await window.adminApi.request('/api/categories/' + id);
            if (!res.ok) throw new Error('load failed');
            var payload  = await res.json();
            var cat      = payload.data || payload;

            nameInput.value  = cat.name   || '';
            slugInput.value  = cat.slug   || '';
            statusSel.value  = cat.status || 'active';

            var imgUrl = resolveImage(cat.image);
            if (imgUrl) {
                existingImageUrl = imgUrl;
                setPreview(imgUrl, cat.image.split('/').pop());
            }
        } catch (err) {
            showFormErr('Unable to load category details.');
        } finally {
            saveBtn.disabled      = false;
            spinner.style.display = 'none';
        }
    }

    /* ── Save ──────────────────────────────────────────────────────── */
    saveBtn.addEventListener('click', async function () {
        if (!editingId) return;
        clearErrors();

        var name = nameInput.value.trim();
        if (!name) { showNameErr('Category name is required.'); nameInput.focus(); return; }

        var formData = new FormData();
        formData.append('name',    name);
        formData.append('status',  statusSel.value);
        formData.append('_method', 'PUT');
        if (fileInput.files.length > 0) formData.append('image', fileInput.files[0]);

        saveBtn.disabled      = true;
        spinner.style.display = 'block';

        try {
            await window.adminApi.ensureCsrfCookie();
            var res = await window.adminApi.request('/api/categories/' + editingId, {
                method: 'POST',
                body:   formData,
            });

            if (res.ok) {
                closeModal();
                loadCategories();
                if (window.adminSwalSuccess)
                    window.adminSwalSuccess('Updated', 'Category updated successfully.');
                else if (window.adminToast)
                    window.adminToast('Category updated successfully.');
                return;
            }

            var err = await res.json();
            if (err.errors?.name) showNameErr(err.errors.name[0]);
            else showFormErr(err.message || 'Unable to update category.');
            if (window.adminSwalError)
                window.adminSwalError('Update failed', err.message || 'Unable to update category.');
        } catch (e) {
            showFormErr('Unable to update category.');
        } finally {
            saveBtn.disabled      = false;
            spinner.style.display = 'none';
        }
    });

    /* ── Load category rows ────────────────────────────────────────── */
    async function loadCategories() {
        await window.adminApi.ensureCsrfCookie();
        var res = await window.adminApi.request(
            '/api/categories?q=' + encodeURIComponent(currentQuery) + '&page=' + currentPage
        );
        if (!res.ok) {
            rows.innerHTML = '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="8">Unable to load categories.</td></tr>';
            return;
        }
        var data = await res.json();
        var list = data.data || [];

        rows.innerHTML = list.map(function (cat) {
            var imgUrl      = resolveImage(cat.image);
            var toggleLabel = cat.status === 'active' ? 'Deactivate' : 'Activate';
            return `
                <tr class="hover:bg-slate-50 dark:hover:bg-slate-800/40 transition-colors">
                    <td class="px-4 py-3"><input type="checkbox" class="rounded border-slate-300 text-primary-600 focus:ring-primary-500" /></td>
                    <td class="px-4 py-3">
                        <div class="h-10 w-10 overflow-hidden rounded-xl bg-slate-100 dark:bg-slate-800">
                            ${imgUrl ? `<img src="${imgUrl}" alt="${cat.name}" class="h-full w-full object-cover" />` : ''}
                        </div>
                    </td>
                    <td class="px-4 py-3">
                        <p class="font-semibold text-slate-900 dark:text-white">${cat.name}</p>
                    </td>
                    <td class="px-4 py-3 text-slate-500 text-xs font-mono">${cat.slug}</td>
                    <td class="px-4 py-3">${cat.products_count ?? 0}</td>
                    <td class="px-4 py-3">${statusBadge(cat.status || 'inactive')}</td>
                    <td class="px-4 py-3">${cat.added_by?.name ?? '--'}</td>
                    <td class="px-4 py-3 text-right">
                        <div class="inline-flex items-center justify-end gap-3">
                            <button data-id="${cat.id}" class="text-xs font-semibold text-slate-500 hover:text-slate-800 transition-colors js-view-category">View</button>
                            ${window.adminCan('update_category') ? `<button data-id="${cat.id}"
                                    class="text-xs font-semibold text-violet-600 hover:text-violet-800 transition-colors js-edit-category
                                           inline-flex items-center gap-1">
                                <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
                                Edit
                            </button>
                            <button data-id="${cat.id}" data-status="${cat.status || 'inactive'}"
                                    class="text-xs font-semibold text-slate-500 hover:text-slate-800 transition-colors js-toggle-category">${toggleLabel}</button>` : ''}
                            ${window.adminCan('delete_category') ? `<button data-id="${cat.id}"
                                    class="text-xs font-semibold text-red-500 hover:text-red-700 transition-colors js-delete-category">Delete</button>` : ''}
                        </div>
                    </td>
                </tr>`;
        }).join('') || '<tr><td class="px-4 py-6 text-center text-sm text-slate-500" colspan="8">No categories found.</td></tr>';

        info.textContent    = 'Showing ' + list.length + ' of ' + (data.meta?.total ?? list.length) + ' categories';
        prevButton.disabled = !data.links?.prev;
        nextButton.disabled = !data.links?.next;
    }

    /* ── Search / Pagination ───────────────────────────────────────── */
    searchInput.addEventListener('input', function (e) {
        currentQuery = e.target.value.trim();
        currentPage  = 1;
        loadCategories();
    });
    prevButton.addEventListener('click', function () {
        if (currentPage > 1) { currentPage--; loadCategories(); }
    });
    nextButton.addEventListener('click', function () {
        currentPage++;
        loadCategories();
    });

    /* ── Row delegation ────────────────────────────────────────────── */
    rows.addEventListener('click', async function (e) {
        var t = e.target.closest('button');
        if (!t) return;

        /* VIEW */
        if (t.classList.contains('js-view-category')) {
            await window.adminApi.ensureCsrfCookie();
            var res = await window.adminApi.request('/api/categories/' + t.dataset.id);
            if (!res.ok) { if (window.adminSwalError) window.adminSwalError('View failed', 'Unable to load category details.'); return; }
            var p   = await res.json();
            var cat = p.data || p;
            var imgUrl = resolveImage(cat.image);
            var html = `<div class="text-left">
                <div class="flex items-center gap-4">
                    <div class="h-20 w-20 overflow-hidden rounded-2xl border border-slate-200 bg-slate-50">
                        ${imgUrl ? `<img src="${imgUrl}" alt="${cat.name}" class="h-full w-full object-cover"/>` : '<div class="flex h-full w-full items-center justify-center text-xs text-slate-400">No image</div>'}
                    </div>
                    <div>
                        <p class="text-xs uppercase tracking-widest text-slate-400">Category</p>
                        <p class="text-lg font-semibold text-slate-900">${cat.name || '--'}</p>
                        <div class="mt-2">${statusBadge(cat.status || 'inactive')}</div>
                    </div>
                </div>
                <div class="mt-5 grid gap-3 rounded-2xl border border-slate-200 bg-slate-50 p-4 text-sm text-slate-600">
                    <div class="flex justify-between"><span class="font-semibold text-slate-500">Slug</span><span>${cat.slug || '--'}</span></div>
                    <div class="flex justify-between"><span class="font-semibold text-slate-500">Products</span><span>${cat.products_count ?? 0}</span></div>
                    <div class="flex justify-between"><span class="font-semibold text-slate-500">Created</span><span>${cat.created_at ? new Date(cat.created_at).toLocaleDateString() : '--'}</span></div>
                </div></div>`;
            if (window.Swal) window.Swal.fire({ title:'Category Details', html, confirmButtonColor:'#2563eb', width:560, padding:'1.5rem' });
        }

        /* EDIT */
        if (t.classList.contains('js-edit-category')) {
            openEditModal(t.dataset.id);
        }

        /* TOGGLE */
        if (t.classList.contains('js-toggle-category')) {
            var next = t.dataset.status === 'active' ? 'inactive' : 'active';
            await window.adminApi.ensureCsrfCookie();
            var res = await window.adminApi.request('/api/categories/' + t.dataset.id, {
                method:'PATCH', headers:{'Content-Type':'application/json'},
                body: JSON.stringify({ status: next }),
            });
            if (window.adminToast)
                window.adminToast(res.ok ? 'Category status updated.' : 'Unable to update status.', { type: res.ok ? 'success' : 'error' });
            loadCategories();
        }

        /* DELETE */
        if (t.classList.contains('js-delete-category')) {
            var confirmed = true;
            if (window.adminSwalConfirm) {
                var result = await window.adminSwalConfirm('Delete category?', 'This will remove the category from the catalog.', 'Yes, delete it');
                confirmed = result.isConfirmed;
            } else {
                confirmed = window.confirm('Delete this category?');
            }
            if (!confirmed) return;
            await window.adminApi.ensureCsrfCookie();
            var res = await window.adminApi.request('/api/categories/' + t.dataset.id, { method:'DELETE' });
            if (window.adminToast)
                window.adminToast(res.ok ? 'Category deleted.' : 'Unable to delete category.', { type: res.ok ? 'success' : 'error' });
            loadCategories();
        }
    });

    loadCategories();
});
</script>
@endsection
