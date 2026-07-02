<?php

namespace Database\Seeders;

use App\Models\Permission;
use App\Models\Role;
use Illuminate\Database\Seeder;

class RolePermissionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $permissions = [
            'create_user', 'view_user', 'update_user', 'delete_user',
            'create_role', 'view_role', 'update_role', 'delete_role',
            'create_permission', 'view_permission', 'update_permission', 'delete_permission',
        ];

        foreach ($permissions as $name) {
            Permission::updateOrCreate(['name' => $name]);
        }

        $roles = [
            'Admin' => 'Full access to all features',
            'Manager' => 'Manages users and views roles/permissions',
            'Staff' => 'Limited operational access',
            'User' => 'Basic access',
        ];

        foreach ($roles as $name => $description) {
            Role::updateOrCreate(['name' => $name], ['description' => $description]);
        }

        $admin = Role::where('name', 'Admin')->first();
        $admin->permissions()->sync(Permission::pluck('id'));

        $manager = Role::where('name', 'Manager')->first();
        $manager->permissions()->sync(
            Permission::whereIn('name', ['view_user', 'create_user', 'update_user', 'view_role', 'view_permission'])->pluck('id')
        );

        $staff = Role::where('name', 'Staff')->first();
        $staff->permissions()->sync(
            Permission::whereIn('name', ['view_user'])->pluck('id')
        );
    }
}
