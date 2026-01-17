@props([
    'label',
    'abbr',
])

<button type="submit" {{ $attributes->class(['app-nav-button']) }}>
    <span class="flex h-6 w-6 items-center justify-center rounded-full bg-white/10 text-[10px] font-bold">
        {{ $abbr }}
    </span>

    <span>{{ $label }}</span>
</button>
