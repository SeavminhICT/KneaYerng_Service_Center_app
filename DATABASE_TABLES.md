# Database Tables Inventory

Source of truth: `backend/database/migrations`

Schema snapshot covered by this file:
- First migration: `0001_01_01_000000_create_users_table.php`
- Latest migration in repo: `2026_05_08_000001_create_admin_notification_campaigns_table.php`

Total tables found: `45`

## 1. Laravel Auth and Infrastructure

| Table | Purpose | Current columns |
| --- | --- | --- |
| `users` | Main user accounts for customers, staff, technicians, and admins. | `id`, `first_name`, `last_name`, `email` (nullable, unique), `phone` (nullable, unique), `email_verified_at`, `password`, `avatar`, `role`, `is_admin`, `remember_token`, `otp_code`, `otp_expires_at`, `otp_verified_at`, `created_at`, `updated_at` |
| `password_reset_tokens` | Password reset tokens for email-based recovery. | `email` (PK), `token`, `created_at` |
| `sessions` | Laravel session storage. | `id` (PK), `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity` |
| `personal_access_tokens` | Laravel Sanctum API tokens. | `id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at` |
| `cache` | Laravel application cache entries. | `key` (PK), `value`, `expiration` |
| `cache_locks` | Cache lock records. | `key` (PK), `owner`, `expiration` |
| `jobs` | Queued jobs. | `id`, `queue`, `payload`, `attempts`, `reserved_at`, `available_at`, `created_at` |
| `job_batches` | Queue batch processing state. | `id` (PK), `name`, `total_jobs`, `pending_jobs`, `failed_jobs`, `failed_job_ids`, `options`, `cancelled_at`, `created_at`, `finished_at` |
| `failed_jobs` | Failed queued jobs log. | `id`, `uuid`, `connection`, `queue`, `payload`, `exception`, `failed_at` |

## 2. Catalog and Content

| Table | Purpose | Current columns |
| --- | --- | --- |
| `categories` | Product categories for the shop. | `id`, `name`, `slug`, `image`, `sort_order`, `status`, `created_at`, `updated_at` |
| `products` | Main product catalog. | `id`, `name`, `description`, `sku`, `category_id`, `price`, `discount`, `stock`, `status`, `tag`, `image`, `brand`, `warranty`, `thumbnail`, `image_gallery`, `storage_capacity`, `color`, `condition`, `ram`, `ssd`, `cpu`, `display`, `country`, `created_at`, `updated_at` |
| `product_attribute_options` | Reusable attribute values such as colors or storage options. | `id`, `type`, `value`, `created_at`, `updated_at` |
| `product_variants` | Sellable variants for a product. | `id`, `product_id`, `storage_capacity`, `color`, `condition`, `ram`, `ssd`, `price`, `stock`, `sku`, `image`, `is_active`, `sort_order`, `created_at`, `updated_at` |
| `accessories` | Accessory inventory catalog. | `id`, `brand`, `name`, `price`, `discount`, `tag`, `stock`, `warranty`, `description`, `image`, `created_at`, `updated_at`, `deleted_at` |
| `banners` | Home or marketing banner content. | `id`, `image`, `badge_label`, `title`, `subtitle`, `cta_label`, `created_at`, `updated_at` |

## 3. Orders, Cart, Checkout, and Payments

