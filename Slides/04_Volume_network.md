# Volume & Network

![](ressources/docker-turtles-communication.jpg)

Notes :
- Un conteneur est volatile
- Une fois détruit, les données écrites dedans sont perdues



## Volume

Expose un sous ensemble du filesystem de l'hôte dans un conteneur

<center>⟺</center>

<!-- .element class="align-right" -->
Expose le file system d'un conteneur dans l'hôte

<br/>
⚠ Celui qui écrit le fichier est responsable des droits

<br/>
Utilisation:

- péréniser les données d'une base de données
- pousser une application dans un conteneur
- récupérer les logs d'une application s'exécutant dans un conteneur



# Demo time

![](ressources/fingers-crossed.png)



## Network

<br/>
Permet de créer un réseau multi-hôtes.

<br/>
Offre une isolation pour les containers

<br/>
Par défault, Bridge sur l'hôte, mais mécanisme de plugins

<br/>
<!-- .element class="align-right" -->
> Les piles sont fournies mais changeables



## Besoin


![](ressources/links.png)



# Demo time

![](ressources/fingers-crossed.png)
