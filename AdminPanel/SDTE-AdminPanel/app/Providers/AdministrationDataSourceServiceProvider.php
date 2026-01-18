<?php

namespace App\Providers;

use App\Application\Administration\Activities\AdministratorActivitiesDeleter;
use App\Application\Administration\Activities\AdministratorActivitiesReader;
use App\Application\Administration\Activities\AdministratorActivityCategoriesReader;
use App\Application\Administration\Authentication\AdministratorAuthenticator;
use App\Application\Administration\Dashboard\AdministratorDashboardStatisticsReader;
use App\Application\Administration\Users\AdministratorUsersReader;
use App\Application\Administration\Users\AdministratorUserNamesReader;
use App\Infrastructure\Administration\Activities\ApiAdministratorActivitiesDeleter;
use App\Infrastructure\Administration\Activities\ApiAdministratorActivitiesReader;
use App\Infrastructure\Administration\Activities\ApiAdministratorActivityCategoriesReader;
use App\Infrastructure\Administration\Activities\DatabaseAdministratorActivitiesDeleter;
use App\Infrastructure\Administration\Activities\DatabaseAdministratorActivitiesReader;
use App\Infrastructure\Administration\Activities\DatabaseAdministratorActivityCategoriesReader;
use App\Infrastructure\Administration\Authentication\ApiAdministratorAuthenticator;
use App\Infrastructure\Administration\Authentication\DatabaseAdministratorAuthenticator;
use App\Infrastructure\Administration\Dashboard\ApiAdministratorDashboardStatisticsReader;
use App\Infrastructure\Administration\Dashboard\DatabaseAdministratorDashboardStatisticsReader;
use App\Infrastructure\Administration\Users\ApiAdministratorUsersReader;
use App\Infrastructure\Administration\Users\DatabaseAdministratorUsersReader;
use App\Infrastructure\Administration\Users\ApiAdministratorUserNamesReader;
use App\Infrastructure\Administration\Users\DatabaseAdministratorUserNamesReader;
use Illuminate\Support\ServiceProvider;

class AdministrationDataSourceServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $dataSource = config('administration.data_source');

        $this->app->bind(
            AdministratorActivitiesReader::class,
            $dataSource === 'api' ? ApiAdministratorActivitiesReader::class : DatabaseAdministratorActivitiesReader::class
        );

        $this->app->bind(
            AdministratorActivitiesDeleter::class,
            $dataSource === 'api' ? ApiAdministratorActivitiesDeleter::class : DatabaseAdministratorActivitiesDeleter::class
        );

        $this->app->bind(
            AdministratorActivityCategoriesReader::class,
            $dataSource === 'api' ? ApiAdministratorActivityCategoriesReader::class : DatabaseAdministratorActivityCategoriesReader::class
        );

        $this->app->bind(
            AdministratorUsersReader::class,
            $dataSource === 'api' ? ApiAdministratorUsersReader::class : DatabaseAdministratorUsersReader::class
        );
        
        $this->app->bind(
            AdministratorUserNamesReader::class,
            $dataSource === 'api' ? ApiAdministratorUserNamesReader::class : DatabaseAdministratorUserNamesReader::class
        );

        $this->app->bind(
            AdministratorDashboardStatisticsReader::class,
            $dataSource === 'api'
                ? ApiAdministratorDashboardStatisticsReader::class
                : DatabaseAdministratorDashboardStatisticsReader::class
        );

        $this->app->bind(
            AdministratorAuthenticator::class,
            $dataSource === 'api' ? ApiAdministratorAuthenticator::class : DatabaseAdministratorAuthenticator::class
        );
    }
}
