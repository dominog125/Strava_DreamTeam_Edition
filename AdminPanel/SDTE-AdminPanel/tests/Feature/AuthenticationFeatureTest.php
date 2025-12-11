<?php

namespace Tests\Feature;

use App\Http\Middleware\VerifyCsrfToken;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthenticationFeatureTest extends TestCase
{
    use RefreshDatabase;

    private function disableCsrfMiddleware(): void
    {
        $this->withoutMiddleware(VerifyCsrfToken::class);
    }

    public function test_guest_can_view_login_page(): void
    {
        $response = $this->get('/login');

        $response->assertStatus(200);
        $response->assertSee('Panel logowania');
    }

    public function test_guest_is_redirected_from_admin_to_login(): void
    {
        $response = $this->get('/admin');

        $response->assertRedirect(route('login'));
    }

    public function test_administrator_can_log_in_with_correct_name_and_password(): void
    {
        $this->disableCsrfMiddleware();

        $administrator = User::factory()->create([
            'name' => 'Admin',
            'password' => bcrypt('haslo123'),
            'is_administrator' => true,
        ]);

        $response = $this->post(route('login.process'), [
            'login' => 'Admin',
            'password' => 'haslo123',
        ]);

        $response->assertRedirect(route('administrator.dashboard'));
        $this->assertAuthenticatedAs($administrator);
    }

    public function test_login_fails_with_incorrect_password(): void
    {
        $this->disableCsrfMiddleware();

        User::factory()->create([
            'name' => 'Admin',
            'password' => bcrypt('haslo123'),
            'is_administrator' => true,
        ]);

        $response = $this->post(route('login.process'), [
            'login' => 'Admin',
            'password' => 'zle_haslo',
        ]);

        $response->assertRedirect();
        $response->assertSessionHasErrors('password');
        $this->assertGuest();
    }

    public function test_non_administrator_cannot_log_in(): void
    {
        $this->disableCsrfMiddleware();

        User::factory()->create([
            'name' => 'User',
            'password' => bcrypt('haslo123'),
            'is_administrator' => false,
        ]);

        $response = $this->post(route('login.process'), [
            'login' => 'User',
            'password' => 'haslo123',
        ]);

        $response->assertRedirect();
        $response->assertSessionHasErrors('password');
        $this->assertGuest();
    }

    public function test_administrator_can_logout(): void
    {
        $this->disableCsrfMiddleware();

        $administrator = User::factory()->create([
            'name' => 'Admin',
            'password' => bcrypt('haslo123'),
            'is_administrator' => true,
        ]);

        $this->actingAs($administrator);

        $response = $this->post(route('logout'));

        $response->assertRedirect(route('login'));
        $this->assertGuest();
    }
}
