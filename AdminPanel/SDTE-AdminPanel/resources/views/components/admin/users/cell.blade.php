@props([
    'align' => 'left',
    'rounded' => null, // 'left', 'right' or null
])

@php
    $baseClasses = 'px-3 py-2 text-sm text-gray-700 dark:text-gray-200';
    $alignClass = match ($align) {
        'right' => 'text-right',
        'center' => 'text-center',
        default => 'text-left',
    };
    $roundedClass = match ($rounded) {
        'left' => 'rounded-l-xl',
        'right' => 'rounded-r-xl',
        default => '',
    };
@endphp

<td class="{{ $baseClasses }} {{ $alignClass }} {{ $roundedClass }}">
    {{ $slot }}
</td>
