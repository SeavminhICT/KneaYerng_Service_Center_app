# ─── Stage 1: Build frontend assets ──────────────────────────────────────────
FROM node:20-alpine AS node-builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --frozen-lockfile
COPY . .
RUN npm run build


# ─── Stage 2: Production PHP-FPM image ───────────────────────────────────────
FROM php:8.2-fpm-alpine AS production

# System dependencies
RUN apk add --no-cache \
        bash \
        curl \
        git \
        unzip \
        netcat-openbsd \
        supervisor \
        libpng-dev \
        libjpeg-turbo-dev \
        freetype-dev \
        libzip-dev \
        icu-dev \
        oniguruma-dev \
        openssl-dev \
        linux-headers \
    && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" \
        pdo_mysql \
        mbstring \
        bcmath \
        zip \
        exif \
        pcntl \
        intl \
        gd \
        opcache \
    && apk del .build-deps \
    && mkdir -p /var/log/supervisor

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Install PHP dependencies (production only, skip scripts that need full env)
COPY composer.json composer.lock ./
RUN composer install \
        --no-dev \
        --no-scripts \
        --no-interaction \
        --optimize-autoloader \
        --prefer-dist

# Copy full application source
COPY . .

# Copy built Vite assets from node-builder stage
COPY --from=node-builder /app/public/build ./public/build

# Final autoload optimisation
RUN composer dump-autoload --optimize

# Ensure required directories exist with correct ownership
RUN mkdir -p \
        storage/framework/sessions \
        storage/framework/views \
        storage/framework/cache \
        storage/logs \
        bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Supervisor config
COPY docker/supervisord.conf /etc/supervisord.conf

# PHP-FPM: listen on Unix socket shared with Nginx container
RUN { \
        echo "[www]"; \
        echo "listen = /var/run/php-fpm.sock"; \
        echo "listen.owner = www-data"; \
        echo "listen.group = www-data"; \
        echo "listen.mode = 0660"; \
    } > /usr/local/etc/php-fpm.d/zz-socket.conf

# OPcache tuning for production
RUN { \
        echo "opcache.enable=1"; \
        echo "opcache.memory_consumption=256"; \
        echo "opcache.interned_strings_buffer=16"; \
        echo "opcache.max_accelerated_files=20000"; \
        echo "opcache.revalidate_freq=0"; \
        echo "opcache.validate_timestamps=0"; \
    } > /usr/local/etc/php/conf.d/opcache.ini

EXPOSE 9000

# Entrypoint: runs migrations + caches config/routes before starting supervisord
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
