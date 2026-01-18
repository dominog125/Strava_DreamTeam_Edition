<?php

use App\Http\Middleware\AdministratorAccessMiddleware;
use App\Http\Middleware\SetLocaleFromSession;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Illuminate\Session\TokenMismatchException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__ . '/../routes/web.php',
        api: __DIR__ . '/../routes/api.php',
        commands: __DIR__ . '/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        $middleware->alias([
            'administrator' => AdministratorAccessMiddleware::class,
        ]);

        $middleware->web(append: [
            SetLocaleFromSession::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        $exceptions->render(function (TokenMismatchException $exception, Request $request) {
            if ($request->expectsJson()) {
                return response()->json([
                    'message' => __('ui.page_expired_try_again'),
                ], 419);
            }

            return redirect()
                ->route('login')
                ->withInput($request->only('login'))
                ->withErrors([
                    'login' => __('ui.page_expired_try_again'),
                ]);
        });
    })
    ->create();