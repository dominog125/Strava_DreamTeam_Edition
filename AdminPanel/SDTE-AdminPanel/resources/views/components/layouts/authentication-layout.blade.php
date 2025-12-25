<x-layouts.theme-layout :title="$title ?? 'Logowanie'">
    <div class="min-h-screen flex items-center justify-center px-4">
        {{ $slot }}
    </div>
</x-layouts.theme-layout>