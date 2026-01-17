<x-layouts.admin-layout :title="__('ui.admin_home_title')">
    <x-admin.section-card :title="__('ui.dashboard_summary_title')">
        <div class="grid gap-4 md:grid-cols-3">
            <x-admin.statistic-card :label="__('ui.dashboard_user_count')">
                {{ number_format($userCount ?? 0, 0, ',', ' ') }}
            </x-admin.statistic-card>

            <x-admin.statistic-card :label="__('ui.dashboard_activity_count')">
                {{ number_format($activityCount ?? 0, 0, ',', ' ') }}
            </x-admin.statistic-card>

            <x-admin.statistic-card :label="__('ui.dashboard_total_distance_km')">
                {{ number_format($totalDistanceKilometers ?? 0, 2, ',', ' ') }}
            </x-admin.statistic-card>
        </div>
    </x-admin.section-card>
</x-layouts.admin-layout>
