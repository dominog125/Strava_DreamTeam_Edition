@props([
    'title',
])

<section {{ $attributes->class(['app-section-card', 'px-6 py-5']) }}>
    <h2 class="app-section-title">
        {{ $title }}
    </h2>

    {{ $slot }}
</section>
