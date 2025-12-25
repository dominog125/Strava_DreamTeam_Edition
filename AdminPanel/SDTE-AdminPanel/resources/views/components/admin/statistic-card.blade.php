@props([
    'label',
])

<div
    class="rounded-xl px-4 py-3 text-center shadow-sm
           bg-gray-200 dark:bg-gray-900/80"
>
    <div class="text-xs font-medium text-gray-600 dark:text-gray-300">
        {{ $label }}
    </div>
    <div class="mt-1 text-2xl font-bold text-gray-900 dark:text-gray-100">
        {{ $slot }}
    </div>
</div>
