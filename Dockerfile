FROM ubuntu:16.04
MAINTAINER - Charles Holtzkampf <charles.holtzkampf@gmail.com>
RUN export DEBIAN_FRONTEND="noninteractive"




## Install php nginx mysql supervisor ###
########################################
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    php-fpm \
    php-cli \
    php-gd  \
    php-mcrypt \
    php-mysql \
    php-curl \
    nginx \
    wget \
    unzip \
    mysql-server \
    supervisor
   


### Nginx  & PHP-FPM ###
########################


# Remove the default Nginx configuration file
RUN rm -v /etc/nginx/nginx.conf

# Copy configuration files from the current directory
ADD files/nginx.conf /etc/nginx/nginx.conf
ADD files/php-fpm.conf /etc/php/7.0/fpm/


### MODX ###
############

ADD files/modx-config.xml /tmp/
# You can now use SED and docker ENV variables to update the XML file
RUN cd /tmp/; wget -q https://raw.github.com/craftsmancoding/modx_utils/master/installmodx.php 

### MYSQL ###
############
ENV ROOT_PWD gert
#ADD mysql.sh /tmp/mysql.sh
#RUN sh /tmp/mysql.sh && rm /tmp/mysql.sh

# Volumes explained
# At some point move to using flocker for volumes - http://clusterhq.com/2015/12/09/difference-docker-volumes-flocker-volumes/
# This way yuo can store your data outside of your docker host and onto a Amazon EBS host OR Google Persistent Disk, so your data stays intact even if docker host dies.
# https://www.nschoe.com/articles/2017-01-28-Docker-Taming-the-Beast-Part-4.html
# Step1 - Add persistent disk to your ubuntu host - host docker persistent files on there. 

### Supervisor.conf ###
######################
ADD files/supervisord.conf /etc/supervisor/supervisord.conf


### Container configuration ###
###############################

EXPOSE 80
VOLUME /DATA

# Set the default command to execute
# when creating a new container
ADD start.sh /
RUN chmod u+x /start.sh
CMD /start.sh
