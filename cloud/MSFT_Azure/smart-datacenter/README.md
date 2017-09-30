
## Install web server
Download **nginx** binary
```
wget https://nginx.org/packages/mainline/centos/7/x86_64/RPMS/nginx-1.13.2-1.el7.ngx.x86_64.rpm
```

## Download the RPM package

Log in into Smart Datacenter virtual machine and download the release binary RPM package
```
wget http://72.2.49.243/blueice-release/blueice-smart-datacenter-2.3-361.release.x86_64.rpm
```



# MySQL cluster


CREATE USER 'cornerstone'@'10.0.101.%' IDENTIFIED BY 'Lipton305!';
GRANT USAGE ON *.* TO 'cornerstone'@'10.0.101.%';
GRANT ALL PRIVILEGES ON cornerstone.* TO 'cornerstone'@'10.0.101.%' WITH GRANT OPTION;
-- GRANT ALL PRIVILEGES ON cornerstone_test.* TO 'cornerstone'@'10.0.101.%' WITH GRANT OPTION;
-- GRANT ALL PRIVILEGES ON whetstone.* TO 'cornerstone'@'10.0.101.%' WITH GRANT OPTION;
