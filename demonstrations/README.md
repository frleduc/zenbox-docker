## INIT
Sur machine locale
```bash
cd 00-Init
## export credentials
export DO_Token=<my_token>
## create consul VM
docker-machine create -d digitalocean \
  --digitalocean-access-token=$DO_Token \
  --digitalocean-size=512mb \
  --digitalocean-region=fra1 \
  demo-keystore
eval $(docker-machine env demo-keystore)
docker run -d -p "8500:8500" -h "consul" \
      progrium/consul -server -bootstrap
## create main VM
docker-machine create -d digitalocean \
  --digitalocean-access-token=$DO_Token \
  --digitalocean-region=fra1 \
  --swarm --swarm-master \
  --swarm-discovery="consul://$(docker-machine ip demo-keystore):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip demo-keystore):8500" \
  --engine-opt="cluster-advertise=eth0:2376" \
  demo-node1
## cloudinit
docker-machine ssh demo-node1 "bash -s" < userdata.sh
## cela prend un peu de temps
docker-machine create -d digitalocean \
  --digitalocean-access-token=$DO_Token \
  --digitalocean-region=fra1 \
  --swarm \
  --swarm-discovery="consul://$(docker-machine ip demo-keystore):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip demo-keystore):8500" \
  --engine-opt="cluster-advertise=eth0:2376" \
  demo-node2
## attendre suffisament
docker-machine ssh demo-node1
cd talk-docker-insight/demonstrations/04-Compose
docker-compose up
### quand OK Ctrl+c
docker-compose stop
docker-compose rm
cd ..
```

## DEMO 1 : Runs and builds

```bash
# pull & run
docker pull busybox
docker run busybox echo "Hello Technicolor"
docker run docker/whalesay cowsay "Hello Technicolor"
cd 01-First-build
cat Dockerfile
docker build -t wgetip .
docker run wgetip
docker run wgetip ipinfo.io/hostname
cd ..
# on lance un tomcat
docker run -d -p 8080:8080 tomcat:7
# allez dedans et regarder
docker exec -ti XX bash
# on vérifie que ça tourne
docker ps
# on l'affiche
curl http://localhost:8080
# et aussi http://<ip VM>:8080
# on stop
docker stop <id>
# il est caché...
docker ps
# ...meuh non
docker ps -a
docker start <id>
```

## DEMO 2 : Dev Stack and Volumes

Le principe est que l'appli est à la fois packagée dans une image Docker et modifiée en local grâce aux volumes

```bash
cd 02-Dev-Env
# check Dockerfile et onbuild
cat Dockerfile
# show original Dockerfile
cat ../XX-Misc/Dockerfile.python-onbuild
docker build -t my-killer-app .
docker run -d -p 80:5000 -e DEV_MODE=true -v $PWD:/usr/src/app my-killer-app
curl localhost/hello/Technicolor
## change the returned message and F5
vi hello-server.py
# re curl...
docker ps
docker rm -f <id>
cd ..
```

## DEMO 3 : Links
```bash
cd O3-Links
vi app.py
docker run -d --name cache redis
docker run -d -p 5000:5000 --link cache:redis --name server ggerbaud/pyredis
curl localhost:5000
docker exec -it server bash
cat /etc/hosts
ping cache
# Ctrl + D
cd ..
```

## DEMO 4 : Compose

Stack Angular servie par Node + Java Spring + cache Redis

```bash
cd 04-Compose
vi docker-compose.yml
# avant plan avec logs (Ctrl+C to quit)
docker-compose up
# arriere plan
#docker-compose -d up
#docker-compose stop
cd ..
```

## DEMO 5 : Swarm

```bash
# in host machine
cd 05-Swarm
eval $(docker-machine env --swarm demo-node1)
# server is swarm
docker version
docker info
docker ps
docker ps -a
# creation d'un network
docker network create --driver overlay zen-net
# mise en place de traefik (NOTA : on le fait hors de swarm pour le mettre sur le bon noeud)
docker $(docker-machine config demo-node1) run \
    -d \
    -p 80:80 -p 8080:8080 \
    --net=zen-net \
    -v /etc/docker/:/ssl \
    traefik \
    -l DEBUG \
    -c /dev/null \
    --docker \
    --docker.domain zenika.com \
    --docker.endpoint tcp://$(docker-machine ip demo-node1):3376 \
    --docker.tls \
    --docker.tls.ca /ssl/ca.pem \
    --docker.tls.cert /ssl/server.pem \
    --docker.tls.key /ssl/server-key.pem \
    --docker.tls.insecureSkipVerify \
    --docker.watch  \
    --web
# on run un ou deux container
docker run -d --net zen-net --label-file labels ggerbaud/hello-hostname
docker ps
# s'y connecter
curl -H Host:demo.zenika.com $(docker-machine ip demo-node1)
# contraintes
# noeud
docker run -d --label-file labels -e constraint:node==<mon ip> ggerbaud/hello-hostname

# s'il y a du temps, petite demo de Docker Machine
docker-machine create -d digitalocean \
  --digitalocean-access-token=$DO_Token \
  --digitalocean-region=fra1 \
  --swarm \
  --swarm-discovery="consul://$(docker-machine ip demo-keystore):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip demo-keystore):8500" \
  --engine-opt="cluster-advertise=eth0:2376" \
  demo-node3
## liste des machines
docker-machine ls --filter name=demo
## config et env
docker-machine config demo-node3
docker-machine env demo-node1
## mode swarm
docker-machine env --swarm demo-node1
## ssh
docker-machine ssh $(docker-machine active)
```
## DEMO BONUS

```bash
cd ..
docker build -t zenika/docker-insight .
docker run -it --name talk-docker-insight -v $(PWD)/Slides:/data/Slides -p 8000:8000 zenika/docker-insight
docker run -it --rm -v $(PWD)/dist/:/data/dist/ -v $(PWD)/Slides:/data/Slides zenika/docker-insight package
```
