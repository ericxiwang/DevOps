#!/bin/bash
echo $CLUSTER_NAME
echo $KAFKA_HOME


#setup and start  zookeeper 
if [[ $CLUSTER_NAME == "zookeeper" ]];then
	if [ ! -d $ZK_DATA_DIR ];then
    		mkdir -p $ZK_DATA_DIR
	fi
	if [[ $IS_CLUSTER == "True" ]];then

		sed -i "s/clientPort=2181/clientPort=$clientPort/g" $KAFKA_HOME/config/zookeeper.properties
		echo initLimit=$initLimit >> $KAFKA_HOME/config/zookeeper.properties
		echo syncLimit=$syncLimit >> $KAFKA_HOME/config/zookeeper.properties
		echo tickTime=$tickTime >> $KAFKA_HOME/config/zookeeper.properties
		# generate zookeeper server list
		IFS=', ' read -r -a server_list <<< "$ZOOKEEPER_CONNECT"
		for (( i=0; i<${#server_list[@]}; i++ ))
		do
        		IFS=': ' read -r -a each_seg <<< "${server_list[$i]}"
        		echo server.$(( i + 1))=${each_seg[0]}:$ZK_FOLLOWER_PORT:$ZK_ELECTION_PORT >> $KAFKA_HOME/config/zookeeper.properties
		done

		echo $MY_ID > $ZK_DATA_DIR/myid
	fi
	bash $KAFKA_HOME/bin/zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties

elif [[ $CLUSTER_NAME == "kafka" ]];then

#get ZOOKEEPER_CONNECT and insert into server.properties
	if [[ $IS_CLUSTER == "True" ]];then
		sed -i "s/broker.id=0/broker.id=$BROKER_ID/g" $KAFKA_HOME/config/server.properties
        fi
		sed -i "s/localhost:2181/$ZOOKEEPER_CONNECT/g" $KAFKA_HOME/config/server.properties
	bash $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties

else
	echo "nothing" > /opt/label
	echo $CLUSTER_NAME >> /opt/label

fi

