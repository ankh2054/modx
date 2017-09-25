#!/bin/sh


# 1.MYSQL SETUP 
#
# ###########

MYSQL_CHARSET=${MYSQL_CHARSET:-"utf8"}
MYSQL_COLLATION=${MYSQL_COLLATION:-"utf8_unicode_ci"}

create_data_dir() {
  echo "Creating /var/lib/mysql"
  mkdir -p /var/lib/mysql
  chmod -R 0700 /var/lib/mysql
  chown -R mysql:mysql /var/lib/mysql
}

create_run_dir() {
  echo "Creating /run/mysqld"
  mkdir -p /run/mysqld
  chmod -R 0755 /run/mysqld
  chown -R mysql:root /run/mysqld
}

create_log_dir() {
  echo "Creating /var/log/mysql"
  mkdir -p /var/log/mysql
  chmod -R 0755 /var/log/mysql
  chown -R mysql:mysql /var/log/mysql
}

mysql_default_install() {
  if [ ! -d "/var/lib/mysql/mysql" ]; then
      echo "Creating the default database"
 	/usr/bin/mysql_install_db --datadir=/var/lib/mysql
  else
      echo "MySQL database already initialiazed"
  fi
}

create_modx_database() {

  if [ ! -d "/var/lib/mysql/${DB_NAME}" ]; then

     # start mysql server.
      echo "Starting Mysql server"
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

      else
        echo "How have not provided all the required ENV variabvles to configure the database"

      fi
  else 
      echo "Database \"${DB_NAME}\" already exists"

  fi
  
}

set_mysql_root_pw() {
    # Check if root password has already been set.
    r=`/usr/bin/mysqladmin -uroot  status`
    if [ ! $? -ne 0 ] ; then
      echo "Setting Mysql root password"
      /usr/bin/mysqladmin -u root password "${ROOT_PWD}"
      
      else 
       echo "Mysql root password already set"
    fi
    
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
  chown -R nginx:nginx /DATA/www /DATA/logs

}

# 3.MODX INSTALL  
#
# ################


# copy MODX config files & install if file do not already exist
modx_install(){
  echo "Installing MODX if not already istalled"
  if [ ! -e /DATA/www/core/config/config.inc.php ] ; then

  # get latest MODX cms and extract to /DATA/www
  echo "Downloading and extractig the latest MODX"
  current="$(curl -sSL 'https://api.github.com/repos/modxcms/revolution/tags' | sed -n 's/^.*"name": "v\([^"]*\)-pl".*$/\1/p' | head -n1)"
  curl -o /tmp/modx.zip -sSL https://modx.com/download/direct/modx-$current-pl.zip 
  unzip /tmp/modx.zip -x "*/./" -d /DATA/www > /dev/null 2>&1
  mv /DATA/www/modx-$current-pl/* /DATA/www
  rm -R /DATA/www/modx-$current-pl/

  cat > /DATA/www/setup/config.xml <<EOF
<modx>
  <database_type>mysql</database_type>
  <database_server>localhost</database_server>
  <database>$DB_NAME</database>
  <database_user>$DB_USER</database_user>
  <database_password>$DB_PASS</database_password>
  <database_connection_charset>utf8</database_connection_charset>
  <database_charset>utf8</database_charset>
  <database_collation>utf8_general_ci</database_collation>
  <table_prefix>modx_</table_prefix>
  <https_port>443</https_port>
  <http_host>localhost</http_host>
  <cache_disabled>0</cache_disabled>
  <inplace>1</inplace>
  <unpacked>0</unpacked>
  <language>en</language>
  <cmsadmin>$MODX_ADMIN_USER</cmsadmin>
  <cmspassword>$MODX_ADMIN_PASSWORD</cmspassword>
  <cmsadminemail>$MODX_ADMIN_EMAIL</cmsadminemail>
  <core_path>/DATA/www/core/</core_path>
  <context_mgr_path>/DATA/www/manager/</context_mgr_path>
  <context_mgr_url>/manager/</context_mgr_url>
  <context_connectors_path>/DATA/www/connectors/</context_connectors_path>
  <context_connectors_url>/connectors/</context_connectors_url>
  <context_web_path>/DATA/www/</context_web_path>
  <context_web_url>/</context_web_url>
  <remove_setup_directory>1</remove_setup_directory>
</modx>
EOF
  echo "Installing MODX"
  chown nginx:nginx /DATA/www/setup/config.xml

    if [ -n "${DB_USER}" -a -n "${DB_NAME}" -a -n "${DB_PASS}" -a -n "${MODX_ADMIN_USER}" -a -n "${MODX_ADMIN_PASSWORD}" -a -n "${MODX_ADMIN_EMAIL}" ] ; then
      php /DATA/www/setup/index.php --installmode=new

    else
      echo "You have not provided all the variables to install MODX"

    fi


  # shutdown mysql reeady for supervisor to start mysql.
  timeout=10
  echo "Shutting down Mysql ready for supervisor"
  /usr/bin/mysqladmin -u root --password=${ROOT_PWD} shutdown

  else
    echo "MODX already installed"

  fi

}



# Running all script functions
create_data_dir
create_run_dir
create_log_dir
mysql_default_install
create_modx_database
set_mysql_root_pw
create_www_dir
modx_install
apply_www_permissions


# Start Supervisor 
echo "Starting Supervisor"
/usr/bin/supervisord -n -c /etc/supervisord.con
