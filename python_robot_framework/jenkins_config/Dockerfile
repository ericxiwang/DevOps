FROM jenkins/jenkins:latest

LABEL maintainer="Eric Wang <gowest.wang@gmail.com>"
USER root
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc.yaml

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt
COPY casc.yaml /var/jenkins_home/casc.yaml
RUN mkdir /opt/rt-test
#COPY api_auto_test.robot /opt/rt-test
#COPY api_temp.json /opt/rt-test
#COPY page_auto_test.robot /opt/rt-test
#COPY resources.robot opt/rt-test
COPY requirements.txt opt/rt-test
WORKDIR /opt/rt-test
RUN apt-get -y update && apt-get -y install python3
RUN apt-get -y install python3-pip
RUN yes | pip3 install -r requirements.txt --break-system-packages
