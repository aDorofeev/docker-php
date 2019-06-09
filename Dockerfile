FROM bitnami/minideb:stretch

# Set timezone
ENV TIMEZONE=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime && echo $TIMEZONE > /etc/timezone

# Prepare apt
RUN install_packages \
  curl \
  apt-transport-https \
  ca-certificates

# install php
RUN curl -s -L -o /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb http://packages.sury.org/php stretch main" > /etc/apt/sources.list.d/php-sury.list

# php modules
RUN install_packages \
    php7.3-fpm \
    php7.3-cli \
    php7.3-xml \
    php7.3-curl \
    php7.3-intl \
    php7.3-mysql \
    php7.3-mbstring \
    php7.3-redis \
    php7.3-bcmath \
    php7.3-imagick \
    php7.3-gd \
    php7.3-zip

# php-mongodb module
    # prepare
RUN install_packages \
        php-pear \
        php7.3-dev \
        make && \
    # install
    pecl install mongodb-1.5.3 && \
    echo "extension=mongodb.so" > "/etc/php/7.3/fpm/conf.d/20-mongodb.ini" && \
    echo "extension=mongodb.so" > "/etc/php/7.3/cli/conf.d/20-mongodb.ini" && \
    # cleanup
    apt-get remove --auto-remove --assume-yes \
        php-pear \
        php7.3-dev \
        gcc \
        make && \
    apt-get clean

# install other packages
RUN install_packages \
    git \
    zip \
    unzip

# php configuration
RUN rm -f /etc/php/7.3/fpm/pool.d/www.conf
RUN mkdir /run/php
RUN sed -i "/pid = .*/c\;pid = /run/php/php7.3-fpm.pid" /etc/php/7.3/fpm/php-fpm.conf \
    && sed -i "/;daemonize = .*/c\daemonize = no" /etc/php/7.3/fpm/php-fpm.conf \
    && sed -i "/error_log = .*/c\error_log = /proc/self/fd/2" /etc/php/7.3/fpm/php-fpm.conf \
    && usermod -u 1000 www-data

RUN mkdir -p /var/www
RUN chown -R www-data:1000 /var/www

RUN ln -sf /dev/stderr /var/log/www.log.slow

COPY symfony.pool.conf /etc/php/7.3/fpm/pool.d/

COPY sfconsole /usr/bin/
COPY composer /usr/bin/

CMD ["/usr/sbin/php-fpm7.3"]

RUN chown -R www-data. /var/www/
USER www-data
RUN mkdir /var/www/.composer
WORKDIR /var/www/symfony

# php dev server
EXPOSE 8000
# php-fpm
EXPOSE 9000
