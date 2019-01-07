#!/usr/bin/env bash

# Set locale to UTF-8
update-locale LC_ALL=en_US.UTF-8
source /etc/default/locale

apt-get update
apt-get install -y \
    build-essential \
    curl \
    gnupg \
    dirmngr \
    openjdk-8-jre-headless \
    screen \
    vim \
    git \
    libxslt-dev \
    libxml2-dev \
    mariadb-client \
    mariadb-server \
    libmariadbclient-dev-compat

# Configure MySQL
mysql -e "GRANT ALL PRIVILEGES ON \`hkn\_rails\_%\`.* TO 'hkn_rails'@'localhost' IDENTIFIED BY 'hkn_rails';"
