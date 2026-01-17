<?php

namespace Tests\Feature;

use App\Application\Administration\Activities\AdministratorActivitiesFilters;
use App\Infrastructure\Administration\Activities\ApiAdministratorActivitiesReader;
use Illuminate\Support\Facades\App;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use PHPUnit\Framework\Attributes\Group;
use Tests\TestCase;

#[Group('administration-api')]
class ApiAdministratorActivitiesReaderTest extends TestCase
{
    public function test_it_returns_empty_paginator_when_base_url_missing(): void
    {
        Cache::flush();

        config([
            'administration.api.base_url' => '',
            'administration.api.timeout_seconds' => 10,
        ]);

        $paginator = $this->app->make(ApiAdministratorActivitiesReader::class)->paginate(
            new AdministratorActivitiesFilters(
                searchUserName: null,
                activityType: null,
                dateFrom: null,
                dateTo: null,
                distanceMin: null,
                distanceMax: null,
                perPage: 10,
            )
        );

        $this->assertSame(0, $paginator->total());
        $this->assertSame(0, $paginator->count());
    }

    public function test_it_maps_author_name_using_admin_users_endpoint(): void
    {
        Cache::flush();
        App::setLocale('pl');

        config([
            'administration.api.base_url' => 'https://example.test',
            'administration.api.timeout_seconds' => 10,
        ]);

        Http::preventStrayRequests();

        Http::fake([
            'https://example.test/api/Activities' => Http::response([
                [
                    'id' => 'a1',
                    'name' => 'Aktywność 1',
                    'description' => '',
                    'lengthInKm' => 5.25,
                    'authorId' => 'u1',
                    'categoryName' => 'Bieg',
                    'createdAt' => '2026-01-17T10:12:58.974Z',
                ],
                [
                    'id' => 'a2',
                    'name' => 'Aktywność 2',
                    'description' => '',
                    'lengthInKm' => 3.00,
                    'authorId' => 'u2',
                    'categoryName' => 'Rower',
                    'createdAt' => '2026-01-16T10:12:58.974Z',
                ],
            ], 200),

            'https://example.test/api/admin/users' => Http::response([
                [
                    'userId' => 'u1',
                    'userName' => 'Jan Kowalski',
                    'email' => 'jan@example.com',
                    'isBlocked' => false,
                    'lockoutEndUtc' => null,
                ],
                [
                    'userId' => 'u2',
                    'userName' => 'Anna Nowak',
                    'email' => 'anna@example.com',
                    'isBlocked' => false,
                    'lockoutEndUtc' => null,
                ],
            ], 200),
        ]);

        $paginator = $this->withSession(['administrator.jwt' => 'jwt-123'])
            ->app
            ->make(ApiAdministratorActivitiesReader::class)
            ->paginate(new AdministratorActivitiesFilters(
                searchUserName: null,
                activityType: null,
                dateFrom: null,
                dateTo: null,
                distanceMin: null,
                distanceMax: null,
                perPage: 10,
            ));

        $this->assertSame(2, $paginator->total());
        $this->assertSame(2, $paginator->count());

        $items = $paginator->items();

        $this->assertSame('Jan Kowalski', (string) $items[0]->authorName);
        $this->assertSame('Anna Nowak', (string) $items[1]->authorName);

        Http::assertSent(function ($request) {
            return $request->url() === 'https://example.test/api/Activities'
                && $request->hasHeader('Authorization')
                && $request->hasHeader('Accept-Language', 'pl');
        });

        Http::assertSent(function ($request) {
            return $request->url() === 'https://example.test/api/admin/users'
                && $request->hasHeader('Authorization')
                && $request->hasHeader('Accept-Language', 'pl');
        });
    }

    public function test_it_falls_back_to_author_id_when_users_endpoint_fails(): void
    {
        Cache::flush();
        App::setLocale('pl');

        config([
            'administration.api.base_url' => 'https://example.test',
            'administration.api.timeout_seconds' => 10,
        ]);

        Http::preventStrayRequests();

        Http::fake([
            'https://example.test/api/Activities' => Http::response([
                [
                    'id' => 'a1',
                    'name' => 'Aktywność 1',
                    'description' => '',
                    'lengthInKm' => 5.25,
                    'authorId' => 'u1',
                    'categoryName' => 'Bieg',
                    'createdAt' => '2026-01-17T10:12:58.974Z',
                ],
            ], 200),

            'https://example.test/api/admin/users' => Http::response(['error' => 'fail'], 500),
        ]);

        $paginator = $this->withSession(['administrator.jwt' => 'jwt-123'])
            ->app
            ->make(ApiAdministratorActivitiesReader::class)
            ->paginate(new AdministratorActivitiesFilters(
                searchUserName: null,
                activityType: null,
                dateFrom: null,
                dateTo: null,
                distanceMin: null,
                distanceMax: null,
                perPage: 10,
            ));

        $items = $paginator->items();

        $this->assertSame('u1', (string) ($items[0]->authorName ?? ''));
    }

    public function test_search_user_name_filters_by_author_name(): void
    {
        Cache::flush();
        App::setLocale('pl');

        config([
            'administration.api.base_url' => 'https://example.test',
            'administration.api.timeout_seconds' => 10,
        ]);

        Http::preventStrayRequests();

        Http::fake([
            'https://example.test/api/Activities' => Http::response([
                [
                    'id' => 'a1',
                    'name' => 'Aktywność 1',
                    'description' => '',
                    'lengthInKm' => 5.25,
                    'authorId' => 'u1',
                    'categoryName' => 'Bieg',
                    'createdAt' => '2026-01-17T10:12:58.974Z',
                ],
                [
                    'id' => 'a2',
                    'name' => 'Aktywność 2',
                    'description' => '',
                    'lengthInKm' => 3.00,
                    'authorId' => 'u2',
                    'categoryName' => 'Rower',
                    'createdAt' => '2026-01-16T10:12:58.974Z',
                ],
            ], 200),

            'https://example.test/api/admin/users' => Http::response([
                ['userId' => 'u1', 'userName' => 'Jan Kowalski', 'email' => 'jan@example.com', 'isBlocked' => false, 'lockoutEndUtc' => null],
                ['userId' => 'u2', 'userName' => 'Anna Nowak', 'email' => 'anna@example.com', 'isBlocked' => false, 'lockoutEndUtc' => null],
            ], 200),
        ]);

        $paginator = $this->withSession(['administrator.jwt' => 'jwt-123'])
            ->app
            ->make(ApiAdministratorActivitiesReader::class)
            ->paginate(new AdministratorActivitiesFilters(
                searchUserName: 'jan',
                activityType: null,
                dateFrom: null,
                dateTo: null,
                distanceMin: null,
                distanceMax: null,
                perPage: 10,
            ));

        $this->assertSame(1, $paginator->total());
        $this->assertSame('Jan Kowalski', (string) $paginator->items()[0]->authorName);
    }
}
