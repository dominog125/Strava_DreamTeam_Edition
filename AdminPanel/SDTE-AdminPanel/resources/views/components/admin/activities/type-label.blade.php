@props(['activity'])

{{ \App\Models\Activity::translateActivityType((string) (data_get($activity, 'categoryName') ?? data_get($activity, 'activity_type') ?? '')) }}
