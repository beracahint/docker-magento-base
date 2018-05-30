FROM ubuntu:16.04

ENV MAGE_REPO_USERNAME="c4f6926cfd168b5ab9a4c8a9c0477d71"
ENV MAGE_REPO_PASSWORD="6af9de857d3688254a33273f5ec71887"
ENV M2SETUP_VERSION="2.2.2"

RUN export DEBIAN_FRONTEND=noninteractive

# Update OS
RUN apt-get update && apt-get -y upgrade

# Troubleshoot utils
# -----
# apt install net-tools  # netstat
# apt install iputils-ping
# apt install telnet

# Utilities
#----------
RUN apt-get install -y curl supervisor
COPY os_files/etc/supervisor/supervisord.conf /etc/supervisor/

# aws-cli
RUN curl -O https://bootstrap.pypa.io/get-pip.py \
  && python get-pip.py --user \
  && export PATH=/root/.local/bin:$PATH \
  && ln -s /root/.local/bin/aws /usr/local/bin/aws \
  && pip install awscli --upgrade --user



# Add utility to get filesystem
RUN mkdir /opt/emedic
COPY os_files/opt/emedic/generate_filesystem.sh /opt/emedic/
RUN chmod +x /opt/emedic/generate_filesystem.sh



# Set timezone
#----------
RUN apt-get install -y tzdata \
  && ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime \
  && dpkg-reconfigure -f noninteractive tzdata


# Install nginx
#--------------

RUN echo "deb http://nginx.org/packages/ubuntu/ xenial nginx" >> /etc/apt/sources.list \
  && echo "deb-src http://nginx.org/packages/ubuntu/ xenial nginx" >> /etc/apt/sources.list \
  && apt-get install -y wget \
  && wget http://nginx.org/keys/nginx_signing.key \
  && apt-key add nginx_signing.key \
  && apt-get update \
  && apt-get install -y nginx \
  && sed -i 's/user  nginx;/user www-data;/' /etc/nginx/nginx.conf

COPY os_files/etc/nginx/conf.d /etc/nginx/conf.d/
COPY os_files/etc/nginx/nginx.conf /etc/nginx/

# Install Certbot
#-----------------
RUN apt-get install -y software-properties-common \
  && add-apt-repository ppa:certbot/certbot -y \
  && apt-get update \
  && apt-get install -y python-certbot-nginx

#
# Install PHP 7.0 and PHP-FPM
# ----------------
RUN  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C \
  && echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main" > /etc/apt/sources.list.d/ondrej.list \
  && apt-get -y update \
  && apt-get install -y php7.0 libapache2-mod-php7.0 \
    php7.0 php7.0-common php7.0-gd php7.0-mysql \
    php7.0-mcrypt php7.0-curl php7.0-intl php7.0-xsl \
    php7.0-mbstring php7.0-zip php7.0-bcmath php7.0-iconv php7.0-soap \
    php7.0-fpm

COPY os_files/etc/php/7.0/cli/php.ini /etc/php/7.0/cli/php.ini
COPY os_files/etc/php/7.0/fpm/php.ini /etc/php/7.0/fpm/php.ini


ADD mage_filesystem/filesystem.tar.gz /var/www/html/

# Install Magento
#----------------

# RUN curl -sS https://getcomposer.org/installer | php \
#   && mv composer.phar /usr/local/bin/composer \
#   && cd /var/www/html \
#   && rm * \
#   && mkdir /var/www/.composer \
#   && echo  "{\"http-basic\":{\"repo.magento.com\":{\"username\":\"$MAGE_REPO_USERNAME\",\"password\":\"$MAGE_REPO_PASSWORD\"}}}" > /var/www/.composer/auth.json  \
#   && chown -R www-data:www-data /var/www \
#   && su -c "composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=$M2SETUP_VERSION ." -s /bin/bash www-data \
#   && chown -R www-data:www-data /var/www
#
#
#
# magento setup:install \
#   --base-url=$M2SETUP_BASE_URL \
#   --db-host=$M2SETUP_DB_HOST \
#   --db-name=$M2SETUP_DB_NAME \
#   --db-user=$M2SETUP_DB_USER \
#   --db-password=$M2SETUP_DB_PASSWORD \
#   --admin-firstname=$M2SETUP_ADMIN_FIRSTNAME \
#   --admin-lastname=$M2SETUP_ADMIN_LASTNAME \
#   --admin-email=$M2SETUP_ADMIN_EMAIL \
#   --admin-user=$M2SETUP_ADMIN_USER \
#   --admin-password=$M2SETUP_ADMIN_PASSWORD \
#   --use-secure=$USE_SECURE \
#   --base-url-secure=$M2SETUP_BASE_URL_SECURE \
#   --use-secure-admin=$USE_SECURE_ADMIN

# export PATH=$PATH:/var/www/html/bin

# This is required to run php-fpm
RUN mkdir /run/php

WORKDIR /var/www/html
#supervisord -n -c /etc/supervisor/supervisord.conf

CMD ["/usr/bin/supervisord","-n","-c","/etc/supervisor/supervisord.conf"]
