FROM debian:jessie
MAINTAINER - Charles Holtzkampf <charles.holtzkampf@gmail.com>

#MODX Variables
ENV MODXuser username
ENV MODXpass password

#MYSQL Variables
ENV  ROOT_PWD ackmodx

# Install Nginx - 
RUN apt-get update
RUN apt-get install -y nginx wget mysql-server php5-fpm php5-mysql 

# Remove the default Nginx configuration file
RUN rm -v /etc/nginx/nginx.conf

# Copy configuration files from the current directory
ADD ./nginx-site.conf /etc/nginx/sites-available/default
ADD ./nginx.conf /etc/nginx/

# nginx config
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf  # To ensure the container does not stop
RUN chown -R www-data:www-data /var/lib/nginx # Nginx needs access to create temporary files

#
# mySQL Server
#
RUN  apk add --update mysql mysql-client
COPY mysql.sh /tmp/mysql.sh
RUN  sh /tmp/mysql.sh && rm /tmp/mysql.sh

#
# Container configuration
#
EXPOSE 80
VOLUME /home/modx


# Define mountable directories for Nginx
#VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/www/html"]

#
# MODX
#
COPY modx.sh /tmp/modx.sh
RUN  sh /tmp/modx.sh && rm /tmp/modx.s

# Set the default command to execute
# when creating a new container
CMD service nginx start
