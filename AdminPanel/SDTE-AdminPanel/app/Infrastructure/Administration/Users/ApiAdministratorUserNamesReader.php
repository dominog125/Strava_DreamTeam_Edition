<?php

namespace App\Infrastructure\Administration\Users;

use App\Application\Administration\Users\AdministratorUserNamesReader;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\App;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;

class ApiAdministratorUserNamesReader implements AdministratorUserNamesReader
{
    public function getUserNamesByUserIds(array $userIds): array
    {
        $userIds = collect($userIds)
            ->filter(fn ($id) => is_string($id) && trim($id) !== '')
            ->unique()
            ->values()
            ->all();

        if ($userIds === []) {
            return [];
        }

        $baseUrl = rtrim((string) config('administration.api.base_url'));

        if (trim($baseUrl) === '') {
            return [];
        }

        $jwtToken = (string) session('administrator.jwt', '');
        $cacheKey = 'administration.api.users_map.' . sha1($jwtToken);

        $usersMap = Cache::remember($cacheKey, 300, function () use ($baseUrl, $jwtToken): array {
            try {
                $request = Http::acceptJson()
                    ->connectTimeout(3)
                    ->timeout((int) config('administration.api.timeout_seconds'))
                    ->withHeaders([
                        'Accept-Language' => App::getLocale(),
                    ]);

                if ($jwtToken !== '') {
                    $request = $request->withToken($jwtToken);
                }

                $response = $request->get($baseUrl . '/api/admin/users');
            } catch (ConnectionException) {
                return [];
            }

            if (! $response->successful()) {
                return [];
            }

            $payload = $response->json();

            if (! is_array($payload)) {
                return [];
            }

            $rows = $payload;

            if (array_key_exists('data', $payload) && is_array($payload['data'])) {
                $rows = $payload['data'];
            }

            return collect($rows)
                ->filter(fn ($row) => is_array($row))
                ->mapWithKeys(function (array $row): array {
                    $userId = (string) ($row['userId'] ?? '');
                    $userName = (string) ($row['userName'] ?? '');

                    if (trim($userId) === '' || trim($userName) === '') {
                        return [];
                    }

                    return [$userId => $userName];
                })
                ->all();
        });

        $wanted = array_flip($userIds);

        return array_intersect_key($usersMap, $wanted);
    }
}
