# Zookeeper / Kafka cluster

## Install Kafka v0.10.1.0 / Zookeeper v3.4.8

| Host name    | Private IP | Public IP      |
|--------------|------------|----------------|
| Kafka-01     | 10.0.1.7   | 52.162.126.98  |
| Kafka-02     | 10.0.1.8   | 52.162.249.178 |
| Kafka-03     | 10.0.1.10  | 52.162.124.85  |

Switch to ```root``` user and update the system ```yum update```

Install ```java```. The deployment version is **JDK 8u 121**.
Download the binaries from the Istuary 10.0.10.31 server, public **IP 72.2.49.243**.
```
wget http://72.2.49.243/blueice-thirdparty/jdk-8u121-linux-x64.rpm
yum localinstall -y jdk-8u121-linux-x64.rpm
```
Download **kafka** PRM package and install it.
```
wget http://72.2.49.243/blueice-thirdparty/blueice-smart-kafka-2.11_0.10.1.0-production.x86_64.rpm
yum localinstall -y blueice-smart-kafka-2.11_0.10.1.0-production.x86_64.rpm
```

Configure **ZooKeeper** server.
```
cd /var/lib/
mkdir zookeeper
chown -R kafka:kafka zookeeper
cd zookeeper/
```

Set **zookeeper** broker id.

On ```Kafka-01``` virtual machine 
```
echo 1 > /var/lib/zookeeper/myid
```

On ```Kafka-02``` virtual machine 
```
echo 2 > /var/lib/zookeeper/myid
```

On ```Kafka-03``` virtual machine 
```
echo 3 > /var/lib/zookeeper/myid
```

Create **kafka-logs** folder and assign permissions
```
cd /mnt/resource
mkdir kafka-logs
chown -R kafka:kafka kafka-logs
```

Start **Zookeeper** server and enable it to start on reboot
```
systemctl start zookeeper
systemctl enable zookeeper
```

Start **Kafka** server and enable it to start on reboot
```
systemctl start kafka
systemctl enable kafka
```

Create **sensorRawData** topic with 24 partitions, and set the replication factor to 1.

On ```kafka-01``` virtual machine run the following
```
/opt/kafka/bin/kafka-topics.sh --create --zookeeper 10.0.101.7:2181 --replication-factor 1 --partitions 24 --topic sensorRawData --config cleanup.policy=delete --config delete.retention.ms=60000
```

&nbsp;

&nbsp;

&nbsp;

## Basic Operations Kafka

Login to **Kafka-01** node. List all active topics
```
/opt/kafka/bin/kafka-topics.sh --zookeeper 10.0.101.7:2181 --list
```

> Output
> ```
__consumer_offsets
masterDataSync
notification_0
notification_1cdddcc5-ed51-48e4-9b5e-6e7c1b707225
notification_ae85e97c-7272-48f0-a297-180df9d45a88
notification_bc1ae8cc-5486-4898-a42c-d7fde3e9d048
operationLog
sensorRawData
```

Describe **sensorRawData** topic
```
/opt/kafka/bin/kafka-topics.sh --describe --zookeeper 10.0.101.7:2181 --topic sensorRawData
```

Delete any listed topic
```
/opt/kafka/bin/kafka-topics.sh --zookeeper 10.0.101.7:2181 --delete --topic notification_bc1ae8cc-5486-4898-a42c-d7fde3e9d048
```
> Output
> ```
Topic notification_bc1ae8cc-5486-4898-a42c-d7fde3e9d048 is marked for deletion.
Note: This will have no impact if delete.topic.enable is not set to true.
```

&nbsp;
&nbsp;
&nbsp;

### Minimum In-sync Replicas

We can set the minimum number of in-sync replicas (ISRs) that must be available for the producer
to successfully send messages to a partition using the min.insync.replicas setting.
If **min.insync.replicas** is set to 2 and acks is set to all, each message must be written
successfully to at least two replicas. This guarantees that the message is not lost unless both hosts crash.

> **IMPORTANT**: We operate two Kafka nodes as a cluster. It means that if one of the hosts crashes,
the partition is no longer available for writes.

You can set a parameter using the ```/opt/kafka/bin/kafka-topics.sh --alter``` command for each topic
```
/opt/kafka/bin/kafka-topics --alter --zookeeper 10.0.101.7:2181 --topic sensorRaeData --config min.insync.replicas=2
```


&nbsp;

&nbsp;

&nbsp;

## Basic Operations Zookeeper

To force delete a kafka topic when delete fails, stop kafka service, and run zookeeper shell
```
/opt/kafka/bin/zookeeper-shell.sh 10.0.101.7
```

List all entries in topics
```
ls /config/topics
```
> Output

>```
[notification_bc1ae8cc-5486-4898-a42c-d7fde3e9d048, __consumer_offsets]
```

Remove a topic
```
rmr /config/topics/notification_bc1ae8cc-5486-4898-a42c-d7fde3e9d048
rmr /brokers/topics/notification_bc1ae8cc-5486-4898-a42c-d7fde3e9d048
rmr /admin/delete_topics/notification_bc1ae8cc-5486-4898-a42c-d7fde3e9d048
```
