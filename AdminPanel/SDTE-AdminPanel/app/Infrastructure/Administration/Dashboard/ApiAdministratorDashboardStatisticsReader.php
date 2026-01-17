<?php

namespace App\Infrastructure\Administration\Dashboard;

use App\Application\Administration\Dashboard\AdministratorDashboardStatistics;
use App\Application\Administration\Dashboard\AdministratorDashboardStatisticsReader;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\App;
use Illuminate\Support\Facades\Http;
use RuntimeException;

class ApiAdministratorDashboardStatisticsReader implements AdministratorDashboardStatisticsReader
{
    public function read(): AdministratorDashboardStatistics
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
                ->timeout($timeoutSeconds)
                ->withHeaders([
                    'Accept-Language' => $locale,
                ]);

            if ($jwtToken !== '') {
                $request = $request->withToken($jwtToken);
            }

            $response = $request->get($baseUrl . '/api/admin/stats/global');
        } catch (ConnectionException) {
            throw new RuntimeException(__('ui.api_connection_error'));
        }

        if (in_array($response->status(), [401, 403], true)) {
            throw new RuntimeException(__('ui.api_auth_error'));
        }

        if (! $response->successful()) {
            throw new RuntimeException(__('ui.api_invalid_response'));
        }

        $data = $response->json();

        if (! is_array($data)) {
            throw new RuntimeException(__('ui.api_invalid_response'));
        }

        return new AdministratorDashboardStatistics(
            userCount: (int) ($data['usersCount'] ?? 0),
            activityCount: (int) ($data['activitiesCount'] ?? 0),
            totalDistanceKilometers: (float) ($data['totalDistanceKm'] ?? 0),
        );
    }
}
