<?php

namespace App\Http\Controllers;

use App\Application\Administration\Activities\AdministratorActivitiesDeleter;
use App\Application\Administration\Activities\AdministratorActivitiesFilters;
use App\Application\Administration\Activities\AdministratorActivitiesReader;
use App\Application\Administration\Activities\AdministratorActivityCategoriesReader;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;
use RuntimeException;

class AdministratorActivitiesController extends Controller
{
    public function __construct(
        private readonly AdministratorActivitiesReader $administratorActivitiesReader,
        private readonly AdministratorActivityCategoriesReader $administratorActivityCategoriesReader,
    ) {
    }

    public function index(Request $request): View
    {
        $validated = $request->validate([
            'search_user_name' => ['nullable', 'string', 'max:120'],
            'date_from' => ['nullable', 'date'],
            'date_to' => ['nullable', 'date', 'after_or_equal:date_from'],
            'distance_min' => ['nullable', 'numeric', 'min:0'],
            'distance_max' => ['nullable', 'numeric', 'gte:distance_min'],
            'activity_type' => ['nullable', 'string', 'max:120'],
            'per_page' => ['nullable', 'integer', 'in:10,25,50,100'],
        ]);

        $distanceMinInput = $request->input('distance_min');
        $distanceMaxInput = $request->input('distance_max');

        $distanceMin = $request->filled('distance_min')
            ? (float) $distanceMinInput
            : null;

        $distanceMax = $request->filled('distance_max')
            ? (float) $distanceMaxInput
            : null;

        $filters = new AdministratorActivitiesFilters(
            searchUserName: isset($validated['search_user_name']) && trim((string) $validated['search_user_name']) !== ''
                ? (string) $validated['search_user_name']
                : null,
            activityType: isset($validated['activity_type']) && trim((string) $validated['activity_type']) !== ''
                ? (string) $validated['activity_type']
                : null,
            dateFrom: isset($validated['date_from']) && trim((string) $validated['date_from']) !== ''
                ? (string) $validated['date_from']
                : null,
            dateTo: isset($validated['date_to']) && trim((string) $validated['date_to']) !== ''
                ? (string) $validated['date_to']
                : null,
            distanceMin: $distanceMin,
            distanceMax: $distanceMax,
            perPage: (int) ($validated['per_page'] ?? 10),
        );

        $activities = $this->administratorActivitiesReader
            ->paginate($filters)
            ->appends($request->query());

        $activityTypes = $this->administratorActivityCategoriesReader->listNames();

        return view('admin.activities.index', [
            'activities' => $activities,
            'activityTypes' => $activityTypes,
            'filters' => [
                'search_user_name' => $filters->searchUserName ?? '',
                'date_from' => $filters->dateFrom,
                'date_to' => $filters->dateTo,
                'distance_min' => $request->filled('distance_min') ? (string) $distanceMinInput : '',
                'distance_max' => $request->filled('distance_max') ? (string) $distanceMaxInput : '',
                'activity_type' => $filters->activityType ?? '',
                'per_page' => $filters->perPage,
            ],
        ]);
    }

    public function destroy(string $activity, Request $request, AdministratorActivitiesDeleter $activitiesDeleter): RedirectResponse
    {
        try {
            $activitiesDeleter->delete($activity);

            return redirect()
                ->back()
                ->with('status', __('ui.activity_deleted'));
        } catch (RuntimeException $exception) {
            return redirect()
                ->back()
                ->with('error', $exception->getMessage());
        }
    }
}
