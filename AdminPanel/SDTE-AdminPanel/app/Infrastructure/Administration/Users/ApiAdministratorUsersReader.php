<?php

namespace App\Infrastructure\Administration\Users;

use App\Application\Administration\Users\AdministratorUsersFilters;
use App\Application\Administration\Users\AdministratorUsersReader;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Pagination\Paginator;
use Illuminate\Support\Fluent;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
use RuntimeException;

class ApiAdministratorUsersReader implements AdministratorUsersReader
{
    public function paginate(AdministratorUsersFilters $filters): LengthAwarePaginator
    {
        $apiBaseUrl = (string) config('administration.api.base_url');

        if (trim($apiBaseUrl) === '') {
            throw new RuntimeException('Missing configuration: administration.api.base_url');
        }

        $usersUrl = rtrim($apiBaseUrl, '/') . '/api/admin/users';

        $pendingRequest = Http::acceptJson()->timeout(10);

        $bearerToken = $this->resolveBearerToken();

        if (trim($bearerToken) !== '') {
            $pendingRequest = $pendingRequest->withToken($bearerToken);
        }

        $apiUsersResponse = $pendingRequest->get($usersUrl);
        $apiUsersResponse->throw();

        $apiPayload = $apiUsersResponse->json();

        if (! is_array($apiPayload)) {
            $apiPayload = [];
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
