-- Auto-generated ERD schema from Laravel migrations
-- Generated for SmartDraw import

CREATE TABLE `accessories` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `brand` VARCHAR(255),
  `name` VARCHAR(255),
  `price` DECIMAL(10,2),
  `discount` DECIMAL(10,2),
  `warranty` VARCHAR(255),
  `description` TEXT,
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP,
  `deleted_at` TIMESTAMP,
  `tag` VARCHAR(50),
  `stock` INT UNSIGNED,
  `image` VARCHAR(255)
);

CREATE TABLE `addresses` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP
);

CREATE TABLE `banners` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP,
  `image` VARCHAR(255)
);

CREATE TABLE `cache` (
  `key` VARCHAR(255),
  `value` MEDIUMTEXT,
  `expiration` INT
);

CREATE TABLE `cache_locks` (
  `key` VARCHAR(255),
  `owner` VARCHAR(255),
  `expiration` INT
);

CREATE TABLE `cart_items` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `cart_id` BIGINT UNSIGNED,
  `product_id` BIGINT UNSIGNED,
  `product_name` VARCHAR(255),
  `unit_price` DECIMAL(12,2),
  `quantity` INT UNSIGNED,
  `line_total` DECIMAL(12,2),
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP,
  `item_type` VARCHAR(30),
  `item_id` BIGINT UNSIGNED,
  FOREIGN KEY (`cart_id`) REFERENCES `carts`(`id`),
  FOREIGN KEY (`product_id`) REFERENCES `products`(`id`)
);

CREATE TABLE `carts` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT UNSIGNED,
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
);

CREATE TABLE `categories` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255),
  `slug` VARCHAR(255),
  `image` VARCHAR(255),
  `sort_order` INT UNSIGNED,
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP,
  `status` VARCHAR(255)
);

CREATE TABLE `chat_messages` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `repair_id` BIGINT UNSIGNED,
  `sender_type` VARCHAR(50),
  `message` TEXT,
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP,
  FOREIGN KEY (`repair_id`) REFERENCES `repair_requests`(`id`)
);

CREATE TABLE `diagnostics` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `repair_id` BIGINT UNSIGNED,
  `problem_description` TEXT,
  `parts_required` JSON,
  `labor_cost` DECIMAL(12,2),
  `diagnostic_notes` TEXT,
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP,
  FOREIGN KEY (`repair_id`) REFERENCES `repair_requests`(`id`)
);

CREATE TABLE `failed_jobs` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `uuid` VARCHAR(255),
  `connection` TEXT,
  `queue` TEXT,
  `payload` LONGTEXT,
  `exception` LONGTEXT,
  `failed_at` TIMESTAMP
);

CREATE TABLE `intakes` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `repair_id` BIGINT UNSIGNED,
  `imei_serial` VARCHAR(100),
  `device_condition_checklist` JSON,
  `intake_photos` JSON,
  `notes` TEXT,
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP,
  FOREIGN KEY (`repair_id`) REFERENCES `repair_requests`(`id`)
);

CREATE TABLE `invoices` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `repair_id` BIGINT UNSIGNED,
  `invoice_number` VARCHAR(100),
  `subtotal` DECIMAL(12,2),
  `tax` DECIMAL(12,2),
  `total` DECIMAL(12,2),
  `payment_status` VARCHAR(50),
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP,
  FOREIGN KEY (`repair_id`) REFERENCES `repair_requests`(`id`)
);

CREATE TABLE `job_batches` (
  `id` VARCHAR(255) PRIMARY KEY,
  `name` VARCHAR(255),
  `total_jobs` INT,
  `pending_jobs` INT,
  `failed_jobs` INT,
  `failed_job_ids` LONGTEXT,
  `options` MEDIUMTEXT,
  `cancelled_at` INT,
  `created_at` INT,
  `finished_at` INT
);

CREATE TABLE `jobs` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `queue` VARCHAR(255),
  `payload` LONGTEXT,
  `attempts` TINYINT UNSIGNED,
  `reserved_at` INT UNSIGNED,
  `available_at` INT UNSIGNED,
  `created_at` INT UNSIGNED
);

CREATE TABLE `khqr_transactions` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `transaction_id` VARCHAR(64),
  `order_id` BIGINT UNSIGNED,
  `amount` DECIMAL(12,2),
  `currency` VARCHAR(10),
  `qr_string` TEXT,
  `status` VARCHAR(30),
  `expires_at` TIMESTAMP,
  `paid_at` TIMESTAMP,
  `checked_at` TIMESTAMP,
  `provider_payload` JSON,
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP,
  `md5` VARCHAR(64),
  `full_hash` VARCHAR(128),
  FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`)
);

CREATE TABLE `order_items` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `order_id` BIGINT UNSIGNED,
  `product_id` BIGINT UNSIGNED,
  `product_name` VARCHAR(255),
  `quantity` INT UNSIGNED,
  `price` DECIMAL(12,2),
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP,
  `line_total` DECIMAL(12,2),
  `item_type` VARCHAR(30),
  `item_id` BIGINT UNSIGNED,
  FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`),
  FOREIGN KEY (`product_id`) REFERENCES `products`(`id`)
);

