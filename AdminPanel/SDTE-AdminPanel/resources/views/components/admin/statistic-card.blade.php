@props([
    'label',
])

<div {{ $attributes->class(['app-stat-card']) }}>
    <div class="app-stat-label">
        {{ $label }}
    </div>

    <div class="app-stat-value">
        {{ $slot }}
    </div>
</div>
