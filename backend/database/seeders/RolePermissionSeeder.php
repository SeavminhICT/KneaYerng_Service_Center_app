<?php

namespace Database\Seeders;

use App\Models\Permission;
use App\Models\Role;
use Illuminate\Database\Seeder;

class RolePermissionSeeder extends Seeder
{
    /**
     * Module keys mapped to human readable labels. Every module gets the
     * four CRUD permissions: view_{key}, create_{key}, update_{key}, delete_{key}.
     */
    public const MODULES = [
        'dashboard' => 'Dashboard',
        'notification' => 'Notifications',
        'sales_report' => 'Sales Report',
        'support_inbox' => 'Support Inbox',
        'category' => 'Categories',
        'product' => 'Products',
        'product_master' => 'Product Master',
        'accessory' => 'Accessories',
        'banner' => 'Banners',
        'order' => 'Orders',
        'checking_pickup' => 'Checking Pick Up',
        'tracking_order' => 'Tracking Order',
        'voucher' => 'Vouchers',
        'customer' => 'Customers',
        'payment' => 'Payments',
        'parts_inventory' => 'Parts Inventory',
        'warranty_tracking' => 'Warranty Tracking',
        'user' => 'User Management',
        'role' => 'Role Management',
        'permission' => 'Permission Management',
        'setting' => 'Setting',
    ];

    public const ACTIONS = [
        'view' => 'View',
        'create' => 'Create',
        'update' => 'Update',
        'delete' => 'Delete',
    ];

    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        foreach (self::MODULES as $moduleKey => $moduleLabel) {
            foreach (self::ACTIONS as $actionKey => $actionLabel) {
                Permission::updateOrCreate(
                    ['name' => $actionKey.'_'.$moduleKey],
                    ['description' => $actionLabel.' '.$moduleLabel]
                );
            }
        }

        $roles = [
            'Admin' => 'Full access to all features',
            'Manager' => 'Manages users and views roles/permissions',
            'Staff' => 'Limited operational access',
            'Technician' => 'Repair and delivery assignment account',
            'User' => 'Basic access',
        ];

        foreach ($roles as $name => $description) {
            Role::updateOrCreate(['name' => $name], ['description' => $description]);
        }

        $admin = Role::where('name', 'Admin')->first();
        $admin->permissions()->sync(Permission::pluck('id'));

        $manager = Role::where('name', 'Manager')->first();
        $manager->permissions()->syncWithoutDetaching(
            Permission::whereIn('name', ['view_user', 'create_user', 'update_user', 'view_role', 'view_permission'])->pluck('id')
        );

        $staff = Role::where('name', 'Staff')->first();
        $staff->permissions()->syncWithoutDetaching(
            Permission::whereIn('name', ['view_dashboard', 'view_order', 'view_checking_pickup', 'view_tracking_order'])->pluck('id')
        );
    }
}
