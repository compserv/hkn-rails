#!/usr/bin/env bash

# Set locale to UTF-8
update-locale LC_ALL=en_US.UTF-8
source /etc/default/locale

apt-get update
apt-get install -y curl make openjdk-7-jre postgresql-9.1 screen vim
apt-get install -y build-essential libxslt-dev libxml2-dev libpq.dev

# Install RVM
curl -L https://get.rvm.io | bash -s stable
source /usr/local/rvm/scripts/rvm

# Install Ruby
rvm install 1.9.2
rvm use 1.9.2 --default

# Install gems
gem install bundler
gem install rails -v 3.1.11
cd /vagrant
bundle install

# Modify database.yml
cp vagrant/database.yml.vagrant config/database.yml

# Configure PostgreSQL
cp vagrant/pg_hba.conf /etc/postgresql/9.1/main/pg_hba.conf 
su postgres -c "psql -c \"CREATE USER hkn_rails WITH PASSWORD 'hkn_rails' CREATEDB;\""
/etc/init.d/postgresql restart
