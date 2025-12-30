<x-layouts.admin-layout title="Strona główna">
    <x-admin.section-card title="Podsumowanie systemu">
        <div class="grid gap-4 md:grid-cols-3">
            <x-admin.statistic-card label="Liczba użytkowników">
                {{ number_format($userCount ?? 0, 0, ',', ' ') }}
            </x-admin.statistic-card>

            <x-admin.statistic-card label="Liczba aktywności">
                {{ number_format($activityCount ?? 0, 0, ',', ' ') }}
            </x-admin.statistic-card>

            <x-admin.statistic-card label="Łączny dystans [km]">
                {{ number_format($totalDistanceKilometers ?? 0, 2, ',', ' ') }}
            </x-admin.statistic-card>
        </div>
    </x-admin.section-card>
</x-layouts.admin-layout>