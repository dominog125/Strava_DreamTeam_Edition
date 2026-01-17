<?php

namespace Tests\Feature;

use App\Application\Administration\Users\AdministratorUsersFilters;
use App\Infrastructure\Administration\Users\ApiAdministratorUsersReader;
use Illuminate\Pagination\Paginator;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Session;
use PHPUnit\Framework\Attributes\Group;
use Tests\TestCase;

#[Group('administration-api')]
final class ApiAdministratorUsersReaderTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        config([
            'administration.api.base_url' => 'https://example.test',
            'administration.api.timeout_seconds' => 10,
            'administration.auth_mode' => 'jwt',
        ]);

        Session::put('administrator.jwt', 'jwt-123');

        Paginator::currentPageResolver(fn () => 1);
    }

    public function test_it_paginates_users_from_api_and_sends_bearer_token_from_session(): void
    {
        Http::fake([
            'example.test/api/admin/users' => Http::response([
                ['userId' => '1', 'userName' => 'Jan Kowalski', 'email' => 'jan@example.com', 'isBlocked' => false, 'lockoutEndUtc' => null],
                ['userId' => '2', 'userName' => 'Anna Nowak', 'email' => 'anna@example.com', 'isBlocked' => true, 'lockoutEndUtc' => '2026-01-16T21:11:41.095Z'],
                ['userId' => '3', 'userName' => 'Piotr Zalewski', 'email' => 'piotr@example.com', 'isBlocked' => false, 'lockoutEndUtc' => null],
            ], 200),
        ]);

        $reader = new ApiAdministratorUsersReader();

        $filters = new AdministratorUsersFilters(
            searchName: null,
            searchEmail: null,
            perPage: 2
        );

        $page = $reader->paginate($filters);

        $this->assertSame(3, $page->total());
        $this->assertSame(2, $page->count());
        $this->assertSame('Jan Kowalski', $page->items()[0]->userName);
        $this->assertSame('Anna Nowak', $page->items()[1]->userName);

        Http::assertSent(function ($request) {
            $this->assertSame('https://example.test/api/admin/users', (string) $request->url());
            $this->assertSame('Bearer jwt-123', $request->header('Authorization')[0] ?? null);

            return true;
        });
    }

    public function test_it_filters_users_by_name_case_insensitive(): void
    {
        Http::fake([
            'example.test/api/admin/users' => Http::response([
                ['userId' => '1', 'userName' => 'Jan Kowalski', 'email' => 'jan@example.com', 'isBlocked' => false, 'lockoutEndUtc' => null],
                ['userId' => '2', 'userName' => 'Anna Nowak', 'email' => 'anna@example.com', 'isBlocked' => true, 'lockoutEndUtc' => null],
            ], 200),
        ]);

        $reader = new ApiAdministratorUsersReader();

        $filters = new AdministratorUsersFilters(
            searchName: 'jAn',
            searchEmail: null,
            perPage: 10
        );

        $page = $reader->paginate($filters);

        $this->assertSame(1, $page->total());
        $this->assertSame(1, $page->count());
        $this->assertSame('Jan Kowalski', $page->items()[0]->userName);
    }

    public function test_it_filters_users_by_email_case_insensitive(): void
    {
        Http::fake([
            'example.test/api/admin/users' => Http::response([
                ['userId' => '1', 'userName' => 'Jan Kowalski', 'email' => 'jan@example.com', 'isBlocked' => false, 'lockoutEndUtc' => null],
                ['userId' => '2', 'userName' => 'Anna Nowak', 'email' => 'anna@example.com', 'isBlocked' => true, 'lockoutEndUtc' => null],
            ], 200),
        ]);

        $reader = new ApiAdministratorUsersReader();

        $filters = new AdministratorUsersFilters(
            searchName: null,
            searchEmail: 'ANNA@EXAMPLE.COM',
            perPage: 10
        );

        $page = $reader->paginate($filters);

        $this->assertSame(1, $page->total());
        $this->assertSame(1, $page->count());
        $this->assertSame('anna@example.com', $page->items()[0]->email);
    }

    public function test_it_supports_api_payload_wrapped_in_data_property(): void
    {
        Http::fake([
            'example.test/api/admin/users' => Http::response([
                'data' => [
                    ['userId' => '1', 'userName' => 'Jan Kowalski', 'email' => 'jan@example.com', 'isBlocked' => false, 'lockoutEndUtc' => null],
                    ['userId' => '2', 'userName' => 'Anna Nowak', 'email' => 'anna@example.com', 'isBlocked' => true, 'lockoutEndUtc' => null],
                ],
            ], 200),
        ]);

        $reader = new ApiAdministratorUsersReader();

        $filters = new AdministratorUsersFilters(
            searchName: null,
            searchEmail: null,
            perPage: 10
        );

        $page = $reader->paginate($filters);

        $this->assertSame(2, $page->total());
        $this->assertSame(2, $page->count());
    }

    public function test_it_paginates_second_page(): void
    {
        Http::fake([
            'example.test/api/admin/users' => Http::response([
                ['userId' => '1', 'userName' => 'U1', 'email' => 'u1@example.com', 'isBlocked' => false, 'lockoutEndUtc' => null],
                ['userId' => '2', 'userName' => 'U2', 'email' => 'u2@example.com', 'isBlocked' => false, 'lockoutEndUtc' => null],
                ['userId' => '3', 'userName' => 'U3', 'email' => 'u3@example.com', 'isBlocked' => false, 'lockoutEndUtc' => null],
            ], 200),
        ]);

        Paginator::currentPageResolver(fn () => 2);

        $reader = new ApiAdministratorUsersReader();

        $filters = new AdministratorUsersFilters(
            searchName: null,
            searchEmail: null,
            perPage: 2
        );

        $page = $reader->paginate($filters);

        $this->assertSame(3, $page->total());
        $this->assertSame(1, $page->count());
        $this->assertSame('U3', $page->items()[0]->userName);
    }
}
