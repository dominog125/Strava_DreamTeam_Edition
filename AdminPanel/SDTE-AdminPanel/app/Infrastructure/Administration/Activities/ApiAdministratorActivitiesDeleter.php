<?php

namespace App\Infrastructure\Administration\Activities;

use App\Application\Administration\Activities\AdministratorActivitiesDeleter;
use RuntimeException;

class ApiAdministratorActivitiesDeleter implements AdministratorActivitiesDeleter
{
    public function delete(string $activityUuid): void
    {
        throw new RuntimeException('ApiAdministratorActivitiesDeleter is not implemented.');
    }
}
