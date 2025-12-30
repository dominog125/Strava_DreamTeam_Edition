<?php

namespace App\Application\Administration\Activities;

use Illuminate\Pagination\LengthAwarePaginator;

interface AdministratorActivitiesReader
{
    public function paginate(AdministratorActivitiesFilters $filters): LengthAwarePaginator;
}
