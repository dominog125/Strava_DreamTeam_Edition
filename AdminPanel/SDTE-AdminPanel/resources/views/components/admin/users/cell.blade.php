@props([
    'align' => 'left',
    'rounded' => null,
])

@php
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

<td {{ $attributes->class(['app-table-cell', $alignClass, $roundedClass]) }}>
    {{ $slot }}
</td>
