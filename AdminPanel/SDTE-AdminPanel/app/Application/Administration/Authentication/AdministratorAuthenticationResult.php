<?php

namespace App\Application\Administration\Authentication;

class AdministratorAuthenticationResult
{
    public function __construct(
        public readonly bool $isSuccessful,
        public readonly ?string $failureMessage,
    ) {
    }

    public static function successful(): self
    {
        return new self(true, null);
    }

    public static function failed(string $failureMessage): self
    {
        return new self(false, $failureMessage);
    }
}
