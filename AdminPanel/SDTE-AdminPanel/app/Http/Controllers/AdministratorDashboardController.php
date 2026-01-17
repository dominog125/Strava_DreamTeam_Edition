<?php

namespace App\Http\Controllers;

use App\Application\Administration\Dashboard\AdministratorDashboardStatisticsReader;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class AdministratorDashboardController extends Controller
{
    public function __construct(
        private readonly AdministratorDashboardStatisticsReader $administratorDashboardStatisticsReader
    ) {
    }

    public function index(): View
    {
        $administratorUsername = match (config('administration.auth_mode')) {
            'auth' => (string) (Auth::user()?->name ?? Auth::user()?->email ?? ''),
            default => (string) session('administrator.username', ''),
        };

        $statistics = $this->administratorDashboardStatisticsReader->read();

        return view('admin.dashboard', [
            'administratorUsername' => $administratorUsername,
            'userCount' => $statistics->userCount,
            'activityCount' => $statistics->activityCount,
            'totalDistanceKilometers' => $statistics->totalDistanceKilometers,
        ]);
    }
}
