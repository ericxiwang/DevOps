# Cassandra v3.7.0

Cassandra virtual machines do not have public IP address. Instead, use any 
Azure virtual machine with a public IP address to access **cassandra** nodes.

|  Host name   | Private IP | Public IP |
|--------------|------------|-----------|
| Cassandra-01 | 10.0.101.4 |           |
| Cassandra-02 | 10.0.101.5 |           |
| Cassandra-03 | 10.0.101.6 |           |

## Access Cassandra VM

Use ssh to log in into Cassandra virtual machine ```ssh northstar@10.0.101.4```

## Install pre-requisites

Switch to ```root``` user and update the system ```yum update```

Install ```java``` and ```jemalloc```. Download the binaries from the 
Istuary 10.0.10.31 server, use public IP 72.2.49.243.
```
wget http://72.2.49.243/blueice-thirdparty/jdk-8u121-linux-x64.rpm
yum localinstall -y jdk-8u121-linux-x64.rpm

wget http://72.2.49.243/blueice-thirdparty/jemalloc-3.6.0-1.el7.x86_64.rpm
yum localinstall -y jemalloc-3.6.0-1.el7.x86_64.rpm
```

## Install and configure Cassandra nodes

Add **cassandra** repository and install **cassandra**
```
wget http://72.2.49.243/datastax.repo -P /etc/yum.repos.d
yum install -y datastax-ddc
```

Logout/login is needed to enable **cassandra** user/group session.

We use ```/data``` folder for **cassandra** data storage location.
Create **data** folder and assign permissions
```
cd / && mkdir data && chown -R cassandra:cassandra data
```
For commit logs location, create **commitlog** folder and assign permissions
```
cd /mnt/resource && mkdir commitlog && chown -R cassandra:cassandra commitlog
```

Update **cassandra** configuration file ```/etc/cassandra/conf/cassandra.yaml``` as follows

```
cluster_name: 'Azure_Cluster'
data_file_directories:
    - /data
commitlog_directory: /mnt/resource/commitlog
seeds: "10.0.101.4,10.0.101.5,10.0.101.6"
listen_address: 10.0.101.4
rpc_address:
```

## Start Cassandra service
To disable SELinux open ```/etc/selinux/config``` and change to
```
SELINUX=disabled
```

Start **cassandra** service and enable enable automatic starting after a reboot
```
systemctl start cassandra
systemctl enable cassandra
```

## Testing Cassandra cluster

[*OPTIONAL*] Verify **cassandra** cluster status; run ```nodetool status```. Expect similat output:
```
Datacenter: datacenter1
=======================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address    Load       Tokens       Owns (effective)  Host ID                               Rack
UN  10.0.101.4   236.35 KiB  256          68.0%             6a724a69-0ca0-48d1-b075-953551ffdff9  rack1
UN  10.0.101.5  171.58 KiB  256          68.5%             43058380-c90a-4514-98ef-bbf0103d29a0  rack1
UN  10.0.101.6  80.2 KiB   256          63.5%             2fbf6929-787a-48fd-9a4a-50ab407b8e2b  rack1
```
[*OPTIONAL*] To start **cassandra** client, run ```cqlsh 10.0.101.4```.

```
Connected to Azure_Cluster at 10.0.101.4:9042.
[cqlsh 5.0.1 | Cassandra 3.7.0 | CQL spec 3.4.2 | Native protocol v4]
Use HELP for help.
cqlsh> 
```
