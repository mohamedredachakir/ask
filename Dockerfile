FROM php:8.3-fpm-alpine

# User IDs (to match host user)
ARG UID=1000
ARG GID=1000

# Install system packages
RUN apk add --no-cache \
    bash \
    git \
    unzip \
    libpq-dev \
    oniguruma-dev \
    icu-dev \
    curl

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# PHP extensions
RUN docker-php-ext-install \
    pdo \
    pdo_pgsql \
    intl

# Create laravel user
RUN addgroup -g ${GID} laravel \
    && adduser -D -u ${UID} -G laravel laravel

WORKDIR /var/www/html

# Copy project (for first build, can be empty)
# COPY ./src .   # Uncomment if you have local source

# Ensure storage & cache dirs exist
RUN mkdir -p storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

USER laravel

CMD ["php-fpm"]