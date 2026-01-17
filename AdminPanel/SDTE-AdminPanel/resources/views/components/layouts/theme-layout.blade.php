<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="UTF-8">
        <title>{{ $title ?? 'Aplikacja' }}</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">

        @vite('resources/css/app.css')
    </head>
    <body class="app-page">
        <div class="fixed right-6 top-6 z-50">
            <x-ui.language-switcher />
        </div>

        {{ $slot }}
    </body>
</html>