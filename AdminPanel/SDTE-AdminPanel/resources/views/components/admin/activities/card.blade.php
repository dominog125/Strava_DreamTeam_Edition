@props(['activity'])

<div class="app-card flex items-start justify-between gap-4">
    <div class="min-w-0 space-y-1">
        <div class="app-card-title">
            {{ $activity->user?->name ?? '-' }}
        </div>

        <div class="app-text-muted-xs">
            {{ __('ui.date') }}: {{ $activity->created_at?->format('Y-m-d H:i') }}
        </div>

        <div class="app-text-muted-xs">
            {{ __('ui.type') }}: {{ $activity->activity_type_label }}
        </div>

        <div class="app-text-muted-xs">
            {{ __('ui.length') }}: {{ number_format((float) ($activity->distance_kilometers ?? 0), 2, ',', ' ') }} km
        </div>
    </div>

    <form
        method="post"
        action="{{ route('administrator.activities.destroy', $activity) }}"
        onsubmit="return confirm('{{ __('ui.confirm_delete_activity') }}');"
        class="shrink-0"
    >
        @csrf
        @method('DELETE')

        <x-ui.danger-button type="submit" class="size-14 inline-flex items-center justify-center text-xs leading-tight !rounded-xl">
            {{ __('ui.delete') }}
        </x-ui.danger-button>
    </form>
</div>
