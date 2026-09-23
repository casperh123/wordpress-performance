FROM wordpress:php8.5-fpm

RUN pecl install apcu && docker-php-ext-enable apcu

COPY zz-pool.conf /usr/local/etc/php-fpm.d/zz-pool.conf
