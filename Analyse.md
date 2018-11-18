# Projet R Shiny
Equipe:
- Mahery RAZAFINIAINA  
- Romain LECAT 

Problématique: __Peut-on optimiser sa conduite en analysant les données télémétriques de sa voiture ?__

---
## 1. Introduction
#### 1.1 Contexte
Dans un contexte de hausse des prix du carburant, ainsi que la place importante de la question écologique dans le débat public, nous avons décidé prendre la question de la consommation de caburant comme sujet pour ce projet de statistiques et visualisation des données.
#### 1.2 Provenance des données
Afin de pouvoir analyser la consommation de carburant sur un véhicule non éléctrique, nous avons décidé de relever les données provenant de l'ECU [^1] d'une voiture essence.

Pour se faire, nous avons installé un module de récolte de données sur le port OBD2 [^2] d'un Citroën C4 datant de 2014. Le véhicule est une voiture essence équipée du moteur 1.2L PureTech 130 d'une puissance de 130 chevaux, ce moteur équipe toutes les voiture milieu de gamme du groupe PSA.

![alt](http://www.planete-citroen.com/forum/album/galleries/photo/FLeM.jpg "Voiture utilisée pour relever les données")

La voiture consomme comme carburant de l'E10 [^3], son moteur dispose d'une boite de vitesse manuelle à 6 rapports. La voiture dipose aussi du système Stop & Start [^4].

Les données sont prélevées en temps réel lors des trajets quotidiens du conducteur grâce au module installé sur la voiture. Ce module récupérant les données directement depuis l'ECU[^1], les données ne sont pratiquement pas altérées.

---
## 2. Présentation du jeu de données
Le jeu de données se présente sous la forme d'un fichier au format CSV comportant au total 77 colonnes chacunes correspondant aux données d'un capteur ou du moteur. Parmi toutes ces différentes variables, il y un certain nombre de variable redondantes qui par exemple portent sur le même aspect mais exprimé dans une unité différentes. Pour des questions de simplicité, nous n'utiliserons pas pas toutes les variables en prennant soin d'enlever les redondances.

Voici une description de l'ensemble des variables qui seront analysées:
* __Temps__: Date d'enregistrement des données à la miliseconde près
* __Régime moteur__: nombre de rotation du moteur exprimé en tour par minute (tr/min)
* __Consommation__: Débit de carburant instantané injecté dans le moteur exprimé en cc/min
* __Position de la pédal d'accélérateur__: Position de la pédale d'accélérateur exprimé en pourcentage basé sur l'enfoncement de la pédale
* __Vitesse__: Vitesse instantané du véhicule exprimé en km/h
* __Style de conduite__: classification du type de conduite interprété par l'ECU[^1]
* __Longitude__: longitude enregistrée par le gps du véhicule
* __Latitude__: latitude enregistrée par le gps du véhicule
* __Charge moteur__: Pourcentage de solicitation en fonction du régime maximal théorique exprimé en pourcentage
* __Altitude__: Altitude enregistrée par le gps du véhicule exprimé en mètre
* __Pression de l'air en entrée__: Pression de l'air au niveau du collecteur d'admission du moteur exprimé en PSI
* __Température de l'air en entrée__: Température de l'air en entrée des conduites d'air exprimée en °C
* __Puissance du moteur__: Puissance instantanée délivrée par le moteur exprimée en KW
* __Température du liquide de refroidissement__: Température du liquide de refroidissement dans le radiateur exprimée en °C
* __Position de l'accélérateur au collecteur d'admission__: Position de l'accélérateur au niveau du collecteur d'admission exprimée en pourcentage
 ---
## 3. Analyse des données
### 3.1 Hypothèses de base
Nous allons partir du principe que pour réaliser cette analyse, nous disposons des Hypothèses en mecanique suivants:
* Lorsque le moteur est en marche au régime minimal, le moteur consomme tout de même du carburant
* Pour fonctionner le moteur consomme le carburant du reservoir avec l'air extérieur
* Appuyer sur l'accélérateur permet d'augmenter la vitesse de rotation du moteur (le régime)
* Appuyer sur l'accélérateur augmente la consommation de carburant
* Le frein moteur (engager une vitesse sans appuyer sur l'accélérateur) permet en plus de ralentir le véhicule, d'économiser du carburant

L'ensemble de ces Hypothèses bien que non exhaustifs, sont enseigné lors de l'apprentissage à la conduite. Nous parlons d'hypothèses car le but de notre analyse sera de les vérifier dans l'objectif d'optimiser notre conduite et de réduire notre consommation de carburant.

Du fait que le véhicule ne dispose pas de capteur de C02 rejeté en sortie des echappements, nous n'analyserons pas l'aspect emission de la conduite.

### 3.2 L'utilisation de l'accélérateur
Afin de pouvoir mettre en place une conduite plus économique, le premier aspect à vérifier est de regarder comment fonctionne l'accélérateur. En effet, d'après nos hypothèses, appuyer sur l'accélérateur influe directement sur la consommation.

Regardons la relation qu'a la variable, position de la pédal d'accélérateur avec les autres variables.
Pour ce faire, nous allons utiliser l'onglet "Analyse Bivariée" qui nous permet de comparer deux variables.
Commençons par comparer la position de la pédale d'accélérateuret la consommation 

![alt text](https://raw.githubusercontent.com/nicomahery/ShinyCarLogs/master/images/Capture1.PNG "Données comparatives")

On remarque en premier lieu un coefficient de corrélation au dessus de 0.5.
Mais avec un coefficient de corrélation en dessous de 0.75, on ne peut pas affirmer que la corrélation est absolue entre le fait d'appuyer sur l'accélérateur et la consommation du véhicule.

Cela signifie que la consommation du véhicule peut être provoqué par autre chose.
Afin d'aller un peu plus loin il est nécessaire de regarder comment fonctionne l'accélérateur d'une voiture qui permet d'injecter plus ou moins de carburant dans le système de conbustion.
Nous allons maintenant regarder comment réagit la position de l'accélérateur au niveau de l'admission 


[^1]: ECU: Engine Control Unit, ordinateur qui gère l'ensemble du moteur (capteurs et actionneurs)
[^2]: OBD2: Protocole du matériel permettant le diagnostique électronique sur les véhicules à partir des années 2000
[^3]: E10: anciennement SP95-E10 (sans plomb 95 contenant environ 10 % d'agroéthanol)
[^4]: Stop & Start: dispositif d'arrêt et de redémarrage automatique du moteur d'un véhicule afin d'économiser le carburant et réduire la pollution essentiellement dans les embouteillages et aux feux rouges.