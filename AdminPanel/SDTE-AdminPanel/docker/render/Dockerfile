FROM composer:2 AS vendor
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --no-interaction --no-progress

FROM node:20-alpine AS assets
WORKDIR /app
COPY package.json package-lock.json* ./
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi
COPY . .
RUN npm run build || true

FROM php:8.3-cli-alpine
WORKDIR /app

RUN apk add --no-cache icu-dev oniguruma-dev libzip-dev zip unzip \
  && docker-php-ext-install intl pdo_mysql zip

COPY --from=vendor /app/vendor /app/vendor
COPY . .
COPY --from=assets /app/public/build /app/public/build

RUN mkdir -p storage/framework/{cache,sessions,views} bootstrap/cache

ENV APP_ENV=production
ENV APP_DEBUG=false

CMD sh -c 'php -S 0.0.0.0:${PORT:-10000} -t public'
