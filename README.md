# LAMP Stack for Development of First Table

# PHP
## TODO 
- configurable php version
- configurable production and development ini settings 
- override php settings e.g. memory
- configure fpm settings

## Apache
This comes with server cert and key for my.local and *.my.local domains.

To generate new ones, run this command below in the root of the project. It should generate a key and crt file.

```bash
openssl req \
    -newkey rsa:2048 \
    -x509 \
    -nodes \
    -keyout ./apache/external/server.key \
    -new \
    -out ./apache/external/server.crt \
    -reqexts SAN \
    -extensions SAN \
    -config <(cat /System/Library/OpenSSL/openssl.cnf \
        <(printf '
[req]
default_bits = 2048
prompt = no
default_md = sha256
x509_extensions = v3_req
distinguished_name = dn

[dn]
C = NZ
ST = Queenstown
L = Queenstown
O = MyDomain Inc.
OU = Technology Group
emailAddress = me@mycom
CN = my.local

[v3_req]
subjectAltName = @alt_names

[SAN]
subjectAltName = @alt_names

[alt_names]
DNS.1 = *.my.local
DNS.2 = my.local
')) \
    -sha256 \
    -days 3650
```

## Backup & Restore Database
Check out this [gist](https://gist.github.com/spalladino/6d981f7b33f6e0afe6bb)

## XDebug
By setting the `APP_ENV=dev` and run build will run the docker environment in a development capacity.
Xdebug is setup to take a IDE key of `PHPSTORM` which can be configured in your IDE (hopefully PHPStorm :)).

To trigger debugging, it’s necessary to send a special cookie along with each page request
you wish to debug: `XDEBUG_SESSION=PHPSTORM`

Here is more information: https://ericdraken.com/php-debugging-with-phpstorm-and-xdebug/

## webgrind

Handy for profiling. Uncomment the following in the `docker-compose` file.

```
#  webgrind:
#    image: wodby/webgrind:latest
#    ports:
#      - "8888:8080"
#    volumes:
#      - tmp-volume:/tmp
#    networks:
#      - ftlocal
```


# Composer and installing packages

`docker-compose exec -T --user www-data php composer create-project silverstripe/installer /var/www/current`
