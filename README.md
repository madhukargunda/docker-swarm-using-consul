# docker-swarm-cluster-using-consul

In this article i am going to discuss about the what is the docker swarm and how to configure Hashi corp consul
with docker swarm

## Objective

```
1.What is Docker Swarm
2.Swaram Scheduling Stratagies
3.What is Consul Discovery
3.How to Configure Consul with Docker Swarm

```


## What is Docker Swarm

Docker Swarm is a group of different docker demaons running in differnt hosts group them into one . 
Its a Load balancing tool which provides the clustering and scheduling of the containers in different nodes.
Docker swarm automates manual tasks like 
 ```
 health check of the container.
 ensure all containers are up and running
 scale up and down the container depending on the load 
 adding and updating the containers
 ```

Docker swarm is a automated administrator when ever any of the nodes fails it re schedules the containers/work load 
all the availbale nodes.Docker Swarm is natively implememted load balancer.In the docker swarm administrator gives the instructions to swarm manager which internally talks to the nodes which are in the docker cluster.Once the docker swarm created we no longer to worry about the distributing the work load into different machines , Docker swarm will take cares about all these.Docker Swarm contains the Manager Node and Group of Worker Nodes each Worker node connected to Manager Node.



![docker-swarm-docker-native-clustering-5-638](https://user-images.githubusercontent.com/5623861/55332845-bfd35000-54c8-11e9-9c7b-b589d24de256.jpg)
 	
## Swarm Scheduling Stratagies

Docker Swaram uses the different scheduling stratagies where to distribute the load 

```
a.Spread
b.binpack
c.random
```

## Spread :

a.This is the default Strategies in docker swarm cluster.
b.In this stratagy docker swaram distributes the load evenly in all available Worker Nodes.
c.If we have three nodes swarm cluster ,Docker swarm distribute the one containers in each node.

## binpack :

a.In this stratagy docker swaram distribute the load on the node which is most packed with many container until that node can not run any containers.

## random :

a.In this stratagy docker swaram distibute the load randomly on the different nodes.

We can choose the stratagy by specifying the --strategy flag while swaram creation.

## What is Consul Discovery

Docker swaram internally contains the key value store which is used to store the list of ip adress of the nodes which are in the swaram cluster. We have thire party tools which provides the distributed key value stores and service discovery.
Hashicorp consul is the one of the tool we can configure with the docker swarm



## How to setup Docker Swarm Cluster using Consul.


## Step1 : Create Consul Discovery Service
```
Step 1 :
Create Docker Machine for consul server
docker-machine create -d virtualbox consul

Step 2 :
eval $(docker-machine env consul)

Stpe 3:
Run the consul server in newly created docker machine
docker run -d -p 8500:8500 -h consul --restart always gliderlabs/consul-server -bootstrap

Note : Run the following command docker ps -a to verify the consul-server is running or not
```
<img width="1657" alt="Consul-Server-Running" src="https://user-images.githubusercontent.com/5623861/55341625-94a52c80-54d9-11e9-81e3-25818bd250bb.png">

```
Step 4 :
Do test consul-server is installed successfully
curl $(docker-machine ip consul):8500/v1/catalog/services

Step 5 :
Run the Consul UI URL in the browser and verify UI is getting displayed or not. 
http://192.168.99.100:8500/ui/#/dc1/service

 Note : Run docker-machine ip consul Get the IP address of consul URL 
```
![consul-ui](https://user-images.githubusercontent.com/5623861/55341221-d41f4900-54d8-11e9-8e32-7d389d4e0d2c.jpeg)


## Step 2 : Create the Docker swarm and configure the swaram with consul key value store

```
Create the docker swarm manager with three node cluster and assign label to each node
and configure the by swarm discovery value with consul URL

Step1 : Create the swarm manager and configure the swarm discovery with consul Ip and Port

docker-machine create \
    -d virtualbox \
    --swarm \
    --swarm-master \
    --swarm-discovery="consul://$(docker-machine ip consul):8500"\
    --engine-opt="cluster-store=consul://$(docker-machine ip consul):8500" \
    --engine-opt="cluster-advertise=eth1:2376" \
    manager

Step 2:

Create worker-1 node 

docker-machine create \
	-d virtualbox \
    --swarm \
    --swarm-discovery="consul://$(docker-machine ip consul):8500"\
    --engine-opt="cluster-store=consul://$(docker-machine ip consul):8500" \
    --engine-opt="cluster-advertise=eth1:2376" \
    --engine-label host=worker-1 \
    worker-1

 Step 3 :

 Create worker-2 node

 docker-machine create \
	-d virtualbox \
    --swarm \
    --swarm-discovery="consul://$(docker-machine ip consul):8500"\
    --engine-opt="cluster-store=consul://$(docker-machine ip consul):8500" \
    --engine-opt="cluster-advertise=eth1:2376" \
    --engine-label host=worker-2 \
    worker-2

  Step 4 :

  Create the worker-3 node

  docker-machine create \
	-d virtualbox \
    --swarm \
    --swarm-discovery="consul://$(docker-machine ip consul):8500"\
    --engine-opt="cluster-store=consul://$(docker-machine ip consul):8500" \
    --engine-opt="cluster-advertise=eth1:2376" \
    --engine-label host=worker-3 \
    worker-3
    
 ```
 In the above commands
 --swarm-discovery defines address of the discovery service
 --cluster-advertise advertise the machine on the network
 --cluster-store designate a distributed k/v storage backend for the cluster
 
 ```
 Step 5 : 
 
 execute the below docker command to connect to the manager node
 eval $(docker-machine env --swarm manager)

Step 6 : run the below compose file in manager node "docker-compose up -d" ,This command pulls the images and 
run the container .Docker swaram manager will take care of the distrbuting the services in different nodes

version: '3.3'

services:
  customer-service:
    image: madhukargunda/customer-service:1.0
    ports: 
      - 8080:8080

  account-service:
    image: madhukargunda/account-service:1.0
    ports: 
      - 8081:8081

Ste 7: 
Connect to this newly created master and find some information about it:
eval "$(docker-machine env swarm-master)"
docker info

Containers: 7
 Running: 7
 Paused: 0
 Stopped: 0
Images: 12
Server Version: swarm/1.2.9
Role: primary
Strategy: spread
Filters: health, port, containerslots, dependency, affinity, constraint, whitelist
Nodes: 4

 manager: xxx.xxx.xx.xxx:xxxx
  └ ID: ZC6I:F66E:UMIS:42Z2:QGNR:XJ25:T65I:RRLO:QE34:V72M:AMZB:B52C|xxx.xxx.xx.xxx:xxxx
  └ Status: Healthy
  └ Containers: 2 (2 Running, 0 Paused, 0 Stopped)
  └ Reserved CPUs: 0 / 1
  └ Reserved Memory: 0 B / 1.014 GiB
  └ Labels: kernelversion=4.14.104-boot2docker, operatingsystem=Boot2Docker 18.09.3 (TCL 8.2.1), ostype=linux, provider=virtualbox, storagedriver=overlay2
  └ UpdatedAt: 2019-04-07T16:00:12Z
  └ ServerVersion: 18.09.3
 worker-1: 192.168.99.102:2376
  └ ID: 5RTO:2MVI:XWD7:3LRJ:IXZ3:ZUGX:HR6U:VZ5X:4NAA:XOUO:YNKH:G5CA|xxx.xxx.xx.xxx:xxxx
  └ Status: Healthy
  └ Containers: 1 (1 Running, 0 Paused, 0 Stopped)
  └ Reserved CPUs: 0 / 1
  └ Reserved Memory: 0 B / 1.014 GiB
  └ Labels: host=worker-1, kernelversion=4.14.104-boot2docker, operatingsystem=Boot2Docker 18.09.3 (TCL 8.2.1), ostype=linux, provider=virtualbox, storagedriver=overlay2
  └ UpdatedAt: 2019-04-07T16:00:22Z
  └ ServerVersion: 18.09.3
 worker-2: 192.168.99.103:2376
  └ ID: BXEE:3NXX:3A2B:TDBP:YLGB:RP2I:5O4S:HPZH:AJI6:6EIC:GYHR:44I3|xxx.xxx.xx.xxx:xxxx
  └ Status: Healthy
  └ Containers: 2 (2 Running, 0 Paused, 0 Stopped)
  └ Reserved CPUs: 0 / 1
  └ Reserved Memory: 0 B / 1.014 GiB
  └ Labels: host=worker-2, kernelversion=4.14.104-boot2docker, operatingsystem=Boot2Docker 18.09.3 (TCL 8.2.1), ostype=linux, provider=virtualbox, storagedriver=overlay2
  └ UpdatedAt: 2019-04-07T15:59:56Z
  └ ServerVersion: 18.09.3
  └ Status: Healthy
  └ Containers: 2 (2 Running, 0 Paused, 0 Stopped)
  └ Reserved CPUs: 0 / 1
  └ Reserved Memory: 0 B / 1.014 GiB
  └ Labels: host=worker-3, kernelversion=4.14.104-boot2docker, operatingsystem=Boot2Docker 18.09.3 (TCL 8.2.1), ostype=linux, provider=virtualbox, storagedriver=overlay2
  └ UpdatedAt: 2019-04-07T16:00:24Z
  └ ServerVersion: 18.09.3


We can see the number of list of nodes in the cluster and number of containers running in each node.

Step 8 : 

Run the command to know about the more information about containers
docker ps 
docker ps -a 

madhu@Admins-MacBook-Pro:~/dockerfiles/docker-swarm-consul$ docker ps
CONTAINER ID        IMAGE                                COMMAND                  CREATED             STATUS              PORTS                                     NAMES
0b63f0da1bb7        madhukargunda/customer-service:1.0   "java -jar customer-…"   7 minutes ago       Up 3 minutes        3333/tcp, xxx.xxx.xx.xxx:8080->8080/tcp   worker-2/docker-swarm-consul_customer-service_1
3246045f3036        madhukargunda/account-service:1.0    "java -jar account-s…"   7 minutes ago       Up 3 minutes        2222/tcp, xxx.xxx.xx.xxx:8081->8081/tcp   worker-3/docker-swarm-consul_account-service_1
madhu@Admins-MacBook-Pro:~/dockerfiles/docker-swarm-consul$ 

Step 9 : 

Run the below command to scale the containers

docker-compose scale account-service=4
docker-compose scale customer-service=4

docker swarm distributing the containers in different nodes based on the stratagy we specified.

madhu@Admins-MacBook-Pro:~/dockerfiles/docker-swarm-consul$ docker ps
CONTAINER ID        IMAGE                                COMMAND                  CREATED             STATUS              PORTS                                     NAMES
26a2f4eb6b6e        madhukargunda/customer-service:1.0   "java -jar customer-…"   12 minutes ago      Up 2 minutes        3333/tcp, xxx.xxx.xx.xxx:xxxx->8080/tcp   worker-2/docker-swarm-consul_customer-service_2
6dd4323604b5        madhukargunda/customer-service:1.0   "java -jar customer-…"   12 minutes ago      Up 2 minutes        3333/tcp, xxx.xxx.xx.xxx:xxxx->8080/tcp   manager/docker-swarm-consul_customer-service_3
90638eacd5be        madhukargunda/customer-service:1.0   "java -jar customer-…"   12 minutes ago      Up 2 minutes        3333/tcp, xxx.xxx.xx.xxx:xxxx->8080/tcp   worker-1/docker-swarm-consul_customer-service_4
5206e74f7de6        madhukargunda/account-service:1.0    "java -jar account-s…"   16 minutes ago      Up 7 minutes        2222/tcp, xxx.xxx.xx.xxx:xxxx->8081/tcp   worker-2/docker-swarm-consul_account-service_2
68b0d287ba02        madhukargunda/account-service:1.0    "java -jar account-s…"   16 minutes ago      Up 7 minutes        2222/tcp, xxx.xxx.xx.xxx:xxxx->8081/tcp   worker-3/docker-swarm-consul_account-service_4
ff8dfee06fb5        madhukargunda/account-service:1.0    "java -jar account-s…"   16 minutes ago      Up 7 minutes        2222/tcp, xxx.xxx.xx.xxx:xxxx->8081/tcp   manager/docker-swarm-consul_account-service_3
8bd6823e611b        madhukargunda/customer-service:1.0   "java -jar customer-…"   28 minutes ago      Up 19 minutes       3333/tcp, xxx.xxx.xx.xxx:xxxx->8080/tcp   worker-3/docker-swarm-consul_customer-service_1
9a8d6091e2e2        madhukargunda/account-service:1.0    "java -jar account-s…"   28 minutes ago      Up 19 minutes       2222/tcp, xxx.xxx.xx.xxx:xxxx->8081/tcp   worker-1/docker-swarm-consul_account-service_1


Step 10 : Run the docker info command get the number of containers running all the nodes
```
### Configuring the Registrator

I have created a shell script which connects to the all the nodes and install the registrator container

hosts=(swarm-master load-balancer app-server-1 app-server-2 database)

```
for host in ${hosts[@]}; do
        eval $(docker-machine env ${host})
  docker run -d \
    --name=registrator \
    -h $(docker-machine ip ${host}) \
    -v=/var/run/docker.sock:/tmp/docker.sock \
    gliderlabs/registrator \
    consul://$(docker-machine ip consul):8500
done
```
 
 
