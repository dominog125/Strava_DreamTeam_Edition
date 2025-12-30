<?php

namespace App\Application\Administration\Activities;

class AdministratorActivitiesFilters
{
    public function __construct(
        public readonly ?string $searchUserName,
        public readonly ?string $activityType,
        public readonly ?string $dateFrom,
        public readonly ?string $dateTo,
        public readonly ?float $distanceMin,
        public readonly ?float $distanceMax,
        public readonly int $perPage,
    ) {
    }
}
