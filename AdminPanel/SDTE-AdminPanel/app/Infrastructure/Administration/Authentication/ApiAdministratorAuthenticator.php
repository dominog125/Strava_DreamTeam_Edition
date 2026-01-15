<?php

namespace App\Infrastructure\Administration\Authentication;

use App\Application\Administration\Authentication\AdministratorAuthenticator;
use App\Application\Administration\Authentication\AdministratorAuthenticationResult;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\Http;

class ApiAdministratorAuthenticator implements AdministratorAuthenticator
{
    public function authenticate(string $login, string $password): AdministratorAuthenticationResult
    {
        $baseUrl = config('administration.api.base_url');
        $timeoutSeconds = (int) config('administration.api.timeout_seconds', 10);

        if (! is_string($baseUrl) || trim($baseUrl) === '') {
            return AdministratorAuthenticationResult::failed('Brak konfiguracji API');
        }

        try {
            $response = Http::asJson()
                ->acceptJson()
                ->timeout($timeoutSeconds)
                ->post(
                    rtrim($baseUrl, '/') . '/api/Auth/Login',
                    [
                        'email' => $login,
                        'password' => $password,
                    ]
                );
        } catch (ConnectionException) {
            return AdministratorAuthenticationResult::failed('Brak połączenia z API');
        } catch (\Throwable) {
            return AdministratorAuthenticationResult::failed('Błąd konfiguracji połączenia z API');
        }

        if ($response->status() === 400 || $response->status() === 401) {
            return AdministratorAuthenticationResult::failed('Nieprawidłowy login lub hasło');
        }

        if (! $response->successful()) {
            return AdministratorAuthenticationResult::failed('Błąd autoryzacji po stronie API');
        }

        $data = $response->json();

        if (! isset($data['jwtToken'], $data['username'])) {
            return AdministratorAuthenticationResult::failed('Nieprawidłowa odpowiedź API');
        }

        return AdministratorAuthenticationResult::successful(
            (string) $data['jwtToken'],
            (string) $data['username']
        );
    }
}
