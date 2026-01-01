<x-layouts.admin-layout title="Użytkownicy">
    <div class="space-y-4">
        <x-admin.section-card title="Filtr użytkowników">
            <form method="get" class="grid gap-4 md:grid-cols-[2fr_2fr_auto] md:items-end">
                <x-ui.form-group label="Nazwa użytkownika" for="search_name">
                    <x-ui.form-input
                        id="search_name"
                        name="search_name"
                        type="text"
                        :value="$searchName"
                    />
                </x-ui.form-group>

                <x-ui.form-group label="Email" for="search_email">
                    <x-ui.form-input
                        id="search_email"
                        name="search_email"
                        type="text"
                        :value="$searchEmail"
                    />
                </x-ui.form-group>

                <x-ui.form-group label="Użytkowników na stronę" for="per_page">
                    <x-ui.form-select id="per_page" name="per_page">
                        @foreach ([10, 25, 50, 100] as $option)
                            <option value="{{ $option }}" @selected($perPage === $option)>
                                {{ $option }}
                            </option>
                        @endforeach
                    </x-ui.form-select>
                </x-ui.form-group>

                <div class="md:col-span-3 flex md:justify-end pt-1">
                    <x-ui.primary-button type="submit" class="w-full md:w-auto px-5 py-2 text-xs">
                        Zastosuj filtr
                    </x-ui.primary-button>
                </div>
            </form>
        </x-admin.section-card>

        <x-admin.section-card title="Lista użytkowników">
            @if ($users->isEmpty())
                <p class="app-text-muted">
                    Brak użytkowników dla wybranych filtrów.
                </p>
            @else
                <div class="space-y-2 md:hidden">
                    @foreach ($users as $user)
                        <x-admin.users.card :user="$user" />
                    @endforeach
                </div>

                <div class="hidden md:block overflow-x-auto">
                    <table class="min-w-full border-separate border-spacing-y-2">
                        <thead>
                            <tr>
                                <x-admin.users.header-cell>
                                    Nazwa użytkownika
                                </x-admin.users.header-cell>
                                <x-admin.users.header-cell>
                                    Email
                                </x-admin.users.header-cell>
                                <x-admin.users.header-cell>
                                    Data utworzenia
                                </x-admin.users.header-cell>
                                <x-admin.users.header-cell align="center">
                                    Discord?
                                </x-admin.users.header-cell>
                                <x-admin.users.header-cell align="center">
                                    Google?
                                </x-admin.users.header-cell>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach ($users as $user)
                                <tr class="app-table-row">
                                    <x-admin.users.cell rounded="left">
                                        {{ $user->name }}
                                    </x-admin.users.cell>

                                    <x-admin.users.cell>
                                        {{ $user->email }}
                                    </x-admin.users.cell>

                                    <x-admin.users.cell>
                                        {{ $user->created_at?->format('Y-m-d H:i') }}
                                    </x-admin.users.cell>

                                    <x-admin.users.cell align="center">
                                        {{ $user->is_discord_connected ? 'Tak' : 'Nie' }}
                                    </x-admin.users.cell>

                                    <x-admin.users.cell align="center" rounded="right">
                                        {{ $user->is_google_connected ? 'Tak' : 'Nie' }}
                                    </x-admin.users.cell>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            @endif

            <div class="mt-4">
                {{ $users->links() }}
            </div>
        </x-admin.section-card>
    </div>
</x-layouts.admin-layout>
