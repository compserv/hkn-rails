# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "debian/jessie64"

  config.vm.provision :shell, :path => "vagrant/bootstrap.sh"
  config.vm.provision :shell, :privileged => false, :path => "vagrant/user_bootstrap.sh"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine.
  config.vm.network :forwarded_port, guest: 3000, host: 3000

  config.vm.provider :virtualbox do |vb|
    # Don't boot with headless mode
    vb.gui = false
  end
end
