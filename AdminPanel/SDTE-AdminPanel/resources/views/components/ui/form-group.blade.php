@props([
    'label',
    'for',
])

<div {{ $attributes->class('space-y-1') }}>
    <label for="{{ $for }}" class="block text-xs font-semibold text-gray-700 dark:text-gray-200">
        {{ $label }}
    </label>

    {{ $slot }}
</div>
