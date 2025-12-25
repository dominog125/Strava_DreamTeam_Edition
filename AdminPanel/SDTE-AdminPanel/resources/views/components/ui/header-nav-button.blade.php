@props([
    'href' => '#',
    'label',
    'abbr' => null,
])

<a
    href="{{ $href }}"
    {{ $attributes->class(
        'inline-flex items-center justify-center gap-2
         rounded-full
         bg-gradient-to-r from-orange-500 to-orange-600
         text-white text-xs font-semibold
         px-4 py-1.5
         shadow-lg shadow-orange-500/40
         hover:from-orange-600 hover:to-orange-700
         focus:outline-none focus:ring-2 focus:ring-orange-400
         focus:ring-offset-2 focus:ring-offset-gray-900
         transition'
    ) }}
>
    @if($abbr)
        <span class="flex h-6 w-6 items-center justify-center rounded-full bg-black/10 text-[10px] font-bold">
            {{ $abbr }}
        </span>
    @endif

    <span>{{ $label }}</span>
</a>
