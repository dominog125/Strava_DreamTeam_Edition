@props([
    'align' => 'left',
])

<th
    {{ $attributes->class([
        'px-3 py-1.5 text-xs font-semibold text-gray-500 dark:text-gray-300',
        'text-left' => $align === 'left',
        'text-right' => $align === 'right',
        'text-center' => $align === 'center',
    ]) }}
>
    {{ $slot }}
</th>
