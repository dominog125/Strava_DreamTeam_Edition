<x-layouts.admin-layout title="Aktywności">
    <div class="space-y-4">
        <x-admin.section-card title="Filtr aktywności">
        </x-admin.section-card>

        <x-admin.section-card title="Lista aktywności">
            @if ($activities->isEmpty())
                <p class="text-sm text-gray-600 dark:text-gray-300">
                    Brak aktywności do wyświetlenia.
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
                                <tr class="bg-gray-200 dark:bg-gray-900/80 shadow-sm">
                                    <x-ui.table.cell rounded="left">
                                        {{ $activity->user_name }}
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
        </x-admin.section-card>
    </div>
</x-layouts.admin-layout>
