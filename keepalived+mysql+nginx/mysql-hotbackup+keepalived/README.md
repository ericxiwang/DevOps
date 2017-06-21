# MySQL Master-Master HA Deployment

## Introduction
In this guide we deploy a master/master high availability solution for MySQL 5.7 server
based on VRRP.

> The Virtual Router Redundancy Protocol (VRRP) is a computer networking protocol
that provides for automatic assignment of available Internet Protocol (IP)
routers to participating hosts.

#### ```The Active - Standby configuration. The Active Node is the one which is externally reachable via a Virtual IP address.```


![ModeA](img/mysql-ha-multi-master-modeA.png)

Binary log replica is configured in both directions, from MySQL-1 to MySQL-2 and from MySQL-2 to MySQL-1.

**Keepalived** daemon check that both servers are operational and assigns the virtual IP address to the *MASTER* one,
according to the priority variable.

In case of failure of either **network** interface or **mysqld** on the primary server, the **keepalived** daemon will 
 - disable the virtual IP address on the *MASTER* server
 - enable the virtual IP address on the *BACKUP* server
 - stop the **keepalived** service on the *MASTER* server



![ModeA](img/mysql-ha-multi-master-modeB.png)


## Enable **keepalived** daemon

Keepalive is available in centOS base repository.

Install and enable the service on both MySQL servers
```
yum install -y keepalived
systemctl start keepalived
systemctl enable keepalived
```
Keepalived configuration file: /etc/keepalived/keepalived.conf


## Configure mysqld
We need to assign server id to each of the two servers, and set the ```auto_increment``` variables.

Open ```/etc/my.cnf``` and append the following on **MySQL-1** server
```
server-id = 1
auto-increment-increment = 2
auto-increment-offset = 1
```
then, on **MySQL-2** server add
```
server-id = 2
auto-increment-increment = 2
auto-increment-offset = 2
```

Add the following to both servers
```
character_set_server=utf8
interactive_timeout = 57600
log-bin = mysql-bin
expire-logs-days = 30
replicate-do-db = cornerstone
binlog-ignore-db = mysql
binlog-ignore-db = information_schema

slave-skip-errors=all
log-slave-updates
skip-name-resolve
```

### Setting up master-slave replication: MySQL-1 to MySQL-2



### Setting up master-slave replication: MySQL-2 to MySQL-1

