<form
    method="post"
    action="{{ route('login.process') }}"
    class="space-y-4"
    autocomplete="off"
>
    @csrf

    <x-ui.form-group label="Login:" for="login" class="space-y-1.5">
        <x-ui.form-input
            id="login"
            name="login"
            type="text"
            autocomplete="username"
            :value="old('login')"
        />

        @error('login')
            <p class="app-form-error">{{ $message }}</p>
        @enderror
    </x-ui.form-group>

    <x-ui.form-group label="Hasło:" for="password" class="space-y-1.5">
        <x-ui.form-input
            id="password"
            name="password"
            type="password"
            autocomplete="current-password"
        />

        @error('password')
            <p class="app-form-error">{{ $message }}</p>
        @enderror
    </x-ui.form-group>

    <div class="pt-2">
        <x-ui.primary-button type="submit" class="w-full">
            Zaloguj się
        </x-ui.primary-button>
    </div>
</form>
