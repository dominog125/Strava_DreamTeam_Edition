<?php

namespace App\Infrastructure\Administration\Dashboard;

use App\Application\Administration\Dashboard\AdministratorDashboardStatistics;
use App\Application\Administration\Dashboard\AdministratorDashboardStatisticsReader;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class ApiAdministratorDashboardStatisticsReader implements AdministratorDashboardStatisticsReader
{
    public function read(): AdministratorDashboardStatistics
    {
        $baseUrl = rtrim((string) config('administration.api.base_url'), '/');
        $timeoutSeconds = (int) config('administration.api.timeout_seconds', 10);

        if ($baseUrl === '') {
            Log::error('ADMINISTRATION_API_BASE_URL is not set (administration.api.base_url is empty).');

            return new AdministratorDashboardStatistics(
                userCount: 0,
                activityCount: 0,
                totalDistanceKilometers: 0.0
            );
        }

        $jwtToken = (string) session('administrator.jwt', '');

        try {
            $request = Http::acceptJson()->timeout($timeoutSeconds);

            if ($jwtToken !== '') {
                $request = $request->withToken($jwtToken);
            }

            $response = $request->get($baseUrl . '/api/admin/stats/global');
        } catch (ConnectionException $exception) {
            Log::warning('Dashboard stats API connection failed.', ['exception' => $exception]);

            return new AdministratorDashboardStatistics(
                userCount: 0,
                activityCount: 0,
                totalDistanceKilometers: 0.0
            );
        }

        if (! $response->successful()) {
            Log::warning('Dashboard stats API returned non-success response.', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);

            return new AdministratorDashboardStatistics(
                userCount: 0,
                activityCount: 0,
                totalDistanceKilometers: 0.0
            );
        }

        $data = $response->json();

        return new AdministratorDashboardStatistics(
            userCount: (int) ($data['usersCount'] ?? 0),
            activityCount: (int) ($data['activitiesCount'] ?? 0),
            totalDistanceKilometers: (float) ($data['totalDistanceKm'] ?? 0),
        );
    }
}
