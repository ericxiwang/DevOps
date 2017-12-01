#!/bin/bash

echo "init system"

useradd -m -s /bin/bash -U awrun -p $(openssl passwd -1 awrun)
usermod -aG sudo awrun
cp -pr /home/vagrant/.ssh /home/awrun/
chown -R awrun:awrun /home/awrun
echo "%awrun ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/awrun

apt-get update
apt-get install -y git wget curl vim unzip
add-apt-repository -y ppa:webupd8team/java
apt-get update
debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections

apt-get -y install oracle-java8-installer
