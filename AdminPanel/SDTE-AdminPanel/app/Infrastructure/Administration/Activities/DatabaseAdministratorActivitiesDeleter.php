<?php

namespace App\Infrastructure\Administration\Activities;

use App\Application\Administration\Activities\AdministratorActivitiesDeleter;
use App\Models\Activity;

class DatabaseAdministratorActivitiesDeleter implements AdministratorActivitiesDeleter
{
    public function delete(string $activityUuid): void
    {
        Activity::query()
            ->where('uuid', $activityUuid)
            ->delete();
    }
}
