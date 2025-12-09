<div class="w-full max-w-md">
    <div class="border-2 border-orange-500 rounded-2xl bg-gray-50/95 dark:bg-gray-800/95 shadow-xl p-8 sm:p-9">
        <h1 class="text-center text-2xl font-bold tracking-wide mb-2">
            Panel logowania
        </h1>

        <p class="text-center text-sm text-gray-600 dark:text-gray-300 mb-6">
            Wpisz swój login i hasło, aby przejść do panelu administratora.
        </p>

        <form method="post" action="{{ route('login.process') }}" class="space-y-4" autocomplete="off">
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
                <button
                    type="submit"
                    class="w-full rounded-full
                           bg-gradient-to-r from-orange-500 to-orange-600
                           text-white font-semibold text-sm
                           py-2.5
                           shadow-lg shadow-orange-500/40
                           hover:from-orange-600 hover:to-orange-700
                           focus:outline-none focus:ring-2 focus:ring-orange-400
                           focus:ring-offset-2 focus:ring-offset-gray-100 dark:focus:ring-offset-gray-900
                           transition"
                >
                    Zaloguj się
                </button>
            </div>
        </form>
    </div>
</div>