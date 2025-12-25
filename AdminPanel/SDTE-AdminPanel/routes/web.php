<?php

use App\Http\Controllers\AuthenticationController;
use App\Http\Controllers\AdministratorDashboardController;
use Illuminate\Support\Facades\Route;

Route::redirect('/', '/login');

Route::get('/login', [AuthenticationController::class, 'showLoginForm'])
    ->name('login');

Route::post('/login', [AuthenticationController::class, 'authenticate'])
    ->name('login.process');

Route::post('/logout', [AuthenticationController::class, 'logout'])
    ->name('logout');

Route::middleware('administrator')->get('/admin', [AdministratorDashboardController::class, 'index'])
    ->name('administrator.dashboard');