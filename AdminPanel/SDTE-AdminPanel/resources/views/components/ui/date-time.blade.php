@props([
    'value' => null,
    'format' => 'Y-m-d H:i',
    'timezone' => null,
    'placeholder' => '-',
])

@php
    $displayValue = $placeholder;

    if ($value) {
        try {
            $dateTime = \Illuminate\Support\Carbon::parse($value);
            $targetTimezone = $timezone ?? config('app.timezone');
            $displayValue = $dateTime->timezone($targetTimezone)->format($format);
        } catch (\Throwable) {
            $displayValue = $placeholder;
        }
    }
@endphp

{{ $displayValue }}
