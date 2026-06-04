#!/bin/sh
set -e

cd /var/www/html

echo "[entrypoint] Waiting for database to be ready..."
DB_HOST="${DB_HOST:-mysql}"
DB_PORT="${DB_PORT:-3306}"

# Poll until the TCP port accepts connections (max 60 seconds)
i=0
until nc -z "$DB_HOST" "$DB_PORT" 2>/dev/null; do
    i=$((i + 1))
    if [ "$i" -ge 20 ]; then
        echo "[entrypoint] ERROR: Database did not become ready in 60 s. Aborting."
        exit 1
    fi
    echo "[entrypoint] DB not ready (attempt $i/20), retrying in 3s..."
    sleep 3
done
echo "[entrypoint] Database is up."

echo "[entrypoint] Running database migrations..."
php artisan migrate --force

echo "[entrypoint] Seeding admin user and default data..."
php artisan db:seed --force --class=DatabaseSeeder

echo "[entrypoint] Creating storage symlink..."
rm -rf /var/www/html/public/storage
php artisan storage:link

echo "[entrypoint] Caching config, routes, and views..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "[entrypoint] Starting supervisord..."
exec /usr/bin/supervisord -n -c /etc/supervisord.conf
