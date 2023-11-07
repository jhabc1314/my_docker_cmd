FROM php:8.1-cli

WORKDIR /app

RUN pecl install redis \
    && docker-php-ext-enable redis \
    && docker-php-ext-install mysqli pdo_mysql


# docker run --rm -v ./:/app php8.1 php -m
