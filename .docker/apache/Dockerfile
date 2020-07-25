FROM httpd:2.4.33-alpine
RUN apk update; \
    apk upgrade;
# Copy apache vhost file to proxy php requests to php-fpm container
COPY httpd.conf /usr/local/apache2/conf/myconf.conf
COPY httpd-ssl.conf /usr/local/apache2/conf/extra/httpd-ssl.conf
COPY external/* /usr/local/apache2/conf/

RUN echo "Include /usr/local/apache2/conf/myconf.conf" \
    >> /usr/local/apache2/conf/httpd.conf

RUN sed -i \
        -e 's/^#\(Include .*httpd-ssl.conf\)/\1/' \
        -e 's/^#\(LoadModule .*mod_ssl.so\)/\1/' \
        -e 's/^#\(LoadModule .*mod_socache_shmcb.so\)/\1/' \
        conf/httpd.conf
