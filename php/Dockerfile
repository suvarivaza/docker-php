# https://github.com/serversideup/docker-php
# Choose any image
FROM serversideup/php:8.2-fpm-nginx as base

# Switch to root so we can do root things
USER root

# Install extensions with apt
#RUN set -ex; \
#    apt update; \
#    apt install -y php8.2-pgsql nano

# Install extensions with docker-php-ext-install
#RUN set -ex; \
#    apt update -q && \
#    apt install -q -y libpq-dev && \
#    docker-php-ext-install pdo_pgsql pgsql bcmath

# https://serversideup.net/open-source/docker-php/docs/customizing-the-image/installing-additional-php-extensions
# Supported PHP extensions wich you can install by install-php-extensions here - https://github.com/mlocati/docker-php-extension-installer
# Install extensions with install-php-extensions
RUN set -ex; \
    install-php-extensions intl PDO json gd exif bcmath


# Copy our Laravel app into the Docker image
FROM base as production

# Установка рабочей директории
WORKDIR /var/www/html

COPY --chown=$PUID:$PGID $APP_PATH .
# COPY --chown=www-data:www-data .. .

# Установка зависимостей
#RUN composer install --no-cache --ansi --no-interaction \
#    && composer dump-autoload -o

# Drop back to our unprivileged user
USER www-data
