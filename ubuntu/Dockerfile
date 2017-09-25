FROM ubuntu:16.04
MAINTAINER - Charles Holtzkampf <charles.holtzkampf@gmail.com>

## Install php nginx mysql supervisor ###
########################################
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    php-fpm \
    php-cli \
    php-gd  \
    php-mcrypt \
    php-mysql \
    php-curl \
    php-xml \
    php-json \
    nginx \
    curl \
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


### MYSQL ###
############
ENV ROOT_PWD gert

### Supervisor.conf ###
######################
ADD files/supervisord.conf /etc/supervisor/supervisord.conf


### Container configuration ###
###############################

EXPOSE 80
VOLUME /DATA
VOLUME /var/lib/mysql

# Set the default command to execute
# when creating a new container
ADD start.sh /
RUN chmod u+x /start.sh
CMD /start.sh
