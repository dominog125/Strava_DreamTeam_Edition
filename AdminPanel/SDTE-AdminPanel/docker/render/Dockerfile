FROM composer:2 AS vendor
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --no-interaction --no-progress --no-scripts

FROM node:20-alpine AS assets
WORKDIR /app
COPY package.json package-lock.json* ./
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi
COPY . .
RUN npm run build

FROM php:8.4-cli-alpine
WORKDIR /app

RUN apk add --no-cache \
        icu-dev \
        oniguruma-dev \
        libzip-dev \
        libxml2-dev \
        curl-dev \
        ca-certificates \
        zip \
        unzip \
    && update-ca-certificates \
    && docker-php-ext-install \
        intl \
        pdo_mysql \
        zip \
        opcache \
        mbstring \
        xml \
        bcmath \
        curl

COPY --from=vendor /app/vendor /app/vendor
COPY . .
COPY --from=assets /app/public/build /app/public/build

RUN rm -f public/hot

COPY server.php /server.php
RUN test -f /server.php

RUN mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache \
    && php artisan package:discover --ansi \
    && chown -R www-data:www-data storage bootstrap/cache

RUN { \
    echo "log_errors=On"; \
    echo "error_log=/dev/stderr"; \
    echo "display_errors=On"; \
    echo "display_startup_errors=On"; \
    echo "error_reporting=E_ALL"; \
} > /usr/local/etc/php/conf.d/zz-render-errors.ini

ENV APP_ENV=production
ENV APP_DEBUG=false
ENV LOG_CHANNEL=errorlog
ENV LOG_LEVEL=info
ENV SESSION_DRIVER=file
ENV CACHE_STORE=file
ENV CACHE_DRIVER=file

USER www-data

CMD ["sh", "-c", "php -S 0.0.0.0:${PORT:-10000} -t /public /server.php"]
