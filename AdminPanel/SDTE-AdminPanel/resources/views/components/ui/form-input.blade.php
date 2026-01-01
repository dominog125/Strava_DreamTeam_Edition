@props([
    'type' => 'text',
    'value' => null,
])

<input
    type="{{ $type }}"
    value="{{ $value }}"
    {{ $attributes->merge([
        'class' => 'app-input',
    ]) }}
>
