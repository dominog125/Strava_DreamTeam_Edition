<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class LocaleSwitchTest extends TestCase
{
    use RefreshDatabase;

    public function test_it_switches_locale_and_redirects_back(): void
    {
        $this
            ->from(route('login'))
            ->get(route('locale.switch', ['locale' => 'en']))
            ->assertRedirect(route('login'))
            ->assertSessionHas('locale', 'en');

        $response = $this->get(route('login'));

        $response->assertOk();
        $response->assertSee('lang="en"', false);
        $response->assertDontSee('ui.');
    }

    public function test_it_returns_404_for_invalid_locale(): void
    {
        $this->get(route('locale.switch', ['locale' => 'de']))->assertNotFound();
    }
}
