FROM bitnami/minideb:jessie

# Set timezone
ENV TIMEZONE=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime && echo $TIMEZONE > /etc/timezone

# Prepare apt
RUN install_packages \
  curl \
  apt-transport-https \
  lsb-release \
  ca-certificates

# install php
RUN curl -o /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

RUN install_packages \
    php7.1-fpm \
    php7.1-cli \
    php7.1-xml \
    php7.1-curl \
    php7.1-intl \
    php7.1-mysql \
    php7.1-mcrypt \
# apc user cache (uncomment, or copy to your Dockerfile to enable)
#    php7.1-apcu \
    php7.1-mbstring \
# redis is good for sessions, a better replacement for memcached
    php7.1-redis \
    php7.1-bcmath \
    php7.1-imagick \
    php7.1-gd \
    php7.1-zip

# install other packages
RUN install_packages \
   git

# php configuration
RUN rm -f /etc/php/7.1/fpm/pool.d/www.conf
RUN mkdir /run/php
RUN sed -i "/pid = .*/c\;pid = /run/php/php7.1-fpm.pid" /etc/php/7.1/fpm/php-fpm.conf \
    && sed -i "/;daemonize = .*/c\daemonize = no" /etc/php/7.1/fpm/php-fpm.conf \
    && sed -i "/error_log = .*/c\error_log = /proc/self/fd/2" /etc/php/7.1/fpm/php-fpm.conf \
    && usermod -u 1000 www-data

RUN mkdir -p /var/www
RUN chown -R www-data:1000 /var/www

RUN ln -sf /dev/stderr /var/log/www.log.slow

ADD symfony.pool.conf /etc/php/7.1/fpm/pool.d/

ADD sfconsole /usr/bin/
ADD composer /usr/bin/

CMD ["/usr/sbin/php-fpm7.1"]

RUN chown -R www-data. /var/www/
USER www-data
RUN mkdir /var/www/.composer
WORKDIR /var/www/symfony

# php dev server
EXPOSE 8000
# php-fpm
EXPOSE 9000
