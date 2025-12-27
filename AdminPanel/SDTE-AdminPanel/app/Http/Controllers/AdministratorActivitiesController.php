<?php

namespace App\Http\Controllers;

use Illuminate\View\View;

class AdministratorActivitiesController extends Controller
{
    public function index(): View
    {
        $activities = collect([
            (object) [
                'user_name' => 'Admin',
                'created_at' => now()->subMinutes(10),
                'activity_type' => 'Bieg',
                'distance_kilometers' => 5.2,
            ],
            (object) [
                'user_name' => 'Jan Kowalski',
                'created_at' => now()->subDays(1),
                'activity_type' => 'Spacer',
                'distance_kilometers' => 3.1,
            ],
            (object) [
                'user_name' => 'Anna Nowak',
                'created_at' => now()->subDays(2),
                'activity_type' => 'Rower',
                'distance_kilometers' => 24.7,
            ],
        ]);

        return view('admin.activities.index', [
            'activities' => $activities,
        ]);
    }
}
