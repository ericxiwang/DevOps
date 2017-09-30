#!/bin/bash

echo "[client]" >> /etc/my.cnf
echo "user=root" >> /etc/my.cnf
psw=$(grep 'temporary password is generated for root@localhost:' /var/log/mysqld.log | awk {' printf $11'})
echo "password=$psw" >> /etc/my.cnf
