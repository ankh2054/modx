#!/bin/sh
#
# Install mySQL
# https://github.com/sameersbn/docker-mysql/blob/master/entrypoint.sh


MYSQL_CHARSET=${MYSQL_CHARSET:-"utf8"}
MYSQL_COLLATION=${MYSQL_COLLATION:-"utf8_unicode_ci"}

create_data_dir() {
  mkdir -p /var/lib/mysql
  chmod -R 0700 /var/lib/mysql
  chown -R mysql:mysql /var/lib/mysql
}

create_run_dir() {
  mkdir -p /run/mysqld
  chmod -R 0755 /run/mysqld
  chown -R mysql:root /run/mysqld
}

create_log_dir() {
  mkdir -p /var/log/mysql
  chmod -R 0755 /var/log/mysql
  chown -R mysql:mysql /var/log/mysql
}

mysql_default_install() {
    /usr/bin/mysql_install_db --datadir=/var/lib/mysql
}

set_mysql_root_pw() {
    /usr/bin/mysqld_safe &
    sleep 5
    ps axl
    ls -l /var/lib
    ps axl
    /usr/bin/mysqladmin -u root password "${ROOT_PWD}"
}

create_modx_database() {
    if [ -n "${DB_NAME}" ]; then
        mysql -uroot --password=${ROOT_PWD} -e "CREATE DATABASE ${DB_NAME};"

    fi 

}

create_data_dir
create_run_dir
create_log_dir
mysql_default_install
set_mysql_root_pw
create_modx_database




# Create LOG directoties for NGINX & PHP-FPM
mkdir -p /DATA/logs/php-fpm
mkdir -p /DATA/logs/nginx
mkdir -p /DATA/www

#Copy MODX config files & install if file do not already exist
if [ ! -e /DATA/www/core/config/config.inc.php ] ; then
  cp /tmp/* /DATA/www
fi

#Apply correct permissions
chown -R www-data:www-data /DATA

#Test to see if DB_NAME ENV is available
echo ${DB_NAME} > /tmp/test.txt

#Start Supervisor 
/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
