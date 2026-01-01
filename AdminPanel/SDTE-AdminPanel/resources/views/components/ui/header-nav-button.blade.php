@props([
    'href' => '#',
    'label',
    'abbr' => null,
])

<a
    href="{{ $href }}"
    {{ $attributes->class(
        'app-nav-button'
    ) }}
>
    @if($abbr)
        <span class="flex h-6 w-6 items-center justify-center rounded-full bg-black/10 text-[10px] font-bold">
            {{ $abbr }}
        </span>
    @endif

    <span>{{ $label }}</span>
</a>
