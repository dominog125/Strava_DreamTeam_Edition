@php
    $currentLocale = app()->getLocale();
    $items = [
        ['locale' => 'pl', 'label' => 'Polski', 'flag' => asset('images/flags/pl.svg')],
        ['locale' => 'en', 'label' => 'English', 'flag' => asset('images/flags/us.svg')],
    ];
@endphp

<div class="flex items-center gap-2">
    @foreach ($items as $item)
        <a
            href="{{ route('locale.switch', $item['locale']) }}"
            @class([
                'app-lang-button',
                'app-lang-button-active' => $currentLocale === $item['locale'],
                'app-lang-button-inactive' => $currentLocale !== $item['locale'],
            ])
            aria-label="{{ $item['label'] }}"
        >
            <img src="{{ $item['flag'] }}" alt="{{ $item['label'] }}" class="app-lang-flag">
        </a>
    @endforeach
</div>
