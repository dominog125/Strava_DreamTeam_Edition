@props([
    'align' => 'left',
])

<th
    {{ $attributes->class([
        'app-table-head',
        'text-left' => $align === 'left',
        'text-right' => $align === 'right',
        'text-center' => $align === 'center',
    ]) }}
>
    {{ $slot }}
</th>
