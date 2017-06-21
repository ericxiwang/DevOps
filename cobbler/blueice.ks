# kickstart template for Fedora 8 and later.
# (includes %end blocks)
# do not use with earlier distros

#platform=x86, AMD64, or Intel EM64T
# System authorization information
auth  --useshadow  --enablemd5
# System bootloader configuration
bootloader --location=mbr
# Partition clearing information
clearpart --all --initlabel
# Use text mode install
text
# Firewall configuration
firewall --disable
# Run the Setup Agent on first boot
firstboot --disable
# System keyboard
keyboard us
# System language
lang en_US
# Use network installation
url --url=$tree
# If any cobbler repo definitions were referenced in the kickstart profile, include them here.
$yum_repo_stanza
# Network information
$SNIPPET('network_config')
# Reboot after installation
reboot

#Root password
rootpw --iscrypted $default_password_crypted
# SELinux configuration
selinux --disabled
# System timezone
timezone  America/Vancouver
# Install OS instead of upgrade
install
# Clear the Master Boot Record
zerombr
clearpart --none --initlabel --drives=$disks --all
# Disk partitioning information
#set disks = $getVar('$disks', 'sda')
#set pvnumber = 1
#set pvarray = []
part /boot --fstype="ext4" --ondisk=sda --size=250
#for disk in $disks.split(',')
part pv.0$pvnumber --fstype="lvmpv" --ondisk=$disk --size=1024 --grow
#$pvarray.append("pv.0" + $str($pvnumber)) 
#set $pvnumber = $pvnumber + 1
#end for
volgroup centos --pesize=4096 #echo ' '.join($pvarray)
logvol /  --fstype="ext4" --size=1024 --name=root --vgname=centos --grow

%pre
$SNIPPET('log_ks_pre')
$SNIPPET('kickstart_start')
$SNIPPET('pre_install_network_config')
# Enable installation monitoring
%end

%packages
@base
@core
@x11
vim
wget
screen
qemu-kvm
qemu-img
virt-manager
libvirt
libvirt-python
libvirt-client
virt-install
virt-viewer
bridge-utils
dejavu-lgc-sans-fonts
dejavu-fonts-common
%end

%post
$SNIPPET('log_ks_post')
# Start yum configuration
$yum_config_stanza
# End yum configuration
$SNIPPET('post_install_kernel_options')
$SNIPPET('post_install_network_config')
# Create bi_deploy user and add it to the group
/usr/sbin/groupadd -r bi_deploy --gid=1001
/usr/sbin/useradd -r -m -g bi_deploy --uid=1001 bi_deploy
/usr/sbin/usermod -aG wheel bi_deploy
mkdir --mode=700 /home/bi_deploy/.ssh
cat >> /home/bi_deploy/.ssh/authorized_keys << "PUBLIC_KEY"
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCx1eaHdI+9LL5xC1sggg6QzOJk1H5rnNESoDy8yXozC3Pre1xgWNDb4l8/P9WuuopcAtGwMnZ4WJ4Jpvz0ePAqNKP9LDBKqbkl4Ae4K8c9OR8UWkM5OUUIiRaA8PX7DUVpr20dKhzkwoCXyd44oGPQ1yPz3FQAGY6oT1RWBZjYYSI0DZ9Bfbm6jhUZxkPa1nLF47+E2qfj/MIfT1wdlKBBssfnM8mSD5ggsk8C4KCxTE6yPPVw6EhP0dnMqETejCXY/+gj5Vukr1gdxgWU/Jb+XeNGwRnqJRJ5KZo9EXlb7doi3U0F/ck1t4HRhAkilFIfnmGWeMugrwYmDLs5facd marko.vlahovic@istuary.com
PUBLIC_KEY
chmod 600 /home/bi_deploy/.ssh/authorized_keys
chown -R bi_deploy:bi_deploy /home/bi_deploy/.ssh/
echo 'PermitRootLogin no' >> /etc/ssh/sshd_config
echo 'UseDNS no' >> /etc/ssh/sshd_config
echo '%wheel  ALL=(ALL)       NOPASSWD: ALL' >> /etc/sudoers.d/bi_deploy
echo "GATEWAYDEV=$gatewaydev" >> /etc/sysconfig/network
/usr/bin/yum -y update
# Start final steps
$SNIPPET('kickstart_done')
# End final steps
%end
