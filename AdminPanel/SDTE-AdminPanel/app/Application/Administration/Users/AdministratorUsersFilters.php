<?php

namespace App\Application\Administration\Users;

class AdministratorUsersFilters
{
    public function __construct(
        public readonly ?string $searchName,
        public readonly ?string $searchEmail,
        public readonly int $perPage,
    ) {
    }
}
