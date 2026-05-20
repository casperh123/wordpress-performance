FROM wordpress:php8.3-fpm

RUN apt-get update && apt-get install -y \
    nginx \
    libmemcached-dev \
    zlib1g-dev \
    libssl-dev \
    && pecl install redis apcu memcached \
    && docker-php-ext-enable redis apcu memcached \
    && apt-get purge -y --auto-remove libmemcached-dev \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /etc/nginx/sites-enabled/default

RUN cat > /etc/nginx/nginx.conf << 'EOF'
user www-data;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log;

events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile      on;
    access_log    off;

    server {
        listen 80;
        root /var/www/html;
        index index.php;

        location / {
            try_files $uri $uri/ /index.php?$args;
        }

        location ~ \.php$ {
            fastcgi_pass  127.0.0.1:9000;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include       fastcgi_params;
        }

        location ~ /\.ht {
            deny all;
        }
    }
}
EOF

RUN cat > /usr/local/etc/php-fpm.d/zz-workers.conf << 'EOF'
[www]
pm = static
pm.max_children = 4
EOF

RUN cat > /entrypoint.sh << 'EOF'
#!/bin/bash
set -e

if [ ! -f /var/www/html/wp-login.php ]; then
    cp -r /usr/src/wordpress/. /var/www/html/
    chown -R www-data:www-data /var/www/html
fi

php-fpm -D
exec nginx -g "daemon off;"
EOF

RUN chmod +x /entrypoint.sh

EXPOSE 80

CMD ["/entrypoint.sh"]
