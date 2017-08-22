#!/bin/sh
#
# Get latest MODX Revolution
#
wget -q http://modx.com/download/latest -O /tmp/latest.zip
unzip /tmp/latest.zip -x "*/./" -d /tmp > /dev/null 2>&1

MODX=`ls /tmp | grep -v latest.zip`
cd /tmp/$MODX
mv *  /DATA/www
chown -R www-data:www-data /DATA/www
