FROM debian:jessie
MAINTAINER - test  Charles Holtzkampf <charles.holtzkampf@gmail.com>

# Install Nginx - 
RUN \
apt-get update && apt-get install -y nginx && \

# nginx config
echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \ # To ensure the container does not stop
chown -R www-data:www-data /var/lib/nginx # Nginx needs access to create temporary files


# Define mountable directories for Nginx
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/www/html"]

# Define working directory.
WORKDIR /etc/nginx

# Expose ports
EXPOSE 80

# Define default command.
CMD ["nginx"]
