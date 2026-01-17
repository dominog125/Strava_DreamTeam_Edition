<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class SampleUsersSeeder extends Seeder
{
    public function run(): void
    {
        $namedUsers = [
            ['name' => 'Jan Kowalski',            'email' => 'jan.kowalski@example.com'],
            ['name' => 'Anna Nowak',              'email' => 'anna.nowak@example.com'],
            ['name' => 'Piotr Wiśniewski',        'email' => 'piotr.wisniewski@example.com'],
            ['name' => 'Katarzyna Kamińska',      'email' => 'katarzyna.kaminska@example.com'],
            ['name' => 'Tomasz Lewandowski',      'email' => 'tomasz.lewandowski@example.com'],
            ['name' => 'Paweł Zieliński',         'email' => 'pawel.zielinski@example.com'],
            ['name' => 'Agnieszka Woźniak',       'email' => 'agnieszka.wozniak@example.com'],
            ['name' => 'Michał Dąbrowski',        'email' => 'michal.dabrowski@example.com'],
            ['name' => 'Magdalena Jankowska',     'email' => 'magdalena.jankowska@example.com'],
            ['name' => 'Robert Mazur',            'email' => 'robert.mazur@example.com'],
        ];

        foreach ($namedUsers as $index => $userData) {
            User::factory()->create(array_merge($userData, [
                'is_discord_connected' => $index % 2 === 0,
                'is_google_connected' => $index % 3 === 0,
            ]));
        }

        $minimumUsers = 15;
        $remainingUsers = max(0, $minimumUsers - count($namedUsers));

        if ($remainingUsers > 0) {
            User::factory()->count($remainingUsers)->create();
        }
    }
}
