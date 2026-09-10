#https://serversideup.net/open-source/docker-php/docs

############################################
# Base Image
############################################

# Объявляем аргумент ДО первого FROM
ARG PHP_WEBSERVER
ARG PHP_VERSION

FROM serversideup/php:${PHP_VERSION}-fpm-${PHP_WEBSERVER} as base

#https://serversideup.net/open-source/docker-php/docs/getting-started/installation
#FROM serversideup/php:8.2-fpm-apache as base
#FROM serversideup/php:7.4-fpm-apache as base


############################################
# Development Image
############################################

FROM base AS development

# Switch to root so we can do root things
USER root

# Install extensions with install-php-extensions
# https://serversideup.net/open-source/docker-php/docs/customizing-the-image/installing-additional-php-extensions
# Supported PHP extensions for install-php-extensions - https://github.com/mlocati/docker-php-extension-installer
RUN set -ex; \
    apt update; \
    install-php-extensions intl PDO json gd exif bcmath imap mysqli xmlrpc

# Save the build arguments as a variable
ARG USER_ID=1000
ARG GROUP_ID=1000
ARG PHP_WEBSERVER=nginx

# Use the build arguments to change the UID
# and GID of www-data while also changing
# the file permissions for nginx/apache
RUN docker-php-serversideup-set-id www-data $USER_ID:$GROUP_ID && \
    \
    # Update the file permissions for our NGINX service to match the new UID/GID
    docker-php-serversideup-set-file-permissions --owner $USER_ID:$GROUP_ID --service $PHP_WEBSERVER

# Drop back to our unprivileged user
USER www-data


############################################
# Production Image
############################################

# Since we're calling "base", production isn't
# calling any of that permission stuff
FROM base AS production
