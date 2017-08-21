#!/bin/bash

set -e

chown -R www-data:www-data /DATA

# init mysql db if necessary
#if [ ! -d /var/lib/mysql/mysql ];then
#    mysqld --initialize-insecure --user=root --datadir=/var/lib/mysql
#fi
#
#chown -R mysql:mysql /var/lib/mysql

# start php-fpm
mkdir -p /DATA/logs/php-fpm
# start nginx
mkdir -p /DATA/logs/nginx
mkdir -p /tmp/nginx
chown www-data:www-data /tmp/www-data
chown -R www-data:www-data /DATA

php-fpm7
nginx
