<x-layouts.theme-layout :title="$title ?? 'Panel administratora'">
    <div class="min-h-screen">
        <div class="max-w-6xl mx-auto px-4 py-6 space-y-4">
            <header>
                <div
                    class="w-full rounded-2xl border-2 border-orange-500
                           bg-gray-50/95 dark:bg-gray-800/95
                           px-6 py-4 space-y-4"
                >
                    <div class="text-center md:text-left">
                        <div class="text-xs font-semibold uppercase tracking-wide text-gray-500 dark:text-gray-300">
                            PANEL ADMINISTRATORA
                        </div>
                        <div class="text-lg font-bold text-gray-900 dark:text-gray-100">
                            {{ $title ?? 'Strona główna' }}
                        </div>
                    </div>

                    {{-- NAV: mobile --}}
                    <nav class="flex flex-col gap-2 md:hidden">
                        <x-ui.header-nav-button
                            href="{{ route('administrator.dashboard') }}"
                            label="Dashboard"
                            abbr="D"
                            class="w-full"
                        />

                        <x-ui.header-nav-button
                            href="{{ route('administrator.users') }}"
                            label="Użytkownicy"
                            abbr="U"
                            class="w-full"
                        />

                        <x-ui.header-nav-button
                            href="{{ route('administrator.activities') }}"
                            label="Aktywności"
                            abbr="A"
                            class="w-full"
                        />

                        <x-ui.header-nav-button
                            href="#"
                            label="Logi"
                            abbr="L"
                            class="w-full"
                        />
                    </nav>

                    {{-- NAV: desktop --}}
                    <nav class="hidden md:flex md:flex-wrap md:justify-center md:gap-3">
                        <x-ui.header-nav-button
                            href="{{ route('administrator.dashboard') }}"
                            label="Dashboard"
                            abbr="D"
                        />

                        <x-ui.header-nav-button
                            href="{{ route('administrator.users') }}"
                            label="Użytkownicy"
                            abbr="U"
                        />

                        <x-ui.header-nav-button
                            href="{{ route('administrator.activities') }}"
                            label="Aktywności"
                            abbr="A"
                        />

                        <x-ui.header-nav-button
                            href="#"
                            label="Logi"
                            abbr="L"
                        />
                    </nav>
                </div>
            </header>

            <main>
                {{ $slot }}
            </main>
        </div>
    </div>
</x-layouts.theme-layout>
