@props(['type' => 'submit'])

<button
    type="{{ $type }}"
    {{ $attributes->class(
        'w-full rounded-full
         bg-gradient-to-r from-orange-500 to-orange-600
         text-white font-semibold text-sm
         py-2.5
         shadow-lg shadow-orange-500/40
         hover:from-orange-600 hover:to-orange-700
         focus:outline-none focus:ring-2 focus:ring-orange-400
         focus:ring-offset-2 focus:ring-offset-gray-100 dark:focus:ring-offset-gray-900
         transition'
    ) }}
>
    {{ $slot }}
</button>