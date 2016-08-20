FROM alpine:latest

MAINTAINER Ed Aspra <edaspra@gmail.com>

RUN mkdir -p /etc/apk && echo "http://alpine.gliderlabs.com/alpine/edge/main" > /etc/apk/repositories &&\
# Install openrc
    apk update && apk add openrc &&\
# Tell openrc its running inside a container, till now that has meant LXC
    sed -i 's/#rc_sys=""/rc_sys="lxc"/g' /etc/rc.conf &&\
# Tell openrc loopback and net are already there, since docker handles the networking
    echo 'rc_provide="loopback net"' >> /etc/rc.conf &&\
# no need for loggers
    sed -i 's/^#\(rc_logger="YES"\)$/\1/' /etc/rc.conf &&\
# can't get ttys unless you run the container in privileged mode
    sed -i '/tty/d' /etc/inittab &&\
# can't set hostname since docker sets it
    sed -i 's/hostname $opts/# hostname $opts/g' /etc/init.d/hostname &&\
# can't mount tmpfs since not privileged
    sed -i 's/mount -t tmpfs/# mount -t tmpfs/g' /lib/rc/sh/init.sh &&\
# can't do cgroups
    sed -i 's/cgroup_add_service /# cgroup_add_service /g' /lib/rc/sh/openrc-run.sh && \
# ensure openssl install to allow wget for SSL
    apk add --update bash && \
    apk add openssl

# Environments
#ENV TIMEZONE            Asia/Jakarta
ENV TIMEZONE            US/Eastern
ENV PHP_MEMORY_LIMIT    512M
ENV MAX_UPLOAD          50M
ENV PHP_MAX_FILE_UPLOAD 200
ENV PHP_MAX_POST        100M

# Let's roll
RUN	apk update && \
	apk upgrade && \
	apk add --update tzdata && \
	cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
	echo "${TIMEZONE}" > /etc/timezone && \
	apk add --update \
                apache2 libxml2-dev apache2-utils \
                php5-apache2 \
		php5-cli \
		php5-mysql \
		php5-json \
		php5-soap \
		php5-mcrypt \
		php5-openssl \
		php5-curl \
		php5-gd \
		php5-apcu \
		php5-iconv \
		php5-dom \
		php5-xmlreader \
		php5-xmlrpc \
		php5-xcache \
		php5-zip \
		php5-pdo_mysql \
		php5-gettext \
		php5-bz2 \
		php5-memcache \
		php5-ctype  && \
        mkdir -p /web/run && chown -R apache.www-data /web && \
        sed -i 's#AllowOverride none#AllowOverride All#' /etc/apache2/httpd.conf && \
        sed -i 's/^#ServerName.*/ServerName webproxy/' /etc/apache2/httpd.conf && \
        sed -i 's#PidFile "/run/.*#Pidfile "/web/run/httpd.pid"#g'  /etc/apache2/conf.d/mpm.conf && \
        sed -i 's/Options Indexes/Options /g' /etc/apache2/httpd.conf 
 

VOLUME ["/app","/web","/etc/apache2/conf.d/vhosts","/web/www/html"]

ADD run.sh /app/run.sh

EXPOSE 80 443

ENTRYPOINT ["/app/run.sh"]


