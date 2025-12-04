<?php

use Illuminate\Support\Facades\Route;

Route::redirect('/', '/login');

Route::get('/login', fn () => view('auth.login'))->name('login');
