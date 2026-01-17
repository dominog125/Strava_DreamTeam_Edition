<?php

namespace Tests\Feature;

use App\Application\Administration\Dashboard\AdministratorDashboardStatistics;
use App\Infrastructure\Administration\Dashboard\ApiAdministratorDashboardStatisticsReader;
use Illuminate\Support\Facades\App;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Session;
use PHPUnit\Framework\Attributes\Group;
use Tests\TestCase;

#[Group('administration-api')]
final class ApiAdministratorDashboardStatisticsReaderTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        App::setLocale('pl');

        config([
            'administration.api.base_url' => 'https://example.test',
            'administration.api.timeout_seconds' => 10,
        ]);

        Session::put('administrator.jwt', 'jwt-123');
    }

    public function test_it_returns_zeros_when_api_base_url_is_empty(): void
    {
        config(['administration.api.base_url' => '']);

        $reader = new ApiAdministratorDashboardStatisticsReader();

        $stats = $reader->read();

        $this->assertInstanceOf(AdministratorDashboardStatistics::class, $stats);
        $this->assertSame(0, $stats->userCount);
        $this->assertSame(0, $stats->activityCount);
        $this->assertSame(0.0, $stats->totalDistanceKilometers);
    }

    public function test_it_returns_zeros_when_http_client_fails_to_connect(): void
    {
        Http::fake([
            'example.test/*' => Http::failedConnection(),
        ]);

        $reader = new ApiAdministratorDashboardStatisticsReader();

        $stats = $reader->read();

        $this->assertSame(0, $stats->userCount);
        $this->assertSame(0, $stats->activityCount);
        $this->assertSame(0.0, $stats->totalDistanceKilometers);
    }

    public function test_it_returns_zeros_when_api_returns_non_success_status(): void
    {
        Http::fake([
            'example.test/api/admin/stats/global' => Http::response(['error' => 'server'], 500),
        ]);

        $reader = new ApiAdministratorDashboardStatisticsReader();

        $stats = $reader->read();

        $this->assertSame(0, $stats->userCount);
        $this->assertSame(0, $stats->activityCount);
        $this->assertSame(0.0, $stats->totalDistanceKilometers);
    }

    public function test_it_reads_statistics_and_sends_authorization_and_accept_language_headers(): void
    {
        Http::fake([
            'example.test/api/admin/stats/global' => Http::response([
                'usersCount' => 12,
                'activitiesCount' => 34,
                'totalDistanceKm' => 56.7,
            ], 200),
        ]);

        $reader = new ApiAdministratorDashboardStatisticsReader();

        $stats = $reader->read();

        $this->assertSame(12, $stats->userCount);
        $this->assertSame(34, $stats->activityCount);
        $this->assertSame(56.7, $stats->totalDistanceKilometers);

        Http::assertSent(function ($request) {
            $this->assertSame('https://example.test/api/admin/stats/global', (string) $request->url());
            $this->assertSame('pl', $request->header('Accept-Language')[0] ?? null);
            $this->assertSame('Bearer jwt-123', $request->header('Authorization')[0] ?? null);

            return true;
        });
    }
}
