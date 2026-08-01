@extends('layouts.admin')

@section('title', 'Get API – Sync Data')
@section('page-title', 'Get API / Sync Data')

@section('content')

<script>
window.apiSync = function () {
    var cats  = @json($initialCategories->values());
    var prods = @json($initialProducts->values());

    return {
        /* Settings */
        baseUrl:    @json($settings['base_url']    ?? 'http://127.0.0.1:8000'),
        apiToken:   @json($settings['api_token']   ?? ''),
        shopDomain: @json($settings['shop_domain'] ?? '127.0.0.1:8000'),

        /* Pre-loaded data stores */
        catData:  cats,
        prodData: prods,

        /* Routes */
        routes: {
            settings:       '{{ route("admin.api-sync.settings") }}',
            test:           '{{ route("admin.api-sync.test") }}',
            records:        '{{ route("admin.api-sync.records") }}',
            syncCategories: '{{ route("admin.api-sync.sync-categories") }}',
            syncProducts:   '{{ route("admin.api-sync.sync-products") }}',
            syncAll:        '{{ route("admin.api-sync.sync-all") }}',
            clearType:      '/admin/api-sync/clear/',
            deleteRecord:   '/admin/api-sync/record/',
        },

        /* UI state */
        activeTab:    'categories',
        testType:     'categories',
        saveLoading:  false,
        testLoading:  false,
        syncLoading:  false,
        tableLoading: false,
        clearLoading: false,

        /* Toast */
        toast:      null,
        toastType:  'success',
        testResult: null,

        /* Computed: current table data from the active tab's store */
        get tableData()  { return this.activeTab === 'categories' ? this.catData  : this.prodData; },
        get tableTotal() { return this.tableData.length; },

        get csrf() {
            var m = document.querySelector('meta[name=csrf-token]');
            return m ? m.content : '';
        },

        /* ── Helpers ── */
        showToast: function(msg, type) {
            var self = this;
            self.toast = msg; self.toastType = type || 'success';
            setTimeout(function() { self.toast = null; }, 4500);
        },

        post: async function(url, body) {
            var r = await fetch(url, {
                method:  'POST',
                headers: { 'Content-Type': 'application/json', 'Accept': 'application/json', 'X-CSRF-TOKEN': this.csrf },
                body:    JSON.stringify(body),
            });
            return r.json();
        },

        del: async function(url) {
            var r = await fetch(url, {
                method:  'DELETE',
                headers: { 'Accept': 'application/json', 'X-CSRF-TOKEN': this.csrf },
            });
            return r.json();
        },

        /* ── Switch tab (instant — data already in memory) ── */
        switchTab: function(type) {
            this.activeTab = type;
        },

        /* ── Refresh current tab from server ── */
        refreshTable: async function() {
            this.tableLoading = true;
            try {
                var r    = await fetch(this.routes.records + '?type=' + this.activeTab, {
                    headers: { 'Accept': 'application/json', 'X-CSRF-TOKEN': this.csrf },
                });
                var data = await r.json();
                if (data.success) {
                    if (this.activeTab === 'categories') this.catData  = data.records;
                    else                                  this.prodData = data.records;
                }
            } catch(e) {
                this.showToast('Refresh error: ' + e.message, 'error');
            } finally {
                this.tableLoading = false;
            }
        },

        /* ── Reload a specific type's store ── */
        reloadStore: async function(type) {
            try {
                var r    = await fetch(this.routes.records + '?type=' + type, {
                    headers: { 'Accept': 'application/json', 'X-CSRF-TOKEN': this.csrf },
                });
                var data = await r.json();
                if (data.success) {
                    if (type === 'categories') this.catData  = data.records;
                    else                        this.prodData = data.records;
                }
            } catch(e) { /* silent */ }
        },

        /* ── Save settings ── */
        saveSettings: async function() {
            if (!this.baseUrl) { this.showToast('POS Base URL is required.', 'error'); return; }
            this.saveLoading = true;
            try {
                var d = await this.post(this.routes.settings, {
                    base_url: this.baseUrl, api_token: this.apiToken, shop_domain: this.shopDomain,
                });
                this.showToast(d.message, d.success ? 'success' : 'error');
            } catch(e) { this.showToast(e.message, 'error'); }
            finally    { this.saveLoading = false; }
        },

        /* ── Test connection ── */
        testConnect: async function() {
            if (!this.baseUrl) { this.showToast('Enter POS Base URL first.', 'error'); return; }
            this.testLoading = true; this.testResult = null;
            try {
                var d = await this.post(this.routes.test, {
                    base_url: this.baseUrl, api_token: this.apiToken, type: this.testType,
                });
                this.testResult = d;
                this.showToast(d.message, d.success ? 'success' : 'error');
            } catch(e) {
                this.testResult = { success: false, message: e.message };
                this.showToast(e.message, 'error');
            } finally { this.testLoading = false; }
        },

        /* ── Sync from API ── */
        doSync: async function(type) {
            if (!this.baseUrl) { this.showToast('Enter POS Base URL first.', 'error'); return; }
            var labels = { categories: 'Categories', products: 'Products', all: 'All Data' };
            if (!confirm('Sync ' + (labels[type] || type) + ' from your POS API into the database?')) return;

            this.syncLoading = true;
            var urlMap = {
                categories: this.routes.syncCategories,
                products:   this.routes.syncProducts,
                all:        this.routes.syncAll,
            };
            try {
                var d = await this.post(urlMap[type], { base_url: this.baseUrl, api_token: this.apiToken });
                this.showToast(d.message, d.success ? 'success' : 'error');
                if (d.success) {
                    /* Refresh both stores so both tabs are up to date */
                    await this.reloadStore('categories');
                    await this.reloadStore('products');
                    if (type !== 'all') this.activeTab = type;
                }
            } catch(e) { this.showToast(e.message, 'error'); }
            finally    { this.syncLoading = false; }
        },

        /* ── Delete ALL records of the current tab ── */
        clearAll: async function() {
            var label = this.activeTab === 'categories' ? 'ALL categories' : 'ALL products';
            if (!confirm('Delete ' + label + ' from your local database? This cannot be undone.')) return;
            this.clearLoading = true;
            try {
                var data = await this.del(this.routes.clearType + this.activeTab);
                if (data.success) {
                    if (this.activeTab === 'categories') this.catData  = [];
                    else                                  this.prodData = [];
                    this.showToast(data.message, 'success');
                } else {
                    this.showToast(data.message, 'error');
                }
            } catch(e) { this.showToast(e.message, 'error'); }
            finally    { this.clearLoading = false; }
        },

        /* ── Delete single row ── */
        deleteRow: async function(type, id, name) {
            if (!confirm('Delete [' + name + '] from local database?')) return;
            try {
                var data = await this.del(this.routes.deleteRecord + type + '/' + id);
                if (data.success) {
                    if (type === 'categories') this.catData  = this.catData.filter(function(r) { return r.id !== id; });
                    else                        this.prodData = this.prodData.filter(function(r) { return r.id !== id; });
                    this.showToast(data.message, 'success');
                } else { this.showToast(data.message, 'error'); }
            } catch(e) { this.showToast(e.message, 'error'); }
        },

        init: function() { /* Data is pre-loaded from PHP on page render — no AJAX needed */ },
    };
};
</script>

