Introduction
============
This project is used for easy installation of server blades in Dell Chassis

Requirments 
============
1. Create VM in Virtual Box
2. Install cobbler,httpd,tftp,dhcpd,xinetd
3. Connect your VM to Dell chassis switch

Instructions
============
1. Deploy `settings` to `/etc/cobbler/`
2. Deploy `dnsmasq.template` to `/etc/cobbler/`
3. Run `python setup-cobbler.py`
4. Run `cobbler sync`

keywords of settings:/etc/cobbler/settings
```
next_server: 10.9.52.240  # same as your cobbler PXE server ip
server: 10.9.52.240  # same as your cobbler PXE server ip
```
keywords of tftp server:/etc/xinetd.d/tftp
```
disable = no
```


Notes
=====
This will install dell servers with credentials root/istuary1118. Note that those credentials will work only if you want to login thorugh iKVM

If you want to ssh to one of the servers you will have to use bi_deploy_rsa. Example:

`ssh -i <path to bi_deploy_rsa> bi_deploy@10.9.52.31`

Post-installation
=====
comment out ip address and related info in /etc/sysconfig/network-scripts/ifcfg-xxxx

```
DEVICE=br1051
ONBOOT=yes
TYPE=Bridge
BOOTPROTO=none
#IPADDR=10.9.51.36
#NETMASK=255.255.255.0
#DNS1=8.8.8.8
```