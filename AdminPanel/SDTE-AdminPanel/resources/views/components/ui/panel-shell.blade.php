@props([
    'title',
    'subtitle' => null,
])

<div class="w-full max-w-md mx-auto">
    <div
        class="border-2 border-orange-500 rounded-2xl
               bg-gray-50/95 dark:bg-gray-800/95
               shadow-xl p-8 sm:p-9"
    >
        <h1 class="text-center text-2xl font-bold tracking-wide mb-2">
            {{ $title }}
        </h1>

        @if($subtitle)
            <p class="text-center text-sm text-gray-600 dark:text-gray-300 mb-6">
                {{ $subtitle }}
            </p>
        @endif

        {{ $slot }}
    </div>
</div>