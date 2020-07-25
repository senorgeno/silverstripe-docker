#!/usr/bin/env bash

###
# A CMD or ENTRYPOINT script for a Dockerfile to use to start a Nginx/PHP-FPM
#
# For more details, see 🐳 https://shippingdocker.com
##

if [ ! "production" == "$APP_ENV" ] && [ ! "prod" == "$APP_ENV" ]; then
    rm /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    # Enable xdebug
    touch /usr/local/etc/php/conf.d/xdebug.ini
    echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" >> /usr/local/etc/php/conf.d/xdebug.ini
    echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/xdebug.ini
    echo "display_startup_errors = On" >> /usr/local/etc/php/conf.d/xdebug.ini
    echo "display_errors = On" >> /usr/local/etc/php/conf.d/xdebug.ini
    echo "xdebug.remote_host='host.docker.internal'" >> /usr/local/etc/php/conf.d/xdebug.ini
    echo "xdebug.default_enable=1" >> /usr/local/etc/php/conf.d/xdebug.ini
    echo "xdebug.remote_autostart=1" >> /usr/local/etc/php/conf.d/xdebug.ini
    echo "xdebug.remote_connect_back=off" >> /usr/local/etc/php/conf.d/xdebug.ini
    echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/xdebug.ini
    echo "xdebug.remote_handler='dbgp'" >> /usr/local/etc/php/conf.d/xdebug.ini
    echo "xdebug.remote_port=9005" >> /usr/local/etc/php/conf.d/xdebug.ini
    echo "xdebug.idekey=PHPSTORM" >> /usr/local/etc/php/conf.d/xdebug.ini
    echo "xdebug.max_nesting_level=1500" >> /usr/local/etc/php/conf.d/xdebug.ini
    # uncomment below lines for profiler
    #echo "xdebug.profiler_enable=0" >> /usr/local/etc/php/conf.d/xdebug.ini
    #echo "xdebug.profiler_enable_trigger=1" >> /usr/local/etc/php/conf.d/xdebug.ini

else
    # remove docker-php-ext-xdebug so xdebug isn't running
    rm /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
fi

# Config /etc/php/7.4/mods-available/xdebug.ini
# to correctly set the remote_host to your host computer's IP address
# sed -i "s/xdebug\.remote_host\=.*/xdebug\.remote_host\=$XDEBUG_HOST/g" /usr/local/etc/php/conf.d/xdebug.ini

exec "$@"
