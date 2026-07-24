FROM wordpress:php8.5-fpm

# Install APCu
RUN pecl install apcu && docker-php-ext-enable apcu

# OPcache is already compiled in — just needs enabling
RUN docker-php-ext-enable opcache
