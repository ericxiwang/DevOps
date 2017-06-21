# Dockerfile for data center

FROM ubuntu:latest
RUN apt-get update
RUN apt-get install -y supervisor
RUN apt-get install -y dnsutils
RUN apt-get install -y nginx
RUN apt-get install -y curl
RUN apt-get install -y software-properties-common
# Installing Java Oracle
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
RUN apt-get install -y oracle-java8-set-default
# Installing Cassandra
RUN echo "deb http://debian.datastax.com/community stable main" | tee -a /etc/apt/sources.list.d/cassandra.sources.list
RUN curl -L https://debian.datastax.com/debian/repo_key | apt-key add -
RUN apt-get update
RUN apt-get install -y cassandra
#Installing mosquitto
RUN apt-get install -y mosquitto mosquitto-clients

# Setting smart terminal
RUN mkdir -p /data/preserve
RUN mkdir -p /data/sw
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD data_center_nginx /etc/nginx/sites-available/
RUN rm -f /etc/nginx/sites-enabled/default
RUN ln -s /etc/nginx/sites-available/data_center_nginx /etc/nginx/sites-enabled/default
RUN rm -f /etc/nginx/nginx.conf
ADD nginx.conf /etc/nginx/
ADD terminal_server /usr/share/terminal_server
ADD smart-terminal-entrypoint.sh /usr/share/terminal_server/bin/
ADD dist /usr/share/nginx/html/dist/
ADD dist/ /var/www/html/
ADD southwest.conf /data/sw/
ADD southwest.conf.template /data/sw/
ADD southwest.conf.backup /data/sw/
ADD southwest.conf /usr/share/terminal_server/conf/
EXPOSE 80
VOLUME /var/lib/cassandra
WORKDIR /usr/share/terminal_server/bin/
ENTRYPOINT ["./smart-terminal-entrypoint.sh"]
