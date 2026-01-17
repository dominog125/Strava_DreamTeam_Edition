<?php

namespace Tests\Feature;

use App\Models\Activity;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Tests\TestCase;

class AdministratorActivitiesPageTest extends TestCase
{
    use RefreshDatabase;

    public function test_activities_page_displays_activities_data(): void
    {
        $administrator = User::factory()->create([
            'is_administrator' => true,
        ]);

        $user = User::factory()->create([
            'name' => 'Jan Kowalski',
        ]);

        $createdAt = Carbon::create(2025, 12, 2, 18, 45);

        Activity::factory()->create([
            'user_id' => $user->id,
            'activity_type' => 'Bieg',
            'distance_kilometers' => 12.3,
            'created_at' => $createdAt,
        ]);

        $response = $this->actingAs($administrator)->get(route('administrator.activities'));

        $response->assertStatus(200);
        $response->assertSeeText('Lista aktywności');
        $response->assertSeeText('Jan Kowalski');
        $response->assertSeeText('Bieg');
        $response->assertSeeText($createdAt->format('Y-m-d H:i'));
        $response->assertSeeText('12,30 km');
    }

    public function test_activities_page_filters_by_type(): void
    {
        $administrator = User::factory()->create([
            'is_administrator' => true,
        ]);

        $user = User::factory()->create([
            'name' => 'Jan Kowalski',
        ]);

        $runningActivity = Activity::factory()->create([
            'user_id' => $user->id,
            'activity_type' => 'Bieg',
            'distance_kilometers' => 5.0,
        ]);

        Activity::factory()->create([
            'user_id' => $user->id,
            'activity_type' => 'Rower',
            'distance_kilometers' => 15.0,
        ]);

        $response = $this->actingAs($administrator)->get(route('administrator.activities', [
            'activity_type' => 'Bieg',
            'per_page' => 100,
        ]));

        $response->assertStatus(200);
        $response->assertSeeText('Bieg');

        $response->assertViewHas('activities', function ($paginator) use ($runningActivity) {
            $activities = $paginator->getCollection();

            return $activities->contains('id', $runningActivity->id)
                && $activities->every(fn ($activity) => $activity->activity_type === 'Bieg');
        });
    }
}
