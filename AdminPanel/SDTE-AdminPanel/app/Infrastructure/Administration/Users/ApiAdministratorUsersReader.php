<?php

namespace App\Infrastructure\Administration\Users;

use App\Application\Administration\Users\AdministratorUsersFilters;
use App\Application\Administration\Users\AdministratorUsersReader;
use Illuminate\Pagination\LengthAwarePaginator;
use RuntimeException;

class ApiAdministratorUsersReader implements AdministratorUsersReader
{
    public function paginate(AdministratorUsersFilters $filters): LengthAwarePaginator
    {
        throw new RuntimeException('API data source for users is not implemented yet.');
    }
}
