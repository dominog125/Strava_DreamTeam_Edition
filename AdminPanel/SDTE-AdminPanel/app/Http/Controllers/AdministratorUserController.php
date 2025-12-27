<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class AdministratorUserController extends Controller
{
    public function index(Request $request): View
    {
        $administrator = Auth::user();

        $searchName = $request->string('search_name')->trim();
        $searchEmail = $request->string('search_email')->trim();
        $perPage = $request->integer('per_page') ?: 10;

        if (! in_array($perPage, [10, 25, 50, 100], true)) {
            $perPage = 10;
        }

        $query = User::query();

        if ($searchName->isNotEmpty()) {
            $query->where('name', 'like', '%' . $searchName . '%');
        }

        if ($searchEmail->isNotEmpty()) {
            $query->where('email', 'like', '%' . $searchEmail . '%');
        }

        $users = $query
            ->orderBy('name')
            ->paginate($perPage)
            ->withQueryString();

        return view('admin.users.index', [
            'administrator' => $administrator,
            'users' => $users,
            'searchName' => $searchName->toString(),
            'searchEmail' => $searchEmail->toString(),
            'perPage' => $perPage,
        ]);
    }
}
