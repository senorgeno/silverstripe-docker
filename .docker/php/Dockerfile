ARG TARGET_PHP_VERSION
FROM php:${TARGET_PHP_VERSION}-fpm

ENV DEBIAN_FRONTEND=noninteractive
# is for production or development
ARG APP_ENV
ENV APP_ENV $APP_ENV

COPY ./.shared/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x -R /usr/local/bin/docker-entrypoint.sh

ARG SERVICE_DIR="./php"
COPY ./.shared/scripts/ /tmp/scripts/
RUN chmod +x -R /tmp/scripts/

# set timezone
ARG TZ=UTC
RUN /tmp/scripts/set_timezone.sh ${TZ}

# add users
ARG APP_USER=www-data
ARG APP_GROUP=www-data
ARG APP_USER_ID=1000
ARG APP_GROUP_ID=1000

RUN /tmp/scripts/create_user.sh ${APP_USER} ${APP_GROUP} ${APP_USER_ID} ${APP_GROUP_ID}

RUN /tmp/scripts/install_php_extensions.sh

RUN /tmp/scripts/install_software.sh

# php config
COPY ./.shared/config/php/conf.d/*  /usr/local/etc/php/conf.d/

# php-fpm pool config
COPY ${SERVICE_DIR}/php-fpm.d/* /usr/local/etc/php-fpm.d
RUN /tmp/scripts/modify_config.sh /usr/local/etc/php-fpm.d/zz-app.conf \
    "__APP_USER" \
    "${APP_USER}" \
 && /tmp/scripts/modify_config.sh /usr/local/etc/php-fpm.d/zz-app.conf \
    "__APP_GROUP" \
    "${APP_GROUP}" \
;

# install composer
COPY --from=composer /usr/bin/composer /usr/bin/composer
USER ${APP_USER}
RUN composer global require hirak/prestissimo
USER root

# install all scripts
RUN /tmp/scripts/install_php_extensions.sh

# workdir
ARG APP_CODE_PATH="/var/www/current"
WORKDIR "$APP_CODE_PATH"
VOLUME "$APP_CODE_PATH"

RUN /tmp/scripts/cleanup.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh","php-fpm"]
EXPOSE 9000
