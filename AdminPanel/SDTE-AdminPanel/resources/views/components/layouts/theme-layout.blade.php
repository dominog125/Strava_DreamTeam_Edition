<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <title>{{ $title ?? 'Aplikacja' }}</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    @vite('resources/css/app.css')
</head>
<body class="min-h-screen bg-gray-200 text-gray-900 dark:bg-gray-900 dark:text-gray-100 antialiased">
    {{ $slot }}
</body>
</html>