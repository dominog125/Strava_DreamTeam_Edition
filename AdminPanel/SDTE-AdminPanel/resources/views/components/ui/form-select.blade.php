<select
    {{ $attributes->merge([
        'class' => 'block w-full rounded-xl border border-gray-300 dark:border-gray-600
                    bg-white dark:bg-gray-900/80
                    px-3 py-2 text-sm
                    text-gray-900 dark:text-gray-100
                    focus:outline-none focus:ring-2 focus:ring-orange-400 focus:border-orange-400
                    transition',
    ]) }}
>
    {{ $slot }}
</select>
