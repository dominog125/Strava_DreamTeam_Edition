<?php

namespace App\Application\Administration\Authentication;

interface AdministratorAuthenticator
{
    public function authenticate(string $login, string $password): AdministratorAuthenticationResult;
}
