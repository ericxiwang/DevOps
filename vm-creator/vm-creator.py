#!/bin/env python
import argparse
import sys
import os
import uuid
import re
import socket
from jinja2 import Environment, FileSystemLoader
import subprocess
import shlex
import random


def render_template(template_filename, context):
    PATH = os.path.dirname(os.path.abspath(__file__))
    TEMPLATE_ENVIRONMENT = Environment(
        autoescape=False,
        loader=FileSystemLoader(os.path.join(PATH, 'templates')),
        trim_blocks=False)
    return TEMPLATE_ENVIRONMENT.get_template(template_filename).render(context)

def create_ks(hostname, gateway, ip):
    fname = '/tmp/%s-vm.ks' % uuid.uuid4()
    print 'Creating %s' % fname
    context = {
        'ip': ip,
        'gateway' : gateway,
        'hostname' : hostname,
    }
    with open(fname, 'w') as f:
        kickstart = render_template('vm.ks', context)
        f.write(kickstart)
    return fname.split('/')[-1]

def validate_ip(ipaddress):
    '''Validate ipaddress'''
    if (ipaddress.startswith('10.9.51.') or ipaddress.startswith('10.9.50.')) and (len(ipaddress) < 12):
        return True
    else:
        return False

def get_bridge_interface(ipaddress):
    '''Get proper bridge interface based on ip address'''
    if ipaddress.startswith('10.9.51.'):
        return 'br1051'
    if ipaddress.startswith('10.9.50.'):
        return 'br1050'
    raise "Invalid IP %s specified" % ipaddress

def get_default_gateway(ipaddress):
    '''Get default gateway based on ip address'''
    ip_a = ipaddress.split('.')
    ip_a[-1] = '1'
    return '.'.join(ip_a)

def parse():
    parser = argparse.ArgumentParser(description = "Helper tool to create blueice VMs fast")
    parser.add_argument('--hostname', required = True, help = "Your VM hostname")
    parser.add_argument('--ip', required = True, help = "IP of your VM. It can be in range 10.9.51.X or 10.9.50.X")
    parser.add_argument('--disk', required = True, help = "Disk size in GB for the VM")
    parser.add_argument('--ram', required = True, help = "RAM size in MB for the VM")
    parser.add_argument('--vcpu', required = True, help = "CPU size for the VM")
    parser.add_argument('--iso', help = "Location of the iso file", default='/var/CentOS-7-x86_64-Minimal-1611.iso')
    args = parser.parse_args()
    if not validate_ip(args.ip):
        print "Your ip has to be either in 10.9.50.0/24 range or 10.9.51.0/24 range"
        sys.exit(1)
    return args

def create_vm(params):
    cmd = 'virt-install \
            -n %(hostname)s \
            --nographics \
            --noautoconsole \
            --os-type=Linux \
            --os-variant=rhel7 \
            --ram=%(ram)s \
            --vcpus=%(vcpu)s \
            --disk path=/var/lib/libvirt/images/%(hostname)s.qcow2,size=%(disk)s,format=qcow2,bus=virtio \
            --location=%(iso)s \
            --extra-args "ks=http://%(host_ip)s:8000/%(kickstart)s console=ttyS0,115200n8 ksdevice=eth0 ip=%(ip)s netmask=255.255.255.0 gateway=%(gateway)s" \
            --network bridge:%(bridge)s' % (params)
    cmd = re.sub(r'[\s\t]+',' ', cmd)
    print cmd
    subprocess.check_output(shlex.split(cmd))
    
def main():
    args = parse()
    hostname = args.hostname
    iso = args.iso
    ip = args.ip
    disk = args.disk
    ram = args.ram
    vcpu = args.vcpu
    bridge = get_bridge_interface(ip)
    gateway = get_default_gateway(ip)
    kickstart = create_ks(hostname, gateway, ip)
    install_ip_a = ip.split('.')
    install_ip_a[-1] = str(random.randint(200, 253))
    virt_install_params = {
        'hostname' : hostname,
        'iso' : iso,
        'ram' : ram,
        'vcpu' : vcpu,
        'disk' : disk,
        'kickstart' : kickstart,
        'bridge' : bridge,
        'gateway' : gateway,
        'ip': '.'.join(install_ip_a),
        'host_ip' : os.popen('ip addr show %s | grep "\<inet\>" | awk \'{ print $2 }\' | awk -F "/" \'{ print $1 }\'' % 'p2p1').read().strip()    
        }
    create_vm(virt_install_params)

main()
