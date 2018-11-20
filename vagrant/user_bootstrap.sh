#!/usr/bin/env bash

# Install RVM
gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
curl -L https://get.rvm.io | bash -s stable
source /usr/local/rvm/scripts/rvm

# Install Ruby
rvm install 2.5.0
rvm use 2.5.0 --default

# Install gems
gem install bundler
cd /vagrant
bundle install

# Modify database.yml
cp vagrant/database.yml.vagrant config/database.yml
