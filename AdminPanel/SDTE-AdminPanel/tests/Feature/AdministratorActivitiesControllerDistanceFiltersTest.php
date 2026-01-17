<?php

namespace Tests\Feature;

use App\Infrastructure\Administration\Authentication\ApiAdministratorAuthenticator;
use Illuminate\Support\Facades\App;
use Illuminate\Support\Facades\Http;
use PHPUnit\Framework\Attributes\Group;
use Tests\TestCase;

#[Group('administration-api')]
class AdministratorActivitiesControllerDistanceFiltersTest extends TestCase
{
    public function test_it_fails_when_base_url_missing(): void
    {
        config([
            'administration.api.base_url' => '',
            'administration.api.timeout_seconds' => 10,
        ]);

        $result = (new ApiAdministratorAuthenticator())->authenticate('a@a.pl', 'x');

        $this->assertFalse($result->isSuccessful);
        $this->assertSame(__('ui.api_configuration_missing'), $result->failureMessage);
    }

    public function test_it_fails_on_connection_exception(): void
    {
        App::setLocale('pl');

        config([
            'administration.api.base_url' => 'https://example.test',
            'administration.api.timeout_seconds' => 10,
        ]);

        Http::preventStrayRequests();

        Http::fake([
            'example.test/*' => Http::failedConnection(),
        ]);

        $result = (new ApiAdministratorAuthenticator())->authenticate('a@a.pl', 'x');

        $this->assertFalse($result->isSuccessful);
        $this->assertSame(__('ui.api_connection_error'), $result->failureMessage);
    }

    public function test_it_fails_on_invalid_credentials(): void
    {
        App::setLocale('pl');

        config([
            'administration.api.base_url' => 'https://example.test',
            'administration.api.timeout_seconds' => 10,
        ]);

        Http::preventStrayRequests();

        Http::fake([
            'example.test/api/Auth/Login' => Http::response([], 401),
        ]);

        $result = (new ApiAdministratorAuthenticator())->authenticate('a@a.pl', 'bad');

        $this->assertFalse($result->isSuccessful);
        $this->assertSame(__('ui.invalid_credentials'), $result->failureMessage);
    }

    public function test_it_fails_on_non_success_response(): void
    {
        App::setLocale('pl');

        config([
            'administration.api.base_url' => 'https://example.test',
            'administration.api.timeout_seconds' => 10,
        ]);

        Http::preventStrayRequests();

        Http::fake([
            'example.test/api/Auth/Login' => Http::response(['x' => 1], 500),
        ]);

        $result = (new ApiAdministratorAuthenticator())->authenticate('a@a.pl', 'x');

        $this->assertFalse($result->isSuccessful);
        $this->assertSame(__('ui.api_auth_error'), $result->failureMessage);
    }

    public function test_it_fails_on_invalid_payload(): void
    {
        App::setLocale('pl');

        config([
            'administration.api.base_url' => 'https://example.test',
            'administration.api.timeout_seconds' => 10,
        ]);

        Http::preventStrayRequests();

        Http::fake([
            'example.test/api/Auth/Login' => Http::response(['jwtToken' => 't'], 200),
        ]);

        $result = (new ApiAdministratorAuthenticator())->authenticate('a@a.pl', 'x');

        $this->assertFalse($result->isSuccessful);
        $this->assertSame(__('ui.api_invalid_response'), $result->failureMessage);
    }

    public function test_it_succeeds_and_sets_token_and_username(): void
    {
        App::setLocale('pl');

        config([
            'administration.api.base_url' => 'https://example.test',
            'administration.api.timeout_seconds' => 10,
        ]);

        Http::preventStrayRequests();

        Http::fake([
            'example.test/api/Auth/Login' => Http::response(['jwtToken' => 'jwt-123', 'username' => 'admin'], 200),
        ]);

        $result = (new ApiAdministratorAuthenticator())->authenticate('a@a.pl', 'x');

        $this->assertTrue($result->isSuccessful);
        $this->assertSame('jwt-123', $result->jwtToken);
        $this->assertSame('admin', $result->username);

        Http::assertSent(fn ($request) => $request->hasHeader('Accept-Language', 'pl'));
    }
}
