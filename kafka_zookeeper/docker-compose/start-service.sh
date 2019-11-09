#!/bin/bash
echo $CLUSTER_NAME
echo $KAFKA_HOME
if [[ $CLUSTER_NAME == "zookeeper" ]];then

bash $KAFKA_HOME/bin/zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties

elif [[ $CLUSTER_NAME == "kafka" ]];then

#get ZOOKEEPER_CONNECT and insert into server.properties

sed -i "s/broker.id=0/broker.id=$BROKER_ID/g" $KAFKA_HOME/config/server.properties
sed -i "s/localhost:2181/$ZOOKEEPER_CONNECT/g" $KAFKA_HOME/config/server.properties
bash $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties

else
echo "nothing" > /opt/label
echo $CLUSTER_NAME >> /opt/label

fi

