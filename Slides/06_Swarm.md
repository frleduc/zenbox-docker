# docker swarm

<figure style="position: absolute; bottom: 50px; right: 300px">
    <img src="ressources/logo_swarm.png" alt="Logo Docker" />
</figure>



## Principes

Gère des clusters d'hôte docker

Basé sur l'API de docker (compatible avec compose)

  1. ouvrir le daemon docker sur TCP
  2. configurer TLS
  3. 1 manager
  4. x nodes

<br/>
La création / répartition des conteneur est à la charge de swarm

Aléatoire / Répartition de charge / Contraintes



## Pour aller plus loin

Très haute disponibilité / Service discovery

- Consul: https://www.consul.io/
- Zookeeper: https://zookeeper.apache.org/
- Etcd: https://coreos.com/etcd/

<br/>
Reverse proxy pour avoir un seul point d'entrée

![](ressources/traefik.logo.svg)
<center>https://traefik.io</center>



# Demo time

![](ressources/fingers-crossed.png)


