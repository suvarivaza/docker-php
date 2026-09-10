#https://serversideup.net/open-source/docker-php/docs

#base — image serversideup/php + PHP extensions
#├── development — setup UID/GID for local development
#└── production — implements base

# docker-compose.dev.yml
#build:
#  target: development

# docker-compose.prod.yml
#build:
#  target: production


############################################
# Base Image
############################################
ARG PHP_WEBSERVER=nginx
ARG PHP_VERSION=8.2

#https://serversideup.net/open-source/docker-php/docs/getting-started/installation
#FROM serversideup/php:8.2-fpm-apache as base
FROM serversideup/php:${PHP_VERSION}-fpm-${PHP_WEBSERVER} as base

# Switch to root so we can do root things
USER root

# Install extensions with install-php-extensions
# https://serversideup.net/open-source/docker-php/docs/customizing-the-image/installing-additional-php-extensions
# Supported PHP extensions for install-php-extensions - https://github.com/mlocati/docker-php-extension-installer
RUN set -ex; \
    apt update; \
    install-php-extensions intl PDO json gd exif bcmath imap mysqli xmlrpc

# Drop back to our unprivileged user
USER www-data

############################################
# Development Image
############################################
FROM base AS development

# Switch to root so we can do root things
USER root

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG PHP_WEBSERVER=nginx

# Use the build arguments to change the UID
# and GID of www-data while also changing
# the file permissions for nginx/apache
# Update the file permissions for our NGINX service to match the new UID/GID
RUN docker-php-serversideup-set-id www-data $USER_ID:$GROUP_ID && \
    docker-php-serversideup-set-file-permissions \
      --owner $USER_ID:$GROUP_ID \
      --service $PHP_WEBSERVER

# Drop back to our unprivileged user
USER www-data

############################################
# Production Image
############################################
# Since we're calling "base", production isn't
# calling any of that permission stuff
FROM base AS production
