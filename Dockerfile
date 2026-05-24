FROM wordpress:php8.5-fpm

RUN apt-get update && apt-get install -y \
    libmemcached-dev \
    zlib1g-dev \
    libssl-dev \
    pkg-config \
    redis-server \
    memcached \
    supervisor \
    && pecl install igbinary apcu redis memcached \
    && docker-php-ext-enable igbinary apcu redis memcached \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable igbinary serializer for Redis
RUN echo "redis.serializer = igbinary" > /usr/local/etc/php/conf.d/redis-igbinary.ini

# Create runtime directories
RUN mkdir -p /var/run/redis \
    && mkdir -p /var/run/memcached

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
