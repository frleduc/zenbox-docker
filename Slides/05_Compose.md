# écosystème Docker

<figure style="position: absolute; bottom: 10px; right: 200px">
    <img src="ressources/ecosystem.jpg" alt="Logo Docker" width="650" />
</figure>

Notes :
L'ensemble des outils ci après sont OSS et gratuits



# docker compose

<figure style="position: absolute; bottom: 50px; right: 400px">
    <img src="ressources/logo_compose.png" alt="Logo Docker" width="460" />
</figure>



## Cas d'utilisation

Permet de démarrer plusieurs conteneurs simultanément

<br/>
Idéal pour le développement

<br/>
Fichier de configuration yaml simple

<br/>
Image, liens, volumes, # instances

<br/>
Contrôle un ensemble cohérent de conteneurs



## docker-compose.yml

```
version: "3"
services:
  web:
    build: .
    ports:
     - "5000:5000"
    volumes:
     - .:/code
  redis:
    image: redis
```



# Demo time

![](ressources/fingers-crossed.png)



# docker registry

<figure style="position: absolute; bottom: 200px; right: 200px">
    <img src="ressources/docker-registry.png" alt="Docker Registry" width="800" />
</figure>




# docker machine

<figure style="position: absolute; bottom: 50px; right: 400px">
    <img src="ressources/logo-machine.png" alt="Logo Docker" width="460" />
</figure>



# docker machine

- Cas d'utilisation
  - Pour utiliser Docker facilement sous Mac et Windows
  - Pour installer Docker sur des machines distantes (des "machines") : Google, AWS...

<figure style="position: absolute; bottom: 50px; right: 150px">
    <img src="https://docs.docker.com/engine/installation/images/linux_docker_host.svg" alt="Logo Docker" />
</figure>

<figure style="position: absolute; bottom: 50px; right: 600px">
    <img src="https://docs.docker.com/engine/installation/images/win_docker_host.svg" alt="Logo Docker" />
</figure>



# docker kitematic

<br/><br/><br/><br/><br/>
GUI de gestion pour Mac et Windows

<figure style="position: absolute; bottom: 150px; right: 250px">
    <img src="https://pbs.twimg.com/profile_images/505211933666975745/ZyasF8Em_400x400.png" alt="Logo Docker" width="350" />
</figure>
<figure style="position: absolute; bottom: 150px; left: 250px">
    <img src="ressources/product_kitematic.png" alt="Logo Docker" width="350" />
</figure>



## kitematic, gui for docker #1

![](ressources/kitematic-browse-images.png)



## kitematic, gui for docker #2

![](ressources/kitematic-cli-redis-container.png)



## kitematic, gui for docker #3

![](ressources/kitematic-volumes-dir.png)



# docker toolbox

<br/><br/><br/><br/><br/>
Pour Mac et Windows. Inclut Docker, Compose, Machine, Kitematic.

<figure style="position: absolute; bottom: 150px; right: 350px">
    <img src="https://www.docker.com/sites/default/files/products/tbox.jpg" alt="Logo Docker" />
</figure>
