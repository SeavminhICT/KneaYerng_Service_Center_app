<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="csrf-token" content="{{ csrf_token() }}">

        <title>{{ config('app.name', 'Laravel') }}</title>

        <!-- Fonts -->
        <link rel="preconnect" href="https://fonts.bunny.net">
        <link href="https://fonts.bunny.net/css?family=inter:400,500,600,700&display=swap" rel="stylesheet" />

        <!-- Scripts -->
        @vite(['resources/css/app.css', 'resources/js/app.js'])
    </head>
    <body class="font-sans text-slate-900 antialiased dark:text-slate-100">
        <div class="min-h-screen bg-slate-50 dark:bg-slate-950">
            <div class="grid min-h-screen lg:grid-cols-[1.1fr_1fr]">
                <div class="relative hidden overflow-hidden bg-slate-900 lg:flex">
                    <div class="absolute inset-0 bg-gradient-to-br from-slate-900 via-slate-900 to-primary-900"></div>
                    <div class="absolute -left-20 -top-20 h-72 w-72 rounded-full bg-primary-600/30 blur-3xl"></div>
                    <div class="absolute bottom-0 right-0 h-64 w-64 rounded-full bg-emerald-500/20 blur-3xl"></div>
                    <div class="relative z-10 flex h-full w-full flex-col justify-between p-12 text-white">
                        <a href="/" class="flex items-center gap-3 text-lg font-semibold tracking-tight">
                            <span class="inline-flex h-10 w-10 items-center justify-center rounded-2xl bg-white/10">
                                <x-application-logo class="h-6 w-6 fill-current text-white" />
                            </span>
                            {{ config('app.name', 'Laravel') }}
                        </a>
                        <div>
                            <p class="text-3xl font-semibold leading-tight">Manage orders, products, and customers in one place.</p>
                            <p class="mt-4 text-sm text-slate-200">Secure admin access for your web dashboard and API stack.</p>
                        </div>
                        <div class="text-xs text-slate-300">Version 2025 • Powered by Laravel</div>
                    </div>
                </div>

                <div class="flex items-center justify-center px-6 py-12 sm:px-10">
                    <div class="w-full max-w-md">
                        <div class="flex items-center gap-3 lg:hidden">
                            <span class="inline-flex h-10 w-10 items-center justify-center rounded-2xl bg-primary-600 text-white">
                                <x-application-logo class="h-6 w-6 fill-current text-white" />
                            </span>
                            <span class="text-lg font-semibold tracking-tight">{{ config('app.name', 'Laravel') }}</span>
                        </div>
                        <div class="mt-8 rounded-3xl border border-slate-200 bg-white/90 p-8 shadow-xl shadow-slate-200/60 backdrop-blur dark:border-slate-800 dark:bg-slate-900/80 dark:shadow-black/30">
                            {{ $slot }}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
