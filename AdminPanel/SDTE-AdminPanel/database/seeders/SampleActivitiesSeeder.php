<?php

namespace Database\Seeders;

use App\Models\Activity;
use App\Models\User;
use Illuminate\Database\Seeder;

class SampleActivitiesSeeder extends Seeder
{
    public function run(): void
    {
        $users = User::query()->where('is_administrator', false)->get();

        if ($users->isEmpty()) {
            return;
        }

        foreach ($users as $user) {
            Activity::factory()
                ->count(random_int(1, 4))
                ->create([
                    'user_id' => $user->id,
                ]);
        }
    }
}
