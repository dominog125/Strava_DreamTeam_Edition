<?php

namespace App\Infrastructure\Administration\Activities;

use App\Application\Administration\Activities\AdministratorActivitiesFilters;
use App\Application\Administration\Activities\AdministratorActivitiesReader;
use Illuminate\Pagination\LengthAwarePaginator;
use RuntimeException;

class ApiAdministratorActivitiesReader implements AdministratorActivitiesReader
{
    public function paginate(AdministratorActivitiesFilters $filters): LengthAwarePaginator
    {
        throw new RuntimeException('API data source for activities is not implemented yet.');
    }
}
