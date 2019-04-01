# docker-swarm-cluster-using-hashicorp-consul

In this article i am going to discuss about the what is the docker swarm and how to configure Hashi corp consul
with docker swarm

## Objective

```
1.What is Docker Swarm
2.How to Configure Consul with Docker Swarm

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
 	

## How to configure Doccker Swarm with Consul


## Step1 : 

