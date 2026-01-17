<?php

namespace App\Application\Administration\Activities;

interface AdministratorActivityCategoriesReader
{
    public function listNames(): array;
}
