@props([
    'title',
])

<section
    class="w-full rounded-2xl border-2 border-orange-500
           bg-gray-50/95 dark:bg-gray-800/95
           px-6 py-5 shadow-md"
>
    <h2 class="mb-4 text-base font-semibold text-gray-900 dark:text-gray-100">
        {{ $title }}
    </h2>

    {{ $slot }}
</section>
