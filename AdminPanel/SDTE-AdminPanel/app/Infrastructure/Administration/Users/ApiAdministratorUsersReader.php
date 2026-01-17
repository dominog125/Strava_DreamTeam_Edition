<?php

namespace App\Infrastructure\Administration\Users;

use App\Application\Administration\Users\AdministratorUsersFilters;
use App\Application\Administration\Users\AdministratorUsersReader;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Pagination\Paginator;
use Illuminate\Support\Facades\App;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Fluent;
use Illuminate\Support\Str;
use RuntimeException;

class ApiAdministratorUsersReader implements AdministratorUsersReader
{
    public function paginate(AdministratorUsersFilters $filters): LengthAwarePaginator
    {
        $apiBaseUrl = rtrim((string) config('administration.api.base_url'));
        $timeoutSeconds = (int) config('administration.api.timeout_seconds');

        if (trim($apiBaseUrl) === '') {
            throw new RuntimeException(__('ui.api_configuration_missing'));
        }

        $usersUrl = $apiBaseUrl . '/api/admin/users';

        try {
            $pendingRequest = Http::acceptJson()
                ->timeout($timeoutSeconds)
                ->withHeaders([
                    'Accept-Language' => App::getLocale(),
                ]);

            $bearerToken = $this->resolveBearerToken();

            if (trim($bearerToken) !== '') {
                $pendingRequest = $pendingRequest->withToken($bearerToken);
            }

            $response = $pendingRequest->get($usersUrl);
        } catch (ConnectionException) {
            throw new RuntimeException(__('ui.api_connection_error'));
        }

        if (in_array($response->status(), [401, 403], true)) {
            throw new RuntimeException(__('ui.api_auth_error'));
        }

        if (! $response->successful()) {
            throw new RuntimeException(__('ui.api_invalid_response'));
        }

        $apiPayload = $response->json();

        if (! is_array($apiPayload)) {
            throw new RuntimeException(__('ui.api_invalid_response'));
        }

        $apiUsers = $apiPayload;

        if (array_key_exists('data', $apiPayload) && is_array($apiPayload['data'])) {
            $apiUsers = $apiPayload['data'];
        }

        $users = collect($apiUsers)->filter(fn ($user) => is_array($user));

        if ($filters->searchName) {
            $needle = trim($filters->searchName);
            $users = $users->filter(fn (array $user) => Str::contains(
                (string) ($user['userName'] ?? ''),
                $needle,
                ignoreCase: true
            ));
        }

        if ($filters->searchEmail) {
            $needle = trim($filters->searchEmail);
            $users = $users->filter(fn (array $user) => Str::contains(
                (string) ($user['email'] ?? ''),
                $needle,
                ignoreCase: true
            ));
        }

        $pageName = 'page';
        $currentPage = Paginator::resolveCurrentPage($pageName);
        $perPage = $filters->perPage;

        $total = $users->count();

        $pageItems = $users
            ->slice(($currentPage - 1) * $perPage, $perPage)
            ->values()
            ->map(fn (array $user) => new Fluent($user));

        return new LengthAwarePaginator(
            $pageItems,
            $total,
            $perPage,
            $currentPage,
            [
                'path' => Paginator::resolveCurrentPath(),
                'pageName' => $pageName,
            ]
        );
    }

    private function resolveBearerToken(): string
    {
        if (config('administration.auth_mode') === 'jwt') {
            return (string) session('administrator.jwt', '');
        }

        return (string) config('administration.api.token', '');
    }
}