| Table | Purpose | Current columns |
| --- | --- | --- |
| `addresses` | Placeholder address table. | `id`, `created_at`, `updated_at` |
| `orders` | Customer order header and workflow state. | `id`, `order_number`, `user_id`, `assigned_staff_id`, `approved_by`, `approved_at`, `rejected_by`, `rejected_at`, `rejected_reason`, `cancelled_by`, `cancelled_at`, `cancelled_reason`, `customer_name`, `customer_email`, `order_type`, `payment_method`, `delivery_address`, `delivery_phone`, `delivery_note`, `delivery_lat`, `delivery_lng`, `subtotal`, `delivery_fee`, `voucher_id`, `voucher_code`, `discount_type`, `discount_value`, `discount_amount`, `pickup_qr_token`, `pickup_qr_generated_at`, `pickup_qr_expires_at`, `pickup_verified_at`, `pickup_verified_by`, `total_amount`, `payment_status`, `status`, `current_status_at`, `inventory_deducted`, `placed_at`, `telegram_chat_id`, `telegram_message_id`, `telegram_last_action`, `telegram_last_action_by`, `telegram_last_action_at`, `telegram_message_sent_at`, `created_at`, `updated_at` |
| `order_items` | Order line items. | `id`, `order_id`, `product_id`, `item_type`, `item_id`, `product_variant_id`, `product_name`, `variant_label`, `quantity`, `price`, `line_total`, `created_at`, `updated_at` |
| `carts` | One active cart per user. | `id`, `user_id`, `created_at`, `updated_at` |
| `cart_items` | Cart line items. | `id`, `cart_id`, `product_id`, `item_type`, `item_id`, `product_variant_id`, `product_name`, `variant_label`, `unit_price`, `quantity`, `line_total`, `created_at`, `updated_at` |
| `vouchers` | Discount voucher master data. | `id`, `code`, `name`, `discount_type`, `discount_value`, `min_order_amount`, `starts_at`, `expires_at`, `usage_limit_total`, `usage_limit_per_user`, `is_active`, `is_stackable`, `description`, `created_at`, `updated_at` |
| `voucher_redemptions` | Voucher use history per user and order. | `id`, `voucher_id`, `user_id`, `order_id`, `redeemed_at`, `created_at`, `updated_at` |
| `payments` | Generic order payment records. | `id`, `order_id`, `method`, `status`, `transaction_id`, `provider`, `amount`, `callback_payload`, `paid_at`, `created_at`, `updated_at` |
| `khqr_transactions` | KHQR-specific payment transactions. | `id`, `transaction_id`, `md5`, `full_hash`, `order_id`, `amount`, `currency`, `qr_string`, `status`, `expires_at`, `paid_at`, `checked_at`, `provider_payload`, `created_at`, `updated_at` |

## 4. Repair Service Management

| Table | Purpose | Current columns |
| --- | --- | --- |
| `technicians` | Technician roster and workload state. | `id`, `name`, `skill_set`, `active_jobs_count`, `availability_status`, `created_at`, `updated_at` |
| `repair_requests` | Main repair job records. | `id`, `customer_id`, `technician_id`, `device_model`, `issue_type`, `service_type`, `appointment_datetime`, `status`, `created_at`, `updated_at` |
| `intakes` | Device intake details for a repair request. | `id`, `repair_id`, `imei_serial`, `device_condition_checklist`, `intake_photos`, `notes`, `created_at`, `updated_at` |
| `diagnostics` | Diagnostic results and estimated labor for a repair request. | `id`, `repair_id`, `problem_description`, `parts_required`, `labor_cost`, `diagnostic_notes`, `created_at`, `updated_at` |
| `quotations` | Repair quotations awaiting approval. | `id`, `repair_id`, `parts_cost`, `labor_cost`, `total_cost`, `status`, `customer_approved_at`, `created_at`, `updated_at` |
| `repair_status_logs` | Status history for repair jobs. | `id`, `repair_id`, `status`, `updated_by`, `logged_at`, `created_at`, `updated_at` |
| `parts` | Repair parts inventory. | `id`, `name`, `type`, `brand`, `sku`, `stock`, `unit_cost`, `status`, `tag`, `created_at`, `updated_at` |
| `parts_usages` | Pivot table for parts consumed by repairs. | `id`, `repair_id`, `part_id`, `quantity`, `cost`, `created_at`, `updated_at` |
| `warranties` | Warranty issued for a completed repair. | `id`, `repair_id`, `duration_days`, `covered_issues`, `start_date`, `end_date`, `status`, `created_at`, `updated_at` |
| `invoices` | Repair billing invoices. | `id`, `repair_id`, `invoice_number`, `subtotal`, `tax`, `total`, `payment_status`, `created_at`, `updated_at` |
| `repair_payments` | Payments attached to repair invoices. | `id`, `invoice_id`, `type`, `method`, `amount`, `status`, `transaction_ref`, `created_at`, `updated_at` |
| `chat_messages` | Repair-related customer/staff chat. | `id`, `repair_id`, `sender_type`, `message`, `created_at`, `updated_at` |
| `repair_notifications` | Notifications pushed for repair events. | `id`, `user_id`, `repair_id`, `type`, `title`, `body`, `read_at`, `created_at`, `updated_at` |

