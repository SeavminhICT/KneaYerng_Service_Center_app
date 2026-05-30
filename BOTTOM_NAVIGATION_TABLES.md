# Database schema for button navigation

This file maps the bottom navigation buttons in the mobile app to the database tables used by the project.

## Navigation: `Home`

| Table Name | Status | Use |
| --- | --- | --- |
| `banners` | Current | Home banner slider |
| `categories` | Current | Category list on home |
| `products` | Current | Main product list and product cards |
| `product_variants` | Current | Product options such as storage, color, condition, RAM, SSD |
| `accessories` | Current | Search results from home search |
| `users` | Current | Logged-in user greeting/profile summary on home |
| `order_tracking_notifications` | Current | Notification list opened from home notification button |

### Notes

- Home search uses `products`, `accessories`, and `categories`.
- Repair service suggestions on home search are currently static in code, not stored in a table.

## Navigation: `Repair`

| Table Name | Status | Use |
| --- | --- | --- |
| `accessories` | Current | The current `Repair` screen loads accessory items from `/accessories` |
| `repair_requests` | Available backend | Main repair request records |
| `technicians` | Available backend | Technician assignment |
| `intakes` | Available backend | Device intake data |
| `diagnostics` | Available backend | Diagnostic notes and repair analysis |
| `quotations` | Available backend | Repair quotation and approval |
| `repair_status_logs` | Available backend | Repair status history |
| `parts` | Available backend | Parts inventory for repair work |
| `parts_usages` | Available backend | Parts used in each repair |
| `warranties` | Available backend | Repair warranty records |
| `invoices` | Available backend | Repair invoice header |
| `repair_payments` | Available backend | Repair payment records |
| `chat_messages` | Available backend | Repair chat messages |
| `repair_notifications` | Available backend | Repair notifications for users |

### Notes

- The current mobile `Repair` tab is using `accessories` now.
- The full repair workflow already exists in the backend tables and API.

## Navigation: `Order`

| Table Name | Status | Use |
| --- | --- | --- |
| `orders` | Current | Main order header table |
| `order_items` | Current | Order line items |
| `payments` | Current | Order payment records |
| `khqr_transactions` | Current | KHQR payment transactions |
| `vouchers` | Current | Discount voucher master data |
| `voucher_redemptions` | Current | Voucher usage history |
| `order_tracking_histories` | Current | Order status timeline/history |
| `order_tracking_notifications` | Current | Notifications for order updates |
| `users` | Current | Customer, staff, approver, rejector, canceller links |

### Notes

- Pickup and delivery orders both come from `orders`.
- The `Orders` screen also reads tracking history and payment data.

## Navigation: `Favorite`

| Table Name | Status | Use |
| --- | --- | --- |
| `favorites` | Recommended | Save favorite items per user |

### Recommended columns for `favorites`

| Column Name | Data Type | Description |
| --- | --- | --- |
| `id` | `BIGINT UNSIGNED` | Primary Key |
| `user_id` | `BIGINT UNSIGNED` | Foreign Key `users.id` |
| `item_type` | `VARCHAR(30)` | Example: `product`, `accessory` |
| `item_id` | `BIGINT UNSIGNED` | ID of the favorited item |
| `created_at` | `TIMESTAMP` | Created time |
| `updated_at` | `TIMESTAMP` | Updated time |

### Notes

- There is no current database table for favorites.
- The app currently stores favorites only in memory through `FavoriteService`.
- If you want favorites to persist after app restart or login on another device, create the `favorites` table.

## Navigation: `Profile`

| Table Name | Status | Use |
| --- | --- | --- |
| `users` | Current | Main profile data |
| `orders` | Current | Completed order history preview in profile |
| `order_items` | Current | Items shown with order history data |
| `mobile_device_tokens` | Current | Device token registration for notifications |
| `support_conversations` | Current | Support chat conversation header |
| `support_messages` | Current | Support chat messages |
| `order_tracking_notifications` | Current | User notification screen |
| `repair_notifications` | Current | Repair-related notification list |
| `admin_notification_campaigns` | Current admin feature | Admin notification history and sending panel |
| `addresses` | Scaffold only | Exists in DB, but not actively used by the app |

### Notes

- Saved addresses are currently stored locally in the mobile app, not in the database `addresses` table.
- The mobile `UserProfile` model expects `birth` and `gender`, but those columns do not exist in the current `users` migrations.

## Summary

| Navigation Button | Main tables |
| --- | --- |
| `Home` | `banners`, `categories`, `products`, `product_variants` |
| `Repair` | `accessories`, `repair_requests`, `technicians`, `diagnostics`, `quotations` |
| `Order` | `orders`, `order_items`, `payments`, `order_tracking_histories`, `order_tracking_notifications` |
| `Favorite` | `favorites` recommended |
| `Profile` | `users`, `orders`, `support_conversations`, `support_messages`, `mobile_device_tokens` |
