@props(['activity'])

<div class="app-card flex items-start justify-between gap-4">
    <div class="min-w-0 space-y-1">
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
            Długość: {{ number_format((float) ($activity->distance_kilometers ?? 0), 2, ',', ' ') }} km
        </div>
    </div>

    <form
        method="post"
        action="{{ route('administrator.activities.destroy', $activity) }}"
        onsubmit="return confirm('Czy na pewno usunąć tę aktywność?');"
        class="shrink-0 self-start"
    >
        @csrf
        @method('DELETE')

        <x-ui.danger-button type="submit" class="size-14 inline-flex items-center justify-center text-xs leading-tight !rounded-xl">
            Usuń
        </x-ui.danger-button>
    </form>
</div>
