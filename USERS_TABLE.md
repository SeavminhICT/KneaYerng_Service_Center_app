# Database schema for the project

## Table: `users`

| Column Name | Data Type | Description |
| --- | --- | --- |
| `id` | `BIGINT UNSIGNED` | Primary Key |
| `first_name` | `VARCHAR(255)` | Not Null |
| `last_name` | `VARCHAR(255)` | Not Null |
| `email` | `VARCHAR(255)` | Nullable, Unique |
| `phone` | `VARCHAR(255)` | Nullable, Unique |
| `email_verified_at` | `TIMESTAMP` | Nullable |
| `password` | `VARCHAR(255)` | Not Null |
| `avatar` | `VARCHAR(255)` | Nullable |
| `role` | `VARCHAR(255)` | Not Null, Default: `'user'` |
| `is_admin` | `BOOLEAN` | Not Null, Default: `false` |
| `remember_token` | `VARCHAR(100)` | Nullable |
| `otp_code` | `VARCHAR(255)` | Nullable |
| `otp_expires_at` | `TIMESTAMP` | Nullable |
| `otp_verified_at` | `TIMESTAMP` | Nullable |
| `created_at` | `TIMESTAMP` | Not Null |
| `updated_at` | `TIMESTAMP` | Not Null |

## Notes

- This is the main user table for customers, staff, technicians, and admins.
- Final schema is based on these migrations:
  - `0001_01_01_000000_create_users_table.php`
  - `2025_12_21_120000_add_role_to_users_table.php`
  - `2026_01_10_180000_add_phone_and_otp_to_users_table.php`
  - `2026_03_08_210000_make_users_email_nullable.php`
