<?php

namespace App\Http\Controllers;

use App\Application\Administration\Authentication\AdministratorAuthenticator;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class AuthenticationController extends Controller
{
    public function __construct(
        private readonly AdministratorAuthenticator $administratorAuthenticator
    ) {
    }

    public function showLoginForm(): View
    {
        return view('auth.login');
    }

    public function authenticate(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'login' => ['required', 'string', 'max:255'],
            'password' => ['required', 'string', 'max:255'],
        ]);

        $result = $this->administratorAuthenticator->authenticate(
            $validated['login'],
            $validated['password']
        );

        if (! $result->isSuccessful) {
            return back()
                ->withErrors(['password' => $result->failureMessage ?? 'Błąd w loginie/haśle'])
                ->onlyInput('login');
        }

        $request->session()->regenerate();

        if (config('administration.auth_mode') === 'jwt') {
            if ($result->jwtToken === null) {
                return back()
                    ->withErrors(['password' => 'Brak tokenu JWT w odpowiedzi z API'])
                    ->onlyInput('login');
            }

            $request->session()->put('administrator.jwt', $result->jwtToken);
            $request->session()->put('administrator.username', $result->username ?? $validated['login']);
        }

        return redirect()->route('administrator.dashboard');
    }

    public function logout(Request $request): RedirectResponse
    {
        Auth::logout();

        $request->session()->forget([
            'administrator.jwt',
            'administrator.username',
        ]);

        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('login');
    }
}
