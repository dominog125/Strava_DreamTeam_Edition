<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class AdministratorDashboardController extends Controller
{
    public function index(): View
    {
        $administrator = Auth::user();

        $userCount = 42;
        $activityCount = 123;
        $totalDistanceKilometers = 987.65;

        return view('admin.dashboard', [
            'administrator'             => $administrator,
            'userCount'                 => $userCount,
            'activityCount'             => $activityCount,
            'totalDistanceKilometers'   => $totalDistanceKilometers,
        ]);
    }
}
