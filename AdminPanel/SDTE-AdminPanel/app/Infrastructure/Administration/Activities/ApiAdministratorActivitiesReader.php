<?php

namespace App\Infrastructure\Administration\Activities;

use App\Application\Administration\Activities\AdministratorActivitiesFilters;
use App\Application\Administration\Activities\AdministratorActivitiesReader;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Pagination\Paginator;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\App;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Fluent;
use Illuminate\Support\Str;
use RuntimeException;

class ApiAdministratorActivitiesReader implements AdministratorActivitiesReader
{
    public function paginate(AdministratorActivitiesFilters $filters): LengthAwarePaginator
    {
        $baseUrl = rtrim((string) config('administration.api.base_url'));
        $timeoutSeconds = (int) config('administration.api.timeout_seconds');

        if (trim($baseUrl) === '') {
            throw new RuntimeException(__('ui.api_configuration_missing'));
        }

        $jwtToken = (string) session('administrator.jwt', '');
        $locale = App::getLocale();

        try {
            $request = Http::acceptJson()
                ->connectTimeout(3)
                ->timeout($timeoutSeconds)
                ->withHeaders([
                    'Accept-Language' => $locale,
                ]);

            if ($jwtToken !== '') {
                $request = $request->withToken($jwtToken);
            }

            $response = $request->get($baseUrl . '/api/Activities');
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

        $items = collect($payload)->filter(fn ($row) => is_array($row));

        $userNamesByUserId = $this->resolveUserNamesMap($baseUrl, $timeoutSeconds, $jwtToken, $locale);

        $items = $items->map(function (array $row) use ($userNamesByUserId): array {
            $authorId = (string) ($row['authorId'] ?? '');

            if ($authorId !== '') {
                $row['authorName'] = $userNamesByUserId[$authorId] ?? $authorId;
            }

            return $row;
        });

        if ($filters->searchUserName) {
            $needle = trim($filters->searchUserName);

            if ($needle !== '') {
                $items = $items->filter(function (array $row) use ($needle): bool {
                    $authorId = (string) ($row['authorId'] ?? '');
                    $authorName = (string) ($row['authorName'] ?? '');
                    $name = (string) ($row['name'] ?? '');
                    $description = (string) ($row['description'] ?? '');

                    return Str::contains($authorName, $needle, ignoreCase: true)
                        || Str::contains($authorId, $needle, ignoreCase: true)
                        || Str::contains($name, $needle, ignoreCase: true)
                        || Str::contains($description, $needle, ignoreCase: true);
                });
            }
        }

        if ($filters->activityType) {
            $selectedCategoryName = trim($filters->activityType);

            if ($selectedCategoryName !== '') {
                $items = $items->filter(fn (array $row) => (string) ($row['categoryName'] ?? '') === $selectedCategoryName);
            }
        }

        if ($filters->dateFrom || $filters->dateTo) {
            $from = $filters->dateFrom ? Carbon::parse($filters->dateFrom)->startOfDay() : null;
            $to = $filters->dateTo ? Carbon::parse($filters->dateTo)->endOfDay() : null;

            $items = $items->filter(function (array $row) use ($from, $to): bool {
                $createdAtRaw = (string) ($row['createdAt'] ?? '');

                if ($createdAtRaw === '') {
                    return false;
                }

                try {
                    $createdAt = Carbon::parse($createdAtRaw);
                } catch (\Throwable) {
                    return false;
                }

                if ($from && $createdAt->lt($from)) {
                    return false;
                }

                if ($to && $createdAt->gt($to)) {
                    return false;
                }

                return true;
            });
        }

        if ($filters->distanceMin !== null) {
            $min = (float) $filters->distanceMin;
            $items = $items->filter(fn (array $row) => (float) ($row['lengthInKm'] ?? 0) >= $min);
        }

        if ($filters->distanceMax !== null) {
            $max = (float) $filters->distanceMax;
            $items = $items->filter(fn (array $row) => (float) ($row['lengthInKm'] ?? 0) <= $max);
        }

        $items = $items->sortByDesc(function (array $row): int {
            $createdAtRaw = (string) ($row['createdAt'] ?? '');

            if ($createdAtRaw === '') {
                return 0;
            }

            try {
                return Carbon::parse($createdAtRaw)->getTimestamp();
            } catch (\Throwable) {
                return 0;
            }
        })->values();

        $pageName = 'page';
        $currentPage = Paginator::resolveCurrentPage($pageName);
        $perPage = $filters->perPage;
        $total = $items->count();

        $pageItems = $items
            ->slice(($currentPage - 1) * $perPage, $perPage)
            ->values()
            ->map(fn (array $row) => new Fluent($row));

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

    private function resolveUserNamesMap(string $baseUrl, int $timeoutSeconds, string $jwtToken, string $locale): array
    {
        $cacheKey = 'administration.api.users_map.' . sha1($baseUrl . '|' . $jwtToken);

        return Cache::remember($cacheKey, 300, function () use ($baseUrl, $timeoutSeconds, $jwtToken, $locale): array {
            try {
                $request = Http::acceptJson()
                    ->connectTimeout(3)
                    ->timeout($timeoutSeconds)
                    ->withHeaders([
                        'Accept-Language' => $locale,
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
    }
}
