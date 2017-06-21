#!/bin/bash

if [ -z $TENANT_ID ]; then
        echo "You must specify environmental variable TENANT_ID"
        exit 1
fi

if [ -z $ST_MYSQL_HOST ]; then
        ST_MYSQL_HOST="mysql-$TENANT_ID.marathon.mesos"
fi

if [ -z $ST_MYSQL_PORT ]; then
        ST_MYSQL_PORT=$(dig _mysql-tenant-1._tcp.marathon.mesos SRV +short| awk -F" " '{print $3}')
        if [ -z $ST_MYSQL_PORT ]; then
                echo "Can't find mysql-$TENANT_ID.marathon.mesos in DC/OS"
                exit 1
        fi 
fi

if [ -z "$ST_KAFKA_SERVERS" ]; then 
        echo "You must specify environmental variable ST_KAFKA_REMOTE_SERVER"
        echo "For example ST_KAFKA_SERVERS='kafka1:9092,kafka2:9092,kafka3:9092'"
        exit 1
fi

if [ -z "$ST_ZOOKEEPER_SERVERS" ]; then 
        echo "You must specify environmental variable ST_ZOOKEEPER_SERVERS"
        echo "For example ST_ZOOKEEPER_SERVERS='zk1:2181,zk2:2181,zk3:2181'"
        exit 1
fi

if [ -z "$ST_CASSANDRA_HOST" ]; then 
        echo "You should specify environmental variable ST_CASSANDRA_HOST"
        ST_CASSANDRA_HOST="localhost"
fi

cp -f /usr/share/terminal_server/conf/log4j.xml /data/sw
cp -f /data/sw/southwest.conf.template /data/sw/southwest.conf

sed -i "s/TEMPLATE_CASSANDRA_HOST/$ST_CASSANDRA_HOST/g" /data/sw/southwest.conf
sed -i "s/TEMPLATE_MYSQL_HOST/$ST_MYSQL_HOST/g" /data/sw/southwest.conf
sed -i "s/TEMPLATE_MYSQL_PORT/$ST_MYSQL_PORT/g" /data/sw/southwest.conf
sed -i "s/TEMPLATE_KAFKA_SERVERS/$ST_KAFKA_SERVERS/g" /data/sw/southwest.conf
sed -i "s/TEMPLATE_ZOOKEEPER_SERVERS/$ST_ZOOKEEPER_SERVERS/g" /data/sw/southwest.conf
echo "starting smart_terminal"
/usr/bin/supervisord
