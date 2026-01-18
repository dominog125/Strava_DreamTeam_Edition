<?php

namespace Tests\Feature;

use App\Infrastructure\Administration\Activities\ApiAdministratorActivitiesDeleter;
use Illuminate\Support\Facades\App;
use Illuminate\Support\Facades\Http;
use PHPUnit\Framework\Attributes\Group;
use RuntimeException;
use Tests\TestCase;

#[Group('administration-api')]
class ApiAdministratorActivitiesDeleterTest extends TestCase
{
    public function test_it_throws_when_base_url_missing(): void
    {
        config([
            'administration.api.base_url' => '',
            'administration.api.timeout_seconds' => 10,
        ]);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage(__('ui.api_configuration_missing'));

        $this->app->make(ApiAdministratorActivitiesDeleter::class)->delete('a1');
    }

    public function test_it_throws_on_connection_exception(): void
    {
        App::setLocale('pl');

        config([
            'administration.api.base_url' => 'https://example.test',
            'administration.api.timeout_seconds' => 10,
        ]);

        Http::preventStrayRequests();

        Http::fake([
            'https://example.test/api/Activities/*' => Http::failedConnection(),
        ]);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage(__('ui.api_connection_error'));

        $this->withSession(['administrator.jwt' => 'jwt-123'])
            ->app
            ->make(ApiAdministratorActivitiesDeleter::class)
            ->delete('a1');
    }

    public function test_it_throws_on_unauthorized_or_forbidden(): void
    {
        App::setLocale('pl');

        config([
            'administration.api.base_url' => 'https://example.test',
            'administration.api.timeout_seconds' => 10,
        ]);

        Http::preventStrayRequests();

        Http::fake([
            'https://example.test/api/Activities/*' => Http::response([], 401),
        ]);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage(__('ui.api_auth_error'));

        $this->withSession(['administrator.jwt' => 'jwt-123'])
            ->app
            ->make(ApiAdministratorActivitiesDeleter::class)
            ->delete('a1');
    }

    public function test_it_throws_on_non_success_response(): void
    {
        App::setLocale('pl');

        config([
            'administration.api.base_url' => 'https://example.test',
            'administration.api.timeout_seconds' => 10,
        ]);

        Http::preventStrayRequests();

        Http::fake([
            'https://example.test/api/Activities/*' => Http::response(['error' => 'x'], 500),
        ]);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage(__('ui.activity_delete_failed'));

        $this->withSession(['administrator.jwt' => 'jwt-123'])
            ->app
            ->make(ApiAdministratorActivitiesDeleter::class)
            ->delete('a1');
    }

    public function test_it_deletes_successfully_and_sends_bearer_token(): void
    {
        App::setLocale('pl');

        config([
            'administration.api.base_url' => 'https://example.test',
            'administration.api.timeout_seconds' => 10,
        ]);

        Http::preventStrayRequests();

        Http::fake([
            'https://example.test/api/Activities/*' => Http::response(null, 204),
        ]);

        $this->withSession(['administrator.jwt' => 'jwt-123'])
            ->app
            ->make(ApiAdministratorActivitiesDeleter::class)
            ->delete('a1');

        Http::assertSent(function ($request) {
            return $request->method() === 'DELETE'
                && $request->url() === 'https://example.test/api/Activities/a1'
                && $request->hasHeader('Authorization')
                && $request->hasHeader('Accept-Language', 'pl');
        });
    }
}
