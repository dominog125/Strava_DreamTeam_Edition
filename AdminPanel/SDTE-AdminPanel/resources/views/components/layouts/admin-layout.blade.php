<x-layouts.theme-layout :title="$title ?? 'Panel administratora'">
    @php
        $navigationItems = [
            ['type' => 'link', 'route' => 'administrator.dashboard', 'label' => 'Dashboard', 'abbr' => 'D'],
            ['type' => 'link', 'route' => 'administrator.users', 'label' => 'Użytkownicy', 'abbr' => 'U'],
            ['type' => 'link', 'route' => 'administrator.activities', 'label' => 'Aktywności', 'abbr' => 'A'],
            ['type' => 'logout', 'label' => 'Wyloguj', 'abbr' => 'W'],
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
                            @if (($item['type'] ?? 'link') === 'logout')
                                <form method="post" action="{{ route('logout') }}" class="w-full">
                                    @csrf

                                    <x-ui.header-nav-submit-button
                                        label="{{ $item['label'] }}"
                                        abbr="{{ $item['abbr'] }}"
                                        class="w-full"
                                    />
                                </form>
                            @else
                                <x-ui.header-nav-button
                                    href="{{ route($item['route']) }}"
                                    label="{{ $item['label'] }}"
                                    abbr="{{ $item['abbr'] }}"
                                    class="w-full"
                                />
                            @endif
                        @endforeach
                    </nav>

                    <nav class="hidden md:flex md:flex-wrap md:justify-center md:gap-3">
                        @foreach ($navigationItems as $item)
                            @if (($item['type'] ?? 'link') === 'logout')
                                <form method="post" action="{{ route('logout') }}">
                                    @csrf

                                    <x-ui.header-nav-submit-button
                                        label="{{ $item['label'] }}"
                                        abbr="{{ $item['abbr'] }}"
                                    />
                                </form>
                            @else
                                <x-ui.header-nav-button
                                    href="{{ route($item['route']) }}"
                                    label="{{ $item['label'] }}"
                                    abbr="{{ $item['abbr'] }}"
                                />
                            @endif
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
