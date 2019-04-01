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

Step 4 :
Do test consul-server is installed successfully
curl $(docker-machine ip consul):8500/v1/catalog/services

Step 5 :
Run the Consul UI URL in the browser and verify UI is getting displayed or not. 
http://192.168.99.100:8500/ui/#/dc1/service

 Note : Run docker-machine ip consul Get the IP address of consul URL 

```
## Step 2 : Create the Docker swaram and configure the swaram with consul key value store

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
