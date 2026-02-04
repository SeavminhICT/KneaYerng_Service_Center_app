<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}" class="scroll-smooth">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="csrf-token" content="{{ csrf_token() }}">

        <title>@yield('title', 'Admin') · {{ config('app.name', 'Laravel') }}</title>

        <link rel="preconnect" href="https://fonts.bunny.net">
        <link href="https://fonts.bunny.net/css?family=inter:400,500,600,700&display=swap" rel="stylesheet" />

        <script>
            (function () {
                var stored = localStorage.getItem('theme');
                if (stored === 'dark') {
                    document.documentElement.classList.add('dark');
                }
            })();
        </script>

        @vite(['resources/css/app.css', 'resources/js/app.js'])
    </head>
    <body class="font-sans antialiased" x-data="{ sidebarOpen: false, theme: (localStorage.getItem('theme') || 'light') }" x-init="document.documentElement.classList.toggle('dark', theme === 'dark')">
        <div class="min-h-screen bg-slate-50 text-slate-900 dark:bg-slate-950 dark:text-slate-100">
            <div class="fixed inset-0 z-30 bg-slate-900/40 backdrop-blur-sm lg:hidden" x-show="sidebarOpen" x-transition.opacity x-cloak @click="sidebarOpen = false"></div>

            <x-admin.sidebar />

            <div class="lg:pl-72">
                <x-admin.topbar />

                <main class="px-6 pb-24 pt-24 lg:px-10">
                    @yield('content')
                </main>

                <x-admin.footer />
            </div>
        </div>

        <div id="admin-toast-container" class="pointer-events-none fixed right-6 top-6 z-50 flex w-full max-w-sm flex-col gap-3"></div>

        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

        <script>
            (function () {
                function getCookie(name) {
                    var match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
                    return match ? decodeURIComponent(match[2]) : null;
                }

                async function ensureCsrfCookie() {
                    await fetch('/sanctum/csrf-cookie', { credentials: 'include' });
                }

                async function apiRequest(url, options) {
                    var opts = options || {};
                    var headers = Object.assign({ 'Accept': 'application/json' }, opts.headers || {});
                    var token = getCookie('XSRF-TOKEN');
                    if (token) {
                        headers['X-XSRF-TOKEN'] = token;
                    }
                    return fetch(url, Object.assign({ credentials: 'include' }, opts, { headers: headers }));
                }

                window.adminApi = {
                    ensureCsrfCookie: ensureCsrfCookie,
                    request: apiRequest,
                };
            })();
        </script>

        <script>
            (function () {
                var container = document.getElementById('admin-toast-container');
                if (!container) {
                    return;
                }

                function removeToast(toast, delay) {
                    toast.classList.add('opacity-0', 'translate-y-2');
                    setTimeout(function () {
                        if (toast.parentNode) {
                            toast.parentNode.removeChild(toast);
                        }
                    }, delay);
                }

                function showToast(message, options) {
                    var opts = options || {};
                    var type = opts.type || 'success';
                    var duration = typeof opts.duration === 'number' ? opts.duration : 3200;

                    var toast = document.createElement('div');
                    var baseClass = 'pointer-events-auto flex w-full items-start gap-3 rounded-xl border px-4 py-3 text-sm shadow-xl backdrop-blur transform transition duration-200 ease-out opacity-0 translate-y-2';
                    var typeClass = type === 'error'
                        ? 'bg-danger-50 border-danger-100 text-danger-700 dark:bg-danger-500/10 dark:border-danger-500/40 dark:text-danger-100'
                        : 'bg-success-50 border-success-50 text-success-700 dark:bg-success-500/10 dark:border-success-500/40 dark:text-success-100';
                    toast.className = baseClass + ' ' + typeClass;
                    toast.setAttribute('role', type === 'error' ? 'alert' : 'status');

                    var text = document.createElement('div');
                    text.className = 'flex-1 font-semibold';
                    text.textContent = message;

                    var close = document.createElement('button');
                    close.type = 'button';
                    close.className = 'text-xs font-semibold uppercase tracking-widest text-slate-500 hover:text-slate-700 dark:text-slate-300 dark:hover:text-slate-100';
                    close.textContent = 'Close';
                    close.addEventListener('click', function () {
                        removeToast(toast, 200);
                    });

                    toast.appendChild(text);
                    toast.appendChild(close);
                    container.appendChild(toast);

                    requestAnimationFrame(function () {
                        toast.classList.remove('opacity-0', 'translate-y-2');
                        toast.classList.add('opacity-100', 'translate-y-0');
                    });

                    setTimeout(function () {
                        removeToast(toast, 200);
                    }, duration);
                }

                function storeToast(payload) {
                    try {
                        localStorage.setItem('adminToast', JSON.stringify(payload));
                    } catch (error) {
                        return;
                    }
                }

                function consumeToast() {
                    try {
                        var raw = localStorage.getItem('adminToast');
                        if (!raw) {
                            return;
                        }
                        localStorage.removeItem('adminToast');
                        var payload = JSON.parse(raw);
                        if (payload && payload.message) {
                            showToast(payload.message, { type: payload.type || 'success' });
                        }
                    } catch (error) {
                        localStorage.removeItem('adminToast');
                    }
                }

                window.adminToast = showToast;
                window.adminToastStore = storeToast;
                window.adminMaxUploadBytes = 5 * 1024 * 1024;
                window.adminValidateFileSize = function (file, label) {
                    if (!file) {
                        return true;
                    }
                    if (file.size <= window.adminMaxUploadBytes) {
                        return true;
                    }
                    var message = (label || 'File') + ' must be 5MB or smaller.';
                    if (window.adminToast) {
                        window.adminToast(message, { type: 'error' });
                    }
                    return false;
                };
                consumeToast();
            })();
        </script>

        <script>
            (function () {
                if (!window.Swal) {
                    return;
                }

                function storeAlert(payload) {
                    try {
                        localStorage.setItem('adminSwal', JSON.stringify(payload));
                    } catch (error) {
                        return;
                    }
                }

                function consumeAlert() {
                    try {
                        var raw = localStorage.getItem('adminSwal');
                        if (!raw) {
                            return;
                        }
                        localStorage.removeItem('adminSwal');
                        var payload = JSON.parse(raw);
                        if (payload) {
                            window.Swal.fire(payload);
                        }
                    } catch (error) {
                        localStorage.removeItem('adminSwal');
                    }
                }

                window.adminSwalStore = storeAlert;
                window.adminSwalSuccess = function (title, text) {
                    return window.Swal.fire({
                        icon: 'success',
                        title: title || 'Success',
                        text: text || '',
                        confirmButtonColor: '#2563eb',
                    });
                };
                window.adminSwalError = function (title, text) {
                    return window.Swal.fire({
                        icon: 'error',
                        title: title || 'Error',
                        text: text || '',
                        confirmButtonColor: '#dc2626',
                    });
                };
                window.adminSwalConfirm = function (title, text, confirmText) {
                    return window.Swal.fire({
                        icon: 'warning',
                        title: title || 'Are you sure?',
                        text: text || 'This action cannot be undone.',
                        showCancelButton: true,
                        confirmButtonColor: '#dc2626',
                        cancelButtonColor: '#64748b',
                        confirmButtonText: confirmText || 'Yes, delete it',
                    });
                };

                consumeAlert();
            })();
        </script>
    </body>
</html>
