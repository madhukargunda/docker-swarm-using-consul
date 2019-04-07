hosts=(manager worker-1 worker-2 worker-3)

for host in ${hosts[@]}; do
        eval $(docker-machine env ${host})
  docker run -d \
    --name=registrator \
    -h $(docker-machine ip ${host}) \
    -v=/var/run/docker.sock:/tmp/docker.sock \
    gliderlabs/registrator \
    consul://$(docker-machine ip consul):8500
done