CREATE TABLE `orders` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `order_number` VARCHAR(255),
  `user_id` BIGINT UNSIGNED,
  `customer_name` VARCHAR(255),
  `customer_email` VARCHAR(255),
  `total_amount` DECIMAL(12,2),
  `payment_status` VARCHAR(255),
  `status` VARCHAR(255),
  `placed_at` TIMESTAMP,
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP,
  `order_type` VARCHAR(255),
  `payment_method` VARCHAR(255),
  `delivery_address` VARCHAR(255),
  `delivery_phone` VARCHAR(255),
  `pickup_qr_token` TEXT,
  `pickup_qr_generated_at` TIMESTAMP,
  `pickup_verified_at` TIMESTAMP,
  `delivery_note` TEXT,
  `subtotal` DECIMAL(12,2),
  `delivery_fee` DECIMAL(12,2),
  `inventory_deducted` TINYINT(1),
  `voucher_id` BIGINT UNSIGNED,
  `voucher_code` VARCHAR(255),
  `discount_type` VARCHAR(255),
  `discount_value` DECIMAL(12,2),
  `discount_amount` DECIMAL(12,2),
  `delivery_lat` DECIMAL(10,7),
  `delivery_lng` DECIMAL(10,7),
  `telegram_chat_id` VARCHAR(255),
  `telegram_message_id` VARCHAR(255),
  `telegram_last_action` VARCHAR(255),
  `telegram_last_action_by` VARCHAR(255),
  `telegram_last_action_at` TIMESTAMP,
  `telegram_message_sent_at` TIMESTAMP,
  `pickup_qr_expires_at` TIMESTAMP,
  `pickup_verified_by` BIGINT UNSIGNED,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`),
  FOREIGN KEY (`voucher_id`) REFERENCES `vouchers`(`id`)
);

CREATE TABLE `otp_verifications` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `destination_type` VARCHAR(10),
  `destination` VARCHAR(255),
  `purpose` VARCHAR(50),
  `user_id` BIGINT UNSIGNED,
  `otp_hash` VARCHAR(255),
  `status` VARCHAR(20),
  `attempts` TINYINT UNSIGNED,
  `max_attempts` TINYINT UNSIGNED,
  `expires_at` TIMESTAMP,
  `cooldown_until` TIMESTAMP,
  `locked_until` TIMESTAMP,
  `consumed_at` TIMESTAMP,
  `request_ip` VARCHAR(45),
  `device_id` VARCHAR(191),
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
);

CREATE TABLE `parts` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255),
  `sku` VARCHAR(100),
  `stock` INT UNSIGNED,
  `unit_cost` DECIMAL(12,2),
  `status` VARCHAR(50),
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP,
  `type` VARCHAR(100),
  `brand` VARCHAR(50),
  `tag` VARCHAR(50)
);

CREATE TABLE `parts_usages` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `repair_id` BIGINT UNSIGNED,
  `part_id` BIGINT UNSIGNED,
  `quantity` INT UNSIGNED,
  `cost` DECIMAL(12,2),
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP,
  FOREIGN KEY (`repair_id`) REFERENCES `repair_requests`(`id`),
  FOREIGN KEY (`part_id`) REFERENCES `parts`(`id`)
);

CREATE TABLE `password_reset_tokens` (
  `email` VARCHAR(255),
  `token` VARCHAR(255),
  `created_at` TIMESTAMP
);

CREATE TABLE `payments` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `order_id` BIGINT UNSIGNED,
  `method` VARCHAR(255),
  `status` VARCHAR(255),
  `transaction_id` VARCHAR(255),
  `provider` VARCHAR(255),
  `amount` DECIMAL(12,2),
  `callback_payload` JSON,
  `paid_at` TIMESTAMP,
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP,
  FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`)
);

CREATE TABLE `personal_access_tokens` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `tokenable_id` BIGINT UNSIGNED,
  `tokenable_type` VARCHAR(255),
  `name` TEXT,
  `token` VARCHAR(64),
  `abilities` TEXT,
  `last_used_at` TIMESTAMP,
  `expires_at` TIMESTAMP,
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP
);

CREATE TABLE `product_attribute_options` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `type` VARCHAR(50),
  `value` VARCHAR(150),
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP
);

CREATE TABLE `products` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP,
  `name` VARCHAR(255),
  `sku` VARCHAR(255),
  `category_id` BIGINT UNSIGNED,
  `price` DECIMAL(12,2),
  `stock` INT UNSIGNED,
  `status` VARCHAR(255),
  `image` VARCHAR(255),
  `description` TEXT,
  `discount` DECIMAL(12,2),
  `brand` VARCHAR(255),
  `thumbnail` VARCHAR(255),
  `image_gallery` JSON,
  `storage_capacity` JSON,
  `color` JSON,
  `condition` JSON,
  `warranty` VARCHAR(255),
  `tag` VARCHAR(50),
  `ram` JSON,
  `ssd` JSON,
  `cpu` JSON,
  `display` JSON,
  `country` JSON,
  FOREIGN KEY (`category_id`) REFERENCES `categories`(`id`)
);

