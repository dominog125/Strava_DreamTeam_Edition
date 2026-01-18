<?php

namespace Tests\Feature;

use App\Infrastructure\Administration\Authentication\ApiAdministratorAuthenticator;
use Illuminate\Support\Facades\App;
use Illuminate\Support\Facades\Http;
use PHPUnit\Framework\Attributes\Group;
use Tests\TestCase;

#[Group('administration-api')]
final class ApiAdministratorAuthenticatorTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        App::setLocale('pl');

        config([
            'administration.api.base_url' => 'https://example.test',
            'administration.api.timeout_seconds' => 10,
        ]);
    }

    public function test_it_returns_configuration_missing_when_api_base_url_is_empty(): void
    {
        config(['administration.api.base_url' => '']);

        $authenticator = new ApiAdministratorAuthenticator();

        $result = $authenticator->authenticate('admin@example.com', 'secret');

        $this->assertFalse($result->isSuccessful);
        $this->assertSame(__('ui.api_configuration_missing'), $result->failureMessage);
    }

    public function test_it_returns_connection_error_when_http_client_fails_to_connect(): void
    {
        Http::fake([
            'example.test/*' => Http::failedConnection(),
        ]);

        $authenticator = new ApiAdministratorAuthenticator();

        $result = $authenticator->authenticate('admin@example.com', 'secret');

        $this->assertFalse($result->isSuccessful);
        $this->assertSame(__('ui.api_connection_error'), $result->failureMessage);
    }

    public function test_it_returns_invalid_credentials_when_api_returns_401(): void
    {
        Http::fake([
            'example.test/api/Auth/Login' => Http::response('', 401),
        ]);

        $authenticator = new ApiAdministratorAuthenticator();

        $result = $authenticator->authenticate('admin@example.com', 'wrong');

        $this->assertFalse($result->isSuccessful);
        $this->assertSame(__('ui.invalid_credentials'), $result->failureMessage);
    }

    public function test_it_returns_api_auth_error_when_api_returns_non_success_status(): void
    {
        Http::fake([
            'example.test/api/Auth/Login' => Http::response(['error' => 'server'], 500),
        ]);

        $authenticator = new ApiAdministratorAuthenticator();

        $result = $authenticator->authenticate('admin@example.com', 'secret');

        $this->assertFalse($result->isSuccessful);
        $this->assertSame(__('ui.api_auth_error'), $result->failureMessage);
    }

    public function test_it_returns_invalid_response_when_api_response_does_not_contain_required_fields(): void
    {
        Http::fake([
            'example.test/api/Auth/Login' => Http::response(['jwtToken' => 'token-only'], 200),
        ]);

        $authenticator = new ApiAdministratorAuthenticator();

        $result = $authenticator->authenticate('admin@example.com', 'secret');

        $this->assertFalse($result->isSuccessful);
        $this->assertSame(__('ui.api_invalid_response'), $result->failureMessage);
    }

    public function test_it_authenticates_successfully_and_sends_accept_language_header(): void
    {
        Http::fake([
            'example.test/api/Auth/Login' => Http::response([
                'jwtToken' => 'jwt-123',
                'username' => 'Admin',
            ], 200),
        ]);

        $authenticator = new ApiAdministratorAuthenticator();

        $result = $authenticator->authenticate('admin@example.com', 'secret');

        $this->assertTrue($result->isSuccessful);
        $this->assertSame('jwt-123', $result->jwtToken);
        $this->assertSame('Admin', $result->username);

        Http::assertSent(function ($request) {
            $this->assertSame('https://example.test/api/Auth/Login', (string) $request->url());
            $this->assertSame('pl', $request->header('Accept-Language')[0] ?? null);

            $data = $request->data();
            $this->assertSame('admin@example.com', $data['email'] ?? null);
            $this->assertSame('secret', $data['password'] ?? null);

            return true;
        });
    }
}
