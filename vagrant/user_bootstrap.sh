#!/usr/bin/env bash

# Download RVM GPG signing keys
curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -

# FIXME: cannot contact keyserver.
# gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

# Install RVM
curl -sSL https://get.rvm.io | bash -s stable
source $HOME/.rvm/scripts/rvm || source /etc/profile.d/rvm.sh

# Install Ruby
rvm install 2.5.1
rvm use 2.5.1 --default

# Install gems
gem install bundler
cd /vagrant
bundle install

# Setup dev database, secrets
cp config/database.yml.sample config/database.yml
cp config/secrets.yml.sample config/secrets.yml

# Create database
bundle exec rake db:setup
