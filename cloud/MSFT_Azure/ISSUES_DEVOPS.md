# DevOps Issues

- MSFT Load Balancer service for SmartDataCenters
- MySQL cluster
- Kafka private/external network
- SmartTerminal /data permissions for blueice user
- Zookeerer cluster: ODD number of nodes

&nbsp;

&nbsp;

&nbsp;


## MSFT/Arure Load Balancer Service for SmartDataCenters

### Actual configuration
The https server is already setup as you described below. Basically, the environment is set up to take over based on service availability on port 443. I setup the same environment for HTTP service. For now on, when the port 80 is down on one of the servers, the load Balancer will redirect the traffic to the Server which has HTTP available.


Following below the new setup for HTTP server on Blue Ice Load Balancer.

The Azure Load Balancer uses probes in order the check if the service is available. These probes are sent every 5 seconds. Once the probes fail 2 consecutive times, the load balancer will take over the connection to the available server on the Load Balancer Rules.


### Proposed solution

* Actual LB configuration checks whether SmartDataCenter-01 / SmartDataCenter-02
run web server on 80/443 ports.


This is, however, may not be a desired/required scenario.

        Example: SmartDataCenter-01 service is down,
        but the load balancer still redirects the traffic to this VM,
        because the nginx web server is active.


* We suggest, if possible, to configure custom probes, that check availability of 
SmartDataCenter service, namely REST API.

This can be done by checking the HTTPS/API status on the corresponding VMs.
```
curl -I https://dc1.blueicecloud.com/api
HTTP/1.1 200 OK

curl -I https://dc2.blueicecloud.com/api
HTTP/1.1 200 OK
```

If SmartDataCenter-01 is down, and the VM is still online, the output is
```
curl -I https://dc1.blueicecloud.com/api
HTTP/1.1 404 Not Found
```

* This strategy requires dc1 and dc2 to be linked to 10.0.1.15 and 10.0.1.17, respectively.

&nbsp;

&nbsp;

&nbsp;

## MySql cluster
In the actual deployment we run MySQL-01 as the main master data base.
MySQL-02 has a binary log replica enabled, but it will not become a master
in case MySQL-01 server fails or goes offline.


&nbsp;

&nbsp;

&nbsp;


## Kafka cluster private/external network
Kafka cluster is configured to use internal, private notwork **10.0.1.0/24**.
External connections to Kafka cluster are possible via Azure public IP addresses.

Kafka configuration file ```/opt/kafka/config/server.properties``` enables
```
listeners=PLAINTEXT://10.0.1.12:9092
advertised.listeners=PLAINTEXT://52.237.159.149:9092
```

### Proposed solution
this is how we can configure Kafka to use internal ip within the cloud and the external ip/fqn from outside the cloud.


The trick is to use:


 > ```different "protocols" PLAIN and TRACE```

 > ```different ports "9092" and "9093"```

-> corresponding entries have to be set in listener and advertised.listener sections


Trace should be used in production, despite it is even being used in the official documentation.

https://kafka.apache.org/0100/documentation.html


#### Kafka Broker


Two listeners - Protocol: PLAINTEXT / TRACE, Ports: 9092 and 9093


listeners = PLAINTEXT://dcservices:9092,TRACE://10.0.50.116:9093


Two advertised listeners - Protocol PLAINTEXT / TRACE, Ports 9092 and 9093 and different ip/fqn for the two listeners

```
advertised.listeners=PLAINTEXT://dcservices:9092,TRACE://10.0.50.116:9093
```

**Smart Terminal 1 Configuration**
Kafka/ZooKeeper (using Port 9093)

**Smart Terminal 2 Configuration**
Kafka/ZooKeeper (using Port 9092)

Logfile after starting Smart Terminal Smart Terminal 1

IP is being returned

Discovered coordinator 10.0.50.116:9093 (id: 2147483646 rack: null) for group defaultTopicConsumerGroup.

Logfile after starting Smart Terminal Smart Terminal 2

FQN is being returned

Discovered coordinator dcservices:9092 (id: 2147483646 rack: null) for group defaultTopicConsumerGroup.

Here is the link to the internal implementation

https://apache.googlesource.com/kafka/+/refs/heads/trunk/clients/src/main/java/org/apache/kafka/common/protocol/SecurityProtocol.java


&nbsp;

&nbsp;

&nbsp;

## Zookeepr cluster: Odd number of nodes

In order to elect a leader, a quorum should ideally have an odd number of nodes (Otherwise, a node will not be able to win majority and become the leader). In your case, with two nodes, zookeeper will not possibly be able to elect a leader for a long time since both nodes will be candidates and wait for the other node to vote for it. Even though they elect a leader, your ensemble will not work properly in network patitioning situations.