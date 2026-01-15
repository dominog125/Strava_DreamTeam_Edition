<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class AdministratorAccessMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        return match (config('administration.auth_mode')) {
            'auth' => $this->handleAuth($request, $next),
            'jwt'  => $this->handleJwt($request, $next),
            default => redirect()->route('login'),
        };
    }

    private function handleAuth(Request $request, Closure $next): Response
    {
        if (! Auth::check() || ! Auth::user()->is_administrator) {
            return redirect()->route('login');
        }

        return $next($request);
    }

    private function handleJwt(Request $request, Closure $next): Response
    {
        if (! $request->session()->has('administrator.jwt')) {
            return redirect()->route('login');
        }

        return $next($request);
    }
}
