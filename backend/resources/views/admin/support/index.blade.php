@extends('layouts.admin')

@section('title', 'Support Inbox')
@section('page-title', 'Support Inbox')

@section('content')
<!-- Support Inbox Container -->
<div class="h-[calc(100vh-14rem)] overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900">
    <div class="flex h-full divide-x divide-slate-100 dark:divide-slate-800">
        
        <!-- LEFT PANEL: Conversation List -->
        <div class="flex w-80 flex-col shrink-0 bg-white dark:bg-slate-900">
            <!-- Fixed Header: Search -->
            <div class="p-4 space-y-4">
                <div class="relative">
                    <input id="chat-search" type="text" placeholder="Search inbox..." class="h-10 w-full rounded-xl border border-slate-200 bg-slate-50 pl-10 pr-4 text-sm text-slate-700 placeholder:text-slate-400 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200" />
                    <svg class="absolute left-3 top-3 h-4 w-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                </div>
                
                <!-- Independent Filtering Tabs (Fixed) -->
                <div class="flex items-center gap-1 overflow-x-auto no-scrollbar pb-1">
                    <button onclick="window.setFilter('all')" class="filter-tab px-3 py-1.5 text-xs font-semibold rounded-lg bg-primary-600 text-white whitespace-nowrap active" data-filter="all">All</button>
                    <button onclick="window.setFilter('new')" class="filter-tab px-3 py-1.5 text-xs font-semibold rounded-lg text-slate-500 hover:bg-slate-100 dark:hover:bg-slate-800 whitespace-nowrap" data-filter="new">New</button>
                    <button onclick="window.setFilter('waiting_for_support')" class="filter-tab px-3 py-1.5 text-xs font-semibold rounded-lg text-slate-500 hover:bg-slate-100 dark:hover:bg-slate-800 whitespace-nowrap" data-filter="waiting_for_support">Waiting</button>
                    <button onclick="window.setFilter('resolved')" class="filter-tab px-3 py-1.5 text-xs font-semibold rounded-lg text-slate-500 hover:bg-slate-100 dark:hover:bg-slate-800 whitespace-nowrap" data-filter="resolved">Done</button>
                </div>
                <div class="flex items-center justify-between rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 dark:border-slate-800 dark:bg-slate-900/60">
                    <p class="text-[11px] font-semibold text-slate-500">Browser alerts + sound</p>
                    <button id="enable-browser-alerts-btn" type="button" class="rounded-lg bg-primary-600 px-2.5 py-1 text-[11px] font-semibold text-white transition hover:bg-primary-700">
                        Enable
                    </button>
                </div>
            </div>
            
            <!-- Scrollable Conversation List Area -->
            <div id="conversation-list" class="flex-1 overflow-y-auto p-2 space-y-1 overscroll-contain border-t border-slate-50 dark:border-slate-800/50">
                <div class="p-4 text-center text-slate-500 text-sm">
                    <div class="animate-pulse flex flex-col items-center gap-2">
                        <div class="h-8 w-8 rounded-full bg-slate-100 dark:bg-slate-800"></div>
                        <span>Loading inbox...</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- RIGHT PANEL: Conversation Context -->
        <div id="chat-area" class="flex flex-1 flex-col bg-slate-50/30 dark:bg-slate-950/10">
            <!-- Empty State (Shown when no chat selected) -->
            <div id="empty-chat" class="flex flex-1 flex-col items-center justify-center text-slate-400">
                <div class="rounded-full bg-white p-8 shadow-sm dark:bg-slate-800/50">
                    <svg class="h-16 w-16 text-primary-500/40" fill="none" stroke="currentColor" stroke-width="1" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M8.625 12a.375.375 0 11-.75 0 .375.375 0 01.75 0zm0 0H8.25m4.125 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zm0 0H12m4.125 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zm0 0h-.375M21 12c0 4.556-4.03 8.25-9 8.25a9.764 9.764 0 01-2.555-.337A5.972 5.972 0 015.41 20.97a5.969 5.969 0 01-.474-.065 4.48 4.48 0 00.978-2.025c.09-.457-.133-.901-.467-1.226C3.93 16.178 3 14.189 3 12c0-4.556 4.03-8.25 9-8.25s9 3.694 9 8.25z" />
                    </svg>
                </div>
                <h3 class="mt-6 text-lg font-bold text-slate-800 dark:text-slate-200">Select a conversation</h3>
                <p class="mt-1 text-sm">Pick a user from the list to start chatting.</p>
            </div>

            <!-- Active Conversation Area (Hidden by default) -->
            <div id="active-chat" class="hidden flex h-full flex-col overflow-hidden">
                <!-- Fixed Header: Customer details & Status -->
                <div class="flex items-center justify-between border-b border-slate-100 bg-white/50 p-4 backdrop-blur-md dark:border-slate-800 dark:bg-slate-900/50">
                    <div class="flex items-center gap-3">
                        <div id="current-customer-avatar" class="flex h-11 w-11 items-center justify-center rounded-full border-2 border-primary-100 bg-primary-50 text-base font-bold text-primary-600 dark:border-primary-900/30 dark:bg-primary-900/20 dark:text-primary-400">
                            -
                        </div>
                        <div class="min-w-0">
                            <h3 id="current-customer-name" class="truncate font-bold text-slate-900 dark:text-white">-</h3>
                            <p id="current-conversation-subject" class="truncate text-xs font-medium text-slate-500">-</p>
                        </div>
                    </div>
                    <div class="flex items-center gap-2">
                        @if (auth()->user()?->hasPermission('update_support_inbox'))
                        <select id="chat-status-select" class="h-9 rounded-lg border border-slate-200 bg-white px-3 text-xs font-bold text-slate-700 shadow-sm focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200">
                            <option value="new">New Inquiry</option>
                            <option value="open">Open</option>
                            <option value="waiting_for_support">Waiting for Support</option>
                            <option value="waiting_for_user">Waiting for User</option>
                            <option value="resolved">Resolved</option>
                            <option value="closed">Closed</option>
                        </select>
                        @endif
                        <button id="close-chat-btn" class="p-2 text-slate-400 hover:text-slate-600 dark:hover:text-slate-200">
                            <svg class="h-6 w-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                            </svg>
                        </button>
                    </div>
                </div>

                <!-- Scrollable Messages Area Only -->
                <div id="messages-container" class="flex-1 overflow-y-auto space-y-6 p-6 overscroll-contain bg-slate-50/50 dark:bg-slate-950/20">
                    <!-- Messages will be dynamically rendered here -->
                </div>

                <!-- Fixed Message Input Area at Bottom -->
                @if (auth()->user()?->hasAnyPermission('create_support_inbox', 'update_support_inbox'))
                <div class="border-t border-slate-100 bg-white p-4 dark:border-slate-800 dark:bg-slate-900">
                    <input type="file" id="image-input" accept="image/*" class="hidden" />
                    <form id="reply-form" class="flex items-end gap-3">
                        <button type="button" id="image-btn" title="Send image" class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl text-slate-400 hover:bg-slate-100 hover:text-slate-600 dark:hover:bg-slate-800 dark:hover:text-slate-200">
                            <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 15.75l5.159-5.159a2.25 2.25 0 013.182 0l5.159 5.159m-1.5-1.5l1.409-1.409a2.25 2.25 0 013.182 0l2.909 2.909M21 6.75a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM3 6.75v10.5A2.25 2.25 0 005.25 19.5h13.5A2.25 2.25 0 0021 17.25V6.75A2.25 2.25 0 0018.75 4.5H5.25A2.25 2.25 0 003 6.75z" />
                            </svg>
                        </button>
                        <button type="button" id="mic-btn" title="Record voice message" class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl text-slate-400 hover:bg-slate-100 hover:text-slate-600 dark:hover:bg-slate-800 dark:hover:text-slate-200">
                            <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M12 18.75a6 6 0 006-6v-1.5m-6 7.5a6 6 0 01-6-6v-1.5m6 7.5v3.75m-3.75 0h7.5M12 15.75a3 3 0 01-3-3V4.5a3 3 0 116 0v8.25a3 3 0 01-3 3z" />
                            </svg>
                        </button>

                        <div id="recording-indicator" class="hidden flex-1 items-center gap-2 rounded-xl border border-red-200 bg-red-50 px-3 py-2.5 text-sm font-semibold text-red-600 dark:border-red-500/30 dark:bg-red-500/10 dark:text-red-300">
                            <span class="h-2.5 w-2.5 animate-pulse rounded-full bg-red-500"></span>
                            <span>Recording...</span>
                            <span id="recording-timer" class="ml-1">0:00</span>
                            <button type="button" id="cancel-recording-btn" class="ml-auto text-xs font-bold uppercase text-red-500 hover:text-red-700">Cancel</button>
                        </div>

                        <div id="text-input-wrapper" class="flex-1">
                            <textarea id="message-input" rows="1" placeholder="Write your message..." class="block w-full max-h-32 resize-none rounded-xl border border-slate-200 bg-slate-50 p-3 text-sm text-slate-700 focus:border-primary-500 focus:ring-primary-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-200"></textarea>
                        </div>
                        <button type="submit" id="send-btn" class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-primary-600 text-white shadow-lg shadow-primary-500/20 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-primary-500 transition-all active:scale-95 disabled:opacity-50">
                            <svg class="h-5 w-5 rotate-90" fill="currentColor" viewBox="0 0 24 24">
                                <path d="M3.4 20.4l17.45-7.48a1 1 0 000-1.84L3.4 3.6a1 1 0 00-1.39 1.3l2.84 7.1h7.43v2h-7.43L2.01 19.1a1 1 0 001.39 1.3z" />
                            </svg>
                        </button>
                    </form>
                </div>
                @endif
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    let conversations = [];
    let activeConversationId = null;
    let listPollInterval = null;
    let chatPollInterval = null;
    let isFetchingList = false;
    let isFetchingChat = false;
    let currentFilter = 'all';
    const initialConversationFromUrl = Number(new URLSearchParams(window.location.search).get('conversation') || 0);
    let initialConversationOpened = false;
    let conversationSnapshotReady = false;
    const latestCustomerMessageSnapshot = new Map();

    const convList = document.getElementById('conversation-list');
    const chatArea = document.getElementById('chat-area');
    const activeChat = document.getElementById('active-chat');
    const emptyChat = document.getElementById('empty-chat');
    const messagesContainer = document.getElementById('messages-container');
    const replyForm = document.getElementById('reply-form');
    const messageInput = document.getElementById('message-input');
    const statusSelect = document.getElementById('chat-status-select');
    const searchInput = document.getElementById('chat-search');
    const enableBrowserAlertsBtn = document.getElementById('enable-browser-alerts-btn');
    const imageInput = document.getElementById('image-input');
    const imageBtn = document.getElementById('image-btn');
    const micBtn = document.getElementById('mic-btn');
    const sendBtn = document.getElementById('send-btn');
    const recordingIndicator = document.getElementById('recording-indicator');
    const recordingTimerEl = document.getElementById('recording-timer');
    const textInputWrapper = document.getElementById('text-input-wrapper');
    const cancelRecordingBtn = document.getElementById('cancel-recording-btn');
    let soundUnlocked = false;
    let mediaRecorder = null;
    let recordedChunks = [];
    let recordingStartedAt = 0;
    let recordingTimerInterval = null;
    let recordingStream = null;

    function resolveMediaUrl(mediaUrl) {
        if (!mediaUrl) return '';
        return '/api/media/' + mediaUrl.replace(/^\/+/, '');
    }

    function updateAlertButtonState() {
        if (!enableBrowserAlertsBtn) {
            return;
        }

        if (!('Notification' in window)) {
            enableBrowserAlertsBtn.textContent = 'Unsupported';
            enableBrowserAlertsBtn.disabled = true;
            enableBrowserAlertsBtn.classList.add('cursor-not-allowed', 'opacity-60');
            return;
        }

        if (Notification.permission === 'granted') {
            enableBrowserAlertsBtn.textContent = 'Test Alert';
            enableBrowserAlertsBtn.disabled = false;
            enableBrowserAlertsBtn.classList.remove('cursor-not-allowed', 'opacity-60');
            return;
        }

        if (Notification.permission === 'denied') {
            enableBrowserAlertsBtn.textContent = 'Fix Browser';
            enableBrowserAlertsBtn.disabled = false;
            enableBrowserAlertsBtn.classList.remove('cursor-not-allowed', 'opacity-60');
            return;
        }

        enableBrowserAlertsBtn.textContent = 'Enable';
        enableBrowserAlertsBtn.disabled = false;
        enableBrowserAlertsBtn.classList.remove('cursor-not-allowed', 'opacity-60');
    }

    function sendTestBrowserNotification() {
        if (!('Notification' in window) || Notification.permission !== 'granted') {
            return false;
        }

        const testNote = new Notification('Support Alerts Active', {
            body: 'You will receive new support messages here.',
            tag: 'support-test-alert',
            renotify: true,
        });

        setTimeout(() => {
            testNote.close();
        }, 4500);

        return true;
    }

    function showNotificationPermissionHelp() {
        if (window.Swal) {
            window.Swal.fire({
                icon: 'warning',
                title: 'Notifications Are Blocked',
                html: '1. Click the lock icon in the address bar.<br>2. Set Notifications to Allow.<br>3. Reload this page.',
                confirmButtonColor: '#2563eb',
            });
            return;
        }

        if (typeof window.adminToast === 'function') {
            window.adminToast('Notifications blocked. Set site permission to Allow, then reload page.', {
                type: 'error',
                duration: 6200
            });
        }
    }

    async function requestBrowserNotificationPermission() {
        await unlockNotificationSound();

        if (!('Notification' in window)) {
            updateAlertButtonState();
            return 'unsupported';
        }

        if (Notification.permission !== 'default') {
            updateAlertButtonState();
            return Notification.permission;
        }

        try {
            const permission = await Notification.requestPermission();
            if (permission === 'granted' && typeof window.adminToast === 'function') {
                window.adminToast('Browser notifications enabled for support chat.', { type: 'success' });
                playIncomingNotificationSound();
                sendTestBrowserNotification();
            } else if (permission === 'denied' && typeof window.adminToast === 'function') {
                window.adminToast('Browser notifications were blocked by this browser.', { type: 'error' });
            }
            return permission;
        } catch (err) {
            console.error('Unable to request notification permission:', err);
            return 'error';
        } finally {
            updateAlertButtonState();
        }
    }

    async function promptNotificationPermissionOnOpen() {
        if (!('Notification' in window) || Notification.permission !== 'default') {
            return;
        }

        if (!window.Swal) {
            if (typeof window.adminToast === 'function') {
                window.adminToast('Click Enable to allow browser notifications for support messages.', {
                    type: 'success',
                    duration: 5200
                });
            }
            return;
        }

        const result = await window.Swal.fire({
            icon: 'info',
            title: 'Enable Support Alerts',
            text: 'Allow browser notifications and sound for new customer messages.',
            showCancelButton: true,
            confirmButtonText: 'Enable Now',
            cancelButtonText: 'Not Now',
            confirmButtonColor: '#2563eb',
            cancelButtonColor: '#64748b',
        });

        if (result.isConfirmed) {
            await requestBrowserNotificationPermission();
        }
    }

    async function unlockNotificationSound() {
        soundUnlocked = true;
    }

    function playIncomingNotificationSound() {
        if (!soundUnlocked) {
            return;
        }

        if (typeof window.adminRealtimePlaySound === 'function') {
            window.adminRealtimePlaySound();
        }
    }

    function getMessagePreview(message, fallback) {
        if (!message) {
            return fallback || 'New support message';
        }

        if (message.message_type === 'voice') {
            return 'Sent a voice message';
        }

        if (message.message_type === 'image') {
            return 'Sent a photo';
        }

        if ((message.body || '').trim() !== '') {
            return message.body;
        }

        return fallback || 'Sent a message';
    }

    function maybeShowBrowserNotification(conversation, latestMessage) {
        if (!('Notification' in window) || Notification.permission !== 'granted') {
            return;
        }

        const customerName = conversation.customer?.name || 'Customer';
        const preview = getMessagePreview(latestMessage, conversation.subject || 'New support request');
        const browserNote = new Notification('New Support Message', {
            body: `${customerName}: ${preview}`,
            tag: `support-${conversation.id}`,
            renotify: true,
        });

        browserNote.onclick = () => {
            window.focus();
            if (typeof window.selectConversation === 'function') {
                window.selectConversation(conversation.id);
            }
            browserNote.close();
        };
    }

    function notifyIncomingCustomerMessage(conversation, latestMessage) {
        const customerName = conversation.customer?.name || 'Customer';
        const preview = getMessagePreview(latestMessage, conversation.subject || 'New support request');
        const isViewingSameConversation = activeConversationId === conversation.id && document.visibilityState === 'visible';

        if (!isViewingSameConversation && typeof window.adminToast === 'function') {
            window.adminToast(`New support message from ${customerName}: ${preview}`, {
                type: 'success',
                duration: 5200
            });
        }

        playIncomingNotificationSound();
        maybeShowBrowserNotification(conversation, latestMessage);
    }

    function trackIncomingCustomerMessages(nextConversations) {
        const seenConversationIds = new Set();

        nextConversations.forEach(conversation => {
            seenConversationIds.add(conversation.id);

            const latestMessage = conversation.latest_message;
            if (!latestMessage || latestMessage.sender_type !== 'customer') {
                latestCustomerMessageSnapshot.delete(conversation.id);
                return;
            }

            const currentSignature = String(
                latestMessage.id || latestMessage.created_at || `${conversation.id}:${latestMessage.body || ''}`
            );
            const previousSignature = latestCustomerMessageSnapshot.get(conversation.id);

            if (conversationSnapshotReady && currentSignature !== previousSignature) {
                notifyIncomingCustomerMessage(conversation, latestMessage);
            }

            latestCustomerMessageSnapshot.set(conversation.id, currentSignature);
        });

        Array.from(latestCustomerMessageSnapshot.keys()).forEach(conversationId => {
            if (!seenConversationIds.has(conversationId)) {
                latestCustomerMessageSnapshot.delete(conversationId);
            }
        });

        if (!conversationSnapshotReady) {
            conversationSnapshotReady = true;
        }
    }

    function buildMessageSignature(conversationId, message) {
        if (!message) {
            return null;
        }

        return String(
            message.id || message.created_at || `${conversationId}:${message.body || ''}`
        );
    }

    async function fetchConversations() {
        if (isFetchingList) return;
        isFetchingList = true;
        try {
            await window.adminApi.ensureCsrfCookie();
            const response = await window.adminApi.request('/api/admin/support/conversations');
            if (response.ok) {
                const result = await response.json();
                conversations = result.data;
                trackIncomingCustomerMessages(conversations);
                renderConversationList();

                if (!initialConversationOpened && initialConversationFromUrl > 0) {
                    const matchedConversation = conversations.find(c => Number(c.id) === initialConversationFromUrl);
                    if (matchedConversation && typeof window.selectConversation === 'function') {
                        initialConversationOpened = true;
                        window.selectConversation(initialConversationFromUrl);
                    }
                }
            }
        } catch (err) {
            console.error('Failed to fetch conversations:', err);
        } finally {
            isFetchingList = false;
        }
    }

    window.setFilter = function(filter) {
        currentFilter = filter;
        document.querySelectorAll('.filter-tab').forEach(b => {
            if (b.dataset.filter === filter) {
                b.classList.add('bg-primary-600', 'text-white', 'active');
                b.classList.remove('text-slate-500', 'hover:bg-slate-100', 'dark:hover:bg-slate-800');
            } else {
                b.classList.remove('bg-primary-600', 'text-white', 'active');
                b.classList.add('text-slate-500', 'hover:bg-slate-100', 'dark:hover:bg-slate-800');
            }
        });
        renderConversationList();
    };

    function renderConversationList() {
        const searchTerm = searchInput.value.toLowerCase();
        const filtered = conversations.filter(c => {
            const matchesSearch = (c.customer?.name || '').toLowerCase().includes(searchTerm) || 
                                  (c.customer?.email || '').toLowerCase().includes(searchTerm) || 
                                  (c.subject || '').toLowerCase().includes(searchTerm);
            
            const matchesFilter = currentFilter === 'all' || c.status === currentFilter;
            
            return matchesSearch && matchesFilter;
        });

        if (filtered.length === 0) {
            convList.innerHTML = `<div class="p-8 text-center text-slate-400 text-xs font-medium">No ${currentFilter === 'all' ? '' : currentFilter.replace(/_/g, ' ')} messages found</div>`;
            return;
        }

        convList.innerHTML = filtered.map(c => {
            const isActive = c.id === activeConversationId;
            const initials = (c.customer?.name || '??').split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2);
            
            let timeStr = '';
            if (c.last_message_at) {
                const date = new Date(c.last_message_at);
                const now = new Date();
                const diffDays = Math.floor((now - date) / (1000 * 60 * 60 * 24));
                if (diffDays > 0) {
                    timeStr = diffDays + 'd';
                } else {
                    timeStr = date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: true });
                }
            }

            const unreadCount = c.unread_for_support || 0;
            const lastMsg = c.latest_message?.body || c.subject || 'New request';

            return `
                <div onclick="window.selectConversation(${c.id})" class="group relative cursor-pointer mx-2 rounded-xl p-3 transition-all duration-200 ${isActive ? 'bg-primary-50 dark:bg-primary-900/20' : 'hover:bg-slate-50 dark:hover:bg-slate-800/40'}">
                    <div class="flex items-center gap-3">
                        <!-- Avatar Container -->
                        <div class="relative shrink-0">
                            <div class="flex h-12 w-12 items-center justify-center rounded-full border-2 ${isActive ? 'border-primary-200' : 'border-slate-100 dark:border-slate-800'} bg-white text-sm font-bold text-slate-600 dark:bg-slate-800 dark:text-slate-400">
                                ${initials}
                            </div>
                            <span class="absolute bottom-0 right-0 h-3 w-3 rounded-full border-2 border-white bg-green-500 dark:border-slate-900"></span>
                        </div>
                        
                        <!-- Info Container -->
                        <div class="min-w-0 flex-1">
                            <div class="flex items-center justify-between mb-0.5">
                                <h4 class="truncate font-bold text-[15px] ${isActive ? 'text-primary-700 dark:text-primary-500' : 'text-slate-900 dark:text-white'}">
                                    ${c.customer?.name || 'Unknown User'}
                                </h4>
                                <span class="text-[11px] font-bold text-slate-400">${timeStr}</span>
                            </div>
                            <p class="truncate text-sm leading-tight ${unreadCount > 0 ? 'text-slate-900 dark:text-slate-200 font-bold' : 'text-slate-500 font-medium'}">
                                ${lastMsg}
                            </p>
                        </div>

                        <!-- Badge -->
                        ${unreadCount > 0 ? `
                            <div class="flex shrink-0 ml-1">
                                <span class="h-3.5 w-3.5 rounded-full bg-blue-600 shadow-[0_0_8px_rgba(37,99,235,0.5)]"></span>
                            </div>
                        ` : ''}
                    </div>
                </div>
            `;
        }).join('');
    }

    async function fetchChatMessages(id, skipLoading = false) {
        if (isFetchingChat) return;
        isFetchingChat = true;
        try {
            const response = await window.adminApi.request(`/api/admin/support/conversations/${id}`);
            if (response.ok && activeConversationId === id) {
                const result = await response.json();
                const conv = result.data;
                
                if (!skipLoading) {
                    document.getElementById('current-customer-name').textContent = conv.customer?.name || 'Unknown';
                    document.getElementById('current-conversation-subject').textContent = conv.subject || 'Support Request';
                    document.getElementById('current-customer-avatar').textContent = (conv.customer?.name || '??').split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2);
                    if (statusSelect) statusSelect.value = conv.status;
                }
                
                const oldScrollHeight = messagesContainer.scrollHeight;
                const wasAtBottom = messagesContainer.scrollTop + messagesContainer.clientHeight >= oldScrollHeight - 100;

                renderMessages(conv.messages || []);
                
                if (!skipLoading || wasAtBottom) {
                    scrollChatToBottom();
                }
            }
        } catch (err) {
            console.error('Failed to fetch conversation details:', err);
        } finally {
            isFetchingChat = false;
        }
    }

    window.selectConversation = function(id) {
        if (activeConversationId === id) return;
        
        activeConversationId = id;
        renderConversationList();
        
        emptyChat.classList.add('hidden');
        activeChat.classList.remove('hidden');
        
        messagesContainer.innerHTML = '<div class="flex h-full items-center justify-center"><div class="animate-spin rounded-full h-10 w-10 border-4 border-slate-100 border-t-primary-600"></div></div>';

        if (chatPollInterval) clearInterval(chatPollInterval);
        
        fetchChatMessages(id);
        
        chatPollInterval = setInterval(() => {
            if (activeConversationId) fetchChatMessages(activeConversationId, true);
        }, 3000);

        fetchConversations();
    };

    function renderMessages(messages) {
        if (messages.length === 0) {
            messagesContainer.innerHTML = '<div class="flex h-full items-center justify-center text-slate-400 font-medium">No messages in this chat yet.</div>';
            return;
        }

        const html = messages.map(m => {
            const isSupport = m.sender_type === 'support';
            const time = new Date(m.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

            let bodyHtml;
            if (m.message_type === 'image' && m.media_url) {
                const src = resolveMediaUrl(m.media_url);
                bodyHtml = `<img src="${src}" onclick="window.open('${src}', '_blank')" class="max-w-[220px] max-h-[220px] cursor-pointer rounded-lg object-cover" />`;
            } else if (m.message_type === 'voice' && m.media_url) {
                bodyHtml = `<audio controls preload="none" class="max-w-[220px]" src="${resolveMediaUrl(m.media_url)}"></audio>`;
            } else {
                bodyHtml = `<p class="text-[14px] leading-relaxed whitespace-pre-wrap">${m.body || ''}</p>`;
            }

            return `
                <div class="flex ${isSupport ? 'justify-end' : 'justify-start'} animate-in fade-in slide-in-from-bottom-2 duration-300">
                    <div class="max-w-[70%] ${isSupport ? 'order-1' : ''}">
                        <div class="relative rounded-2xl px-5 py-3 shadow-sm ${isSupport ? 'bg-primary-600 text-white rounded-br-none' : 'bg-white text-slate-700 dark:bg-slate-800 dark:text-slate-200 rounded-bl-none'}">
                            ${bodyHtml}
                        </div>
                        <div class="mt-1.5 flex items-center gap-2 ${isSupport ? 'justify-end' : 'justify-start'}">
                            <span class="text-[10px] font-bold text-slate-400 uppercase tracking-tighter">${time}</span>
                            ${isSupport ? `<span class="text-[10px] font-bold text-slate-400 uppercase tracking-tighter">${m.delivery_status || 'delivered'}</span>` : ''}
                        </div>
                    </div>
                </div>
            `;
        }).join('');

        if (messagesContainer.innerHTML !== html) {
            messagesContainer.innerHTML = html;
        }
    }

    function scrollChatToBottom() {
        setTimeout(() => {
            messagesContainer.scrollTo({
                top: messagesContainer.scrollHeight,
                behavior: 'smooth'
            });
        }, 100);
    }

    async function uploadSupportMedia(file, type) {
        await window.adminApi.ensureCsrfCookie();
        const formData = new FormData();
        formData.append('type', type);
        formData.append('file', file);
        const response = await window.adminApi.request('/api/admin/support/upload', {
            method: 'POST',
            body: formData,
        });
        if (!response.ok) {
            throw new Error('Media upload failed.');
        }
        const result = await response.json();
        return result.media_url;
    }

    async function sendMediaMessage(messageType, mediaUrl, durationSec) {
        if (!activeConversationId) return;
        const payload = { message_type: messageType, media_url: mediaUrl };
        if (durationSec) {
            payload.media_duration_sec = durationSec;
        }
        const response = await window.adminApi.request(`/api/admin/support/conversations/${activeConversationId}/messages`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload),
        });
        if (response.ok) {
            scrollChatToBottom();
            await fetchChatMessages(activeConversationId, true);
            fetchConversations();
        } else if (typeof window.adminToast === 'function') {
            window.adminToast('Failed to send message.', { type: 'error' });
        }
    }

    if (imageBtn) imageBtn.addEventListener('click', () => {
        if (!activeConversationId) return;
        imageInput.click();
    });

    if (imageInput) imageInput.addEventListener('change', async () => {
        const file = imageInput.files && imageInput.files[0];
        imageInput.value = '';
        if (!file || !activeConversationId) return;

        imageBtn.disabled = true;
        try {
            const mediaUrl = await uploadSupportMedia(file, 'image');
            await sendMediaMessage('image', mediaUrl, null);
        } catch (err) {
            console.error('Image upload failed:', err);
            if (typeof window.adminToast === 'function') {
                window.adminToast('Failed to upload image.', { type: 'error' });
            }
        } finally {
            imageBtn.disabled = false;
        }
    });

    function updateRecordingTimer() {
        const elapsed = Math.floor((Date.now() - recordingStartedAt) / 1000);
        const minutes = Math.floor(elapsed / 60);
        const seconds = elapsed % 60;
        recordingTimerEl.textContent = `${minutes}:${String(seconds).padStart(2, '0')}`;
    }

    function setRecordingUiActive(active) {
        recordingIndicator.classList.toggle('hidden', !active);
        recordingIndicator.classList.toggle('flex', active);
        textInputWrapper.classList.toggle('hidden', active);
        imageBtn.classList.toggle('hidden', active);
        micBtn.classList.toggle('text-red-500', active);
    }

    async function startRecording() {
        if (!activeConversationId || mediaRecorder) return;
        try {
            recordingStream = await navigator.mediaDevices.getUserMedia({ audio: true });
        } catch (err) {
            console.error('Microphone permission denied:', err);
            if (typeof window.adminToast === 'function') {
                window.adminToast('Microphone permission is required to record voice messages.', { type: 'error' });
            }
            return;
        }

        recordedChunks = [];
        mediaRecorder = new MediaRecorder(recordingStream);
        mediaRecorder.addEventListener('dataavailable', (event) => {
            if (event.data && event.data.size > 0) {
                recordedChunks.push(event.data);
            }
        });

        recordingStartedAt = Date.now();
        recordingTimerEl.textContent = '0:00';
        setRecordingUiActive(true);
        recordingTimerInterval = setInterval(updateRecordingTimer, 500);
        mediaRecorder.start();
    }

    function teardownRecording() {
        if (recordingTimerInterval) {
            clearInterval(recordingTimerInterval);
            recordingTimerInterval = null;
        }
        if (recordingStream) {
            recordingStream.getTracks().forEach(track => track.stop());
            recordingStream = null;
        }
        mediaRecorder = null;
        setRecordingUiActive(false);
    }

    async function stopRecording(shouldSend) {
        if (!mediaRecorder) return;

        const recorder = mediaRecorder;
        const durationSec = Math.max(1, Math.round((Date.now() - recordingStartedAt) / 1000));

        const stopped = new Promise(resolve => {
            recorder.addEventListener('stop', resolve, { once: true });
        });
        recorder.stop();
        await stopped;

        const mimeType = recorder.mimeType || 'audio/webm';
        teardownRecording();

        if (!shouldSend) {
            recordedChunks = [];
            return;
        }

        const blob = new Blob(recordedChunks, { type: mimeType });
        recordedChunks = [];
        const extension = mimeType.includes('mp4') ? 'mp4' : (mimeType.includes('ogg') ? 'ogg' : 'webm');
        const file = new File([blob], `voice-message.${extension}`, { type: mimeType });

        try {
            const mediaUrl = await uploadSupportMedia(file, 'voice');
            await sendMediaMessage('voice', mediaUrl, durationSec);
        } catch (err) {
            console.error('Voice upload failed:', err);
            if (typeof window.adminToast === 'function') {
                window.adminToast('Failed to upload voice message.', { type: 'error' });
            }
        }
    }

    if (micBtn) micBtn.addEventListener('click', () => {
        if (!activeConversationId) return;
        if (mediaRecorder) {
            stopRecording(true);
        } else {
            startRecording();
        }
    });

    if (cancelRecordingBtn) cancelRecordingBtn.addEventListener('click', () => {
        stopRecording(false);
    });

    if (replyForm) replyForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        const body = messageInput.value.trim();
        if (!body || !activeConversationId) return;

        const btn = sendBtn;
        btn.disabled = true;

        try {
            const response = await window.adminApi.request(`/api/admin/support/conversations/${activeConversationId}/messages`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ body: body })
            });

            if (response.ok) {
                messageInput.value = '';
                messageInput.style.height = 'auto';
                scrollChatToBottom();
                await fetchChatMessages(activeConversationId, true);
                fetchConversations();
            }
        } catch (err) {
            console.error('Failed to send message:', err);
        } finally {
            btn.disabled = false;
        }
    });

    if (statusSelect) statusSelect.addEventListener('change', async function() {
        if (!activeConversationId) return;
        try {
            await window.adminApi.request(`/api/admin/support/conversations/${activeConversationId}/status`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ status: this.value })
            });
            fetchConversations();
        } catch (err) {
            console.error('Failed to update status:', err);
        }
    });

    searchInput.addEventListener('input', () => {
        renderConversationList();
    });

    window.addEventListener('admin:realtime-support-message-created', function (event) {
        const payload = event && event.detail ? event.detail : {};
        const conversation = payload.conversation || {};
        const latestMessage = payload.message || {};
        const conversationId = conversation.id;

        if (!conversationId) {
            return;
        }

        const signature = buildMessageSignature(conversationId, latestMessage);
        if (signature) {
            latestCustomerMessageSnapshot.set(conversationId, signature);
            conversationSnapshotReady = true;
        }

        notifyIncomingCustomerMessage({
            id: conversationId,
            customer: conversation.customer || {},
            subject: conversation.subject || 'Support request',
        }, latestMessage);

        fetchConversations();

        if (activeConversationId === conversationId) {
            fetchChatMessages(conversationId, true);
        }
    });

    document.addEventListener('click', unlockNotificationSound, { once: true });
    document.addEventListener('keydown', unlockNotificationSound, { once: true });

    if (enableBrowserAlertsBtn) {
        enableBrowserAlertsBtn.addEventListener('click', async () => {
            await unlockNotificationSound();

            if (!('Notification' in window)) {
                updateAlertButtonState();
                return;
            }

            if (Notification.permission === 'granted') {
                playIncomingNotificationSound();
                if (sendTestBrowserNotification() && typeof window.adminToast === 'function') {
                    window.adminToast('Test browser notification sent.', { type: 'success' });
                }
                updateAlertButtonState();
                return;
            }

            if (Notification.permission === 'denied') {
                showNotificationPermissionHelp();
                updateAlertButtonState();
                return;
            }

            await requestBrowserNotificationPermission();
        });
    }

    if ('Notification' in window && Notification.permission === 'default') {
        setTimeout(() => {
            promptNotificationPermissionOnOpen();
        });
    }

    updateAlertButtonState();
    fetchConversations();
    listPollInterval = setInterval(fetchConversations, 5000);

    if (messageInput) messageInput.addEventListener('input', function() {
        this.style.height = 'auto';
        this.style.height = Math.min(this.scrollHeight, 128) + 'px';
    });

    document.getElementById('close-chat-btn').addEventListener('click', () => {
        activeConversationId = null;
        activeChat.classList.add('hidden');
        emptyChat.classList.remove('hidden');
        if (chatPollInterval) clearInterval(chatPollInterval);
        renderConversationList();
    });
});
</script>

<style>
.no-scrollbar::-webkit-scrollbar { display: none; }
.no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
</style>
@endsection
