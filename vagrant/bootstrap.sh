#!/usr/bin/env bash

# Set locale to UTF-8
update-locale LC_ALL=en_US.UTF-8
source /etc/default/locale

apt-get update
apt-get install -y make g++
apt-get install -y curl make openjdk-7-jre screen vim git
apt-get install -y build-essential libxslt-dev libxml2-dev libmysqlclient-dev

# Configure PostgreSQL
# cp vagrant/pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf
# su postgres -c "psql -c \"CREATE USER hkn_rails WITH PASSWORD 'hkn_rails' CREATEDB;\""
# # systemctl restart postgresql
# /etc/init.d/postgresql restart
