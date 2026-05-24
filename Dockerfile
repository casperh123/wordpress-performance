FROM wordpress:php8.3-fpm

RUN apt-get update && apt-get install -y \
    libmemcached-dev \
    zlib1g-dev \
    libssl-dev \
    pkg-config \
    && pecl install igbinary apcu redis memcached \
    && docker-php-ext-enable igbinary apcu redis memcached \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN echo "redis.serializer = 3" > /usr/local/etc/php/conf.d/redis-igbinary.ini
