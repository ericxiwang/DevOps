# Smart-terminal deployment: step-by-step guide

## About this guide
This guide will take you through deployment steps of a **smart terminal**
on a Linux box running CentOS 7 (CentOS Linux release 7.3.1611 (Core)).

After completing this guide, you will have a **Smart Terminal**
connected to an existing **Smart Datacenter** running on Azure cloud.


## Install the dependencies
Start with a clean CentOS 7 box.
You will need administrative privileges to install smart terminal. Run update

```bash
sudo su
yum update
```
You are going to update local **yum** repository configuration.

The required packages, e.g. Java, Cassandra, Mosquitto, and BlueIce smart terminal
are downloaded from the Istuary server, piblic IP **72.2.49.243**.

```
wget http://72.2.49.243/datastax.repo -P /etc/yum.repos.d
wget http://72.2.49.243/mqtt.repo -P /etc/yum.repos.d
wget http://72.2.49.243/blueice.repo -P /etc/yum.repos.d
yum update
```

Download the RPM packages
```
wget http://72.2.49.243/blueice-thirdparty/jdk-8u121-linux-x64.rpm
wget http://72.2.49.243/blueice-thirdparty/mysql57-community-release-el7-7.noarch.rpm
wget https://nginx.org/packages/mainline/centos/7/x86_64/RPMS/nginx-1.13.2-1.el7.ngx.x86_64.rpm
wget http://72.2.49.243/blueice-release/blueice-smart-terminal-2.3-388.release.x86_64.rpm
```

Install **nginx**, **cassandra**, **mosquitto**, **MySQL**, and **Java JDK** version 1.8.121
```
yum localinstall -y jdk-8u121-linux-x64.rpm
yum localinstall -y nginx-1.13.2-1.el7.ngx.x86_64.rpm
yum localinstall -y mysql57-community-release-el7-7.noarch.rpm
yum install -y datastax-ddc mosquitto mysql-server
yum localinstall -y blueice-smart-terminal-2.3-388.release.x86_64.rpm
```


Start **cassandra** and enable the daemon
```
systemctl start cassandra
systemctl enable cassandra
```


Start **mosquitto** service, and enable the service on reboot
```
systemctl start mosquitto
systemctl enable mosquitto
```


## Configure **MySQL**

Start **mysqld** daemon
```
systemctl start mysqld
```

A random password will be generated for the root user. Search the log file to retrieve this password
```
cat /var/log/mysqld.log | grep password
```

Expect similar output. We will use this temporary password to login to MySQL server and reset the password for root.

> 2017-06-09T18:52:35.541204Z 1 [Note] A temporary password is generated for root@localhost: Wl3yPaSfpL:x

Use **mysql** client to login to MySQL server and reset root password

```
mysql -u root -p Wl3yPaSfpL:x
```


> ```
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 5
Server version: 5.7.18
Copyright (c) 2000, 2017, Oracle and/or its affiliates. All rights reserved.
Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.
Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
mysql> 
```

Reset root password
```
mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY 'Istuary-1118';
```

> If you may want to disable current policy requirements ```mysql> uninstall plugin validate_password;```

Do not close **mysql>**. Setup the environment required to run a smart terminal
```
DROP DATABASE IF EXISTS smart_terminal;
CREATE DATABASE smart_terminal CHARACTER SET utf8 COLLATE utf8_general_ci;
DROP DATABASE IF EXISTS smart_terminal_test;
CREATE DATABASE smart_terminal_test CHARACTER SET utf8 COLLATE utf8_general_ci;
DROP DATABASE IF EXISTS whetstone;
CREATE DATABASE whetstone CHARACTER SET utf8 COLLATE utf8_general_ci;
DROP USER IF EXISTS 'smart_terminal'@'localhost';
CREATE USER 'smart_terminal'@'localhost' IDENTIFIED BY 'Lipton305!';
GRANT USAGE ON *.* TO 'smart_terminal'@'localhost';
GRANT ALL PRIVILEGES ON smart_terminal.* TO 'smart_terminal'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON smart_terminal_test.* TO 'smart_terminal'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON whetstone.* TO 'smart_terminal'@'localhost' WITH GRANT OPTION;
```

Type ```exit``` to close **mysql>** session.


## Configure Smart Terminal
Actually, **SmartTerminal** will use ```/data``` folder to read/write data.

This folder is creader by the RPM install process. Check that ```blueice``` account ownes the folder.

If needed, set permissions on ```/data``` folder
```
chown -R blueice:blueice /data
```


## Start NGINX web server

Replace ```/etc/nginx/nginx.conf``` file with the one from the repository.

Copy SSL certificates folder to ```/etc/nginx```.


Start **nginx** web server and enable the daemon
```
systemctl start nginx
systemctl enable nginx
```

