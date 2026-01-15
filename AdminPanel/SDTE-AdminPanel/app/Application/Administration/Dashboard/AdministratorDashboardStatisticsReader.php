<?php

namespace App\Application\Administration\Dashboard;

interface AdministratorDashboardStatisticsReader
{
    public function read(): AdministratorDashboardStatistics;
}