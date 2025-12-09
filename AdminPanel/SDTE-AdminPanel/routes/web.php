<?php

use App\Http\Controllers\AuthenticationController;
use Illuminate\Support\Facades\Route;

Route::redirect('/', '/login');

Route::get('/login', [AuthenticationController::class, 'showLoginForm'])
    ->name('login');

Route::post('/login', [AuthenticationController::class, 'authenticate'])
    ->name('login.process');

Route::post('/logout', [AuthenticationController::class, 'logout'])
    ->name('logout');

Route::middleware('administrator')->get('/admin', function () {
    return 'Panel administratora';
})->name('administrator.dashboard');