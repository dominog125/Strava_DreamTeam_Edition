<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Activity extends Model
{
    use HasFactory;
    use HasUuids;

    protected $fillable = [
        'user_id',
        'activity_type',
        'distance_kilometers',
    ];

    protected function casts(): array
    {
        return [
            'distance_kilometers' => 'decimal:2',
        ];
    }

    public function uniqueIds(): array
    {
        return ['uuid'];
    }

    public function getRouteKeyName(): string
    {
        return 'uuid';
    }

    protected function activityTypeLabel(): Attribute
    {
        return Attribute::make(
            get: fn (): string => self::translateActivityType((string) $this->activity_type),
        );
    }

    public static function translateActivityType(string $storedValue): string
    {
        $mappedKey = match ($storedValue) {
            'Spacer'=> 'walk',
            'Bieg'=> 'run',
            'Rower'=> 'bike',
            'Trening siłowy' => 'strength_training',
            'Hiking' => 'hiking',
            default => $storedValue,
        };

        if ($mappedKey === null) {
            return $storedValue;
        }

        $key = 'activity_types.' . $mappedKey;

        if (trans()->has($key)) {
            return __($key);
        }

        return $storedValue;
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
