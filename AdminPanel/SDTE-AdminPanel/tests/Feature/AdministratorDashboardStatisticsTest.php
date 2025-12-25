<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdministratorDashboardStatisticsTest extends TestCase
{
    use RefreshDatabase;

    public function test_administrator_can_see_global_statistics_from_controller(): void
    {
        $administrator = User::factory()->create([
            'is_administrator' => true,
        ]);

        $response = $this->actingAs($administrator)->get('/admin');

        $response->assertStatus(200);

        $response->assertViewHas('userCount', 42);
        $response->assertViewHas('activityCount', 123);
        $response->assertViewHas('totalDistanceKilometers', 987.65);

        $response->assertSeeText('Podsumowanie systemu');
        $response->assertSeeText('Liczba użytkowników');
        $response->assertSeeText('Liczba aktywności');
        $response->assertSeeText('Łączny dystans [km]');
    }

    public function test_guest_is_redirected_from_dashboard_to_login(): void
    {
        $response = $this->get('/admin');

        $response->assertRedirect(route('login'));
    }

    public function test_non_administrator_is_redirected_from_dashboard_to_login(): void
    {
        $user = User::factory()->create([
            'is_administrator' => false,
        ]);

        $response = $this->actingAs($user)->get('/admin');

        $response->assertRedirect(route('login'));
    }
}
