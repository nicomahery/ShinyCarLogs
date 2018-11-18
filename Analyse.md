# Projet R Shiny
Equipe:
- Mahery RAZAFINIAINA  
- Romain LECAT 

Problématique: __Peut-on optimiser sa conduite en analysant les données télémétriques de sa voiture ?__


## 1. Introduction
#### 1.1 Contexte
Dans un contexte de hausse des prix du carburant, ainsi que la place importante de la question écologique dans le débat public, nous avons décidé prendre la question de la consommation de caburant comme sujet pour ce projet de statistiques et visualisation des données.
#### 1.2 Provenance des données
Afin de pouvoir analyser la consommation de carburant sur un véhicule non éléctrique, nous avons décidé de relever les données provenant de l'ECU [^1] d'une voiture essence.

Pour se faire, nous avons installé un module de récolte de données sur le port OBD2 [^2] d'un Citroën C4 datant de 2014. Le véhicule est une voiture essence équipée du moteur 1.2L PureTech 130 d'une puissance de 130 chevaux, ce moteur équipe toutes les voiture milieu de gamme du groupe PSA.

![alt](http://www.planete-citroen.com/forum/album/galleries/photo/FLeM.jpg "Voiture utilisée pour relever les données")

La voiture consomme comme carburant de l'E10 [^3], son moteur dispose d'une boite de vitesse manuelle à 6 rapports. La voiture dipose aussi du système Stop & Start [^4].

Les données sont prélevées en temps réel lors des trajets quotidiens du conducteur grâce au module installé sur la voiture. Ce module récupérant les données directement depuis l'ECU[^1], les données ne sont pratiquement pas altérées.

## 2. Présentation du jeu de données
Le jeu de données se présente sous la forme d'un fichier au format CSV comportant au total 77 colonnes chacunes correspondant aux données d'un capteur ou du moteur. Parmi toutes ces différentes variables, il y un certain nombre de variable redondantes qui par exemple portent sur le même aspect mais exprimé dans une unité différentes. Pour des questions de simplicité, nous n'utiliserons pas pas toutes les variables en prennant soin d'enlever les redondances.

[^1]: ECU: Engine Control Unit, ordinateur qui gère l'ensemble du moteur (capteurs et actionneurs)
[^2]: OBD2: Protocole du matériel permettant le diagnostique électronique sur les véhicules à partir des années 2000
[^3]: E10: anciennement SP95-E10 (sans plomb 95 contenant environ 10 % d'agroéthanol)
[^4]: Stop & Start: dispositif d'arrêt et de redémarrage automatique du moteur d'un véhicule afin d'économiser le carburant et réduire la pollution essentiellement dans les embouteillages et aux feux rouges.