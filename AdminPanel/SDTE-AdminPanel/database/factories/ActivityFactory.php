<?php

namespace Database\Factories;

use App\Models\Activity;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class ActivityFactory extends Factory
{
    protected $model = Activity::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'activity_type' => fake()->randomElement(['Bieg', 'Spacer', 'Rower']),
            'distance_kilometers' => fake()->randomFloat(2, 0.5, 50),
            'created_at' => fake()->dateTimeBetween('-60 days', 'now'),
            'updated_at' => now(),
        ];
    }
}
