<form
    method="post"
    action="{{ route('login.process') }}"
    class="space-y-4"
    autocomplete="off"
>
    @csrf

    <div class="space-y-1.5">
        <label for="login" class="block text-sm font-semibold">
            Login:
        </label>
        <input
            id="login"
            name="login"
            type="text"
            autocomplete="username"
            value="{{ old('login') }}"
            class="block w-full rounded-xl border border-gray-300 dark:border-gray-600
                   bg-white dark:bg-gray-900/80
                   px-3 py-2 text-sm
                   text-gray-900 dark:text-gray-100
                   focus:outline-none focus:ring-2 focus:ring-orange-400 focus:border-orange-400
                   transition"
        >
        @error('login')
            <p class="mt-1 text-xs text-red-600 dark:text-red-400">{{ $message }}</p>
        @enderror
    </div>

    <div class="space-y-1.5">
        <label for="password" class="block text-sm font-semibold">
            Hasło:
        </label>
        <input
            id="password"
            name="password"
            type="password"
            autocomplete="current-password"
            class="block w-full rounded-xl border border-gray-300 dark:border-gray-600
                   bg-white dark:bg-gray-900/80
                   px-3 py-2 text-sm
                   text-gray-900 dark:text-gray-100
                   focus:outline-none focus:ring-2 focus:ring-orange-400 focus:border-orange-400
                   transition"
        >
        @error('password')
            <p class="mt-1 text-xs text-red-600 dark:text-red-400">{{ $message }}</p>
        @enderror
    </div>

    <div class="pt-2">
        <x-ui.primary-button>
            Zaloguj się
        </x-ui.primary-button>
    </div>
</form>