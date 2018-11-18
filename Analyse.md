# Projet R Shiny
Equipe:
- Mahery RAZAFINIAINA  
- Romain LECAT 

Code disponible à [ici](https://github.com/nicomahery/ShinyCarLogs "GitHub").

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

##### 3.2.1 Position de la pédale d'accélérateur et consommation
Commençons par comparer la position de la pédale d'accélérateur et la consommation 

![alt text](https://raw.githubusercontent.com/nicomahery/ShinyCarLogs/master/images/Capture1.PNG "Données comparatives entre la consommation et la position de la pédale d'accélérateur")

On remarque en premier lieu un coefficient de corrélation au dessus de 0.5.
Mais avec un coefficient de corrélation en dessous de 0.75, on ne peut pas affirmer que la corrélation est absolue entre le fait d'appuyer sur l'accélérateur et la consommation du véhicule.

Cela signifie que la consommation du véhicule peut être provoqué par autre chose.
Afin d'aller un peu plus loin il est nécessaire de regarder comment fonctionne l'accélérateur d'une voiture qui permet d'injecter plus ou moins de carburant dans le système de conbustion.

##### 3.2.2 Position de l'accélérateur au collecteur d'admission et consommation
Nous allons maintenant regarder comment réagit la position de l'accélérateur au niveau de l'admission 

![Image2](https://raw.githubusercontent.com/nicomahery/ShinyCarLogs/master/images/Capture2.PNG "Données comparatives entre la consommation et la position de la pédale d'accélérateur")

Cependant, il semblerait que la correlation soit légèrement supérieur dans ce cas de figure. Cependant cette dernière reste en dessous de 0.75.

Le plus étonnant est que cette variable de position de l'accélérateur au niveau de l'admission est censée être la valeur absolu concernant l'accélérateur. En effet c'est à partir de cette commande et pas forcement de la pédale que le débit en carburant et contrôlé.


##### 3.2.3 Position de la pédal d'accélérateur et position de la l'accélérateur au collecteur d'admission
Pour s'assurer de connaitre le rôle de la pédal dans la commande du débit de carburant nous devons comparer la position de la pédale d'accélérateur avec la position de l'accélérateur au niveau de l'admission.

![Image3](https://raw.githubusercontent.com/nicomahery/ShinyCarLogs/master/images/Capture3.PNG "Données comparatives entre les positions des accélérateurs")

Avec un coefficient de corrélation de 0.57, nous ne pouvons pas conclure que la commande de l'accélérateur du moteur (au niveau du collecteur d'admission) est exclusivement commandée par la pédale d'accélérateur. Cela signifie qu'il y a un autre système qui contrôle le débit de carburant dans le moteur.

__Conclusion sur l'accélérateur__: Nous pouvons conclure partiellement que la façon d'appuyer sur la pédal d'accélérateur influence la consommation de carburant. La pédale n'est pas le seul dispositif de la voiture à pouvoir commander le débit de carburant contrairement à ce que beaucoup de personnes pensent. Il nous est nécessaire de comprendre la relation entre la consommation instantané et d'autres variables afin de connaitre les autres facteurs qui influencent la consommation.

__Pourquoi la pédale n'influence pas plus l'accélérateur__: Le fait que l'on se retrouve avec un coefficient de correlation de 0.57 lorsque l'on compare la position de la pédale d'accélérateur avec le position de l'accélérateur au niveau du collecteur d'admission peux s'expliquer par le fait que l'ECU[^1] régule automatique le régime du moteur lorsque l'on actionne l'embrayage pour éviter de faire caler le moteur. En effet sur les voitures récentes, l'ECU est capable de compenser le transfert d'énergie de l'embrayage en augmentatant l'accélérateur sans que le conducteur ne le remarque. Autre chose, l'ECU[^1] s'assure aussi que le mélange entre le carburant et l'O2 de l'air soit optimal. Pour se faire il module légèrement le débit de carburant en fonction de la quantité d'O2 dans l'air. C'est pour cela qu'à haute altitude, les voitures consomment plus (du fait des tests en région parisienne, cet aspect ne peut être testé). 

### 3.3 Ce qui influence la consommation

##### 3.3.1 Consommation et vitesse

Il est connu que plus on roule vite, plus on consomme. Nous allons vérifier cette théorie via les données du véhicule.

![Image8](https://raw.githubusercontent.com/nicomahery/ShinyCarLogs/master/images/Capture8.PNG "Données comparatives entre la consommation et la vitesse")

Avec un coefficient de correlation à 0.5, on constate que la vitesse a une influence sur la consommation du véhicule. Cette influence est moindre que celle de l'accélérateur.

En regardant les autres variables tout en les comparant avec la consommation, nous n'arrivons pas à trouver des variables qui disposent de corrélation satifaisante avec la consommation instantanée du moteur.

##### 3.3.2 Consommation et pression de l'air
La seul variable qui arrive à sortir du lot est la pression de l'air en entrée.

![Image4](https://raw.githubusercontent.com/nicomahery/ShinyCarLogs/master/images/Capture4.PNG "Données comparatives entre la consommation et la pression de l'air")

On constate qu'avec un coefficient de corrélation à 0.40, la pression de l'air semble influencer légèrement la consommation du véhicule.
En regardant plus en détails la variation de la pression de l'air grâce à ce graphique

![Image5](https://raw.githubusercontent.com/nicomahery/ShinyCarLogs/master/images/Capture5.PNG "Données sur la pression de l'air")

On constate que cette dernière varient beaucoup dans le temps, cela peut se comprendre du fait que le véhicule circule à des vitesse différentes avec l'air en plein face ou avec un véhicule devant, ce qui aura pour effet de réduire le pression de l'air en entrée.

##### 3.3.3 Consommation et régime moteur
Lorsque l'on compare le régime moteur avec la consommation, on se rend compte que ces deux variables sont très légèrement anti-corrélées.

![Image6](https://raw.githubusercontent.com/nicomahery/ShinyCarLogs/master/images/Capture6.PNG "Données sur le régime moteur et la consommation")

Contrairement à ce qu'on pourrait attendre, du fait que conduire en sous-régime ou sur-régime est censé augmenter la consommation, de manière étonnante, le régime moteur influence que très peu la consommation

##### 3.3.4 L'influence du style de conduite 
Parmis l'ensemble des variables disponibles dans le jeu de données, on a à notre disposition une variable qualitative dénommée "Style de conduite".
Cette dernière est directement générée par l'ECU[^1] afin de pouvoir caractériser le type de conduite en cours. 
Il existe troix styles de conduites:
* Idle Driving: Lorsque le véhicule est à l'arrêt ou à très faible vitesse (inférieur à 5 km/h)
* City Driving: Lorsque le véhicule roule entre 5 km/h et 90 km/h, caractérise une conduite plus urbaine
* Highway Driving: Lorsque le véhicule roule au dessus de 90 km/h, caractérise une conduite sur autoroute
* Nan: Style de conduite inconnu (erreur de ordinateur ou manque de données sur la conduite)
 
En utilisant l'onglet d'analyse Univariée, nous alors regarder l'influence du style de conduite sur la consommation de carburant.

![Image7](https://raw.githubusercontent.com/nicomahery/ShinyCarLogs/master/images/Capture7.PNG "Données la consommation en fonction du style de conduite")


La première chose que l'on remarque est le fait que pour le style Idle Driving, la consommation est généralement assez basse. Cela peut s'expliquer du fait qu'un véhicule en arrêt moteur allumé consomme le stricte minimum.
Dans un second temps la consommation de type ville dispose d'une répartition sur presque toutes les plages de consommation, signifiant que ce style de conduite dispose d'une consommation équilibrée qui tend légèrement dans la fourchette basse de consommation.
Concernant la conduite sur autoroute, on constate que cette dernière est celle qui consomme le plus. En effet la plupart des consommations pour ce style de conduite sont situés au dessus de 150 cc/min.
---
## 4. Conclusion

En conclusion on constate que la consommation du véhicule est grandement influencée par quatre variables:
* La position de la pédale d'accélérateur
* La position de l'accélérateur au niveau du collecteur d'admission
* La vitesse du véhicule
* Le style de conduite

Une conduite sur autoroute favorisera une vitesse plus élévé ainsi que d'appuyer plus sur la pédale d'accélérateur plus longtemps et de de manière constante afin de concervé la vitesse du véhicule. Cette combinaison amène à un plus grande consommation du véhicule.
Cependant il faut relativiser cette consommation, en effet dans ce cas de figure, les distances parcourues sont plus grandes pour le même laspse de temps comparée à une conduite en ville.

Pour optimiser sa conduite, appuyer en moyenne moins sur l'accélérateur permet de baisser la consommation surtout en ville du fait des arrêts fréquents du milieu urbain (Stop, Feux rouges, intersections). L'utilisation de l'accélérateur au stricte minimum est nécessaire, pour les voitures à embrayage manuel solliciter d'avantage l'embrayage permet de faire un gain conséquent en terme de consommation (du fait du manque de corrélation entre le régime moteur et la consommation). L'utilisation plus fréquente du sous-régime serait une solution.

L'utilisation plus souple de l'accélérateur nécessite d'avoir une conduite très basée sur l'anticipation afin d'éviter tout arrêt puis rédémarrage qui augmenterai la consommation.

---
### 5. Axes d'amélioration
Afin d'améliorer la pertinence de cette analyse, il aurait été préférable d'avoir accès aux données portant sur l'embrayage. En effet connaitre le rapport en cours nous aurait permis de définir plus explicitement si faire du sous-régime est efficace ou non.
Une autre amélioration aurait été de croiser ces données avec les relevés de trafic, ce qui nous aurait permis de montrer la relation entre les bouchons et la consommation.
Un dernier axes d'amélioration aurait porté sur l'aspect écologique. En effet, avoir à disposition les quantités de CO2 rejettées par le véhicule nous aurait permis de mettre en place des recommandation concernant un style de conduite à adopter pour réduite les émissions.

[^1]: ECU: Engine Control Unit, ordinateur qui gère l'ensemble du moteur (capteurs et actionneurs)
[^2]: OBD2: Protocole du matériel permettant le diagnostique électronique sur les véhicules à partir des années 2000
[^3]: E10: anciennement SP95-E10 (sans plomb 95 contenant environ 10 % d'agroéthanol)
[^4]: Stop & Start: dispositif d'arrêt et de redémarrage automatique du moteur d'un véhicule afin d'économiser le carburant et réduire la pollution essentiellement dans les embouteillages et aux feux rouges.