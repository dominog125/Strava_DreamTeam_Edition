<x-layouts.admin-layout title="Strona główna">
    <section
        class="w-full rounded-2xl border-2 border-orange-500
               bg-gray-50/95 dark:bg-gray-800/95
               px-6 py-5 shadow-md"
    >
        <h2 class="mb-4 text-base font-semibold text-gray-900 dark:text-gray-100">
            Podsumowanie systemu
        </h2>

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
    </section>
</x-layouts.admin-layout>
