FROM ubuntu:16.04
MAINTAINER - Charles Holtzkampf <charles.holtzkampf@gmail.com>
RUN export DEBIAN_FRONTEND="noninteractive"




## Install php nginx mysql supervisor ###
########################################
RUN apt-get update && apt-get install -y \
    php-fpm \
    php-cli \
    php-gd  \
    php-mcrypt \
    php-mysql \
    php-curl \
    nginx \
    wget \
    unzip \
    supervisor
   


### Nginx  & PHP-FPM ###
########################


# Remove the default Nginx configuration file
RUN rm -v /etc/nginx/nginx.conf

# Copy configuration files from the current directory
ADD files/nginx.conf /etc/nginx/nginx.conf
ADD files/php-fpm.conf /etc/php7/fpm/


# PHP FPM config changes

# Create LOG directoties for NGINX & PHP-FPM
RUN mkdir -p /DATA/logs/php-fpm
RUN mkdir -p /DATA/logs/nginx
RUN mkdir -p /DATA/www
RUN chown -R www-data:www-data /DATA



### MODX ###
############

ADD  ./modx.sh /tmp/modx.sh
RUN  sh /tmp/modx.sh && rm /tmp/modx.sh


### Container configuration ###
###############################

EXPOSE 80
VOLUME ["/DATA"]


# Volumes explained
# At some point move to using flocker for volumes - http://clusterhq.com/2015/12/09/difference-docker-volumes-flocker-volumes/
# This way yuo can store your data outside of your docker host and onto a Amazon EBS host OR Google Persistent Disk, so your data stays intact even if docker host dies.
# https://www.nschoe.com/articles/2017-01-28-Docker-Taming-the-Beast-Part-4.html
# Step1 - Add persistent disk to your ubuntu host - host docker persistent files on there. 

### Supervisor.conf ###
######################
ADD files/supervisor.conf /etc/supervisor/conf.d/supervisord.conf


# Set the default command to execute
# when creating a new container
CMD /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf 
