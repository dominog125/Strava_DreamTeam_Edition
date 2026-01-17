<?php

namespace App\Infrastructure\Administration\Users;

use App\Application\Administration\Users\AdministratorUsersFilters;
use App\Application\Administration\Users\AdministratorUsersReader;
use App\Models\User;
use Illuminate\Pagination\LengthAwarePaginator;

class DatabaseAdministratorUsersReader implements AdministratorUsersReader
{
    public function paginate(AdministratorUsersFilters $filters): LengthAwarePaginator
    {
        $query = User::query()
            ->where('is_administrator', false);

        if ($filters->searchName) {
            $query->where('name', 'like', '%' . $filters->searchName . '%');
        }

        if ($filters->searchEmail) {
            $query->where('email', 'like', '%' . $filters->searchEmail . '%');
        }

        return $query
            ->orderByDesc('created_at')
            ->paginate($filters->perPage);
    }
}
