@props(['activity'])

<div class="app-card">
    <div class="app-card-title">
        {{ $activity->user?->name ?? '-' }}
    </div>

    <div class="app-text-muted-xs">
        Data: {{ $activity->created_at?->format('Y-m-d H:i') }}
    </div>

    <div class="app-text-muted-xs">
        Typ: {{ $activity->activity_type }}
    </div>

    <div class="app-text-muted-xs">
        Długość: {{ number_format((float) $activity->distance_kilometers, 2, ',', ' ') }} km
    </div>
</div>
