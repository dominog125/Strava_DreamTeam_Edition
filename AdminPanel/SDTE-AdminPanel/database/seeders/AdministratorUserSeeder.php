<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class AdministratorUserSeeder extends Seeder
{
    public function run(): void
    {
        $name = env('ADMINISTRATION_SEED_NAME');
        $email = env('ADMINISTRATION_SEED_EMAIL');
        $password = env('ADMINISTRATION_SEED_PASSWORD');

        if (! $name || ! $email || ! $password) {
            return;
        }

        User::updateOrCreate(
            ['email' => $email],
            [
                'name' => $name,
                'password' => bcrypt($password),
                'is_administrator' => true,
            ]
        );
    }
}