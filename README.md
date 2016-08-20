# alpine-apache2-php56

A Docker image for running [Apache][apache] with PHP v.5.6.x, based on Alpine Linux. Also added is bash and openrc support. For PHP, it both MySql and Mongo connectivity.

## Features

This image features:

- [Alpine Linux][alpinelinux]
- [Apache][apache]
- [PHP5][php5]

## Versions

- `1.0.0`, `latest` [(Dockerfile)](https://github.com/edaspra/alpine-apache2-php56/tree/alpine-apache2-php56-v1.0.0/alpine-apache)


## Usage

To use this image include `FROM edaspra/alpine-apache2-php56` at the top of your `Dockerfile`, or simply `docker run -p 80:80 -p 443:443 --name apache edaspra/alpine-apache2-php56`.

You have the options to mount your volumes to /etc/apache2/conf.d/vhosts for additional vhost entry if you require one, and /web/www/html for your application folder.

Apache logs (access and error logs) aren't automatically streamed to `stdout` and `stderr`. To review the logs, you can do one of two things:

Run the following in another terminal window:

```
docker exec -i apache tail -f /var/log/apache2/access.log -f /var/log/apache2/error.log
```

or, in your `Dockerfile` symlink the Apache logs to `stdout` and `stderr`:

```
RUN ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log
```

## Customisation

This container comes setup as follows:

- Apache will be automatically started for you.
- If Apache dies, so will the container.

### PHP Info

To check on the PHP configuration, you can access it thru: <container IP/hostname>/info.php. To remove this, comment the following line in `run.sh`.

```
echo "<?php echo phpinfo(); ?>" > /var/www/localhost/htdocs/info.php
```

### Apache configuration

A basic Apache configuration is supplied with this image. However, it's easy to overwrite:

- Create your own `httpd.conf`.
- In your `Dockerfile`, make sure your `httpd.conf` file is copied to `/etc/apache2/httpd.conf`.
- Also, you can create multiple vhosts. `/etc/apache2/conf.d/vhosts` is the exposed volume to contain the vhosts, while `/web/www/html` shall hold the application files. 

### Apache crash

By default, if Apache crashes, the container will stop. 


# start apache
exec /usr/sbin/apachectl -DFOREGROUND;
```

