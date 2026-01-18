<?php

return [
    'data_source' => env('ADMINISTRATION_DATA_SOURCE'),

    'auth_mode' => env('ADMINISTRATION_AUTH_MODE'),

    'api' => [
        'base_url' => env('ADMINISTRATION_API_BASE_URL'),
        'timeout_seconds' => (int) env('ADMINISTRATION_API_TIMEOUT_SECONDS'),
    ],
];