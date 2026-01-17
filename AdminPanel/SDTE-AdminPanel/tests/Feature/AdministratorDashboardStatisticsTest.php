<?php

namespace Tests\Feature;

use App\Application\Administration\Dashboard\AdministratorDashboardStatistics;
use App\Application\Administration\Dashboard\AdministratorDashboardStatisticsReader;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdministratorDashboardStatisticsTest extends TestCase
{
    use RefreshDatabase;

    public function test_administrator_can_see_global_statistics_from_reader(): void
    {
        $administrator = User::factory()->create([
            'is_administrator' => true,
        ]);

        $this->app->instance(
            AdministratorDashboardStatisticsReader::class,
            new class implements AdministratorDashboardStatisticsReader {
                public function read(): AdministratorDashboardStatistics
                {
                    return new AdministratorDashboardStatistics(
                        userCount: 1234,
                        activityCount: 567,
                        totalDistanceKilometers: 8901.25
                    );
                }
            }
        );

        $response = $this->actingAs($administrator)->get(route('administrator.dashboard'));

        $response->assertStatus(200);
        $response->assertSeeText('1 234');
        $response->assertSeeText('567');
        $response->assertSeeText('8 901,25');
    }

    public function test_guest_is_redirected_from_dashboard_to_login(): void
    {
        $response = $this->get(route('administrator.dashboard'));

        $response->assertRedirect(route('login'));
    }

    public function test_non_administrator_is_redirected_from_dashboard_to_login(): void
    {
        $user = User::factory()->create([
            'is_administrator' => false,
        ]);

        $response = $this->actingAs($user)->get(route('administrator.dashboard'));

        $response->assertRedirect(route('login'));
    }
}
