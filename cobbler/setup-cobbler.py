#!/usr/bin/env python
import yaml
import shutil
import os
import re
from fabric.api import local, settings

def download_iso():
    if not os.path.exists('/mnt/CentOS7.iso'):
        local('wget http://centos.mirror.globo.tech/7/isos/x86_64/CentOS-7-x86_64-Everything-1611.iso -O /mnt/CentOS7.iso')

def setup_kickstart():
    dir_path = os.path.dirname(os.path.realpath(__file__))
    local('\cp -rf %s/blueice.ks /var/lib/cobbler/kickstarts/' % dir_path)

def create_profile():
    with settings(warn_only=True):
        local('mkdir -p /mnt/CentOS7')
        local('mount -t iso9660 -o loop,ro /mnt/CentOS7.iso /mnt/CentOS7')
        local('cobbler import --name=CentOS7 --arch=x86_64 --path=/mnt/CentOS7')

def remove_system(system):
    with settings(warn_only=True):
        cmd = 'cobbler system remove --name %(name)s' % system
        local(cmd)

def create_system(system):
    remove_system(system)
    cmd = 'cobbler system add \
            --name %(name)s \
            --hostname %(hostname)s \
            --profile=CentOS7-x86_64 \
            --kickstart=/var/lib/cobbler/kickstarts/blueice.ks' % system
    cmd = re.sub(r'[\s\t]+',' ', cmd)
    local(cmd)

def create_static_interface(iface):
    cmd = 'cobbler system edit --name %(system-name)s \
            --interface=%(name)s \
            --mac=%(mac)s \
            --ip-address=%(ip)s \
            --subnet=%(subnet)s \
            --gateway=%(gateway)s \
            --name-servers="%(name-servers)s" \
            --static=1' % (iface)
    cmd = re.sub(r'[\s\t]+',' ', cmd)
    local(cmd)

def create_bridge_slave_interface(iface):
    cmd = 'cobbler system edit --name %(system-name)s \
            --interface=%(name)s \
            --interface-type=bridge_slave \
            --interface-master=%(interface-master)s \
            --static=1' % (iface)
    cmd = re.sub(r'[\s\t]+',' ', cmd)
    local(cmd)

def create_bridge_interface(iface):
    cmd = 'cobbler system edit --name %(system-name)s \
            --interface=%(name)s \
            --ip-address=%(ip)s \
            --subnet=%(subnet)s \
            --static-routes="%(static-routes)s" \
            --interface-type=bridge \
            --static=1' % (iface)
    cmd = re.sub(r'[\s\t]+',' ', cmd)
    local(cmd)

def create_interface(system_name, interface):
    iface = interface
    iface["system-name"] = system_name
    if iface['type'] == 'static':
        create_static_interface(iface)
    if iface['type'] == 'bridge_slave':
        create_bridge_slave_interface(iface)
    if iface['type'] == 'bridge':
        create_bridge_interface(iface)

def add_ksmeta(system):
    meta=[]
    meta.append('disks=%s' % system['disks'])
    for interface in system['interfaces']:
        if interface['primary']:
            meta.append('gatewaydev=%s' % interface['name'])
            break
    cmd = 'cobbler system edit --name %s --ksmeta="%s"' % (system['name']," ".join(meta))
    local(cmd)

def main():
    download_iso()
    setup_kickstart()
    create_profile()
    with open("blade-system.yaml") as system_setup:
        systems = yaml.load(system_setup)
        for system in systems:
            create_system(system)
            for interface in system['interfaces']:
                create_interface(system['name'],interface)
            add_ksmeta(system)

if __name__ == "__main__":
    main()

