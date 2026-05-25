import axios from 'axios';
import Echo from 'laravel-echo';
import Pusher from 'pusher-js';

window.axios = axios;

window.axios.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';

const pusherKey = import.meta.env.VITE_PUSHER_APP_KEY;
const pusherCluster = import.meta.env.VITE_PUSHER_APP_CLUSTER || 'mt1';
const pusherHost = import.meta.env.VITE_PUSHER_HOST || undefined;
const pusherPort = import.meta.env.VITE_PUSHER_PORT ? Number(import.meta.env.VITE_PUSHER_PORT) : undefined;
const pusherScheme = import.meta.env.VITE_PUSHER_SCHEME || 'https';
const notificationSoundPath = import.meta.env.VITE_ADMIN_NOTIFICATION_SOUND || '/sounds/mixkit-bell-notification-933.wav';

let notificationAudio = null;

function isAdminPage() {
    return Boolean(document.body && document.body.dataset && document.body.dataset.adminArea === '1');
}

function getNotificationAudio() {
    if (notificationAudio) {
        return notificationAudio;
    }

    if (typeof window.Audio !== 'function') {
        return null;
    }

    notificationAudio = new window.Audio(notificationSoundPath);
    notificationAudio.preload = 'auto';
    notificationAudio.volume = 1;

    return notificationAudio;
}

function playNotificationSound() {
    const audio = getNotificationAudio();
    if (!audio) {
        return;
    }

    try {
        audio.currentTime = 0;
        const maybePromise = audio.play();
        if (maybePromise && typeof maybePromise.catch === 'function') {
            maybePromise.catch(function () {});
        }
    } catch (error) {
        // Ignore autoplay/user gesture errors.
    }
}

function emitRealtimeEvent(eventName, detail) {
    window.dispatchEvent(new window.CustomEvent(eventName, { detail: detail }));
}

window.adminRealtimePlaySound = playNotificationSound;

if (pusherKey) {
    window.Pusher = Pusher;

    const csrfTokenMeta = document.querySelector('meta[name="csrf-token"]');
    const csrfToken = csrfTokenMeta ? csrfTokenMeta.getAttribute('content') : null;
    const authOptions = csrfToken ? {
        headers: {
            'X-CSRF-TOKEN': csrfToken,
        },
    } : undefined;

    window.Echo = new Echo({
        broadcaster: 'pusher',
        key: pusherKey,
        cluster: pusherCluster,
        wsHost: pusherHost,
        wsPort: pusherPort,
        wssPort: pusherPort,
        forceTLS: pusherScheme === 'https',
        enabledTransports: ['ws', 'wss'],
        authEndpoint: '/broadcasting/auth',
        auth: authOptions,
    });

    if (isAdminPage()) {
        window.Echo.private('admin.notifications')
            .listen('.admin.order.created', function (payload) {
                playNotificationSound();
                emitRealtimeEvent('admin:realtime-order-created', payload);
            })
            .listen('.admin.support.message.created', function (payload) {
                emitRealtimeEvent('admin:realtime-support-message-created', payload);
            });
    }
}
