#!/bin/sh
#
# Get latest MODX Revolution
#
wget -q http://modx.com/download/latest -O /tmp/latest.zip
unzip /tmp/latest.zip -x "*/./" -d /tmp > /dev/null 2>&1
rm /home/latest.zip
MODX=`ls /tmp | grep -v latest.zip`
mv /home/$MODX /var/www/modx
chown -R www-data:www-data /var/www/modx
