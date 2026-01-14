<?php

use App\Http\Controllers\AuthenticationController;
use App\Http\Controllers\AdministratorDashboardController;
use App\Http\Controllers\AdministratorUserController;
use App\Http\Controllers\AdministratorActivitiesController;
use Illuminate\Support\Facades\Route;

Route::get('/locale/{locale}', function (string $locale) {
    if (! in_array($locale, ['pl', 'en'], true)) {
        abort(404);
    }

    session(['locale' => $locale]);

    return redirect()->back();
})->name('locale.switch');

Route::redirect('/', '/login');

Route::get('/login', [AuthenticationController::class, 'showLoginForm'])
    ->name('login');

Route::post('/login', [AuthenticationController::class, 'authenticate'])
    ->name('login.process');

Route::post('/logout', [AuthenticationController::class, 'logout'])
    ->name('logout');

Route::middleware(['auth', 'administrator'])->group(function () {
    Route::get('/admin', [AdministratorDashboardController::class, 'index'])
        ->name('administrator.dashboard');

    Route::get('/admin/users', [AdministratorUserController::class, 'index'])
        ->name('administrator.users');

    Route::get('/admin/activities', [AdministratorActivitiesController::class, 'index'])
        ->name('administrator.activities');

    Route::delete('/admin/activities/{activity}', [AdministratorActivitiesController::class, 'destroy'])
        ->name('administrator.activities.destroy');
});
