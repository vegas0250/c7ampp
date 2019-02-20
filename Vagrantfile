# 1. vagrant plugin install vagrant-winnfsd
# 2. vagrant up

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"

  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 3306, host: 3306
  config.vm.network "forwarded_port", guest: 5432, host: 5432

  #config.vm.network "forwarded_port", guest: 2812, host: 2812

  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder "./www", "/vagrant", type: "nfs", nfs_upd: false

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
  end

  config.vm.provision 'shell', path: './boot.sh'
end