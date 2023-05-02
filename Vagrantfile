# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "debian/contrib-buster64"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine.
  config.vm.network :forwarded_port, guest: 3000, host: 3000

  config.vm.provider :virtualbox do |vb|
    # Don't boot with headless mode
    vb.gui = false
  end

  # Root-level bootstrap
  config.vm.provision :shell, inline: <<-SHELL
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
        libmariadbclient-dev-compat \
        nodejs

    # Configure MySQL
    # mysql -e "GRANT ALL PRIVILEGES ON \\`hkn\\_rails\\_%\\`.* TO 'hkn_rails'@'localhost' IDENTIFIED BY 'hkn_rails';"
  SHELL

  # User-level bootstrap
  config.vm.provision :shell, privileged: false, inline: <<-SHELL
    # Download RVM GPG signing keys
    curl --insecure -sSL https://rvm.io/mpapis.asc | gpg --import -
    curl --insecure -sSL https://rvm.io/pkuczynski.asc | gpg --import -

    # FIXME: cannot contact keyserver.
    # gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

    # Install RVM
    curl --insecure -sSL https://get.rvm.io | bash -s stable
    source $HOME/.rvm/scripts/rvm || source /etc/profile.d/rvm.sh

    # Install Ruby
    rvm install 2.5.7
    rvm use 2.5.7 --default

    # Install gems
    gem install bundler -v "< 2.0"
    cd /vagrant
    bundle install

    # Setup dev database, secrets
    cp config/database.yml.sample config/database.yml
    cp config/secrets.yml.sample config/secrets.yml

    # Create database
    bundle exec rake db:setup
  SHELL
end
