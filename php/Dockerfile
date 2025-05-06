#https://serversideup.net/open-source/docker-php/docs

############################################
# Base Image
############################################

#FROM serversideup/php:8.2-fpm-nginx as base
FROM serversideup/php:8.2-fpm-apache as base


############################################
# Development Image
############################################

FROM base AS development

# Switch to root so we can do root things
USER root

# Install extensions with install-php-extensions
# https://serversideup.net/open-source/docker-php/docs/customizing-the-image/installing-additional-php-extensions
# Supported PHP extensions wich you can install by install-php-extensions here - https://github.com/mlocati/docker-php-extension-installer
RUN set -ex; \
    apt update; \
    install-php-extensions intl PDO json gd exif bcmath

# Save the build arguments as a variable
ARG USER_ID
ARG GROUP_ID

# Use the build arguments to change the UID
# and GID of www-data while also changing
# the file permissions for NGINX
RUN docker-php-serversideup-set-id www-data $USER_ID:$GROUP_ID && \
    \
    # Update the file permissions for our NGINX service to match the new UID/GID
    docker-php-serversideup-set-file-permissions --owner $USER_ID:$GROUP_ID --service nginx

# Drop back to our unprivileged user
USER www-data


############################################
# Production Image
############################################

# Since we're calling "base", production isn't
# calling any of that permission stuff
FROM base AS production

# Copy our app files as www-data
COPY --chown=www-data:www-data $APP_PATH /var/www/html
