@props(['activity'])

<div class="rounded-xl bg-gray-200 dark:bg-gray-900
            text-gray-900 dark:text-gray-100
            p-3 space-y-1">
    <div class="text-sm font-semibold">
        {{ $activity->user?->name ?? '-' }}
    </div>

    <div class="text-xs text-gray-600 dark:text-gray-300">
        Data: {{ $activity->created_at?->format('Y-m-d H:i') }}
    </div>

    <div class="text-xs text-gray-600 dark:text-gray-300">
        Typ: {{ $activity->activity_type }}
    </div>

    <div class="text-xs text-gray-600 dark:text-gray-300">
        Długość: {{ number_format((float) $activity->distance_kilometers, 2, ',', ' ') }} km
    </div>
</div>
