<?php

namespace App\Application\Administration\Dashboard;

class AdministratorDashboardStatistics
{
    public function __construct(
        public readonly int $userCount,
        public readonly int $activityCount,
        public readonly float $totalDistanceKilometers,
    ) {
    }
}
