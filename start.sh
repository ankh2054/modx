#!/bin/sh


# 1.MYSQL SETUP 
#
# ###########

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

create_modx_database() {
   # start mysql server.
    /usr/bin/mysqld_safe >/dev/null 2>&1 &

   # wait for mysql server to start (max 30 seconds).
    timeout=30
    echo -n "Waiting for database server to accept connections"
    while ! /usr/bin/mysqladmin -u root status >/dev/null 2>&1
    do
      timeout=$(($timeout - 1))
      if [ $timeout -eq 0 ]; then
        echo -e "\nCould not connect to database server. Aborting..."
        exit 1
      fi
      echo -n "."
      sleep 1
    done
    echo
    
    # create database and assign user permissions.
    if [ -n "${DB_NAME}" -a -n "${DB_USER}" -a -n "${DB_PASS}" ]; then
       echo "Creating database \"${DB_NAME}\" and granting access to \"${DB_USER}\" database."
        mysql -uroot  -e  "CREATE DATABASE ${DB_NAME};"
        mysql -uroot  -e  "GRANT USAGE ON *.* TO ${DB_USER}@localhost IDENTIFIED BY '${DB_PASS}';"
        mysql -uroot  -e  "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO ${DB_USER}@localhost;"

    fi 
  
}

set_mysql_root_pw() {
    # set root password for mysql.
    echo "Setting root password"
    /usr/bin/mysqladmin -u root password "${ROOT_PWD}"

    # shutdown mysql reeady for supervisor to start mysql.
    /usr/bin/mysqladmin -u root --password=${ROOT_PWD} shutdown
}


# 2.NGINX & PHP-FPM 
#
# ################

create_www_dir() {
  # Create LOG directoties for NGINX & PHP-FPM
  echo "Creating www directories"
  mkdir -p /DATA/logs/php-fpm
  mkdir -p /DATA/logs/nginx
  mkdir -p /DATA/www

}

apply_www_permissions(){
  echo "Applying www permissions"
  chown -R www-data:www-data /DATA

}

# 3.MODX INSTALL  
#
# ################


# copy MODX config files & install if file do not already exist
if [ ! -e /DATA/www/core/config/config.inc.php ] ; then
  cp /tmp/* /DATA/www
fi


# Running all script functions
create_data_dir
create_run_dir
create_log_dir
mysql_default_install
create_modx_database
set_mysql_root_pw
create_www_dir
apply_www_permissions

# Start Supervisor 
echo "Starting Supervisor"
/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
