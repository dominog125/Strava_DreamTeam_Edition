@props(['user'])

<div class="app-card">
    <div class="app-card-title">
        {{ $user->name }}
    </div>

    <div class="app-text-muted-xs break-all">
        {{ $user->email }}
    </div>

    <div class="app-text-muted-xs">
        Utworzony: {{ $user->created_at?->format('Y-m-d H:i') }}
    </div>

    <div class="app-text-muted-xs flex gap-3">
        <span>Discord: {{ $user->is_discord_connected ? 'Tak' : 'Nie' }}</span>
        <span>Google: {{ $user->is_google_connected ? 'Tak' : 'Nie' }}</span>
    </div>
</div>