<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Tests\TestCase;

class AdministratorUsersPageTest extends TestCase
{
    use RefreshDatabase;

    public function test_users_page_displays_users_data(): void
    {
        $administrator = User::factory()->create([
            'is_administrator' => true,
        ]);

        $createdAt = Carbon::create(2025, 12, 1, 9, 30);

        $user = User::factory()->create([
            'name' => 'Jan Kowalski',
            'email' => 'jan.kowalski@example.com',
            'created_at' => $createdAt,
            'is_discord_connected' => true,
            'is_google_connected' => false,
        ]);

        $response = $this->actingAs($administrator)->get(route('administrator.users'));

        $response->assertStatus(200);
        $response->assertSeeText('Lista użytkowników');
        $response->assertSeeText($user->name);
        $response->assertSeeText($user->email);
        $response->assertSeeText($createdAt->format('Y-m-d H:i'));
        $response->assertSeeText('Tak');
        $response->assertSeeText('Nie');
    }

    public function test_users_page_filters_by_name(): void
    {
        $administrator = User::factory()->create([
            'is_administrator' => true,
        ]);

        User::factory()->create([
            'name' => 'Jan Kowalski',
            'email' => 'jan.kowalski@example.com',
        ]);

        User::factory()->create([
            'name' => 'Anna Nowak',
            'email' => 'anna.nowak@example.com',
        ]);

        $response = $this->actingAs($administrator)->get(route('administrator.users', [
            'search_name' => 'Jan',
            'per_page' => 100,
        ]));

        $response->assertStatus(200);
        $response->assertSeeText('Jan Kowalski');
        $response->assertDontSeeText('Anna Nowak');
    }
}
