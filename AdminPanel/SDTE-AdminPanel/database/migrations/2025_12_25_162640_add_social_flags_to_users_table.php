<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->boolean('is_discord_connected')->default(false)->after('remember_token');
            $table->boolean('is_google_connected')->default(false)->after('is_discord_connected');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'is_discord_connected',
                'is_google_connected',
            ]);
        });
    }
};
