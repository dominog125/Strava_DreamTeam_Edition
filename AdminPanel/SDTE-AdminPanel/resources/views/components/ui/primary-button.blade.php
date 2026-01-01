@props(['type' => 'submit'])

<button
    type="{{ $type }}"
    {{ $attributes->class(
        'rounded-full
         bg-gradient-to-r from-orange-500 to-orange-600
         text-white font-semibold
         shadow-lg shadow-orange-500/40
         hover:from-orange-600 hover:to-orange-700
         focus:outline-none focus:ring-2 focus:ring-orange-400
         focus:ring-offset-2 focus:ring-offset-gray-50 dark:focus:ring-offset-gray-800
         transition'
    ) }}
>
    {{ $slot }}
</button>