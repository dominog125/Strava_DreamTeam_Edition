<x-layouts.theme-layout :title="$title ?? 'Panel administratora'">
    @php
        $navigationItems = [
            ['route' => 'administrator.dashboard', 'label' => 'Dashboard', 'abbr' => 'D'],
            ['route' => 'administrator.users', 'label' => 'Użytkownicy', 'abbr' => 'U'],
            ['route' => 'administrator.activities', 'label' => 'Aktywności', 'abbr' => 'A'],
            ['route' => null, 'href' => '#', 'label' => 'Logi', 'abbr' => 'L'],
        ];
    @endphp

    <div class="min-h-screen">
        <div class="max-w-6xl mx-auto px-4 py-6 space-y-4">
            <header>
                <div class="app-surface app-panel-padding space-y-4">
                    <div class="text-center md:text-left">
                        <div class="app-admin-kicker">
                            PANEL ADMINISTRATORA
                        </div>

                        <div class="app-admin-title">
                            {{ $title ?? 'Strona główna' }}
                        </div>
                    </div>

                    <nav class="flex flex-col gap-2 md:hidden">
                        @foreach ($navigationItems as $item)
                            <x-ui.header-nav-button
                                href="{{ $item['route'] ? route($item['route']) : ($item['href'] ?? '#') }}"
                                label="{{ $item['label'] }}"
                                abbr="{{ $item['abbr'] }}"
                                class="w-full"
                            />
                        @endforeach
                    </nav>

                    <nav class="hidden md:flex md:flex-wrap md:justify-center md:gap-3">
                        @foreach ($navigationItems as $item)
                            <x-ui.header-nav-button
                                href="{{ $item['route'] ? route($item['route']) : ($item['href'] ?? '#') }}"
                                label="{{ $item['label'] }}"
                                abbr="{{ $item['abbr'] }}"
                            />
                        @endforeach
                    </nav>
                </div>
            </header>

            <main>
                {{ $slot }}
            </main>
        </div>
    </div>
</x-layouts.theme-layout>
