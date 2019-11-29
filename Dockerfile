FROM debian:9.9-slim

RUN apt-get update && apt-get -y upgrade

RUN apt-get install -y \
    wget \
    curl \
    dialog \
    cron \
    unzip \
    git \
    supervisor \
    catdoc \
    nano \
    poppler-utils \
    ca-certificates \
    gnupg \
    libfcgi \
    mysql-client \
    libhiredis-dev \
    apt-transport-https

RUN cd /tmp && wget https://github.com/htacg/tidy-html5/releases/download/5.4.0/tidy-5.4.0-64bit.deb && dpkg -i tidy-5.4.0-64bit.deb

RUN wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
RUN echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list

RUN apt-get update

RUN apt-get install -y php7.1 php7.1-mysql php7.1-xml php7.1-curl php7.1-gd php7.1-mcrypt php7.1-intl php7.1-zip php7.1-mbstring php7.1-fpm php7.1-sqlite php7.1-ldap php7.1-redis php7.1-dev


RUN cd /tmp && git clone https://github.com/nrk/phpiredis.git
RUN cd /tmp/phpiredis && phpize && ./configure --enable-phpiredis
RUN cd /tmp/phpiredis && make && make install
RUN echo "extension=phpiredis.so" > /etc/php/7.1/mods-available/phpiredis.ini
RUN ln -s /etc/php/7.1/mods-available/phpiredis.ini /etc/php/7.1/cli/conf.d/phpiredis.ini
RUN ln -s /etc/php/7.1/mods-available/phpiredis.ini /etc/php/7.1/fpm/conf.d/phpiredis.ini
RUN rm -rf /tmp/phpiredis

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin
RUN /usr/bin/composer.phar self-update

RUN composer.phar global require hirak/prestissimo

RUN wget -O /usr/local/bin/php-fpm-healthcheck https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck
RUN chmod +x /usr/local/bin/php-fpm-healthcheck
#
# Remove the packages that are no longer required after the package has been installed
RUN DEBIAN_FRONTEND=noninteractive apt-get autoremove --purge -q -y
RUN DEBIAN_FRONTEND=noninteractive apt-get autoclean -y -q
RUN DEBIAN_FRONTEND=noninteractive apt-get clean -y

# Remove all non-required information from the system to have the smallest
# image size as possible
# ftp://cgm_gebraucht%40used-forklifts.org:bZAo6dH1cyxhJpgJwO@ftp.strato.com/
RUN rm -rf /usr/share/doc/* /usr/share/man/?? /usr/share/man/??_* /usr/share/locale/* /var/cache/debconf/*-old /var/lib/apt/lists/* /tmp/*

