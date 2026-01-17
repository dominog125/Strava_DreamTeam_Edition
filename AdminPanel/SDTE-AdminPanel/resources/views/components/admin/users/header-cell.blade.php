@props([
    'align' => 'left',
])

@php
    $alignClass = match ($align) {
        'right' => 'text-right',
        'center' => 'text-center',
        default => 'text-left',
    };
@endphp

<th {{ $attributes->class(['app-table-head', $alignClass]) }}>
    {{ $slot }}
</th>
