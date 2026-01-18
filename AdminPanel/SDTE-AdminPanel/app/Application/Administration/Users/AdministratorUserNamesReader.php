<?php

namespace App\Application\Administration\Users;

interface AdministratorUserNamesReader
{
    public function getUserNamesByUserIds(array $userIds): array;
}
