FROM alpine:3.6

#FROM php:7.1-fpm-alpine
ENV ALPINE_VERSION=3.6

# Install needed packages. Notes:
#   * dumb-init: a proper init system for containers, to reap zombie children
#   * musl: standard C library
#   * linux-headers: commonly needed, and an unusual package name from Alpine.
#   * build-base: used so we include the basic development packages (gcc)
#   * bash: so we can access /bin/bash - REMOVED to use build in busybox instead
#   * ca-certificates: for SSL verification during Pip and easy_install
#   * python: the binaries themselves
#   * python-dev: are used for gevent e.g.
#   * py-setuptools: required only in major version 2, installs easy_install so we can install Pip.
#   * mysql: Mysql server.
#   * mysql-client: Required for django to use mysql as database.
#   * supervisor: To autostart and ensure services stay running.
#   * mariadb-dev: Required by - pip install mysqlclient.
#   * nginx: To serve Django static content and proxy connections back to Django.
#   * php7-*: Modules requied by MODX

ENV PACKAGES="\
  dumb-init \
  musl \
  linux-headers \
  build-base \
  ca-certificates \
  python2 \
  python2-dev \
  py-setuptools \
  mysql \ 
  mysql-client\
  supervisor \
  mariadb-dev \
  nginx \
  curl \
  unzip \
  php7 \
  php7-session \
  php7-simplexml \
  php7-zlib \
  php7-fpm \
  php7-cli \
  php7-gd  \
  php7-mcrypt \
  php7-pdo_mysql \
  php7-mysqli \
  php7-curl \
  php7-xml \
  php7-json \
"

RUN echo \
  # replacing default repositories with edge ones
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" > /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \

  # Add the packages, with a CDN-breakage fallback if needed
  && apk update \
  && apk add --no-cache $PACKAGES \

  # make some useful symlinks that are expected to exist
  && if [[ ! -e /usr/bin/python ]];        then ln -sf /usr/bin/python2.7 /usr/bin/python; fi \
  && if [[ ! -e /usr/bin/python-config ]]; then ln -sf /usr/bin/python2.7-config /usr/bin/python-config; fi \
  && if [[ ! -e /usr/bin/easy_install ]];  then ln -sf /usr/bin/easy_install-2.7 /usr/bin/easy_install; fi \
  && echo 


### MYSQL ###
############
ENV ROOT_PWD gert

# Add files
ADD files/nginx.conf /etc/nginx/nginx.conf
ADD files/php-fpm.conf /etc/php/7.0/fpm/
ADD files/supervisord.conf /etc/supervisord.conf
ADD files/my.cnf /etc/mysql/my.cnf

# Entrypoint
ADD start.sh /
RUN chmod u+x /start.sh
CMD /start.s
