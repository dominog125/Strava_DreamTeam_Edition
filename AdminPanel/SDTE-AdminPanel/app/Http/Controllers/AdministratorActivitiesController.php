<?php

namespace App\Http\Controllers;

use App\Models\Activity;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\View\View;

class AdministratorActivitiesController extends Controller
{
    public function index(Request $request): View
    {
        $validated = $request->validate([
            'search_user_name' => ['nullable', 'string', 'max:120'],
            'date_from' => ['nullable', 'date'],
            'date_to' => ['nullable', 'date', 'after_or_equal:date_from'],
            'distance_min' => ['nullable', 'numeric', 'min:0'],
            'distance_max' => ['nullable', 'numeric', 'gte:distance_min'],
            'activity_type' => ['nullable', 'string', 'max:64'],
            'per_page' => ['nullable', 'integer', 'in:10,25,50,100'],
        ]);

        $searchUserName = (string) ($validated['search_user_name'] ?? '');
        $dateFrom = $validated['date_from'] ?? null;
        $dateTo = $validated['date_to'] ?? null;
        $distanceMin = $validated['distance_min'] ?? null;
        $distanceMax = $validated['distance_max'] ?? null;
        $activityType = (string) ($validated['activity_type'] ?? '');
        $perPage = (int) ($validated['per_page'] ?? 10);

        $query = Activity::query()->with('user');

        if ($searchUserName !== '') {
            $query->whereHas('user', function ($userQuery) use ($searchUserName) {
                $userQuery->where('name', 'like', '%' . $searchUserName . '%');
            });
        }

        if ($activityType !== '') {
            $query->where('activity_type', $activityType);
        }

        if ($dateFrom || $dateTo) {
            $from = $dateFrom ? Carbon::parse($dateFrom)->startOfDay() : Carbon::minValue();
            $to = $dateTo ? Carbon::parse($dateTo)->endOfDay() : Carbon::maxValue();

            $query->whereBetween('created_at', [$from, $to]);
        }

        if ($distanceMin !== null) {
            $query->where('distance_kilometers', '>=', $distanceMin);
        }

        if ($distanceMax !== null) {
            $query->where('distance_kilometers', '<=', $distanceMax);
        }

        $activities = $query
            ->orderByDesc('created_at')
            ->paginate($perPage)
            ->withQueryString();

        $activityTypes = Activity::query()
            ->select('activity_type')
            ->distinct()
            ->orderBy('activity_type')
            ->pluck('activity_type');

        return view('admin.activities.index', [
            'activities' => $activities,
            'activityTypes' => $activityTypes,
            'filters' => [
                'search_user_name' => $searchUserName,
                'date_from' => $dateFrom,
                'date_to' => $dateTo,
                'distance_min' => $distanceMin,
                'distance_max' => $distanceMax,
                'activity_type' => $activityType,
                'per_page' => $perPage,
            ],
        ]);
    }
}
