<?php

use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('App.Models.User.{id}', function ($user, $id) {
    return (int) $user->id === (int) $id;
});

Broadcast::channel('admin.notifications', function ($user) {
    $isAdmin = method_exists($user, 'isAdmin') && $user->isAdmin();
    $isTechnician = method_exists($user, 'isTechnician') && $user->isTechnician();
    $canViewAlerts = method_exists($user, 'hasAnyPermission')
        && $user->hasAnyPermission('view_order', 'view_support_inbox', 'view_notification');

    return $isAdmin || (! $isTechnician && $canViewAlerts);
});
