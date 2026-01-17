<?php

namespace App\Application\Administration\Authentication;

class AdministratorAuthenticationResult
{
    public function __construct(
        public readonly bool $isSuccessful,
        public readonly ?string $failureMessage = null,
        public readonly ?string $jwtToken = null,
        public readonly ?string $username = null,
    ) {
    }

    public static function successful(?string $jwtToken = null, ?string $username = null): self
    {
        return new self(true, null, $jwtToken, $username);
    }

    public static function failed(string $failureMessage): self
    {
        return new self(false, $failureMessage);
    }
}
