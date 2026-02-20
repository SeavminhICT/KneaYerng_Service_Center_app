@extends('layouts.admin')

@section('title', 'Reports')
@section('page-title', 'Reports')

@section('content')
    <div class="space-y-6">
        <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex flex-col gap-3 lg:flex-row lg:items-center lg:justify-between">
                <div>
                    <h2 class="text-lg font-semibold text-slate-900 dark:text-white">Reports</h2>
                    <p class="text-sm text-slate-500">Generate insights for sales, inventory, and customer activity.</p>
                </div>
                <button id="report-refresh" class="inline-flex h-10 items-center rounded-xl bg-primary-600 px-4 text-sm font-semibold text-white shadow-sm">Refresh</button>
            </div>

            <div class="mt-5 grid gap-4 lg:grid-cols-12">
                <div class="lg:col-span-3">
                    <label class="text-xs font-semibold uppercase tracking-widest text-slate-400">Date Range</label>
                    <select id="report-preset" class="mt-2 h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200">
                        <option value="last_7_days">Last 7 days</option>
                        <option value="last_30_days" selected>Last 30 days</option>
                        <option value="last_90_days">Last 90 days</option>
                        <option value="this_month">This month</option>
                        <option value="last_month">Last month</option>
                        <option value="year_to_date">Year to date</option>
                        <option value="custom">Custom range</option>
                    </select>
                </div>
                <div id="custom-range" class="hidden grid gap-3 lg:col-span-5 lg:grid-cols-2">
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400">Start</label>
                        <input id="report-start" type="date" class="mt-2 h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                    <div>
                        <label class="text-xs font-semibold uppercase tracking-widest text-slate-400">End</label>
                        <input id="report-end" type="date" class="mt-2 h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    </div>
                </div>
                <div class="lg:col-span-2">
                    <label class="text-xs font-semibold uppercase tracking-widest text-slate-400">Low Stock Threshold</label>
                    <input id="report-threshold" type="number" min="0" value="10" class="mt-2 h-10 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 text-sm text-slate-600 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                </div>
                <div class="lg:col-span-2">
                    <label class="text-xs font-semibold uppercase tracking-widest text-slate-400">Export Formats</label>
                    <div class="mt-2 flex items-center gap-3 text-sm text-slate-600 dark:text-slate-300">
                        <label class="inline-flex items-center gap-2">
                            <input id="format-csv" type="checkbox" class="rounded border-slate-300 text-primary-600 focus:ring-primary-500" checked />
                            CSV
                        </label>
                        <label class="inline-flex items-center gap-2">
                            <input id="format-pdf" type="checkbox" class="rounded border-slate-300 text-primary-600 focus:ring-primary-500" checked />
                            PDF
                        </label>
                    </div>
                </div>
            </div>
        </div>

        <div class="grid gap-6 xl:grid-cols-3">
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex items-start justify-between gap-4">
                    <div>
                        <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Sales Report</h3>
                        <p id="sales-range" class="mt-1 text-xs text-slate-500">Range: --</p>
                    </div>
                    <button data-report="sales" class="report-generate rounded-xl bg-primary-600 px-4 py-2 text-xs font-semibold text-white">Generate</button>
                </div>
                <div class="mt-4 grid gap-4 sm:grid-cols-2">
                    <div class="rounded-xl border border-slate-200 bg-slate-50 p-4 dark:border-slate-800 dark:bg-slate-950/40">
                        <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Total Sales</p>
                        <p id="sales-total" class="mt-2 text-xl font-semibold text-slate-900 dark:text-white">--</p>
                    </div>
                    <div class="rounded-xl border border-slate-200 bg-slate-50 p-4 dark:border-slate-800 dark:bg-slate-950/40">
                        <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Total Orders</p>
                        <p id="sales-orders" class="mt-2 text-xl font-semibold text-slate-900 dark:text-white">--</p>
                    </div>
                    <div class="rounded-xl border border-slate-200 bg-slate-50 p-4 dark:border-slate-800 dark:bg-slate-950/40">
                        <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Average Order</p>
                        <p id="sales-avg" class="mt-2 text-xl font-semibold text-slate-900 dark:text-white">--</p>
                    </div>
                    <div class="rounded-xl border border-slate-200 bg-slate-50 p-4 dark:border-slate-800 dark:bg-slate-950/40">
                        <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Paid Orders</p>
                        <p id="sales-paid" class="mt-2 text-xl font-semibold text-slate-900 dark:text-white">--</p>
                    </div>
                </div>
                <p class="mt-4 text-xs text-slate-500"><span class="font-semibold text-slate-700 dark:text-slate-200">Top Items:</span> <span id="sales-top">--</span></p>
            </div>

            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex items-start justify-between gap-4">
                    <div>
                        <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Inventory Report</h3>
                        <p id="inventory-range" class="mt-1 text-xs text-slate-500">Range: --</p>
                    </div>
                    <button data-report="inventory" class="report-generate rounded-xl border border-slate-200 bg-white px-4 py-2 text-xs font-semibold text-slate-600 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300">Generate</button>
                </div>
                <div class="mt-4 grid gap-4 sm:grid-cols-2">
                    <div class="rounded-xl border border-slate-200 bg-slate-50 p-4 dark:border-slate-800 dark:bg-slate-950/40">
                        <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Products</p>
                        <p id="inventory-products" class="mt-2 text-xl font-semibold text-slate-900 dark:text-white">--</p>
                    </div>
                    <div class="rounded-xl border border-slate-200 bg-slate-50 p-4 dark:border-slate-800 dark:bg-slate-950/40">
                        <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Accessories</p>
                        <p id="inventory-accessories" class="mt-2 text-xl font-semibold text-slate-900 dark:text-white">--</p>
                    </div>
                    <div class="rounded-xl border border-slate-200 bg-slate-50 p-4 dark:border-slate-800 dark:bg-slate-950/40">
                        <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Parts</p>
                        <p id="inventory-parts" class="mt-2 text-xl font-semibold text-slate-900 dark:text-white">--</p>
                    </div>
                    <div class="rounded-xl border border-slate-200 bg-slate-50 p-4 dark:border-slate-800 dark:bg-slate-950/40">
                        <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Low Stock</p>
                        <p id="inventory-low" class="mt-2 text-xl font-semibold text-slate-900 dark:text-white">--</p>
                    </div>
                </div>
                <div class="mt-4">
                    <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Low Stock Items</p>
                    <div id="inventory-low-list" class="mt-2 space-y-1 text-xs text-slate-500">--</div>
                </div>
                <p class="mt-4 text-xs text-slate-500"><span class="font-semibold text-slate-700 dark:text-slate-200">Top Movers:</span> <span id="inventory-movers">--</span></p>
            </div>

            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
                <div class="flex items-start justify-between gap-4">
                    <div>
                        <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Customer Report</h3>
                        <p id="customers-range" class="mt-1 text-xs text-slate-500">Range: --</p>
                    </div>
                    <button data-report="customers" class="report-generate rounded-xl border border-slate-200 bg-white px-4 py-2 text-xs font-semibold text-slate-600 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300">Generate</button>
                </div>
                <div class="mt-4 grid gap-4 sm:grid-cols-2">
                    <div class="rounded-xl border border-slate-200 bg-slate-50 p-4 dark:border-slate-800 dark:bg-slate-950/40">
                        <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Total Customers</p>
                        <p id="customers-total" class="mt-2 text-xl font-semibold text-slate-900 dark:text-white">--</p>
                    </div>
                    <div class="rounded-xl border border-slate-200 bg-slate-50 p-4 dark:border-slate-800 dark:bg-slate-950/40">
                        <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">New Customers</p>
                        <p id="customers-new" class="mt-2 text-xl font-semibold text-slate-900 dark:text-white">--</p>
                    </div>
                    <div class="rounded-xl border border-slate-200 bg-slate-50 p-4 dark:border-slate-800 dark:bg-slate-950/40">
                        <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Active Customers</p>
                        <p id="customers-active" class="mt-2 text-xl font-semibold text-slate-900 dark:text-white">--</p>
                    </div>
                    <div class="rounded-xl border border-slate-200 bg-slate-50 p-4 dark:border-slate-800 dark:bg-slate-950/40">
                        <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Repeat Customers</p>
                        <p id="customers-repeat" class="mt-2 text-xl font-semibold text-slate-900 dark:text-white">--</p>
                    </div>
                </div>
                <p class="mt-4 text-xs text-slate-500"><span class="font-semibold text-slate-700 dark:text-slate-200">Top Customers:</span> <span id="customers-top">--</span></p>
            </div>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex items-center justify-between gap-3">
                <h3 class="text-sm font-semibold text-slate-900 dark:text-white">Recent Exports</h3>
                <button id="exports-refresh" class="rounded-xl border border-slate-200 px-3 py-1 text-xs font-semibold text-slate-600 dark:border-slate-800 dark:text-slate-300">Refresh</button>
            </div>
            <div id="recent-exports" class="mt-4 space-y-3 text-sm text-slate-600 dark:text-slate-300">
                <p class="text-xs text-slate-500">No exports generated yet.</p>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var presetSelect = document.getElementById('report-preset');
            var customRange = document.getElementById('custom-range');
            var startInput = document.getElementById('report-start');
            var endInput = document.getElementById('report-end');
            var thresholdInput = document.getElementById('report-threshold');
            var refreshButton = document.getElementById('report-refresh');
            var exportRefresh = document.getElementById('exports-refresh');
            var csvToggle = document.getElementById('format-csv');
            var pdfToggle = document.getElementById('format-pdf');
            var generateButtons = Array.prototype.slice.call(document.querySelectorAll('.report-generate'));
            var currencyFormatter = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });

            var salesRange = document.getElementById('sales-range');
            var salesTotal = document.getElementById('sales-total');
            var salesOrders = document.getElementById('sales-orders');
            var salesAvg = document.getElementById('sales-avg');
            var salesPaid = document.getElementById('sales-paid');
            var salesTop = document.getElementById('sales-top');

            var inventoryRange = document.getElementById('inventory-range');
            var inventoryProducts = document.getElementById('inventory-products');
            var inventoryAccessories = document.getElementById('inventory-accessories');
            var inventoryParts = document.getElementById('inventory-parts');
            var inventoryLow = document.getElementById('inventory-low');
            var inventoryLowList = document.getElementById('inventory-low-list');
            var inventoryMovers = document.getElementById('inventory-movers');

            var customersRange = document.getElementById('customers-range');
            var customersTotal = document.getElementById('customers-total');
            var customersNew = document.getElementById('customers-new');
            var customersActive = document.getElementById('customers-active');
            var customersRepeat = document.getElementById('customers-repeat');
            var customersTop = document.getElementById('customers-top');

            var exportsContainer = document.getElementById('recent-exports');

            function isCustomRange() {
                return presetSelect.value === 'custom';
            }

            function isCustomRangeValid() {
                if (!isCustomRange()) {
                    return true;
                }
                return Boolean(startInput.value && endInput.value);
            }

            function updateCustomRangeVisibility() {
                customRange.classList.toggle('hidden', !isCustomRange());
            }

            function updateActionState() {
                var enabled = isCustomRangeValid();
                refreshButton.disabled = !enabled;
                generateButtons.forEach(function (button) {
                    button.disabled = !enabled;
                });
            }

            function buildParams() {
                var params = new URLSearchParams();
                params.set('preset', presetSelect.value);
                if (isCustomRange() && startInput.value && endInput.value) {
                    params.set('start', startInput.value);
                    params.set('end', endInput.value);
                }
                if (thresholdInput && thresholdInput.value !== '') {
                    params.set('threshold', thresholdInput.value);
                }
                return params;
            }

            function selectedFormats() {
                var formats = [];
                if (csvToggle && csvToggle.checked) {
                    formats.push('csv');
                }
                if (pdfToggle && pdfToggle.checked) {
                    formats.push('pdf');
                }
                return formats;
            }

            function rangeLabel(range) {
                if (!range) {
                    return '--';
                }
                return range.label + ' (' + range.start + ' to ' + range.end + ')';
            }

            function renderSales(data) {
                salesRange.textContent = 'Range: ' + rangeLabel(data.range);
                salesTotal.textContent = currencyFormatter.format(data.metrics?.total_sales || 0);
                salesOrders.textContent = data.metrics?.total_orders ?? 0;
                salesAvg.textContent = currencyFormatter.format(data.metrics?.average_order_value || 0);
                salesPaid.textContent = data.metrics?.paid_orders ?? 0;
                if (data.top_items && data.top_items.length) {
                    salesTop.textContent = data.top_items.map(function (item) {
                        return item.name + ' (' + item.quantity + ')';
                    }).join(', ');
                } else {
                    salesTop.textContent = 'No sales data.';
                }
            }

            function renderInventory(data) {
                inventoryRange.textContent = 'Range: ' + rangeLabel(data.range);
                inventoryProducts.textContent = data.metrics?.total_products ?? 0;
                inventoryAccessories.textContent = data.metrics?.total_accessories ?? 0;
                inventoryParts.textContent = data.metrics?.total_parts ?? 0;
                inventoryLow.textContent = data.metrics?.low_stock_count ?? 0;

                if (data.low_stock && data.low_stock.length) {
                    inventoryLowList.innerHTML = data.low_stock.map(function (item) {
                        var sku = item.sku ? ' · ' + item.sku : '';
                        return '<div class="flex items-center justify-between gap-3"><span>' + item.name + ' (' + item.type + ')' + sku + '</span><span class="font-semibold text-slate-700 dark:text-slate-200">' + item.stock + '</span></div>';
                    }).join('');
                } else {
                    inventoryLowList.innerHTML = '<p class="text-xs text-slate-500">No low stock items.</p>';
                }

                if (data.top_movers && data.top_movers.length) {
                    inventoryMovers.textContent = data.top_movers.map(function (item) {
                        return item.name + ' (' + item.quantity + ')';
                    }).join(', ');
                } else {
                    inventoryMovers.textContent = 'No movement data.';
                }
            }

            function renderCustomers(data) {
                customersRange.textContent = 'Range: ' + rangeLabel(data.range);
                customersTotal.textContent = data.metrics?.total_customers ?? 0;
                customersNew.textContent = data.metrics?.new_customers ?? 0;
                customersActive.textContent = data.metrics?.active_customers ?? 0;
                customersRepeat.textContent = data.metrics?.repeat_customers ?? 0;

                if (data.top_customers && data.top_customers.length) {
                    customersTop.textContent = data.top_customers.map(function (customer) {
                        return customer.name + ' (' + customer.orders_count + ')';
                    }).join(', ');
                } else {
                    customersTop.textContent = 'No customer activity.';
                }
            }

            async function loadReport(type) {
                var params = buildParams();
                var response = await window.adminApi.request('/api/admin/reports/' + type + '?' + params.toString());
                if (!response.ok) {
                    return;
                }
                var data = await response.json();
                if (type === 'sales') {
                    renderSales(data);
                } else if (type === 'inventory') {
                    renderInventory(data);
                } else {
                    renderCustomers(data);
                }
            }

            function formatBytes(bytes) {
                if (!bytes && bytes !== 0) {
                    return '';
                }
                var sizes = ['B', 'KB', 'MB', 'GB'];
                if (bytes === 0) {
                    return '0 B';
                }
                var i = Math.min(Math.floor(Math.log(bytes) / Math.log(1024)), sizes.length - 1);
                var value = bytes / Math.pow(1024, i);
                return value.toFixed(1) + ' ' + sizes[i];
            }

            function titleCase(value) {
                if (!value) {
                    return '';
                }
                return value.charAt(0).toUpperCase() + value.slice(1);
            }

            async function loadExports() {
                var response = await window.adminApi.request('/api/admin/reports/exports');
                if (!response.ok) {
                    return;
                }
                var data = await response.json();
                var exports = data.exports || [];
                if (!exports.length) {
                    exportsContainer.innerHTML = '<p class="text-xs text-slate-500">No exports generated yet.</p>';
                    return;
                }

                exportsContainer.innerHTML = exports.map(function (item) {
                    var generated = item.generated_at ? new Date(item.generated_at).toLocaleString() : '--';
                    var range = item.range ? item.range.start + ' to ' + item.range.end : '';
                    var size = formatBytes(item.size);
                    var label = titleCase(item.type) + ' Report (' + item.format.toUpperCase() + ')';
                    var meta = [generated, range, size].filter(Boolean).join(' · ');
                    return (
                        '<div class="flex items-center justify-between gap-4 rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 dark:border-slate-800 dark:bg-slate-950/40">'
                        + '<div>'
                        + '<p class="text-sm font-semibold text-slate-900 dark:text-white">' + label + '</p>'
                        + '<p class="text-xs text-slate-500">' + meta + '</p>'
                        + '</div>'
                        + '<a class="text-xs font-semibold text-primary-600" href="' + item.download_url + '">Download</a>'
                        + '</div>'
                    );
                }).join('');
            }

            async function generateExport(type) {
                var formats = selectedFormats();
                if (!formats.length) {
                    if (window.adminToast) {
                        window.adminToast('Select at least one export format.', { type: 'error' });
                    }
                    return;
                }
                if (!isCustomRangeValid()) {
                    if (window.adminToast) {
                        window.adminToast('Select a valid custom date range.', { type: 'error' });
                    }
                    return;
                }

                var payloadBase = {
                    type: type,
                    preset: presetSelect.value,
                    start: startInput.value || null,
                    end: endInput.value || null,
                    threshold: thresholdInput.value || null
                };

                await window.adminApi.ensureCsrfCookie();

                for (var i = 0; i < formats.length; i += 1) {
                    var format = formats[i];
                    var response = await window.adminApi.request('/api/admin/reports/export', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(Object.assign({}, payloadBase, { format: format }))
                    });

                    if (response.ok) {
                        var data = await response.json();
                        if (data.download_url) {
                            window.open(data.download_url, '_blank');
                        }
                    }
                }

                loadExports();
            }

            function refreshAll() {
                if (!isCustomRangeValid()) {
                    return;
                }
                loadReport('sales');
                loadReport('inventory');
                loadReport('customers');
            }

            presetSelect.addEventListener('change', function () {
                updateCustomRangeVisibility();
                updateActionState();
                refreshAll();
            });
            startInput.addEventListener('change', function () {
                updateActionState();
                refreshAll();
            });
            endInput.addEventListener('change', function () {
                updateActionState();
                refreshAll();
            });
            thresholdInput.addEventListener('change', function () {
                refreshAll();
            });
            refreshButton.addEventListener('click', function () {
                refreshAll();
            });
            exportRefresh.addEventListener('click', function () {
                loadExports();
            });
            generateButtons.forEach(function (button) {
                button.addEventListener('click', function () {
                    var type = button.dataset.report;
                    if (type) {
                        generateExport(type);
                    }
                });
            });

            updateCustomRangeVisibility();
            updateActionState();
            refreshAll();
            loadExports();
        });
    </script>
@endsection
