<?php

namespace App\Infrastructure\Administration\Dashboard;

use App\Application\Administration\Dashboard\AdministratorDashboardStatistics;
use App\Application\Administration\Dashboard\AdministratorDashboardStatisticsReader;
use App\Models\Activity;
use App\Models\User;

class DatabaseAdministratorDashboardStatisticsReader implements AdministratorDashboardStatisticsReader
{
    public function read(): AdministratorDashboardStatistics
    {
        $userCount = User::query()
            ->where('is_administrator', false)
            ->count();

        $activityCount = Activity::query()->count();

        $totalDistanceKilometers = (float) Activity::query()->sum('distance_kilometers');

        return new AdministratorDashboardStatistics(
            userCount: $userCount,
            activityCount: $activityCount,
            totalDistanceKilometers: $totalDistanceKilometers,
        );
    }
}
