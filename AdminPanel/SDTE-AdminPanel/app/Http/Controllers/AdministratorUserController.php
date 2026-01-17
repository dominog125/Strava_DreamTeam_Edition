<?php

namespace App\Http\Controllers;

use App\Application\Administration\Users\AdministratorUsersFilters;
use App\Application\Administration\Users\AdministratorUsersReader;
use Illuminate\Http\Request;
use Illuminate\View\View;

class AdministratorUserController extends Controller
{
    public function __construct(
        private readonly AdministratorUsersReader $administratorUsersReader
    ) {
    }

    public function index(Request $request): View
    {
        $perPage = (int) $request->input('per_page', 10);
        $perPage = $perPage > 0 ? $perPage : 10;

        $filters = new AdministratorUsersFilters(
            searchName: $request->input('search_name') ?: null,
            searchEmail: $request->input('search_email') ?: null,
            perPage: $perPage,
        );

        $users = $this->administratorUsersReader
            ->paginate($filters)
            ->appends($request->query());

        return view('admin.users.index', [
            'users' => $users,
            'searchName' => $filters->searchName ?? '',
            'searchEmail' => $filters->searchEmail ?? '',
            'perPage' => $filters->perPage,
        ]);
    }
}
