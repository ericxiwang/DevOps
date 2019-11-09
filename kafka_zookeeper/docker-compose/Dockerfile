FROM ubuntu:16.04
MAINTAINER eric xi wang
ENV KAFKA_HOME=/opt/kafka
RUN apt-get update && apt-get -y install vim wget curl unzip git
#install jdk
RUN apt-get install -y openjdk-8-jdk
#install kafka/zookeeper
ADD kafka_2.10-0.10.2.1 /opt/kafka
#install supervisord
RUN apt-get install -y supervisor
#copy supervidord config file
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start-service.sh /usr/bin/start-service.sh
EXPOSE 9092 2181
ENTRYPOINT ["/usr/bin/supervisord"]

