<?php

namespace App\Application\Administration\Users;

use Illuminate\Pagination\LengthAwarePaginator;

interface AdministratorUsersReader
{
    public function paginate(AdministratorUsersFilters $filters): LengthAwarePaginator;
}
