<?php

namespace App\Infrastructure\Administration\Authentication;

use App\Application\Administration\Authentication\AdministratorAuthenticator;
use App\Application\Administration\Authentication\AdministratorAuthenticationResult;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\App;
use Illuminate\Support\Facades\Http;

class ApiAdministratorAuthenticator implements AdministratorAuthenticator
{
    public function authenticate(string $login, string $password): AdministratorAuthenticationResult
    {
        $baseUrl = config('administration.api.base_url');

        if (! is_string($baseUrl) || trim($baseUrl) === '') {
            return AdministratorAuthenticationResult::failed(__('ui.api_configuration_missing'));
        }

        try {
            $response = Http::asJson()
                ->timeout((int) config('administration.api.timeout_seconds'))
                ->withHeaders([
                    'Accept-Language' => App::getLocale(),
                ])
                ->post(rtrim($baseUrl, '/') . '/api/Auth/Login', [
                    'email' => $login,
                    'password' => $password,
                ]);
        } catch (ConnectionException) {
            return AdministratorAuthenticationResult::failed(__('ui.api_connection_error'));
        }

        if (in_array($response->status(), [400, 401], true)) {
            return AdministratorAuthenticationResult::failed(__('ui.invalid_credentials'));
        }

        if (! $response->successful()) {
            return AdministratorAuthenticationResult::failed(__('ui.api_auth_error'));
        }

        $data = $response->json();

        if (! is_array($data) || ! isset($data['jwtToken'], $data['username'])) {
            return AdministratorAuthenticationResult::failed(__('ui.api_invalid_response'));
        }

        return AdministratorAuthenticationResult::successful(
            (string) $data['jwtToken'],
            (string) $data['username']
        );
    }
}
