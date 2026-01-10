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
    </body>
</html>
