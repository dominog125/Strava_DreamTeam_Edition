@props(['activity'])

<div class="app-card">
    <div class="app-card-title">
        @if (trim((string) data_get($activity, 'name', '')) !== '')
            {{ data_get($activity, 'name') }}
        @else
            <x-admin.activities.type-label :activity="$activity" />
        @endif
    </div>

    @if (trim((string) data_get($activity, 'description', '')) !== '')
        <div class="app-text-muted-xs break-all">
            {{ data_get($activity, 'description') }}
        </div>
    @endif

    <div class="app-text-muted-xs break-all">
        {{ __('ui.user_name') }}:
        {{ data_get($activity, 'authorName') ?? data_get($activity, 'authorId') ?? data_get($activity, 'user.name') ?? '-' }}
    </div>

    <div class="app-text-muted-xs">
        {{ __('ui.added_at') }}:
        <x-ui.date-time :value="data_get($activity, 'createdAt') ?? data_get($activity, 'created_at')" />
    </div>

    <div class="app-text-muted-xs">
        {{ __('ui.activity_type') }}:
        <x-admin.activities.type-label :activity="$activity" />
    </div>

    <div class="app-text-muted-xs">
        {{ __('ui.length') }}:
        {{ number_format((float) (data_get($activity, 'lengthInKm') ?? data_get($activity, 'distance_kilometers') ?? 0), 2, ',', ' ') }} km
    </div>

    <div class="pt-2 flex justify-end">
        <x-admin.activities.delete-form :activity="$activity" />
    </div>
</div>
