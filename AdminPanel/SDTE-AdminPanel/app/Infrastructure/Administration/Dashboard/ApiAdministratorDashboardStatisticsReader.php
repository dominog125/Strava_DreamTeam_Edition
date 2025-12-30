<?php

namespace App\Infrastructure\Administration\Dashboard;

use App\Application\Administration\Dashboard\AdministratorDashboardStatistics;
use App\Application\Administration\Dashboard\AdministratorDashboardStatisticsReader;
use RuntimeException;

class ApiAdministratorDashboardStatisticsReader implements AdministratorDashboardStatisticsReader
{
    public function read(): AdministratorDashboardStatistics
    {
        throw new RuntimeException('API data source for dashboard statistics is not implemented yet.');
    }
}
