<?php

namespace App\Application\Administration\Activities;

interface AdministratorActivitiesDeleter
{
    public function delete(string $activityUuid): void;
}
