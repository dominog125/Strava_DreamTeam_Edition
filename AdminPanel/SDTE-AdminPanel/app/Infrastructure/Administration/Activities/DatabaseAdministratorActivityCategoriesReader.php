<?php

namespace App\Infrastructure\Administration\Activities;

use App\Application\Administration\Activities\AdministratorActivityCategoriesReader;
use App\Models\Activity;

class DatabaseAdministratorActivityCategoriesReader implements AdministratorActivityCategoriesReader
{
    public function listNames(): array
    {
        return Activity::query()
            ->select('activity_type')
            ->distinct()
            ->orderBy('activity_type')
            ->pluck('activity_type')
            ->filter(fn ($value) => is_string($value) && trim($value) !== '')
            ->values()
            ->all();
    }
}
