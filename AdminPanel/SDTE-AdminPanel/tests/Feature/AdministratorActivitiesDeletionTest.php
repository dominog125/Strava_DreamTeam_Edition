<?php

namespace Tests\Feature\Administration;

use App\Models\Activity;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

class AdministratorActivitiesDeletionTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        config(['administration.data_source' => 'database']);
    }

    public function test_administrator_can_delete_activity(): void
    {
        $owner = User::factory()->create();

        $activity = Activity::query()->create([
            'user_id' => $owner->id,
            'activity_type' => 'Spacer',
            'distance_kilometers' => 15.65,
        ]);

        $administrator = $this->createAdministratorUser();

        $referer = route('administrator.activities', ['per_page' => 10]);

        $response = $this
            ->actingAs($administrator)
            ->from($referer)
            ->delete(route('administrator.activities.destroy', $activity));

        $response
            ->assertRedirect($referer)
            ->assertSessionHas('status', 'Aktywność została usunięta.');

        $this->assertDatabaseMissing('activities', ['id' => $activity->id]);
    }

    public function test_guest_cannot_delete_activity_even_if_they_know_the_url(): void
    {
        $owner = User::factory()->create();

        $activity = Activity::query()->create([
            'user_id' => $owner->id,
            'activity_type' => 'Bieg',
            'distance_kilometers' => 49.94,
        ]);

        $response = $this->delete(route('administrator.activities.destroy', $activity));

        $response->assertRedirect(route('login'));

        $this->assertDatabaseHas('activities', ['id' => $activity->id]);
    }

    public function test_authenticated_non_admin_cannot_delete_activity(): void
    {
        $owner = User::factory()->create();

        $activity = Activity::query()->create([
            'user_id' => $owner->id,
            'activity_type' => 'Bieg',
            'distance_kilometers' => 10.00,
        ]);

        $nonAdmin = User::factory()->create();

        $response = $this
            ->actingAs($nonAdmin)
            ->delete(route('administrator.activities.destroy', $activity));

        $this->assertTrue(in_array($response->status(), [302, 403], true));

        $this->assertDatabaseHas('activities', ['id' => $activity->id]);
    }

    private function createAdministratorUser(): User
    {
        $user = User::factory()->create();

        if (Schema::hasColumn('users', 'is_administrator')) {
            $user->forceFill(['is_administrator' => true])->save();
        }

        if (Schema::hasColumn('users', 'is_admin')) {
            $user->forceFill(['is_admin' => true])->save();
        }

        if (Schema::hasColumn('users', 'role')) {
            $user->forceFill(['role' => 'administrator'])->save();
        }

        return $user;
    }
}
