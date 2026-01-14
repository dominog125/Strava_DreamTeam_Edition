<x-layouts.authentication-layout :title="__('ui.login_panel_title')">
    <x-ui.panel-shell
        :title="__('ui.login_panel_title')"
        :subtitle="__('ui.login_panel_subtitle')"
    >
        <x-authentication.login-form-card />
    </x-ui.panel-shell>
</x-layouts.authentication-layout>
