<x-layouts.admin-layout title="Aktywności">
    <div class="space-y-4">
        <x-admin.section-card title="Filtr aktywności">
            <form method="get" class="grid gap-4 md:grid-cols-6 md:items-end">
                <x-ui.form-group class="md:col-span-2" label="Użytkownik" for="search_user_name">
                    <x-ui.form-input
                        id="search_user_name"
                        name="search_user_name"
                        type="text"
                        :value="$filters['search_user_name'] ?? ''"
                    />
                </x-ui.form-group>

                <x-ui.form-group class="md:col-span-1" label="Data od" for="date_from">
                    <x-ui.form-input
                        id="date_from"
                        name="date_from"
                        type="date"
                        :value="$filters['date_from'] ?? ''"
                    />
                </x-ui.form-group>

                <x-ui.form-group class="md:col-span-1" label="Data do" for="date_to">
                    <x-ui.form-input
                        id="date_to"
                        name="date_to"
                        type="date"
                        :value="$filters['date_to'] ?? ''"
                    />
                </x-ui.form-group>

                <x-ui.form-group class="md:col-span-1" label="Dystans min (km)" for="distance_min">
                    <x-ui.form-input
                        id="distance_min"
                        name="distance_min"
                        type="number"
                        step="0.01"
                        min="0"
                        :value="$filters['distance_min'] ?? ''"
                    />
                </x-ui.form-group>

                <x-ui.form-group class="md:col-span-1" label="Dystans max (km)" for="distance_max">
                    <x-ui.form-input
                        id="distance_max"
                        name="distance_max"
                        type="number"
                        step="0.01"
                        min="0"
                        :value="$filters['distance_max'] ?? ''"
                    />
                </x-ui.form-group>

                <x-ui.form-group class="md:col-span-2" label="Typ aktywności" for="activity_type">
                    <x-ui.form-select id="activity_type" name="activity_type">
                        <option value="" @selected(($filters['activity_type'] ?? '') === '')>Wszystkie</option>
                        @foreach ($activityTypes ?? [] as $type)
                            <option value="{{ $type }}" @selected(($filters['activity_type'] ?? '') === $type)>{{ $type }}</option>
                        @endforeach
                    </x-ui.form-select>
                </x-ui.form-group>

                <x-ui.form-group class="md:col-span-2" label="Ilość na stronę" for="per_page">
                    <x-ui.form-select id="per_page" name="per_page">
                        @foreach ([10, 25, 50, 100] as $option)
                            <option value="{{ $option }}" @selected((int)($filters['per_page'] ?? 10) === $option)>{{ $option }}</option>
                        @endforeach
                    </x-ui.form-select>
                </x-ui.form-group>

                <div class="md:col-span-6 flex md:justify-end pt-1">
                    <x-ui.primary-button type="submit" class="w-full md:w-auto px-5 py-2 text-xs">
                        Zastosuj filtr
                    </x-ui.primary-button>
                </div>
            </form>
        </x-admin.section-card>

        <x-admin.section-card title="Lista aktywności">
            @if ($activities->isEmpty())
                <p class="app-text-muted">
                    Brak aktywności dla wybranych filtrów.
                </p>
            @else
                <div class="space-y-2 md:hidden">
                    @foreach ($activities as $activity)
                        <x-admin.activities.card :activity="$activity" />
                    @endforeach
                </div>

                <div class="hidden md:block overflow-x-auto">
                    <table class="min-w-full border-separate border-spacing-y-2">
                        <thead>
                            <tr>
                                <x-ui.table.header-cell>Nazwa użytkownika</x-ui.table.header-cell>
                                <x-ui.table.header-cell>Data dodania</x-ui.table.header-cell>
                                <x-ui.table.header-cell>Typ aktywności</x-ui.table.header-cell>
                                <x-ui.table.header-cell align="right">Długość</x-ui.table.header-cell>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach ($activities as $activity)
                                <tr class="app-table-row">
                                    <x-ui.table.cell rounded="left">
                                        {{ $activity->user?->name ?? '-' }}
                                    </x-ui.table.cell>

                                    <x-ui.table.cell>
                                        {{ $activity->created_at?->format('Y-m-d H:i') }}
                                    </x-ui.table.cell>

                                    <x-ui.table.cell>
                                        {{ $activity->activity_type }}
                                    </x-ui.table.cell>

                                    <x-ui.table.cell align="right" rounded="right">
                                        {{ number_format((float) ($activity->distance_kilometers ?? 0), 2, ',', ' ') }} km
                                    </x-ui.table.cell>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            @endif

            <div class="mt-4">
                {{ $activities->links() }}
            </div>
        </x-admin.section-card>
    </div>
</x-layouts.admin-layout>