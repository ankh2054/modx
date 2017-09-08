![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)

# MODX-DOCKER

modx-docker sets up a container running nginx, mysql and modx. The container will expose port 80 and you will require a running nginx-proxy container to forward request to the MODX container.
Please see NGINX-PROXY section to start your nginx-proxy container.


### MODX-DOCKER Usage


Firstly you need to create the necessary folders on your docker host. The container will expose directories created below directly into the container to ensure our WWW, MYSQL and LOG folders are persistent.
This ensures that even if your container is lost or deleted, you won't loose your MODX database or website files.

	$ mkdir -p /data/sites/www.test.co.uk/www
	$ mkdir -p /data/sites/www.test.co.uk/logs
	$ mkdir -p /data/sites/www.test.co.uk/mysql


To buld the docker modx image:
    $ docker build -t modx. 

To run it:

    $ docker run  --name docker.modx --expose 80 \
	 -d -e 'VIRTUAL_HOST=www.test.co.uk' \
	 -e 'MODX_DB_HOST=localhost' \
	 -e 'MODX_DB_NAME=docker' \
	 -e 'MODX_DB_USER=modx' \
	 -e 'MODX_DB_PASSWORD=password' \
	 -e 'MODX_ADMIN_USER=admin' \
	 -e 'MODX_ADMIN_PASSWORD=password' \
	 -e 'MODX_ADMIN_EMAIL=test@test.com' \
	 -e 'DB_NAME=docker' \
	 -e 'DB_USER=modx' \
	 -e 'DB_PASS=nightshade900' \
	 -v /data/sites/www.test.co.uk/mysql:/var/lib/mysql \
	 -v /data/sites/www.test.co.uk:/DATA modx


This will create a new MODX instance with the following values:

	$ Virtual Host: - www.test.co.uk
	$ MODX database: modx
	$ MODX database user: modx
	$ MODX database password: password
	$ MODX admin username: admin
	$ MODX admin password: password
	


# NGINX-PROXY




nginx-proxy sets up a container running nginx and [docker-gen][1].  docker-gen generates reverse proxy configs for nginx and reloads nginx when containers are started and stopped.

See [Automated Nginx Reverse Proxy for Docker][2] for why you might want to use this.

### Nginx-proxy Usage

To run it:

    $ docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro etopian/nginx-proxy




[1]: https://github.com/etopian/docker-gen
[2]: http://jasonwilder.com/blog/2014/03/25/automated-nginx-reverse-proxy-for-docker/