## 5. Tracking, Support, Notifications, and OTP

| Table | Purpose | Current columns |
| --- | --- | --- |
| `otp_verifications` | OTP challenge records for email or phone verification. | `id`, `destination_type`, `destination`, `purpose`, `user_id`, `otp_hash`, `status`, `attempts`, `max_attempts`, `expires_at`, `cooldown_until`, `locked_until`, `consumed_at`, `request_ip`, `device_id`, `created_at`, `updated_at` |
| `email_otps` | Email OTP storage keyed by email address. | `id`, `email`, `otp_hash`, `expires_at`, `verified_at`, `attempts`, `last_sent_at`, `created_at`, `updated_at` |
| `order_tracking_histories` | Order status transition history. | `id`, `order_id`, `from_status`, `to_status`, `changed_by_user_id`, `changed_by_role`, `assigned_staff_id`, `override_used`, `note`, `meta`, `created_at`, `updated_at` |
| `order_tracking_notifications` | Push/inbox notifications for order updates. | `id`, `user_id`, `order_id` (nullable), `type`, `title`, `body`, `payload`, `read_at`, `created_at`, `updated_at` |
| `mobile_device_tokens` | Device tokens for push notifications. | `id`, `user_id`, `token`, `platform`, `last_used_at`, `created_at`, `updated_at` |
| `support_conversations` | Customer support threads. | `id`, `customer_id`, `assigned_to`, `status`, `context_type`, `context_id`, `subject`, `last_message_at`, `customer_last_read_at`, `support_last_read_at`, `resolved_at`, `created_at`, `updated_at` |
| `support_messages` | Messages inside support conversations. | `id`, `conversation_id`, `sender_user_id`, `sender_type`, `message_type`, `body`, `media_url`, `media_duration_sec`, `delivery_status`, `seen_at`, `created_at`, `updated_at` |
| `admin_notification_campaigns` | Admin-created notification campaigns for users. | `id`, `admin_user_id`, `type`, `title`, `message`, `audience`, `custom_user_ids`, `deep_link`, `action`, `status`, `scheduled_for`, `summary`, `meta`, `created_at`, `updated_at` |

## 6. Important Notes

1. `addresses` is currently only a scaffold table with no real address fields yet.
2. The Flutter app currently stores saved addresses locally in `app_ky_service_center/lib/services/address_book_service.dart`, so the database `addresses` table is not the active source for customer saved addresses.
3. `product_variants` appears in two migrations:
   - `2026_05_02_000001_create_product_variants_table.php`
   - `2026_05_05_000003_ensure_product_variants_table_exists.php`
   The second migration is a deployment safety guard and does not change the shape of the table.
4. `order_tracking_notifications.order_id` was created as required and later changed to nullable in `2026_04_03_000005_make_order_tracking_notifications_order_nullable.php`.
5. The table name for repair part usage is exactly `parts_usages` in the migrations, even though some teams might normally prefer `part_usages`.

## 7. Table Count by Domain

| Domain | Table count |
| --- | ---: |
| Laravel auth and infrastructure | 9 |
| Catalog and content | 6 |
| Orders, cart, checkout, and payments | 9 |
| Repair service management | 13 |
| Tracking, support, notifications, and OTP | 8 |
| **Total** | **45** |
