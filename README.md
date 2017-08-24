![nginx 1.9.0](https://img.shields.io/badge/nginx-1.9.0-brightgreen.svg) ![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)

modx-docker sets up a container running nginx, mysql and modx. 


The container will expose port 80 and you will require a running nginx-proxy container to forward request to the MODX container.

Please see below to statr yoru nginx-proxy container.

nginx-proxy sets up a container running nginx and [docker-gen][1].  docker-gen generates reverse proxy configs for nginx and reloads nginx when containers are started and stopped.

See [Automated Nginx Reverse Proxy for Docker][2] for why you might want to use this.

### Usage

To run it:

    $ docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro etopian/nginx-proxy




[1]: https://github.com/etopian/docker-gen
[2]: http://jasonwilder.com/blog/2014/03/25/automated-nginx-reverse-proxy-for-docker/
