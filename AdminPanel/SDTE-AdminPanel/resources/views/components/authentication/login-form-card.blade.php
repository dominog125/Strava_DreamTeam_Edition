<form
    method="post"
    action="{{ route('login.process') }}"
    class="space-y-4"
    autocomplete="off"
>
    @csrf

    <x-ui.form-group :label="__('ui.login') . ':'" for="login" class="space-y-1.5">
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

    <x-ui.form-group :label="__('ui.password') . ':'" for="password" class="space-y-1.5">
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

    <div class="pt-4 flex justify-center">
        <x-ui.primary-button type="submit" class="px-8 py-3 text-sm">
            {{ __('ui.sign_in') }}
        </x-ui.primary-button>
    </div>
</form>
