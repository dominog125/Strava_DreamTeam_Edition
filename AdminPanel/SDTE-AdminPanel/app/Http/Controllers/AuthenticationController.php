<?php

namespace App\Http\Controllers;

use App\Http\Requests\AuthenticationLoginRequest;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

class AuthenticationController extends Controller
{
    public function showLoginForm(): View|RedirectResponse
    {
        if (Auth::check() && Auth::user()->is_administrator) {
            return redirect()->route('administrator.dashboard');
        }

        return view('auth.login');
    }

    public function authenticate(AuthenticationLoginRequest $request): RedirectResponse
    {
        $credentials = [
            'name' => $request->input('login'),
            'password' => $request->input('password'),
            'is_administrator' => true,
        ];

        if (! Auth::attempt($credentials)) {
            throw ValidationException::withMessages([
                'password' => 'Błąd w loginie lub haśle.',
            ]);
        }

        $request->session()->regenerate();

        return redirect()->route('administrator.dashboard');
    }

    public function logout(Request $request): RedirectResponse
    {
        Auth::logout();

        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('login');
    }
}