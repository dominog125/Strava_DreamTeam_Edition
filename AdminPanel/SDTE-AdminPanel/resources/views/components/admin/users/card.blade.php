@props(['user'])

<div class="rounded-xl bg-gray-200 dark:bg-gray-900
            text-gray-900 dark:text-gray-100
            p-3 space-y-1">
    <div class="text-sm font-semibold">
        {{ $user->name }}
    </div>

    <div class="text-xs text-gray-600 dark:text-gray-300 break-all">
        {{ $user->email }}
    </div>

    <div class="text-xs text-gray-600 dark:text-gray-300">
        Utworzony: {{ $user->created_at?->format('Y-m-d H:i') }}
    </div>

    <div class="text-xs text-gray-600 dark:text-gray-300 flex gap-3">
        <span>Discord: {{ $user->is_discord_connected ? 'Tak' : 'Nie' }}</span>
        <span>Google: {{ $user->is_google_connected ? 'Tak' : 'Nie' }}</span>
    </div>
</div>