CREATE TABLE `quotations` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `repair_id` BIGINT UNSIGNED,
  `parts_cost` DECIMAL(12,2),
  `labor_cost` DECIMAL(12,2),
  `total_cost` DECIMAL(12,2),
  `status` VARCHAR(50),
  `customer_approved_at` TIMESTAMP,
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP,
  FOREIGN KEY (`repair_id`) REFERENCES `repair_requests`(`id`)
);

CREATE TABLE `repair_notifications` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT UNSIGNED,
  `repair_id` BIGINT UNSIGNED,
  `type` VARCHAR(50),
  `title` VARCHAR(150),
  `body` TEXT,
  `read_at` TIMESTAMP,
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`),
  FOREIGN KEY (`repair_id`) REFERENCES `repair_requests`(`id`)
);

CREATE TABLE `repair_payments` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `invoice_id` BIGINT UNSIGNED,
  `type` VARCHAR(50),
  `method` VARCHAR(50),
  `amount` DECIMAL(12,2),
  `status` VARCHAR(50),
  `transaction_ref` VARCHAR(150),
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP,
  FOREIGN KEY (`invoice_id`) REFERENCES `invoices`(`id`)
);

CREATE TABLE `repair_requests` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `customer_id` BIGINT UNSIGNED,
  `technician_id` BIGINT UNSIGNED,
  `device_model` VARCHAR(255),
  `issue_type` VARCHAR(255),
  `service_type` VARCHAR(50),
  `appointment_datetime` DATETIME,
  `status` VARCHAR(50),
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP,
  FOREIGN KEY (`customer_id`) REFERENCES `users`(`id`),
  FOREIGN KEY (`technician_id`) REFERENCES `technicians`(`id`)
);

CREATE TABLE `repair_status_logs` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `repair_id` BIGINT UNSIGNED,
  `status` VARCHAR(50),
  `updated_by` BIGINT UNSIGNED,
  `logged_at` TIMESTAMP,
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP,
  FOREIGN KEY (`repair_id`) REFERENCES `repair_requests`(`id`),
  FOREIGN KEY (`updated_by`) REFERENCES `users`(`id`)
);

CREATE TABLE `sessions` (
  `id` VARCHAR(255) PRIMARY KEY,
  `user_id` BIGINT UNSIGNED,
  `ip_address` VARCHAR(45),
  `user_agent` TEXT,
  `payload` LONGTEXT,
  `last_activity` INT
);

CREATE TABLE `technicians` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255),
  `skill_set` JSON,
  `active_jobs_count` INT UNSIGNED,
  `availability_status` VARCHAR(50),
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP
);

CREATE TABLE `users` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `first_name` VARCHAR(255),
  `last_name` VARCHAR(255),
  `email` VARCHAR(255),
  `email_verified_at` TIMESTAMP,
  `password` VARCHAR(255),
  `avatar` VARCHAR(255),
  `remember_token` VARCHAR(100),
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP,
  `role` VARCHAR(255),
  `is_admin` TINYINT(1),
  `phone` VARCHAR(255),
  `otp_code` VARCHAR(255),
  `otp_expires_at` TIMESTAMP,
  `otp_verified_at` TIMESTAMP
);

CREATE TABLE `voucher_redemptions` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `voucher_id` BIGINT UNSIGNED,
  `user_id` BIGINT UNSIGNED,
  `order_id` BIGINT UNSIGNED,
  `redeemed_at` TIMESTAMP,
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP,
  FOREIGN KEY (`voucher_id`) REFERENCES `vouchers`(`id`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`),
  FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`)
);

CREATE TABLE `vouchers` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `code` VARCHAR(255),
  `name` VARCHAR(255),
  `discount_type` VARCHAR(255),
  `discount_value` DECIMAL(12,2),
  `min_order_amount` DECIMAL(12,2),
  `starts_at` TIMESTAMP,
  `expires_at` TIMESTAMP,
  `usage_limit_total` INT UNSIGNED,
  `usage_limit_per_user` INT UNSIGNED,
  `is_active` TINYINT(1),
  `is_stackable` TINYINT(1),
  `description` TEXT,
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP
);

CREATE TABLE `warranties` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `repair_id` BIGINT UNSIGNED,
  `duration_days` INT UNSIGNED,
  `covered_issues` TEXT,
  `start_date` DATE,
  `end_date` DATE,
  `status` VARCHAR(50),
  `created_at` TIMESTAMP,
  `updated_at` TIMESTAMP,
  FOREIGN KEY (`repair_id`) REFERENCES `repair_requests`(`id`)
);
