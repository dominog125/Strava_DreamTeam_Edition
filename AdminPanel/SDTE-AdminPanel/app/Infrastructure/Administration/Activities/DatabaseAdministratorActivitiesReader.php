<?php

namespace App\Infrastructure\Administration\Activities;

use App\Application\Administration\Activities\AdministratorActivitiesFilters;
use App\Application\Administration\Activities\AdministratorActivitiesReader;
use App\Models\Activity;
use Illuminate\Pagination\LengthAwarePaginator;

class DatabaseAdministratorActivitiesReader implements AdministratorActivitiesReader
{
    public function paginate(AdministratorActivitiesFilters $filters): LengthAwarePaginator
    {
        $query = Activity::query()->with('user');

        if ($filters->searchUserName) {
            $search = $filters->searchUserName;

            $query->whereHas('user', function ($userQuery) use ($search) {
                $userQuery->where('name', 'like', '%' . $search . '%');
            });
        }

        if ($filters->activityType) {
            $query->where('activity_type', $filters->activityType);
        }

        if ($filters->dateFrom) {
            $query->whereDate('created_at', '>=', $filters->dateFrom);
        }

        if ($filters->dateTo) {
            $query->whereDate('created_at', '<=', $filters->dateTo);
        }

        if ($filters->distanceMin !== null) {
            $query->where('distance_kilometers', '>=', $filters->distanceMin);
        }

        if ($filters->distanceMax !== null) {
            $query->where('distance_kilometers', '<=', $filters->distanceMax);
        }

        return $query
            ->orderByDesc('created_at')
            ->paginate($filters->perPage);
    }
}
