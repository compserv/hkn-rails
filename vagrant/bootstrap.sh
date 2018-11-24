#!/usr/bin/env bash

# Set locale to UTF-8
update-locale LC_ALL=en_US.UTF-8
source /etc/default/locale

# Add jessie-backports to /etc/apt/sources.list
echo "deb http://deb.debian.org/debian jessie-backports main" >> /etc/apt/sources.list

apt-get update
apt-get install -y \
    build-essential \
    curl \
    openjdk-7-jre \
    screen \
    vim \
    git \
    libxslt-dev \
    libxml2-dev \
    mariadb-client \
    mariadb-server \
    default-libmysqlclient-dev \

# Configure MySQL
mysql -e "GRANT ALL PRIVILEGES ON \`hkn\_rails\_%\`.* TO 'hkn_rails'@'localhost' IDENTIFIED BY 'hkn_rails';"
