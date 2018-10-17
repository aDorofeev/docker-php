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
    php7.2-fpm \
    php7.2-cli \
    php7.2-xml \
    php7.2-curl \
    php7.2-intl \
    php7.2-mysql \
#    php7.2-mcrypt \ -- dropped in favor of openssl
# apc user cache (uncomment, or copy to your Dockerfile to enable)
#    php7.2-apcu \
    php7.2-mbstring \
# redis is good for sessions, a better replacement for memcached
    php7.2-redis \
    php7.2-bcmath \
    php7.2-imagick \
    php7.2-gd \
    php7.2-zip

# install other packages
RUN install_packages \
    git \
    zip \
    unzip

# php configuration
RUN rm -f /etc/php/7.2/fpm/pool.d/www.conf
RUN mkdir /run/php
RUN sed -i "/pid = .*/c\;pid = /run/php/php7.2-fpm.pid" /etc/php/7.2/fpm/php-fpm.conf \
    && sed -i "/;daemonize = .*/c\daemonize = no" /etc/php/7.2/fpm/php-fpm.conf \
    && sed -i "/error_log = .*/c\error_log = /proc/self/fd/2" /etc/php/7.2/fpm/php-fpm.conf \
    && usermod -u 1000 www-data

RUN mkdir -p /var/www
RUN chown -R www-data:1000 /var/www

RUN ln -sf /dev/stderr /var/log/www.log.slow

ADD symfony.pool.conf /etc/php/7.2/fpm/pool.d/

ADD sfconsole /usr/bin/
ADD composer /usr/bin/

CMD ["/usr/sbin/php-fpm7.2"]

RUN chown -R www-data. /var/www/
USER www-data
RUN mkdir /var/www/.composer
WORKDIR /var/www/symfony

# php dev server
EXPOSE 8000
# php-fpm
EXPOSE 9000
