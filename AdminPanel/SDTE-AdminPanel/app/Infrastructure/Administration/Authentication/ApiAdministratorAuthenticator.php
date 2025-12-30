<?php

namespace App\Infrastructure\Administration\Authentication;

use App\Application\Administration\Authentication\AdministratorAuthenticationResult;
use App\Application\Administration\Authentication\AdministratorAuthenticator;
use RuntimeException;

class ApiAdministratorAuthenticator implements AdministratorAuthenticator
{
    public function authenticate(string $login, string $password): AdministratorAuthenticationResult
    {
        throw new RuntimeException('API authentication is not implemented yet.');
    }
}
