#!/bin/sh

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


#Start Supervisor 
/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
