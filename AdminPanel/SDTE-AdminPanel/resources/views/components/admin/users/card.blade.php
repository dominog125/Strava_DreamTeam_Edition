@props(['user'])

<div class="app-card">
    <div class="app-card-title">
        {{ data_get($user, 'userName') ?? data_get($user, 'name') ?? '' }}
    </div>

    <div class="app-text-muted-xs break-all">
        {{ data_get($user, 'email') ?? '' }}
    </div>

    <div class="app-text-muted-xs">
        {{ __('ui.is_blocked') }}
        {{ (bool) (data_get($user, 'isBlocked') ?? data_get($user, 'is_blocked') ?? false) ? __('ui.yes') : __('ui.no') }}
    </div>

    <div class="app-text-muted-xs">
        {{ __('ui.lockout_end_utc') }}
        <x-ui.date-time :value="data_get($user, 'lockoutEndUtc') ?? data_get($user, 'lockout_end_utc')" />
    </div>
</div>
