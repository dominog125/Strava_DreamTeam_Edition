<?php

namespace Tests\Feature;

use App\Http\Middleware\AdministratorAuthorizationMiddleware;
use App\Models\Activity;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminLocalizationTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_users_page_is_translated_in_polish_and_english(): void
    {
        $viewer = User::factory()->create();
        User::factory()->count(11)->create();

        $this->actingAs($viewer);
        $this->withoutMiddleware(AdministratorAuthorizationMiddleware::class);

        $this
            ->from(route('administrator.users'))
            ->get(route('locale.switch', ['locale' => 'pl']))
            ->assertRedirect(route('administrator.users'));

        $pl = $this->get(route('administrator.users'));
        $pl->assertOk();
        $pl->assertSee('lang="pl"', false);
        $pl->assertSee($this->translated('ui.nav_users', 'pl'));
        $pl->assertSee($this->translated('pagination.next', 'pl'), false);
        $pl->assertDontSee('ui.');

        $this
            ->from(route('administrator.users'))
            ->get(route('locale.switch', ['locale' => 'en']))
            ->assertRedirect(route('administrator.users'));

        $en = $this->get(route('administrator.users'));
        $en->assertOk();
        $en->assertSee('lang="en"', false);
        $en->assertSee($this->translated('ui.nav_users', 'en'));
        $en->assertSee($this->translated('pagination.next', 'en'), false);
        $en->assertDontSee('ui.');
    }

    public function test_admin_activities_page_translates_activity_type_labels_in_english(): void
    {
        $viewer = User::factory()->create();

        Activity::query()->create([
            'user_id' => $viewer->id,
            'activity_type' => 'Spacer',
            'distance_kilometers' => 12.34,
        ]);

        $this->actingAs($viewer);
        $this->withoutMiddleware(AdministratorAuthorizationMiddleware::class);

        $this
            ->from(route('administrator.activities'))
            ->get(route('locale.switch', ['locale' => 'en']))
            ->assertRedirect(route('administrator.activities'));

        $response = $this->get(route('administrator.activities'));

        $response->assertOk();
        $response->assertSee('lang="en"', false);
        $response->assertDontSee('ui.');
        $response->assertSee(User::query()->first()->name);
        $response->assertSee($this->translated('activity_types.walk', 'en'));
    }

    private function translated(string $key, string $locale): string
    {
        $current = app()->getLocale();

        app()->setLocale($locale);
        $value = __($key);
        app()->setLocale($current);

        return $value;
    }
}
