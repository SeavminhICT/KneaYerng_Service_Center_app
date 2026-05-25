<?php

use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('App.Models.User.{id}', function ($user, $id) {
    return (int) $user->id === (int) $id;
});

Broadcast::channel('admin.notifications', function ($user) {
    $isAdmin = method_exists($user, 'isAdmin') && $user->isAdmin();
    $isStaff = method_exists($user, 'isStaff') && $user->isStaff();

    return $isAdmin || $isStaff;
});
