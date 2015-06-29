FROM debian:jessie
MAINTAINER - Charles Holtzkampf <charles.holtzkampf@gmail.com>

# Install Nginx - 
RUN apt-get update
RUN apt-get install -y nginx nano wget dialog net-tools mysql-server php5-fpm php5-mysql 

# Remove the default Nginx configuration file
RUN rm -v /etc/nginx/nginx.conf

# Copy configuration files from the current directory
AADD ./nginx-site.conf /etc/nginx/sites-available/default
ADD ./nginx.conf /etc/nginx/

# nginx config
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf  # To ensure the container does not stop
RUN chown -R www-data:www-data /var/lib/nginx # Nginx needs access to create temporary files


# Define mountable directories for Nginx
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/www/html"]

# Define working directory.
WORKDIR /etc/nginx

# Expose ports
EXPOSE 80

# Set the default command to execute
# when creating a new container
CMD service nginx start
