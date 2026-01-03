<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('activities', function (Blueprint $table) {
            $table->uuid('uuid')->nullable()->after('id');
        });

        DB::table('activities')
            ->whereNull('uuid')
            ->orderBy('id')
            ->chunkById(200, function ($activities) {
                foreach ($activities as $activity) {
                    DB::table('activities')
                        ->where('id', $activity->id)
                        ->update(['uuid' => (string) Str::uuid()]);
                }
            });

        Schema::table('activities', function (Blueprint $table) {
            $table->unique('uuid');
        });
    }

    public function down(): void
    {
        Schema::table('activities', function (Blueprint $table) {
            $table->dropUnique(['uuid']);
            $table->dropColumn('uuid');
        });
    }
};
