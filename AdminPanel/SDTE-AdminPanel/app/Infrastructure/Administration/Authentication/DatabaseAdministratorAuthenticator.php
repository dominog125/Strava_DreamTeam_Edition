<?php

namespace App\Infrastructure\Administration\Authentication;

use App\Application\Administration\Authentication\AdministratorAuthenticationResult;
use App\Application\Administration\Authentication\AdministratorAuthenticator;
use Illuminate\Support\Facades\Auth;

class DatabaseAdministratorAuthenticator implements AdministratorAuthenticator
{
    public function authenticate(string $login, string $password): AdministratorAuthenticationResult
    {
        $credentials = [
            'name' => $login,
            'password' => $password,
            'is_administrator' => true,
        ];

        if (! Auth::attempt($credentials)) {
            return AdministratorAuthenticationResult::failed('Błąd w loginie/haśle');
        }

        return AdministratorAuthenticationResult::successful();
    }
}
