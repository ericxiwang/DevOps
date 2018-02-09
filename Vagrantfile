# need install plugin for disksize 'vagrant plugin install vagrant-disksize
Vagrant.configure("2") do |config|
  #config.vm.provider "virtualbox" do |v|
  #  v.memory = 2048
  #  v.cpus = 2
  #end
  config.vm.define "web" do |web|
    web.vm.box = "ubuntu/trusty64"
    web.disksize.size = '50GB'
    web.vm.network "public_network", ip: "10.0.100.212"
    web.vm.provider "virtualbox" do |v|
       v.memory = 4096
       v.cpus = 2
    end
    config.vm.provision "shell", path: "inst.sh"
  end
  config.vm.define "db" do |db|
    db.vm.box = "ubuntu/trusty64"
    db.vm.network "public_network", ip: "10.0.100.213"
  end
end
