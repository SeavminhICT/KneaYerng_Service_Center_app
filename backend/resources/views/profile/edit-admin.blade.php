@extends('layouts.admin')

@section('title', __('My Profile'))
@section('page-title', __('My Profile'))

@section('content')
    @include('profile.partials.profile-content')
@endsection