<div x-data="apiSync()" class="space-y-6">

    {{-- ── Toast ── --}}
    <div
        x-show="toast !== null"
        x-transition:enter="transition ease-out duration-200"
        x-transition:enter-start="opacity-0 -translate-y-2"
        x-transition:enter-end="opacity-100 translate-y-0"
        x-transition:leave="transition ease-in duration-150"
        x-transition:leave-end="opacity-0"
        class="fixed right-6 top-20 z-50 flex min-w-72 max-w-sm items-center gap-3 rounded-xl px-4 py-3 shadow-xl"
        :class="toastType === 'success' ? 'bg-emerald-600 text-white' : 'bg-red-600 text-white'"
        x-cloak
    >
        <svg x-show="toastType === 'success'" class="h-5 w-5 shrink-0" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/>
        </svg>
        <svg x-show="toastType !== 'success'" class="h-5 w-5 shrink-0" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/>
        </svg>
        <p class="text-sm font-medium leading-snug" x-text="toast"></p>
    </div>

    {{-- ══════════════ Header ══════════════ --}}
    <div class="flex flex-wrap items-center justify-between gap-4 rounded-2xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
        <div>
            <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Get API / Sync Data</h2>
            <p class="mt-0.5 text-sm text-slate-500 dark:text-slate-400">
                Configure your POS API, test the connection, then sync <strong>Categories</strong> &amp; <strong>Products</strong> to your database.
            </p>
        </div>
        <span class="inline-flex items-center gap-1.5 rounded-full border border-indigo-200 bg-indigo-50 px-3 py-1 text-xs font-semibold text-indigo-700 dark:border-indigo-500/30 dark:bg-indigo-500/10 dark:text-indigo-300">
            <svg class="h-3 w-3" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z"/>
            </svg>
            Live Sync Engine
        </span>
    </div>

    {{-- ══════════════ Settings card ══════════════ --}}
    <div class="rounded-2xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900">
        <div class="flex items-center gap-3 border-b border-slate-100 px-6 py-4 dark:border-slate-800">
            <div class="flex h-8 w-8 items-center justify-center rounded-lg bg-indigo-100 dark:bg-indigo-500/10">
                <svg class="h-4 w-4 text-indigo-600 dark:text-indigo-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.356.873 2.416 2.416a1.724 1.724 0 001.065 2.573c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.873 3.356-2.416 2.416a1.724 1.724 0 00-2.573 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.356-.873-2.416-2.416a1.724 1.724 0 00-1.065-2.573c-1.756-.426-1.756-2.924 0-3.35z"/>
                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                </svg>
            </div>
            <div>
                <p class="text-sm font-semibold text-slate-900 dark:text-white">API Connection Settings</p>
                <p class="text-xs text-slate-400">Fill in the fields and save before syncing.</p>
            </div>
        </div>

        <div class="grid gap-5 p-6 sm:grid-cols-3">
            {{-- POS Base URL --}}
            <div>
                <label class="mb-1.5 block text-xs font-semibold uppercase tracking-wider text-slate-500" for="pos-base-url">
                    POS Base URL <span class="text-red-500">*</span>
                </label>
                <input id="pos-base-url" type="text" x-model="baseUrl"
                    placeholder="http://127.0.0.1:8000"
                    autocomplete="off" spellcheck="false"
                    class="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm text-slate-700 placeholder-slate-400 focus:border-indigo-500 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-200"/>
                <p class="mt-1 text-xs text-slate-400">Appends <code class="rounded bg-slate-100 px-1 dark:bg-slate-800">/categories</code> or <code class="rounded bg-slate-100 px-1 dark:bg-slate-800">/products</code></p>
            </div>

            {{-- API Token --}}
            <div>
                <label class="mb-1.5 block text-xs font-semibold uppercase tracking-wider text-slate-500" for="api-token">
                    API Token <span class="ml-1 rounded bg-slate-100 px-1.5 py-0.5 text-xs font-normal lowercase text-slate-400 dark:bg-slate-800">optional</span>
                </label>
                <div class="relative">
                    <input id="api-token" type="password" x-model="apiToken"
                        placeholder="Leave blank for public APIs"
                        autocomplete="new-password"
                        class="w-full rounded-xl border border-slate-200 bg-slate-50 py-2.5 pl-3 pr-9 text-sm text-slate-700 placeholder-slate-400 focus:border-indigo-500 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-200"
                        x-ref="tokenInput"/>
                    <button type="button" tabindex="-1"
                        class="absolute inset-y-0 right-2.5 flex items-center text-slate-400 hover:text-slate-700"
                        @click="$refs.tokenInput.type = $refs.tokenInput.type === 'password' ? 'text' : 'password'">
                        <svg class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                            <path stroke-linecap="round" stroke-linejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                        </svg>
                    </button>
                </div>
                <p class="mt-1 text-xs text-slate-400">Sent as <code class="rounded bg-slate-100 px-1 dark:bg-slate-800">Authorization: Bearer …</code></p>
            </div>

            {{-- Shop Domain --}}
            <div>
                <label class="mb-1.5 block text-xs font-semibold uppercase tracking-wider text-slate-500" for="shop-domain">Shop Domain</label>
                <input id="shop-domain" type="text" x-model="shopDomain"
                    placeholder="127.0.0.1:8000"
                    autocomplete="off" spellcheck="false"
                    class="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm text-slate-700 placeholder-slate-400 focus:border-indigo-500 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-200"/>
                <p class="mt-1 text-xs text-slate-400">Default: <code class="rounded bg-slate-100 px-1 dark:bg-slate-800">127.0.0.1:8000</code></p>
            </div>
        </div>

        {{-- Action bar --}}
        <div class="flex flex-wrap items-center gap-3 border-t border-slate-100 bg-slate-50/60 px-6 py-4 dark:border-slate-800 dark:bg-slate-800/30">
            {{-- Save --}}
            <button id="btn-save-settings" type="button" @click="saveSettings()" :disabled="saveLoading"
                class="inline-flex items-center gap-2 rounded-xl bg-slate-800 px-5 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-slate-700 active:scale-95 disabled:opacity-60 dark:bg-slate-600">
                <svg x-show="!saveLoading" class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M8 7H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-3m-1 4l-3 3m0 0l-3-3m3 3V4"/>
                </svg>
                <svg x-show="saveLoading" class="h-4 w-4 animate-spin" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"/>
                </svg>
                Save Settings
            </button>

            <div class="h-6 w-px bg-slate-200 dark:bg-slate-700"></div>

            <div class="flex items-center gap-2">
                <span class="text-xs font-medium text-slate-500">Test endpoint:</span>
                <select x-model="testType"
                    class="rounded-lg border border-slate-200 bg-white px-2.5 py-1.5 text-xs text-slate-700 focus:border-indigo-500 focus:outline-none dark:border-slate-700 dark:bg-slate-800 dark:text-slate-200">
                    <option value="categories">Categories</option>
                    <option value="products">Products</option>
                </select>
            </div>

            {{-- Test Connection --}}
            <button id="btn-test-connect" type="button" @click="testConnect()" :disabled="testLoading"
                class="inline-flex items-center gap-2 rounded-xl border-2 border-indigo-500 bg-white px-4 py-2 text-sm font-semibold text-indigo-600 shadow-sm transition hover:bg-indigo-50 active:scale-95 disabled:opacity-60 dark:border-indigo-400 dark:bg-slate-900 dark:text-indigo-400">
                <svg x-show="!testLoading" class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                </svg>
                <svg x-show="testLoading" class="h-4 w-4 animate-spin" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"/>
                </svg>
                <span x-text="testLoading ? 'Testing…' : 'Test Connection'">Test Connection</span>
            </button>

            {{-- Test badge --}}
            <template x-if="testResult !== null">
                <span class="inline-flex items-center gap-1.5 rounded-full border px-3 py-1 text-xs font-semibold"
                      :class="testResult.success ? 'border-emerald-200 bg-emerald-50 text-emerald-700' : 'border-red-200 bg-red-50 text-red-700'">
                    <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                        <path x-show="testResult.success"  stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/>
                        <path x-show="!testResult.success" stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/>
                    </svg>
                    <span x-text="testResult.success ? testResult.count + ' records found' : 'Failed'"></span>
                </span>
            </template>
        </div>
    </div>

    {{-- ══════════════ Manual Sync + Table ══════════════ --}}
    <div class="rounded-2xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900">

        {{-- Sync header --}}
        <div class="flex flex-wrap items-center justify-between gap-3 border-b border-slate-100 px-6 py-4 dark:border-slate-800">
            <div class="flex items-center gap-3">
                <div class="flex h-8 w-8 items-center justify-center rounded-lg bg-emerald-100 dark:bg-emerald-500/10">
                    <svg class="h-4 w-4 text-emerald-600 dark:text-emerald-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                    </svg>
                </div>
                <div>
                    <p class="text-sm font-semibold text-slate-900 dark:text-white">Manual Sync</p>
                    <p class="text-xs text-slate-400">Pull from the API and upsert into your local database.</p>
                </div>
            </div>
            <div class="flex flex-wrap items-center gap-2">
                <button id="btn-sync-categories" type="button" @click="doSync('categories')" :disabled="syncLoading"
                    class="inline-flex items-center gap-1.5 rounded-lg border border-slate-200 bg-slate-50 px-3 py-2 text-xs font-semibold text-slate-700 transition hover:border-indigo-300 hover:bg-indigo-50 hover:text-indigo-700 disabled:opacity-50 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-300">
                    <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16"/>
                    </svg>
                    Sync Categories
                </button>
                <button id="btn-sync-products" type="button" @click="doSync('products')" :disabled="syncLoading"
                    class="inline-flex items-center gap-1.5 rounded-lg border border-slate-200 bg-slate-50 px-3 py-2 text-xs font-semibold text-slate-700 transition hover:border-indigo-300 hover:bg-indigo-50 hover:text-indigo-700 disabled:opacity-50 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-300">
                    <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 3l8 4-8 4-8-4 8-4zm0 8l8 4-8 4-8-4 8-4z"/>
                    </svg>
                    Sync Products
                </button>
                <button id="btn-sync-all" type="button" @click="doSync('all')" :disabled="syncLoading"
                    class="inline-flex items-center gap-1.5 rounded-lg bg-indigo-600 px-4 py-2 text-xs font-semibold text-white shadow-sm transition hover:bg-indigo-700 disabled:opacity-50">
                    <svg x-show="!syncLoading" class="h-3.5 w-3.5" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                    </svg>
                    <svg x-show="syncLoading" class="h-3.5 w-3.5 animate-spin" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"/>
                    </svg>
                    Sync All
                </button>
            </div>
        </div>

        {{-- Tabs + Delete All row --}}
        <div class="flex items-center justify-between border-b border-slate-100 pl-2 pr-4 dark:border-slate-800">
            <div class="flex">
                <button type="button" @click="switchTab('categories')"
                    :class="activeTab === 'categories' ? 'border-indigo-600 text-indigo-700 dark:border-indigo-400 dark:text-indigo-300' : 'border-transparent text-slate-500 hover:text-slate-700'"
                    class="border-b-2 px-4 py-3 text-sm font-medium transition-colors">
                    <svg class="mr-1.5 inline h-4 w-4" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16"/>
                    </svg>
                    Categories
                    <span class="ml-1.5 rounded-full bg-slate-100 px-1.5 py-0.5 text-xs font-semibold text-slate-500 dark:bg-slate-800" x-text="catData.length">{{ $initialCategories->count() }}</span>
                </button>
                <button type="button" @click="switchTab('products')"
                    :class="activeTab === 'products' ? 'border-indigo-600 text-indigo-700 dark:border-indigo-400 dark:text-indigo-300' : 'border-transparent text-slate-500 hover:text-slate-700'"
                    class="border-b-2 px-4 py-3 text-sm font-medium transition-colors">
                    <svg class="mr-1.5 inline h-4 w-4" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 3l8 4-8 4-8-4 8-4zm0 8l8 4-8 4-8-4 8-4z"/>
                    </svg>
                    Products
                    <span class="ml-1.5 rounded-full bg-slate-100 px-1.5 py-0.5 text-xs font-semibold text-slate-500 dark:bg-slate-800" x-text="prodData.length">{{ $initialProducts->count() }}</span>
                </button>
            </div>

            {{-- Delete All button --}}
            <button type="button" @click="clearAll()" :disabled="clearLoading || tableData.length === 0"
                class="inline-flex items-center gap-1.5 rounded-lg border border-red-200 bg-red-50 px-3 py-1.5 text-xs font-semibold text-red-600 transition hover:bg-red-100 disabled:opacity-40 dark:border-red-500/30 dark:bg-red-500/10 dark:text-red-400"
                title="Delete ALL records of the current tab from your database">
                <svg x-show="!clearLoading" class="h-3.5 w-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                </svg>
                <svg x-show="clearLoading" class="h-3.5 w-3.5 animate-spin" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"/>
                </svg>
                Delete All
            </button>
        </div>

        {{-- Table --}}
        <div class="relative min-h-[200px] overflow-x-auto">

            {{-- Loading overlay --}}
            <div x-show="tableLoading" class="absolute inset-0 z-10 flex items-center justify-center bg-white/80 dark:bg-slate-900/80">
                <div class="flex items-center gap-2 text-sm text-slate-500">
                    <svg class="h-5 w-5 animate-spin text-indigo-600" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"/>
                    </svg>
                    Refreshing…
                </div>
            </div>

            {{-- ── CATEGORIES ── --}}
            <div x-show="activeTab === 'categories'">
                <table class="w-full text-left text-sm">
                    <thead class="border-b border-slate-100 bg-slate-50 dark:border-slate-800 dark:bg-slate-800/60">
                        <tr>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wider text-slate-400">ID</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wider text-slate-400">Name</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wider text-slate-400">Slug</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wider text-slate-400">Status</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wider text-slate-400">Products</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wider text-slate-400">Created</th>
                            <th class="px-4 py-3 text-right text-xs font-semibold uppercase tracking-wider text-slate-400">Action</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100 dark:divide-slate-800">
                        <tr x-show="catData.length === 0 && !tableLoading">
                            <td colspan="7" class="px-4 py-12 text-center">
                                <div class="flex flex-col items-center gap-2">
                                    <svg class="h-10 w-10 text-slate-200 dark:text-slate-700" fill="none" stroke="currentColor" stroke-width="1" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16"/>
                                    </svg>
                                    <p class="text-sm font-medium text-slate-500">No categories in database</p>
                                    <p class="text-xs text-slate-400">Click <strong>Sync Categories</strong> to import from your POS API.</p>
                                </div>
                            </td>
                        </tr>
                        <template x-for="row in catData" :key="row.id">
                            <tr class="transition hover:bg-slate-50 dark:hover:bg-slate-800/40">
                                <td class="px-4 py-3 font-mono text-xs text-slate-400" x-text="row.id"></td>
                                <td class="px-4 py-3 font-medium text-slate-800 dark:text-slate-200" x-text="row.name"></td>
                                <td class="max-w-[160px] truncate px-4 py-3 font-mono text-xs text-slate-500" x-text="row.slug"></td>
                                <td class="px-4 py-3">
                                    <span class="rounded-full px-2 py-0.5 text-xs font-semibold"
                                          :class="row.status === 'active' ? 'bg-emerald-50 text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-300' : 'bg-slate-100 text-slate-500'"
                                          x-text="row.status"></span>
                                </td>
                                <td class="px-4 py-3 text-slate-600 dark:text-slate-300" x-text="row.products_count"></td>
                                <td class="px-4 py-3 text-xs text-slate-400" x-text="row.created_at"></td>
                                <td class="px-4 py-3 text-right">
                                    <button type="button" @click="deleteRow('categories', row.id, row.name)"
                                        class="inline-flex items-center gap-1 rounded-lg border border-red-200 bg-red-50 px-2.5 py-1 text-xs font-semibold text-red-600 transition hover:bg-red-100 dark:border-red-500/30 dark:bg-red-500/10 dark:text-red-400">
                                        <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                                        </svg>
                                        Delete
                                    </button>
                                </td>
                            </tr>
                        </template>
                    </tbody>
                </table>
            </div>

            {{-- ── PRODUCTS ── --}}
            <div x-show="activeTab === 'products'">
                <table class="w-full text-left text-sm">
                    <thead class="border-b border-slate-100 bg-slate-50 dark:border-slate-800 dark:bg-slate-800/60">
                        <tr>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wider text-slate-400">ID</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wider text-slate-400">Name</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wider text-slate-400">SKU</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wider text-slate-400">Category</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wider text-slate-400">Brand</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wider text-slate-400">Price</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wider text-slate-400">Stock</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wider text-slate-400">Status</th>
                            <th class="px-4 py-3 text-xs font-semibold uppercase tracking-wider text-slate-400">Created</th>
                            <th class="px-4 py-3 text-right text-xs font-semibold uppercase tracking-wider text-slate-400">Action</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100 dark:divide-slate-800">
                        <tr x-show="prodData.length === 0 && !tableLoading">
                            <td colspan="10" class="px-4 py-12 text-center">
                                <div class="flex flex-col items-center gap-2">
                                    <svg class="h-10 w-10 text-slate-200 dark:text-slate-700" fill="none" stroke="currentColor" stroke-width="1" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 3l8 4-8 4-8-4 8-4zm0 8l8 4-8 4-8-4 8-4z"/>
                                    </svg>
                                    <p class="text-sm font-medium text-slate-500">No products in database</p>
                                    <p class="text-xs text-slate-400">Click <strong>Sync Products</strong> to import from your POS API.</p>
                                </div>
                            </td>
                        </tr>
                        <template x-for="row in prodData" :key="row.id">
                            <tr class="transition hover:bg-slate-50 dark:hover:bg-slate-800/40">
                                <td class="px-4 py-3 font-mono text-xs text-slate-400" x-text="row.id"></td>
                                <td class="max-w-[160px] truncate px-4 py-3 font-medium text-slate-800 dark:text-slate-200" x-text="row.name"></td>
                                <td class="px-4 py-3 font-mono text-xs text-slate-500" x-text="row.sku"></td>
                                <td class="px-4 py-3 text-slate-500" x-text="row.category"></td>
                                <td class="px-4 py-3 text-slate-500" x-text="row.brand"></td>
                                <td class="px-4 py-3 text-slate-700 dark:text-slate-300" x-text="'$' + Number(row.price).toLocaleString()"></td>
                                <td class="px-4 py-3">
                                    <span class="font-semibold"
                                          :class="Number(row.stock) <= 0 ? 'text-red-500' : Number(row.stock) < 5 ? 'text-amber-500' : 'text-emerald-600'"
                                          x-text="row.stock"></span>
                                </td>
                                <td class="px-4 py-3">
                                    <span class="rounded-full px-2 py-0.5 text-xs font-semibold"
                                          :class="row.status === 'active' ? 'bg-emerald-50 text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-300' : 'bg-slate-100 text-slate-500'"
                                          x-text="row.status"></span>
                                </td>
                                <td class="px-4 py-3 text-xs text-slate-400" x-text="row.created_at"></td>
                                <td class="px-4 py-3 text-right">
                                    <button type="button" @click="deleteRow('products', row.id, row.name)"
                                        class="inline-flex items-center gap-1 rounded-lg border border-red-200 bg-red-50 px-2.5 py-1 text-xs font-semibold text-red-600 transition hover:bg-red-100 dark:border-red-500/30 dark:bg-red-500/10 dark:text-red-400">
                                        <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                                        </svg>
                                        Delete
                                    </button>
                                </td>
                            </tr>
                        </template>
                    </tbody>
                </table>
            </div>

            {{-- Footer --}}
            <div class="flex items-center justify-between border-t border-slate-100 px-6 py-3 dark:border-slate-800">
                <p class="text-xs text-slate-400">
                    Showing <strong class="text-slate-600 dark:text-slate-300" x-text="tableTotal">0</strong> local records
                </p>
                <button type="button" @click="refreshTable()" :disabled="tableLoading"
                    class="inline-flex items-center gap-1.5 rounded-lg border border-slate-200 bg-slate-50 px-3 py-1.5 text-xs font-medium text-slate-600 transition hover:bg-slate-100 disabled:opacity-50 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-300">
                    <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                    </svg>
                    Refresh
                </button>
            </div>
        </div>
    </div>

</div>
@endsection
