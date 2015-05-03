FROM ubuntu:12.04

MAINTAINER Luis Elizondo "lelizondo@gmail.com"
ENV DEBIAN_FRONTEND noninteractive

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

# Update system
RUN apt-get update

# Prevent restarts when installing
RUN echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d

# Basic packages
RUN apt-get -y install php5 php5-fpm php5-mysql php-apc php5-imagick php5-imap php5-mcrypt php5-curl php5-cli php5-gd php5-pgsql php5-sqlite php5-common php-pear curl php5-json php5-memcache nginx-extras git curl supervisor

# Composer
RUN /usr/bin/curl -sS https://getcomposer.org/installer | /usr/bin/php
RUN /bin/mv composer.phar /usr/local/bin/composer
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Composer and Drush
RUN /usr/local/bin/composer self-update
RUN /usr/local/bin/composer global require drush/drush:6.*
RUN ln -s /root/.composer/vendor/drush/drush/drush /usr/local/bin/drush

# Prepare directory
RUN mkdir /var/www
RUN usermod -u 1000 www-data
RUN usermod -a -G users www-data
RUN chown -R www-data:www-data /var/www

EXPOSE 80
WORKDIR /var/www
VOLUME ["/var/www"]
CMD ["/usr/bin/supervisord", "-n"]

# Startup script
# This startup script wll configure nginx
ADD ./startup.sh /opt/startup.sh
RUN chmod +x /opt/startup.sh

RUN mkdir -p /var/cache/nginx/microcache

### Add configuration files
# Supervisor
ADD ./config/supervisor/supervisord-nginx.conf /etc/supervisor/conf.d/supervisord-nginx.conf

# PHP
ADD ./config/php/www.conf /etc/php5/fpm/pool.d/www.conf
ADD ./config/php/php.ini /etc/php5/fpm/php.ini

# Nginx
ADD ./config/nginx/blacklist.conf /etc/nginx/blacklist.conf
ADD ./config/nginx/cron_allowed_hosts.conf /etc/nginx/cron_allowed_hosts.conf
ADD ./config/nginx/drupal6.conf /etc/nginx/drupal6.conf
ADD ./config/nginx/drupal6_upload_progress.conf /etc/nginx/drupal6_upload_progress.conf
ADD ./config/nginx/fastcgi.conf /etc/nginx/fastcgi.conf
ADD ./config/nginx/fastcgi_drupal.conf /etc/nginx/fastcgi_drupal.conf
ADD ./config/nginx/fastcgi_microcache_zone.conf /etc/nginx/fastcgi_microcache_zone.conf
ADD ./config/nginx/fastcgi_no_args_drupal.conf /etc/nginx/fastcgi_no_args_drupal.conf
ADD ./config/nginx/map_cache.conf /etc/nginx/map_cache.conf
ADD ./config/nginx/map_drupal6.conf /etc/nginx/map_drupal6.conf
ADD ./config/nginx/microcache_fcgi_auth.conf /etc/nginx/microcache_fcgi_auth.conf
ADD ./config/nginx/mime.types /etc/nginx/mime.types
ADD ./config/nginx/nginx.conf /etc/nginx/nginx.conf
ADD ./config/nginx/upstream_phpcgi_unix.conf /etc/nginx/upstream_phpcgi_unix.conf
ADD ./config/nginx/map_https_fcgi.conf /etc/nginx/map_https_fcgi.conf
ADD ./config/nginx/map_block_http_methods.conf /etc/nginx/map_block_http_methods.conf
ADD ./config/nginx/php_fpm_status_allowed_hosts.conf /etc/nginx/php_fpm_status_allowed_hosts.conf
ADD ./config/nginx/nginx_status_allowed_hosts.conf /etc/nginx/nginx_status_allowed_hosts.conf
ADD ./config/nginx/map_https_forwarded_proto.conf /etc/nginx/map_https_forwarded_proto.conf
ADD ./config/nginx/default /etc/nginx/sites-enabled/default
