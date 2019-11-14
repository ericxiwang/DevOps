```
                   +-------------+
                   |    docker   |
                   +-------------+
                          |
                          +
			  |
+-------------+    +-------------+    +-------------+
| zookeeper-1 |----| zookeeper-2 |----| zookeeper-3 |
+-------------+    +-------------+    +-------------+
       |                  |                  |
       +------------------+------------------+
       |                  |                  |
+-------------+    +-------------+    +-------------+
|   kafka-1   |    |   kafka-2   |    |   kakfa-3   |
+-------------+    +-------------+    +-------------+
```
docker-compose-single.yml is for running only one zookeeper and one kafka node
docker-compose-cluster.yml is for running simply cluster which has three node for zookeeper and kafka

env-single.env and env-cluster.env include kafka&zookeeper config file

start-service.sh will be build into docker image and will be boot by supervisord
