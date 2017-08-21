FROM ubuntu:16.04
MAINTAINER - Charles Holtzkampf <charles.holtzkampf@gmail.com>
RUN export DEBIAN_FRONTEND="noninteractive"




## Install php nginx mysql supervisor ###
########################################
RUN apt-get update && \
    apt-get install -y php-fpm php-cli php-gd php-mcrypt php-mysql php-curl \
                       nginx \
                       curl \
		       supervisor && \
    echo "mysql-server mysql-server/root_password password" | debconf-set-selections && \
    echo "mysql-server mysql-server/root_password_again password" | debconf-set-selections && \
    apt-get install -y mysql-server && \


### Nginx  & PHP-FPM ###
########################


# Remove the default Nginx configuration file
RUN rm -v /etc/nginx/nginx.conf

# Copy configuration files from the current directory
ADD files/nginx.conf /etc/nginx/nginx.conf
ADD files/php-fpm.conf /etc/php7/fpm/

# nginx config
RUN chown -R www-data:www-data /var/lib/nginx # Nginx needs access to create temporary files

# PHP FPM config changes
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini # Prevents PHP from executing losest file

# Create LOG directoties for NGINX & PHP-FPM
RUN mkdir -p /DATA/logs/php-fpm
RUN mkdir -p /DATA/logs/nginx
RUN chown -R www-data:www-data /DATA



### MODX ###
############

COPY modx.sh /tmp/modx.sh
RUN  sh /tmp/modx.sh && rm /tmp/modx.s

### Supervisor ###
##################

ADD mysql.conf  /etc/supervisor/conf.d
ADD nginx.conf  /etc/supervisor/conf.d
ADD php-fpm.conf /etc/supervisor/conf.d



### Container configuration ###
###############################

EXPOSE 80
VOLUME ["/DATA"]


# Volumes explained
# At some point move to using flocker for volumes - http://clusterhq.com/2015/12/09/difference-docker-volumes-flocker-volumes/
# This way yuo can store your data outside of your docker host and onto a Amazon EBS host OR Google Persistent Disk, so your data stays intact even if docker host dies.
# https://www.nschoe.com/articles/2017-01-28-Docker-Taming-the-Beast-Part-4.html
# Step1 - Add persistent disk to your ubuntu host - host docker persistent files on there. 


# Set the default command to execute
# when creating a new container

CMD start.sh
