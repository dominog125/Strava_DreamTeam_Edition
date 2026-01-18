@props(['activity'])

@php
    $activityId = (string) (data_get($activity, 'id') ?? data_get($activity, 'uuid') ?? '');
@endphp

@if ($activityId !== '')
    <form
        method="post"
        action="{{ route('administrator.activities.destroy', $activityId) }}"
        onsubmit="return confirm('{{ __('ui.confirm_delete_activity') }}');"
    >
        @csrf
        @method('DELETE')

        <x-ui.danger-button type="submit" class="px-4 py-1.5 text-xs">
            {{ __('ui.delete') }}
        </x-ui.danger-button>
    </form>
@endif
