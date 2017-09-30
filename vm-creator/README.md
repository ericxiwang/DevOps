Installation
============
Enable EPEL repository, install ```pip``` support
```
yum install epel-release
yum install python-pip -y
```

You will need to do `pip install uuid jinja2`

Deploy this project anywhere on the server

Running
=======
First thing you need to do is start SimpleHTTPServer in /tmp directory:
```
cd /tmp
python -m SimpleHTTPServer
```

Then you can create VMs:

Example:

```
./vm-creator.py --hostname bluice-test --ip 10.9.50.10 --vcpu 2 --disk 50 --ram 4096 --iso /tmp/CentOS7.iso
```

This will create a VM blueice-test with ip 10.9.50.10 with 2 vcpus, 4G or RAM,  and disk space of 50G.

This VM will be brdged on br1050 interface


Virt-manager
============
You can start virt-manager on each blade to see all the VMs. To do that you need to do:
1. ssh bi_deploy@{blade-ip}
2. xauth list
3. copy the whole Magic Cookie (Example: `van-dell-s8/unix:10  MIT-MAGIC-COOKIE-1  e2d4568bd7ec5fdd278f96a889b76191`)
4. sudo su -
5. xauth add {Magic Cookie from step 3}
6. virt-manager


On the Old Host (kvm01)
============
shutdown the VM

dump its definition to /tmp/vm.xml and copy it over to the new host
copy the VM's image to the new host
undefine the VM and delete its image
```
virsh shutdown vm
```
```
virsh dumpxml vm > /tmp/vm.xml
```
```
scp /tmp/vm.xml kvm02:/tmp/vm.xml
```
```
scp /var/lib/libvirt/images/vm.qcow2 kvm02:/var/lib/libvirt/images/vm.qcow2
```
```
virsh undefine vm
```
```
rm /var/lib/libvirt/images/vm.qcow2
```




On the New Host (kvm02)
==========
define the VM from /tmp/vm.xml
start the VM
```
virsh define /tmp/vm.xml
```
```
Domain vm defined from /tmp/vm.xml
```
```
virsh start vm
```


