<x-layouts.admin-layout :title="__('ui.admin_users_title')">
    <div class="space-y-4">
        <x-admin.section-card :title="__('ui.users_filter_title')">
            <form method="get" class="grid gap-4 md:grid-cols-[2fr_2fr_auto] md:items-end">
                <x-ui.form-group :label="__('ui.users_filter_name')" for="search_name">
                    <x-ui.form-input
                        id="search_name"
                        name="search_name"
                        type="text"
                        :value="$searchName"
                    />
                </x-ui.form-group>

                <x-ui.form-group :label="__('ui.users_filter_email')" for="search_email">
                    <x-ui.form-input
                        id="search_email"
                        name="search_email"
                        type="text"
                        :value="$searchEmail"
                    />
                </x-ui.form-group>

                <x-ui.form-group :label="__('ui.per_page')" for="per_page">
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
                        {{ __('ui.apply_filter') }}
                    </x-ui.primary-button>
                </div>
            </form>
        </x-admin.section-card>

        <x-admin.section-card :title="__('ui.users_list_title')">
            @if ($users->isEmpty())
                <p class="app-text-muted">
                    {{ __('ui.no_users_message') }}
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
                                    {{ __('ui.user_name') }}
                                </x-admin.users.header-cell>

                                <x-admin.users.header-cell>
                                    {{ __('ui.email') }}
                                </x-admin.users.header-cell>

                                <x-admin.users.header-cell align="center">
                                    {{ __('ui.is_blocked') }}
                                </x-admin.users.header-cell>

                                <x-admin.users.header-cell align="center">
                                    {{ __('ui.lockout_end_utc') }}
                                </x-admin.users.header-cell>
                            </tr>
                        </thead>

                        <tbody>
                            @foreach ($users as $user)
                                <tr class="app-table-row">
                                    <x-admin.users.cell rounded="left">
                                        {{ data_get($user, 'userName') ?? data_get($user, 'name') ?? '' }}
                                    </x-admin.users.cell>

                                    <x-admin.users.cell>
                                        {{ data_get($user, 'email') ?? '' }}
                                    </x-admin.users.cell>

                                    <x-admin.users.cell align="center">
                                        {{ (bool) (data_get($user, 'isBlocked') ?? data_get($user, 'is_blocked') ?? false) ? __('ui.yes') : __('ui.no') }}
                                    </x-admin.users.cell>

                                    <x-admin.users.cell align="center" rounded="right">
                                        <x-ui.date-time :value="data_get($user, 'lockoutEndUtc') ?? data_get($user, 'lockout_end_utc')" />
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
