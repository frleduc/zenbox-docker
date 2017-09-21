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
docker container run -d -p "8500:8500" -h "consul" \
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
docker image pull busybox
docker container run busybox echo "Hello from Zenika"
docker container run docker/whalesay cowsay "Hello from Zenika"
cd 01-First-build
cat Dockerfile
docker image build -t wgetip .
docker container run wgetip
docker container run wgetip ipinfo.io/hostname
cd ..
# on lance un tomcat
docker container run -d -p 8080:8080 tomcat:7
# on lance un tomcat 8 maintenant ?
docker container run -d -p 8080:8080 tomcat:8
# allez dedans et regarder
docker container exec -ti XX bash
# on vérifie que ça tourne
docker container ls
# on l'affiche
curl http://localhost:8080
# et aussi http://<ip VM>:8080
# on stop
docker container stop <id>
# il est caché...
docker container ls
# ...meuh non
docker container ls -a
docker container start <id>
```

## DEMO 2 : Dev Stack and Volumes

Le principe est que l'appli est à la fois packagée dans une image Docker et modifiée en local grâce aux volumes

```bash
cd 02-Dev-Env
# check Dockerfile et onbuild
cat Dockerfile
# show original Dockerfile
cat ../XX-Misc/Dockerfile.python-onbuild
docker image build -t my-killer-app .
docker container run -d -p 80:5000 -e DEV_MODE=true -v $PWD:/usr/src/app my-killer-app
curl localhost/hello/zenika
## change the returned message and F5
vi hello-server.py
# re curl...
curl localhost/hello/zenika
# remove container
docker container ls
docker container rm -f <id>
cd ..
```

## DEMO 3 : Network
```bash
cd 03-Network
vi app.py
docker image build -t zenika/demo-py-redis .
docker network create -d bridge mybridge
docker network ls
docker container run -d --net mybridge --name redis redis
# attention sur mac docker container run -d --net mybridge --name redis --sysctl=net.core.somaxconn=511 redis
# cf https://github.com/docker-library/redis/issues/35
docker container run -d -p 5000:5000 --net mybridge --name server zenika/demo-py-redis
curl localhost:5000
docker container exec -it server bash
ping redis
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
# ouvrir http://localhost
# arriere plan
docker-compose -d up
docker-compose stop
cd ..
```

## DEMO 5 : Swarm

```bash
export AWS_ACCESS_KEY_ID=AKIAIWG6AAY3WCF6QYCQ
export AWS_SECRET_ACCESS_KEY=X
export AWS_DEFAULT_REGION=eu-west-2
docker-machine create --driver amazonec2 aws01
docker-machine create --driver amazonec2 aws02
eval $(docker-machine env aws01)
# attentio, docker-machine met mal les autorisations réseau sous aws
# => https://gist.github.com/ghoranyi/f2970d6ab2408a8a37dbe8d42af4f0a5
# montrer qu'on pointe sur cette machine (chercher Operating System: Ubuntu 16.04)
docker info
docker node ls
# avoir l'ip de aws1 : 
docker-machine ip aws01
docker swarm init --advertise-addr <ip aws01>
docker node ls
# voir docker info pour montrer Swarm: Active
docker info
# ajoutons un worker
docker swarm join-token worker
# on se connecte à l'autre machine
eval $(docker-machine env aws02)
# on lance la commande obtenu avec le join-token
docker swarm join --token ... --advertise-addr  <ip aws02> 
# tester
docker service create --name ping alpine ping 8.8.8.8
# on scale
docker service ls
docker service update xx --replicas 8
# on peut exposer des ports 
docker service create --name nginx --publish 8080:80 nginx
docker service ps nginx
# on le voit sur un noeud mais 
# on peut y accéder à partir de plusieurs ip => route mesh
cd ../04-Compose
# penser à pusher l'appli compose web pour ne pas avoir ed "build"
docker stack deploy -c docker-compose.yml myfirstswarmlab
```

OLD DEMO
```bash
# in host machine
cd 05-Swarm
eval $(docker-machine env --swarm demo-node1)
# server is swarm
docker version
docker info
docker container ls
docker container ls -a
# creation d'un network
docker network create --driver overlay zen-net
# mise en place de traefik (NOTA : on le fait hors de swarm pour le mettre sur le bon noeud)
docker $(docker-machine config demo-node1) container run \
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
docker container run -d --net zen-net --label-file labels ggerbaud/hello-hostname
docker container ls
# s'y connecter
curl -H Host:demo.zenika.com $(docker-machine ip demo-node1)
# contraintes
# noeud
docker container run -d --label-file labels -e constraint:node==<mon ip> ggerbaud/hello-hostname

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
docker image build -t zenika/docker-insight .
docker container run -it --name talk-docker-insight -v $(PWD)/Slides:/data/Slides -p 8000:8000 zenika/docker-insight
docker container run -it --rm -v $(PWD)/dist/:/data/dist/ -v $(PWD)/Slides:/data/Slides zenika/docker-insight package
```
