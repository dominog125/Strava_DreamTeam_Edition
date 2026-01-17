<select
    {{ $attributes->merge([
        'class' => 'app-input',
    ]) }}
>
    {{ $slot }}
</select>
