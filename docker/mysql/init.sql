-- Auto-create the application database if it does not exist.
CREATE DATABASE IF NOT EXISTS `db_ky_servicercenter`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

GRANT ALL PRIVILEGES ON `db_ky_servicercenter`.* TO 'laravel'@'%';
FLUSH PRIVILEGES;
