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
        $administrator = Auth::user();
        $statistics = $this->administratorDashboardStatisticsReader->read();

        return view('admin.dashboard', [
            'administrator' => $administrator,
            'userCount' => $statistics->userCount,
            'activityCount' => $statistics->activityCount,
            'totalDistanceKilometers' => $statistics->totalDistanceKilometers,
        ]);
    }
}
