FROM jenkins/jenkins:lts-jdk17

LABEL maintainer="Eric Wang <gowest.wang@gmail.com>"
USER root
RUN mkdir /opt/rt-test
COPY api_auto_test.robot /opt/rt-test
COPY api_temp.json /opt/rt-test
COPY page_auto_test.robot /opt/rt-test
COPY resources.robot opt/rt-test
COPY requirements.txt opt/rt-test
WORKDIR /opt/rt-test
RUN apt-get -y update && apt-get -y install python3
RUN apt-get -y install python3-pip
RUN yes | pip3 install -r requirements.txt --break-system-packages