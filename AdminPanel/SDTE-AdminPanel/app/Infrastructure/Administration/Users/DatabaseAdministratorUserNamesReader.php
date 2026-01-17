<?php

namespace App\Infrastructure\Administration\Users;

use App\Application\Administration\Users\AdministratorUserNamesReader;
use App\Models\User;

class DatabaseAdministratorUserNamesReader implements AdministratorUserNamesReader
{
    public function getUserNamesByUserIds(array $userIds): array
    {
        $userIds = collect($userIds)
            ->filter(fn ($id) => is_string($id) && trim($id) !== '')
            ->unique()
            ->values()
            ->all();

        if ($userIds === []) {
            return [];
        }

        return User::query()
            ->whereIn('id', $userIds)
            ->pluck('name', 'id')
            ->map(fn ($name) => (string) $name)
            ->all();
    }
}
