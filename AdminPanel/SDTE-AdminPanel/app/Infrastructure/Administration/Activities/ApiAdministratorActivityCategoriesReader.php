<?php

namespace App\Infrastructure\Administration\Activities;

use App\Application\Administration\Activities\AdministratorActivityCategoriesReader;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\App;
use Illuminate\Support\Facades\Http;
use RuntimeException;

class ApiAdministratorActivityCategoriesReader implements AdministratorActivityCategoriesReader
{
    public function listNames(): array
    {
        $baseUrl = rtrim((string) config('administration.api.base_url'));
        $timeoutSeconds = (int) config('administration.api.timeout_seconds');

        if (trim($baseUrl) === '') {
            throw new RuntimeException(__('ui.api_configuration_missing'));
        }

        $jwtToken = (string) session('administrator.jwt', '');

        try {
            $request = Http::acceptJson()
                ->connectTimeout(3)
                ->timeout($timeoutSeconds)
                ->withHeaders([
                    'Accept-Language' => App::getLocale(),
                ]);

            if ($jwtToken !== '') {
                $request = $request->withToken($jwtToken);
            }

            $response = $request->get($baseUrl . '/api/ActivityCategories');
        } catch (ConnectionException) {
            throw new RuntimeException(__('ui.api_connection_error'));
        }

        if (in_array($response->status(), [401, 403], true)) {
            throw new RuntimeException(__('ui.api_auth_error'));
        }

        if (! $response->successful()) {
            throw new RuntimeException(__('ui.api_invalid_response'));
        }

        $payload = $response->json();

        if (! is_array($payload)) {
            throw new RuntimeException(__('ui.api_invalid_response'));
        }

        return collect($payload)
            ->filter(fn ($row) => is_array($row))
            ->map(fn (array $row) => (string) ($row['name'] ?? ''))
            ->filter(fn (string $name) => trim($name) !== '')
            ->unique()
            ->sort()
            ->values()
            ->all();
    }
}
