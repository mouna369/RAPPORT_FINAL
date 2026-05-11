

#set par(justify: true)
=  Conception, Architecture et Mise en Œuvre du Pipeline de Données

== Introduction
#h(0.5cm) Le chapitre précédent a posé les fondements : mesures de similarité, architectures Transformer, contraintes Big Data, spécificités morphosyntaxiques de la darija. Ces éléments ne constituent pas une simple revue ils dessinent les contours précis du problème à résoudre. La haute dimensionnalité des représentations vectorielles, la fragmentation arabizi, le déséquilibre structurel entre classes, la latence inhérente à l'inférence distribuée : chaque contrainte identifiée impose, en retour, une décision architecturale.
Ce chapitre traduit ces décisions en un système concret, déployé et validé.

#h(0.5cm) L'architecture que nous présentons n'a pas émergé d'une transposition mécanique de bonnes pratiques issues de la littérature. Elle résulte d'une série d'arbitrages effectués sous contrainte réelle l'inaccessibilité des plateformes cloud internationales depuis le territoire algérien, l'absence d'infrastructure matérielle distribuée au sein du laboratoire, la nécessité de faire cohabiter, sur une machine locale, un cluster Spark de quatre nœuds, un broker Kafka, une instance MongoDB et un serveur d'inférence NLP. Ces contraintes, loin de constituer de simples anecdotes techniques, ont orienté chaque choix de conception de manière déterminante.
Nous articulons l'exposé autour de quatre axes.

#h(0.5cm) La conception et le déploiement de l'infrastructure Docker multi-nœuds, qui émule un environnement distribué viable dans les conditions locales. Le pipeline d'ingestion et de prétraitement des 26 576 interactions collectées auprès du département Social Media d'Algérie Télécom, depuis les fichiers Excel bruts jusqu'aux documents MongoDB enrichis. Le flux de streaming temps réel fondé sur Apache Kafka, qui découple la collecte de l'analyse et garantit la résilience face aux pics de charge. Enfin, la chaîne de prétraitement NLP avancé suppression des doublons, nettoyage, normalisation arabizi, annotation automatique par l'API Gemini, étiquetage sémantique par règles qui constitue le cœur analytique du système.

#h(0.5cm) Chaque composant est présenté non comme un bloc fonctionnel isolé, mais comme un maillon d'un flux de transformation continu, où la défaillance d'une étape se propage mécaniquement aux suivantes. C'est cette logique de dépendances en chaîne qui a gouverné nos choix d'implémentation et que nous cherchons ici à rendre explicite.

== Analyse des besoins
 

#h(0.5cm) Cette section présente l'ensemble des exigences fonctionnelles et non-fonctionnelles identifiées pour notre système d'analyse des interactions clients en dialecte algérien. Ces besoins ont été définis à partir de l'analyse des processus métier du secteur télécom et des lacunes recensées dans l'état de l'art .

=== Besoins fonctionnels

#h(0.5cm) Les besoins fonctionnels décrivent l'ensemble des services et fonctionnalités que le système doit fournir pour répondre aux attentes des utilisateurs finaux (analystes, managers, administrateurs). Ils correspondent à la question : *"Qu'est-ce que le système doit FAIRE ?"*



    #strong[Collecte et ingestion :]
    #list(
      [Collecte multi-sources (Twitter, Facebook, Forums algériens)],
      [Nettoyage du texte (URLs, mentions, hashtags, emojis)],
      [Normalisation Arabizi (ex: "3lik" → "عليك")],
    )
    
    #v(8pt)
    #strong[Analyse NLP :]
    #list(
      [Classification des sentiments (Positif, Neutre, Négatif)],
      [Extraction de thèmes (réseau, facturation, service client, prix)],
      [Détection de crises (alertes automatiques)],
    )
    
    #v(8pt)
    #strong[Visualisation et interaction :]
    #list(
      [Dashboard interactif (graphiques, courbes, KPIs)],
      [Filtrage des données (période, plateforme, région, opérateur)],
    )
 
=== Besoins non-fonctionnels

#h(0.5cm) Les besoins non-fonctionnels définissent les contraintes de qualité, de performance et de sécurité que le système doit respecter. Contrairement aux besoins fonctionnels qui décrivent *ce que* le système fait, les besoins non-fonctionnels spécifient *comment* il le fait.


    #list(
      spacing:10pt,
      [*Performance* : le système doit analyser un tweet en moins de 1 seconde (latence < 1000 ms/tweet)],
      [*Disponibilité* : le système doit fonctionner 24h/24 et 7j/7 (disponibilité > 99%)],
      [*Scalabilité* : le système doit supporter les pics de charge (throughput ≥ 10 000 tweets/minute)],
      [*Sécurité* : les données personnelles doivent être anonymisées (conforme RGPD)],
      [*Précision* : le modèle doit performer sur la Darija algérienne (F1-Score ≥ 0.85)],
    )
  

== Spécifications du système
   === Diagrammes de cas d’utilisation (Use Case UML)
   === Diagrammes de séquence
  === Diagrammes d’activité

== Architecture globale du système et Infrastructure Technique


  === Vue d'ensemble de l'architecture
   
=== Infrastructure Docker multi-nœuds et Orchestration 
  


==== Pipeline de traitement distribué avec Apache Spark
 

#h(0.5cm) L'implémentation opérationnelle de notre architecture de prétraitement distribué repose sur une infrastructure à haute disponibilité, spécifiquement configurée pour la parallélisation des processus de normalisation linguistique appliqués au dialecte algérien. Ce chapitre expose les principes de conception, les modalités de déploiement ainsi que les protocoles de validation de notre grappe Apache Spark, dont l'orchestration est assurée par l'écosystème Docker. 
==== Architecture Spark multi-nœuds sous Docker
*A. Motivation et choix architecturaux : Face aux contraintes locales* 

#h(0.5cm)L'établissement d'une infrastructure Big Data distribuée, dédiée au prétraitement des métadonnées de télécommunications, a requis une phase analytique préalable portant sur la viabilité des solutions de déploiement. Bien que diverses configurations aient été initialement projetées, leur mise en œuvre s'est heurtée à un ensemble de contingences techniques, géographiques et budgétaires inhérentes au contexte socio-économique algérien. Cette section examine les motivations ayant conduit à nos choix technologiques finaux, en mettant en perspective les limitations infrastructurelles locales et les impératifs de performance du pipeline
résumés dans le tableau ci-dessous :
#table(
  columns: (2fr, 3.15fr, 2.93fr),
    inset: (x: 8pt, y: 6pt),
    align: (left, left, left),
    fill: (x, y) => if y == 0 {  } else if calc.rem(y, 2) == 1 {  } else { white },
    stroke: 0.5pt + black,

  // En-têtes
  [ *Solution envisagée* ],
  [ *Problème rencontré* ],
  [ *Conséquence* ],

  // Ligne 1
  [ Google Dataproc ],
  [ Exigence de moyens de paiement internationaux (carte bancaire crédit) ],
  [ Impossible de valider l'inscription depuis l'Algérie sans devise étrangère. ],

  // Ligne 2
  [ AWS EMR ],
  [ Restrictions géographiques et limitations d'accès régional ],
  [ Services non disponibles ou fortement restreints sur notre zone réseau. ],

  // Ligne 3
  [ Azure HDInsight ],
  [ Nécessité d'un compte professionnel entreprise + restrictions géo ],
  [ Inaccessible pour un projet académique sans partenariat industriel formel. ],

  // Ligne 4
  [ Cluster Physique ],
  [ Absence de machines serveur supplémentaires ],
  [ Impossibilité de monter un vrai cluster multi-machines au laboratoire. ],

  // Ligne 5
  [ Connexion P2P ],
  [ Échec de la connexion réseau directe entre les deux PC des binômes ],
  [ Impossible de distribuer les nœuds (Master sur PC1, Workers sur PC2) à cause des pare-feux et de la configuration réseau locale. ]
)
#v(0.5cm)
*B. Le choix de Docker : Une alternative locale maîtrisée*

Pour surmonter ces contraintes, nous avons retenu une architecture localisée fondée sur la conteneurisation Docker, qui offre quatre atouts stratégiques :

#list(
  [ *Isolation systémique et reproductibilité environnementale* : L'encapsulation de chaque composant fonctionnel (nœuds maîtres/esclaves Spark, instances MongoDB et Kafka) dans des conteneurs distincts assure une étanchéité logicielle rigoureuse. Cette approche garantit une symétrie parfaite entre environnements de développement et de production, éliminant les biais d'exécution issus des disparités infrastructurelles. ],
  [ *Portabilité et agnosticisme matériel* : L'abstraction des couches matérielles permet un déploiement ubiquitaire, rendant l'artefact logiciel indépendant de l'hôte. Elle facilite ainsi la migration seamless du pipeline entre stations de travail locales, serveurs on-premise ou instances cloud, sans reconfiguration. ],
  [ *Rationalisation de la gestion des dépendances* : Les images Docker préconfigurées intègrent nativement des bibliothèques hétérogènes et complexes (PySpark, Transformers de Hugging Face, PyMongo) ainsi que les modèles d'analyse de sentiments. Cette méthode prévient les conflits de versions et simplifie la maintenance du cycle de vie logiciel. ],
  [ *Élasticité et scalabilité horizontale* : L'orchestration par Docker Compose confère une agilité granulaire au système, autorisant un ajustement dynamique de la capacité de calcul via l'instanciation ou la terminaison de workers Spark. Elle optimise ainsi l'allocation des ressources face aux volumes de traitement. ]
)
* C. Pourquoi un cluster Spark multi-nœuds ?*
#v(0.1cm)
Dans le cadre de cette étude, l'architecture distribuée d'*Apache Spark* sur un cluster multi-nœuds a été retenue en préférence à une instance locale, pour les motifs suivants :

#list(
  [ *Traitement parallèle massif* : Le nettoyage des données et l'analyse de sentiments appliqués à des dizaines de milliers de commentaires sont répartis sur trois _workers_, réduisant le temps de traitement de plusieurs heures à seulement quelques minutes. ],
  [ *Tolérance aux pannes* : La continuité du pipeline est garantie par la redistribution automatique des tâches vers les nœuds restants en cas de défaillance d'un _worker_. ],
  [ *Gestion optimisée de la mémoire* : Avec 2 Go par _executor_, Spark prévient efficacement les erreurs « Out of Memory » qui surviendraient inévitablement sur une machine locale face à des volumes de données importants. ],
  [ *Évolutivité aisée* : Il est possible d'étendre le cluster de trois à plus de dix _workers_ sans altérer le code source, permettant d'absorber des pics de charge (ex. : 100 000+ commentaires/jour). ]
)


==== Prérequis système et environnement de développement

La mise en place de ce cluster distribué nécessite une machine hôte disposant de ressources suffisantes pour émuler plusieurs nœuds de calcul simultanément. L’environnement de développement retenu présente les caractéristiques suivantes :

#table(
  columns: (2fr, 2fr),
    inset: (x: 8pt, y: 6pt),
    align: (left, left),
    fill: (x, y) => if y == 0 {  } else if calc.rem(y, 2) == 1 {  } else { white },
    stroke: 0.5pt + black,

  //En-tête (optionnel, peut être retiré si vous préférez juste les données)
  [ *Composant* ], [ *Version / Détails* ],

  // Ligne 1
  [ *Système d’exploitation* ],
  [ Ubuntu 24.04.4 LTS ],

  // Ligne 2
  [ *Moteur de conteneurisation* ],
  [ Docker Engine (v29.2.1) ],

  // Ligne 3
  [ *Orchestration* ],
  [ Docker Compose (v5.0.2) ]
)

==== Orchestration des services (Kafka, Zookeeper, MongoDB) 

L'infrastructure complète est définie et orchestrée via un fichier unique *docker-compose.yml*, décrivant neuf services interconnectés sur un réseau bridge privé nommé *spark_network*.

*A. Configuration de l'image Docker personnalisée*


Pour répondre aux exigences du NLP en Darija, l'image Spark officielle s'est révélée insuffisante. Nous avons conçu une image personnalisée *Dockerfile.worker* intégrant les dépendances critiques :

#list(
  [ *transformers, safetensors, sentencepiece* : Indispensables pour charger et inférer les modèles adaptés à la Darija. ],
  [ *torch (PyTorch)* : Backend requis pour les calculs vectoriels des modèles *Transformers* au sein des workers *PySpark*. ],
  [ *pymongo* : Connecteur permettant la lecture/écriture directe depuis *MongoDB* sans fichiers intermédiaires. ]
)
L'installation est optimisée pour minimiser la taille de l'image :
#align(center)[
  #figure(
    block(
      stroke: 2pt + black,
      image("../images/Installation_image.png", width: 7cm)
    ),
    caption: [Extrait du Dockerfile.worker illustrant l'installation optimisée des dépendances NLP.],
  kind: image
  )
]

*B. Topologie du cluster et allocation des ressources*

Le cluster est composé d'un nœud maître et de trois nœuds travailleurs, configurés pour exploiter au maximum les ressources de la machine hôte :

#list(
  [ *Spark Master* : Coordonne le cluster et planifie les tâches. Il expose l'interface Web UI sur le port `8080`. ],
  [ *Spark Workers* (x3) : Chaque worker est configuré avec 2 cœurs CPU et 2 Go de RAM (`SPARK_WORKER_CORES=2`, `SPARK_WORKER_MEMORY=2g`). Cette configuration agrège une capacité virtuelle totale de *6 cœurs* et *6 Go de RAM* pour le traitement parallèle. ],
  [ *Services de données* :
    #list(
      [ *MongoDB* : Stocke les commentaires bruts et nettoyés. Le port externe est mappé sur `27018` pour éviter les conflits. ],
      [ *Kafka & Zookeeper* : Assurent l'ingestion et le tamponnage des flux temps réel. ],
      [ *Dashboard Streamlit* : Visualise les résultats en se connectant directement à MongoDB via le réseau interne. ]
    )
  ]
)
*Configuration détaillée des services clés*\
#align(center)[
  #figure(
    block(
      stroke: 2pt + black,
      image("../images/docker_configuration.png", width: 12cm)
    ),
    caption: [Configuration détaillée des services clés.],
  kind: image
  )
]

*C. Gestion des volumes et du cache*\ 

Pour garantir la persistance des données et optimiser les performances, plusieurs volumes Docker sont montés :

#list(
  [ *mongodb-data* et *spark-data* : Préservent les données et les logs après l'arrêt des conteneurs, assurant la durabilité de l'état du cluster. ],
  
)



==== Validation du déploiement

Une fois le cluster lancé via des commande  *docker compose up -d* , plusieurs vérifications ont permis de valider le bon fonctionnement de l'infrastructure distribuée.

*A. Analyse de l'interface Spark UI*

L'accès à l'interface web du Master (http://localhost:8080) confirme le déploiement réussi. Comme illustré dans la Figure 5.x, le dashboard rapporte les métriques suivantes :
#list(
  [*État des Workers* : 3 nœuds actifs (Alive), confirmant la réplication correcte des conteneurs.],
  [*Capacité de Calcul Totale *: 6 cœurs logiques détectés (Cores in use: 6 Total). Cela valide que chaque worker met bien ses 4 cœurs à disposition du cluster.],
  [*Mémoire Allouée *: Environ 6 Go de RAM totale répartie sur les workers, prête à accueillir les jobs de nettoyage.],
)
#align(center)[
  #figure(
    block(
      stroke: 1.5pt + black,
      image("../images/interface_spark.jpg", width: 15cm)
    ),
    caption: [Interface Spark UI.],
  kind: image
  )
]

*B.L'interface Application UI*

#align(center)[
  #figure(
    block(
      stroke: 1.5pt + black,
      image("../images/INTERFACEAPPLICATION.jpg", width: 15cm)
    ),
    caption: [Interface Application UI.],
  kind: image
  )
]
  



















 === Pipeline de streaming et traitement distribué avec Apache Kafka

#h(0.5cm) Le pipeline de streaming est la moelle épinière de notre architecture de temps réel. Il collecte les commentaires sociaux dès leur création, les transporte et les distribue. Pour la scalabilité et la fiabilité nous avons mis en place une architecture basée sur *Apache Kafka*, orchestrée via Docker, qui sépare la source de donnée (MongoDB) les modules d’analytique.

Cette méthode aident à absorber la charge venant des réseaux sociaux sans perdre aucune donnée et à garder une faible latance adaptée à une surveillance temps réel . 

==== Architecture : topics, producers, consumers

#h(0.5cm) L'architecture du flux de données repose sur trois composants principaux interagissant au sein du réseau Docker spark_network. Le flux suit une logique linéaire : Détection → Publication → Consommation.



#align(center)[
  #figure(
    block(
      stroke: 1pt + black,
      inset: 5pt, image("../images/kafka_pepline.jpg", width: 15cm)
    ),
    caption: [Architecture du Pipeline de Streaming Temps Réel.],
  kind: image
  )
]


*A. Le Producteur (Producer) : Connecteur Personnalisé MongoDB-Kafka*

 #h(0.5cm) Contrairement aux architectures traditionnelles où les applications clientes publient directement dans Kafka, notre source de données est une base de données *MongoDB*. Pour intégrer cette source au flux Kafka, nous avons développé un connecteur personnalisé basé sur les *Change Streams de MongoDB*.

#set list(indent: 2em)

- *Mécanisme de Détection (Event-Driven) :* Le script producteur établit une connexion persistante avec MongoDB et ouvre un curseur d'écoute *(watch)* sur la collection. Il filtre spécifiquement les événements de type insert. Contrairement à une technique de *polling* (interrogation périodique) qui surchargerait le serveur, les Change Streams permettent à MongoDB de notifier instantanément le script dès qu'une nouvelle donnée est écrite.

- *Publication :* Le message est envoyé vers le *topic Kafka*. Cette étape transforme un événement de base de données en un message de stream consommable par n'importe quel service abonné.


*B. Le Broker Kafka : Tampon et Persistance*

#h(0.5cm) Le broker Kafka, configuré via l'image (*confluentinc/cp-kafka:7.5.0*), constitue l'épine dorsale du système.

#set list(indent: 2em)

- *Topic* : Ce topic centralise tous les commentaires entrants. Il agit comme un tampon de découplage (buffer), stockant les messages jusqu'à ce qu'ils soient traités par les consommateurs.

- *Persistance et Fiabilité *: Grâce à la persistance des logs Kafka, les données sont sécurisées. Même si le module de traitement tombe en panne, les messages restent disponibles dans Kafka et peuvent être rejoués (replay) une fois le service rétabli, garantissant une livraison de type "At-least-once".
- *Configuration Réseau :* Deux listeners sont configurés pour permettre à la fois la communication interne entre conteneurs (via le port 29092) et l'accès externe pour le développement et le monitoring (via le port 9092).

* C. Le Consommateur (Consumer) : Worker de Traitement*

#h(0.5cm)Le consommateur est une application Python indépendante qui s'abonne au topic . Son rôle va au-delà de la simple lecture ; il orchestre le cycle de vie du traitement d'un commentaire :

#set list(indent: 2em)

 - *1. Réception :* Il récupère les messages JSON depuis Kafka. Le topic commentaires_bruts agit comme un tampon de découplage (buffer), stockant les messages jusqu'à ce qu'ils soient traités par les consommateurs.

- * 2. Pré-traitement :* Il effectue une normalisation légère du texte (nettoyage des URLs, mentions).
- *3.Vérification d'unicité :* Il calcule un hash du texte pour éviter les doublons.

- *4. Enrichissement :* Il sollicite l'API de prédiction pour l'analyse de sentiment.

- *5. Persistance Finale :* Il stocke le résultat enrichi dans MongoDB.

==== Implémentation du Consumer et Intégration MongoDB

#h(0.5cm)Cette section décrit l'implémentation de la logique de haut niveau dans le consommateur Kafka et son intégration avec les composants. Afin d'optimiser l'utilisation de la puissance de traitement disponible, nous avons opté pour une structure de worker Python personnalisée plutôt que pour Spark Streaming pour l'inférence.

*A. Stratégie de Consommation, Scalabilité et Robustesse*

Le consommateur est configuré avec le paramètre *auto_offset_reset='earliest'*. Cette configuration fondamentale assure l'intégrité et la résilience du pipeline selon trois axes majeurs :

*1. Garantie de Non-Perte (Fault Tolerance)*
Kafka utilise un système d'Offsets pour tracer l'avancement précis du traitement de chaque message.

#set list(indent: 2em)

- *Mécanisme : *En cas d'arrêt imprévu du service (crash, maintenance), les messages non traités restent persistants dans le topic Kafka.

- *Reprise Automatique : * Lors du redémarrage (orchestré par Docker via la politique restart: always), le consommateur consulte son dernier offset validé et reprend la consommation exactement là où il s'était interrompu. Cela garantit qu'aucune donnée n'est perdue, assurant une livraison de type "At-least-once".

*2. Scalabilité Horizontale* via Consumer Groups 

L'architecture de notre worker Python étant légère (le modèle lourd étant externalisé sur l'API Kaggle), elle permet une grande flexibilité de déploiement.

#set list(indent: 2em)
- *Mécanisme :* Il est possible de lancer plusieurs instances du consumer au sein d'un même Consumer Group. Kafka détecte ces nouvelles instances et effectue un Rebalancing automatique, redistribuant équitablement les partitions du topic entre tous les workers actifs.
- *Bénéfice :* Cette parallélisation permet d'augmenter linéairement la capacité de traitement du système. En cas de pic de trafic, l'ajout d'instances supplémentaires réduit drastiquement le Lag (retard) en multipliant le nombre d'appels simultanés à l'API d'inférence.

#block(
  stroke: (left: 4pt + rgb("#dc2626")),  // Bordure gauche rouge
  inset: 10pt,
  fill: rgb("#fef2f2"),                   // Fond rouge très clair
  radius: 4pt,
  width: 100%,
  [
    #align(left)[
      #text(fill: rgb("#dc2626"), weight: "bold", size: 12pt)[*Note*]: Dans notre environnement de test actuel, nous utilisons une instance unique pour simplifier la supervision, mais l'architecture est nativement prête pour la montée en charge (Scale-out).
    ]
    ]
)

*3. Gestion du Lag  et Résilience Face aux Pics (Backpressure)* 

La dépendance à une API externe introduit une variable de latence réseau.

#set list(indent: 2em)
- * Mécanisme de Tamponnage :* Si l'API Kaggle ralentit ou devient temporairement indisponible, Kafka agit comme un tampon élastique (Backpressure). Les messages entrants s'accumulent dans le topic sans être supprimés ni rejetés.
- * Récupération Asynchrone : *Dès que la disponibilité de l'API est rétablie, le consumer absorbe le backlog accumulé à son rythme maximal. Le système ne sature jamais ; le lag n'est qu'un indicateur de délai temporaire, géré de manière asynchrone sans impact sur la collecte des données en amont.

*B. Optimisation des Ressources : Inférence via API Externe* 

L'étape centrale du consumer est l'appel à l'API de prédiction hébergée sur Kaggle (via tunnel ngrok).

#set list(indent: 2em)
- *Architecture Découplée :* Contrairement à une inférence locale où le modèle devrait être chargé en mémoire, notre approche externalise ce coût computationnel. Le worker Python agit comme un client léger qui envoie le texte et reçoit la prédiction JSON.
- *Avantage Mémoire :*  Cette architecture libère la RAM de notre machine locale. Si le modèle était local , l'utilisation de Spark Streaming ou de multiples consumers aurait saturé la mémoire. Ici, la légèreté du script permet une scalabilité horizontale facile.

- * Contrainte de Latence :*  La limitation principale devient la latence réseau. Kafka compense cette latence en stockant les messages en attente, garantissant que le producteur n'est jamais bloqué par la lenteur du consumer.



* C. Logique de Dédoublonnage (Idempotence)* 

Pour optimiser les performances et éviter des appels API coûteux pour des contenus identiques, nous implémentons un mécanisme d'idempotence :

#set list(indent: 2em)
- *Normalisation & Hachage :* Nettoyage du texte et génération d'un hash MD5 unique.
- *Vérification MongoDB : *Interrogation de la collection finale Si le hash existe, le message est ignoré et sa fréquence incrémentée. Sinon, l'inférence est lancée.


*E. Supervision via Kafka UI*

Une interface graphique Kafka UI *(port 8088)* est déployée pour le monitoring en temps réel :
#set list(indent: 2em)

- Visualisation du débit (messages produits/consommés)
- Surveillance du Consumer Lag, indicateur clé de santé du pipeline.
- Inspection de l'état des topics et partitions pour le débogage.
Comme illustré dans la Figure , l'interface permet de visualiser en temps réel les messages sérialisés au format JSON, confirmant le bon fonctionnement du Producteur et la persistance des données dans le broker Kafka


#align(center)[
  #figure(
    block(
      stroke: 1.5pt + black,
      image("../images/interface_fakf_ui.png", width: 15cm)
    ),
    caption: [Interface Kafka UI. ],
  kind: image
  )
]






== Collecte et Ingestion des Données


  === Collecte des données
   ==== Origine et constitution du corpus de données
   #h(0.5cm) Les données exploitées dans le cadre de cette étude proviennent du *département Social Media d'Algérie Télécom*. Ce service assure une veille permanente des interactions clients sur l'ensemble de l'écosystème numérique de l'opérateur.Grâce à une solution interne de social listening, l’équipe dédiée procède à une agrégation systématique des retours utilisateurs, incluant tant les commentaires publics que les échanges par messagerie privée, ainsi que les réponses apportées par les services de modération.Les extraits mensuels ainsi générés constituent la matière première de notre corpus.
   
#v(0.5cm)
#figure(
  block(
    stroke : 1.5pt +black ,
  image("../images/outil_social_listing.jpg", width: 90% ),
   ),
  caption: [Interface de l'outil interne de veille utilisé par le département Social Media d'Algérie Télécom (vue tableau de bord).],
  kind: image
)
#v(0.5cm)
L'accès à ces données internes confère des avantages notables, résumés dans le tableau suivant :

#figure(
  table(
    columns: (1.2fr, 2.8fr),
    inset: 7pt,
    align: (left, left),
    fill: (x, y) => 
      if y == 0 {  }
      else if calc.rem(y, 2) == 1 {  }
      else { white },
    stroke: 0.5pt + black,
    [#text(fill: black)[*Avantage*]], [#text(fill: black)[*Description*]],
    [Authenticité], [Données réelles non synthétiques, représentatives des vrais usages],
    [Volume significatif], [Plus de 26 000 interactions sur trois mois consécutifs],
    [Ancrage local], [Expression naturelle du dialecte algérien en contexte télécom],
    [Labeling implicite], [Présence de la réponse modérateur comme proxy de la qualité de prise en charge],
  ),
  caption: [Principaux avantages des données fournies par Algérie Télécom],
  kind: table
)
==== Périmètre des plateformes et hétérogénéité des données

#h(0.5cm) Les données touchent toutes les plateformes sociales où Algérie Télécom gère sa relation client. Cette variété donne une vue d'ensemble des échanges, mais oblige à prendre en compte les particularités de chaque réseau – longueur des messages, émoticônes, registre linguistique.

#figure(
  table(
    columns: (1.2fr, 2.2fr),
    inset: 5pt,
    align: (left, left),
    fill: (x, y) => 
      if y == 0 {  }
      else if calc.rem(y, 2) == 1 {  }
      else { white },
    stroke: 0.5pt + black,
    [#text(fill: black)[*Plateforme*]], [#text(fill: black)[*Usage principal*]],
    [Facebook], [Espace principal de réclamations et d'échanges],
    [Instagram], [Commentaires sur les campagnes publicitaires],
    [X (ex-Twitter)], [Interactions courtes, souvent urgentes],
    [TikTok], [Vidéos virales, commentaires souvent humoristiques],
    [IdoomMarket], [Avis sur la boutique en ligne d'Algérie Télécom],
    [LinkedIn], [Retours d'experts et partenaires],
    [YouTube], [Commentaires sur les tutoriels et communiqués],
  ),
  caption: [Plateformes sociales couvertes par la collecte],
  kind: table
)
==== Format des données et protocole de collecte
#h(0.5cm) *Méthodologie de collecte* : La stratégie de récupération des données adoptée au sein d’Algérie Télécom se distingue des méthodes conventionnelles d’extraction automatisée par web scraping. Afin de garantir une sécurité informatique optimale et de se conformer aux politiques d’utilisation des réseaux sociaux, l’entreprise privilégie une approche rigoureuse reposant exclusivement sur son outil de modération interne. Ce choix permet également d'assurer le respect de la confidentialité et la protection des données à caractère personnel des usagers, évitant ainsi les risques éthiques et techniques liés aux méthodes de collecte non officielles.

Au terme de ce processus, les données sont consolidées et exportées sous la forme de fichiers tableurs (.xlsx). Ces documents sont structurés de manière chronologique, par mois civil.

#h(0.5cm) Trois fichiers, couvrant la période de novembre 2025 à janvier 2026, ont été retenus pour cette étude.

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    inset: 5pt,
    align: (left, left, left),
    fill: (x, y) => 
      if y == 0 {  }
      else if calc.rem(y, 2) == 1 { }
      else { white },
    stroke: 0.5pt + black,
    [#text(fill: black)[*Mois*]], [#text(fill: black)[*Nombre de lignes*]], [#text(fill: black)[*Proportion*]],
    [Novembre 2025], [9 548], [35,9 %],
    [Décembre 2025], [8 798], [33,1 %],
    [Janvier 2026], [8 230], [31,0 %],
    [*Total*], [*26 576*], [*100 %*],
  ),
  caption: [Répartition des données brutes par mois],
  kind: table
)
Chaque fichier agrège simultanément les commentaires des usagers et les interventions des modérateurs. Cette structure de données appariées constitue un levier d'analyse pertinent, permettant d'évaluer non seulement la polarité des sentiments exprimés par la clientèle, mais également l’adéquation et la qualité des réponses fournies par le service social media.
==== Analyse de la structure et du contenu des bases de données
#h(0.5cm) L’examen des fichiers Excel révèle une architecture tabulaire homogène. Il convient néanmoins de noter que certaines variables présentent des taux de complétude variable variables, marqués par des données manquantes récurrentes.

#figure(
  table(
    columns: (1.6fr, 2.2fr, 1.3fr),
    inset: 6pt,
    align: (left, left, left),
    fill: (x, y) => 
      if y == 0 {  }
      else if calc.rem(y, 2) == 1 {  }
      else { white },
    stroke: 0.5pt + black,
    [#text(fill: black)[*Colonne*]], [#text(fill: black)[*Description*]], [#text(fill: black)[*Taux de remplissage*]],
    [Modérateur], [Nom de l'agent ayant répondu], [Élevé],
    [Réseau Social], [Plateforme source (Facebook, Instagram, etc.)], [100 %],
    [Publication], [Contenu du post initial (souvent vide)], [Très faible],
    [Commentaire Client], [Message textuel de l'utilisateur], [100 %],
    [Commentaire Modérateur], [Réponse apportée par le service client], [~85 %],
    [Date], [Horodatage de la publication], [100 %],
    [Actions], [Métadonnées supplémentaires], [Négligeable],
  ),
  caption: [Description des colonnes des fichiers Excel sources],
  kind: table
)

#figure(
  block(
    stroke : 1.5pt+black,
  image("../images/capture_donneesNov.png", width: 98%),),
  caption: [Extrait des données brutes du fichier Excel pour novembre 2025, montrant les commentaires clients et réponses modérateur.],
  kind: image
)
#let remarque(content) = block(
  fill: luma(240),
  stroke: gray + 1pt,
  radius: 4pt,
  width: 100%,
  inset: 8pt,
)[
  #content
]

#remarque[
  La colonne "Publication" représente une innovation méthodologique significative mise en place par Algérie Télécom dans ses systèmes de suivi pour l'année 2026. Cependant, les données examinées, qui ont été collectées au début du mois de février 2026, couvrent la période allant de novembre 2025 à janvier 2026, soit avant la mise en œuvre effective de cette nouveauté. Par conséquent, cette colonne demeure vide dans l'intégralité du corpus, empêchant toute analyse contextuelle des publications parentes pour cette tranche de données.
]

=== Ingestion dans MongoDB

#h(0.5cm) L'ingestion des données constitue la phase initiale critique de notre pipeline de traitement. Elle assure la transition des données brutes depuis leur format d'origine (fichiers Excel) vers la base de données MongoDB, qui servira de source unique de vérité tout au long du processus d'analyse. Cette étape doit garantir l'intégrité, la traçabilité et la pérennité des 26 576 interactions collectées auprès du département Social Media d'Algérie Télécom.

==== Chargement et insertion des fichiers XLS

#h(0.5cm) Le processus de chargement repose sur une procédure automatisée qui orchestre l'extraction, la transformation et l'insertion des données dans MongoDB. Ce processus a été conçu pour être exécuté une seule fois en phase d'initialisation, avec des mécanismes de validation et de journalisation robustes.

#block(
  stroke: (left: 4pt + rgb("#2563eb")),
  inset: 10pt,
  fill: rgb("#eff6ff"),
  radius: 4pt,
  width: 100%,
  [
    #align(left)[
      #text(fill: rgb("#2563eb"), weight: "bold", size: 11pt)[*Caractéristiques du processus d'import*]
    ]
    #v(6pt)
    #list(
      [Traitement par lots pour optimiser les performances d'insertion],
      [Génération d'identifiants uniques pour chaque document],
      [Préservation des métadonnées de provenance (fichier source, numéro de ligne)],
      [Horodatage automatique de l'import pour la traçabilité],
      [Gestion des erreurs avec possibilité de reprise sur incident],
    )
  ]
)

#h(0.5cm) Le processus d'importation suit une séquence opérationnelle rigoureuse en cinq étapes :

#figure(
  caption: [Séquence opérationnelle du processus d'import Excel vers MongoDB],
  kind: table,
  table(
    columns: (1.2fr, 3.2fr, 1.5fr),
    inset: (x: 7pt, y: 7pt),
    align: (left, left, left),
    fill: (x, y) => if y == 0 { } else if calc.rem(y, 2) == 1 { } else { white },
    stroke: 0.5pt + black,
    [*Étape*], [*Description*], [*Outils*],
    [1. Connexion], "Établissement d'une connexion persistante avec l'instance MongoDB locale sur le port 27018. Validation de la connectivité avant toute opération.", "MongoDB Client",
    [2. Découverte], "Recherche automatique des fichiers Excel dans le répertoire de stockage des données brutes. Identification des trois fichiers mensuels.", "Système de fichiers",
    [3. Extraction], "Lecture de chaque fichier Excel en préservant la structure tabulaire. Les en-têtes de colonnes sont extraits de la première ligne.", "Bibliothèque de lecture Excel",
    [4. Transformation], "Conversion de chaque ligne Excel en document MongoDB avec normalisation des types de données et gestion des valeurs manquantes.", "Moteur de transformation",
    [5. Chargement], "Insertion groupée des documents dans la collection pour maximiser le débit et minimiser les opérations réseau.", "Driver MongoDB",
  ),
) <table_import_steps>

#h(0.5cm) Lors de l'insertion, plusieurs règles de gestion essentielles sont appliquées pour garantir la qualité et la cohérence des données :

#list(
  [ *Génération d'identifiants uniques* : Chaque document reçoit un identifiant unique de type ObjectId. Cet identifiant de 12 octets encode un timestamp, permettant un tri chronologique natif et une indexation automatique optimisée. ],
  [ *Normalisation des dates* : Les dates extraites d'Excel sont converties en un format standardisé "JJ/MM/AAAA HH:MM" pour préserver la lisibilité et éviter les problèmes de fuseaux horaires lors des requêtes ultérieures. ],
  [ *Gestion des valeurs manquantes* : Les champs optionnels, tels que les réponses des modérateurs, sont initialisés avec une chaîne vide plutôt qu'une valeur nulle, simplifiant ainsi les requêtes et les traitements statistiques. ],
  [ *Métadonnées de traçabilité* : Chaque document intègre un objet metadata contenant le nom du fichier source, le numéro de ligne original et l'horodatage de l'import, permettant un audit complet et un débogage efficace. ],
  [ *Flag de traitement* : Le champ traite est initialisé à "faux" pour marquer tous les documents comme non traités, permettant un traitement incrémental et une reprise sur erreur sans perte de données. ],
)

#h(0.5cm) Les résultats de l'importation sont consignés dans un rapport synthétique qui confirme l'intégrité du processus :

#figure(
  caption: [Statistiques d'importation des trois fichiers sources],
  kind: table,
  table(
    columns: (1.5fr, 1.2fr, 1.5fr, 1.5fr),
    inset: (x: 7pt, y: 6pt),
    align: (center, center, center, center),
    fill: (x, y) => if y == 0 { } else if calc.rem(y, 2) == 1 { } else { white },
    stroke: 0.5pt + black,
    [*Fichier source*], [*Période*], [*Lignes lues*], [*Documents insérés*],
    [Social-Media-Nov2025.xlsx], [Novembre 2025], [9 548], [9 548],
    [Social-Media-Dec2025.xlsx], [Décembre 2025], [8 798], [8 798],
    [Social-Media-Jan2026.xlsx], [Janvier 2026], [8 230], [8 230],
    [*Total*], [*3 mois*], [*26 576*], [*26 576*],
  ),
)



==== Modélisation du schéma documentaire

#h(0.5cm) MongoDB étant une base de données orientée documents (NoSQL), nous avons adopté une modélisation dénormalisée qui privilégie la performance en lecture et la flexibilité du schéma. Contrairement aux bases relationnelles, MongoDB permet de stocker des documents JSON (BSON) avec des structures variables, ce qui est particulièrement adapté à notre corpus hétérogène provenant de multiples plateformes sociales.

#h(0.5cm) La conception du schéma documentaire répond à trois impératifs fondamentaux :

#list(
  [ *Traçabilité complète* : Pouvoir retracer l'origine de chaque commentaire jusqu'au fichier Excel source et à la ligne exacte, ],
  [ *Évolutivité du pipeline* : Permettre l'ajout de champs de traitement intermédiaires sans migration de schéma complexe, ],
  [ *Performance des requêtes* : Optimiser l'accès aux données fréquemment consultées telles que la source, la date et le statut de traitement. ],
)

===== Structure du document MongoDB

#h(0.5cm) Chaque document dans la collection `commentaires_bruts` suit une structure organisée en quatre catégories fonctionnelles. Cette structure a été itérativement affinée pour équilibrer exhaustivité des données et efficacité de stockage. L'interface MongoDB Compass illustrée ci-dessous montre la visualisation de trois documents représentatifs :

#figure(
  image("../images/mongodb_documents_view.jpg", width: 100%),
  caption: [Visualisation de documents MongoDB dans l'interface Compass - Collection commentaires_bruts],
  kind: image
) <mongodb_documents>

#h(0.5cm)Voici un exemple de mes documents MongoDB:
#block(
  inset: 12pt,
  stroke: 1pt + gray,
  radius: 6pt,
  fill: luma(250),
  width: 100%,
  [
    #text(weight: "bold", size: 10pt)[Exemple de document - Commentaire Facebook du 31/01/2026]
    #v(8pt)
    #list(
      [
        #text(weight: "bold")["Identifiant unique :"]
        #v(2pt)
        "69f1146e2bae96f854211353 (ObjectId généré automatiquement)"
      ],
      [
        #text(weight: "bold")["Contenu métier :"]
        #v(2pt)
        "Commentaire client : \"نبقاو هكا نهار كامل انترنت تجي 10 د وتروح وتعاود تجي نفس حكاية\""
        #v(2pt)
        "Réponse modérateur : \"يمكنكم طرح انشغالاتكم فيما يخص الانترنت عبر الرسائل الخاصة للصفحة مع ارفاق كل المعلومات الضرورية شكرا لتفهمكم.\""
        #v(2pt)
        "Date : 31/01/2026 22:28"
        #v(2pt)
        "Source : Facebook"
        #v(2pt)
        "Modérateur : Aimen NOURI"
      ],
      [
        #text(weight: "bold")["Workflow de traitement :"]
        #v(2pt)
        "Statut : brut (document en attente de traitement)"
        #v(2pt)
        "Traité : true (marqué pour traitement incrémental)"
      ],
      [
        #text(weight: "bold")["Traçabilité technique :"]
        #v(2pt)
        "Fichier source : Social-Media-Analytics1.xlsx"
        #v(2pt)
        "Ligne originale : 14"
        #v(2pt)
        "Date d'import : 28/04/2026 21:11:26"
      ],
    )
  ]
)





===== Justification des choix de modélisation

#h(0.5cm) Chaque aspect du schéma documentaire résulte d'un arbitrage entre normalisation (bonne pratique relationnelle) et dénormalisation (performance NoSQL). Les choix suivants ont été motivés par des contraintes techniques et fonctionnelles spécifiques à notre contexte algérien.

#strong[A. Stockage des dates en format chaîne]

#h(0.5cm) Contrairement aux bonnes pratiques MongoDB qui recommandent le type Date natif, nous avons conservé les dates au format chaîne "JJ/MM/AAAA HH:MM". Cette décision s'explique par plusieurs facteurs contextuels :

#list(
  [ *Préservation du format original* : Les dates Excel étant déjà formatées selon les standards locaux algériens, leur conversion en ISODate aurait introduit un décalage de fuseau horaire non souhaité et potentiellement source de confusion. ],
  [ *Simplicité d'affichage* : Pour les tableaux de bord interactifs, l'affichage direct d'une chaîne lisible évite des transformations coûteuses côté client et préserve le format familier aux utilisateurs locaux. ],
  [ *Absence de calculs temporels complexes* : Notre pipeline n'effectue pas de requêtes temporelles avancées telles que des agrégations par mois ou des différences de dates précises, rendant le type Date moins critique pour nos besoins spécifiques. ],
)

#strong[B. Champ metadata imbriqué]

#h(0.5cm) Les métadonnées de traçabilité sont regroupées dans un sous-document metadata plutôt qu'aplaties au niveau racine. Cette structure hiérarchique, visible dans la figure @mongodb_documents, offre plusieurs avantages stratégiques :

#list(
  [ *Clarté sémantique* : La séparation entre données métier (commentaires, dates, sources) et métadonnées techniques (fichier, ligne, horodatage) est explicite et facilite la compréhension du document. ],
  [ *Extensibilité* : L'ajout de nouvelles métadonnées telles que des hash de vérification, des numéros de version ou des informations de provenance API n'encombre pas l'espace de noms racine et préserve la lisibilité. ],
  [ *Requêtes ciblées* : Il est possible d'interroger spécifiquement les métadonnées via des requêtes précises, par exemple pour retrouver tous les documents provenant d'un fichier spécifique ou d'une plage de lignes donnée. ],
)

#strong[C. Flags de workflow pour le traitement incrémental]

#h(0.5cm) Le pipeline de traitement étant incrémental et distribué sur un cluster Spark multi-nœuds, la gestion d'état est cruciale pour garantir la cohérence et la reprise sur incident. Deux mécanismes complémentaires assurent cette gestion :

#figure(
  caption: [Machine à états du champ statut illustrant le cycle de vie d'un commentaire],
  kind: table,
  table(
    columns: (1fr, 2.5fr, 2fr),
    inset: (x: 6pt, y: 6pt),
    align: (left, left, left),
    fill: (x, y) => if y == 0 { } else if calc.rem(y, 2) == 1 { } else { white },
    stroke: 0.5pt + black,
    [*État*], [*Signification*], [*Transition déclenchée par*],
    ["brut"], "Document fraîchement importé, contenant les données brutes telles qu'extractes d'Excel.", "Import initial depuis les fichiers sources",
    ["nettoyé"], "Doublons supprimés, texte nettoyé (URLs, émojis, mentions retirés).", "Étape 1 du pipeline Spark - Nettoyage",
    ["normalisé"], "Arabizi converti en arabe, stopwords supprimés, tokenisation effectuée.", "Étape 2 du pipeline - Normalisation linguistique",
    ["annoté"], "Sentiment prédit via l'API Gemini, flags sémantiques ajoutés (plainte, suggestion, etc.).", "Étape 3 du pipeline - Annotation",
    ["complet"], "Toutes les étapes validées, document prêt pour l'analyse statistique et la visualisation.", "Validation finale et indexation",
  ),
)

#h(0.5cm) Le champ booléen traite complète le champ statut en permettant une requête ultra-rapide pour récupérer tous les documents en attente de traitement, sans avoir à analyser des chaînes de caractères. Cette optimisation est cruciale pour le traitement par lots sur le cluster Spark.

===== Stratégie d'indexation pour les performances

#h(0.5cm) Pour optimiser les performances des requêtes fréquentes, nous avons créé des index stratégiques sur les champs les plus sollicités. MongoDB utilise des index B-tree par défaut, offrant une complexité de recherche logarithmique.

#figure(
  caption: [Index créés sur la collection commentaires_bruts et leur impact],
  kind: table,
  table(
    columns: (1.8fr, 2.2fr, 1.5fr),
    inset: (x: 7pt, y: 6pt),
    align: (left, left, center),
    fill: (x, y) => if y == 0 { } else if calc.rem(y, 2) == 1 { } else { white },
    stroke: 0.5pt + black,
    [*Index*], [*Requête optimisée*], [*Gain estimé*],
    ["source (ascendant)"], "Filtrage par plateforme sociale (Facebook, Instagram, IdoomMarket, etc.)", "×50 à ×100",
    ["date (ascendant)"], "Tri chronologique, filtrage par période temporelle (mois, semaine)", "×30 à ×50",
    ["statut (ascendant)"], "Sélection des documents par étape de traitement (pipeline Spark)", "×100+",
    ["metadata.fichier"], "Traçabilité par fichier source (audit, débogage)", "×20 à ×30",
    ["traite (ascendant)"], "Requêtes incrémentales pour documents non traités", "×100+",
  ),
)

#h(0.5cm) L'index composé sur source et statut permet d'optimiser les requêtes combinées fréquentes, telles que "récupérer tous les commentaires Facebook non encore traités". Cette optimisation est particulièrement utile pour le traitement distribué sur le cluster Spark.
#v(1cm)
#block(
  stroke: (left: 4pt + rgb("#dc2626")),
  inset: 10pt,
  fill: rgb("#fef2f2"),
  radius: 4pt,
  width: 100%,
  [
    #align(left)[
      #text(fill: rgb("#dc2626"), weight: "bold", size: 11pt)[*Compromis indexation*]
    ]
    #v(4pt)
    #text(size: 9pt)[
      Les index accélèrent considérablement les lectures mais ralentissent légèrement les écritures 
      (mise à jour de l'index à chaque insertion). Dans notre cas, les écritures étant limitées à 
      l'import initial et les lectures étant fréquentes (tableaux de bord, traitements itératifs), 
      le compromis est nettement favorable à l'indexation.
    ]
  ]
)

===== Volumes et statistiques de stockage

#h(0.5cm) Après l'importation complète des 26 576 documents, la collection commentaires_bruts présente des caractéristiques de stockage optimisées pour notre infrastructure locale :

#figure(
  caption: [Statistiques de stockage de la collection MongoDB],
  kind: table,
  table(
    columns: (2fr, 1.5fr),
    inset: (x: 7pt, y: 6pt),
    align: (left, center),
    fill: (x, y) => if y == 0 { } else if calc.rem(y, 2) == 1 { } else { white },
    stroke: 0.5pt + black,
    [*Métrique*], [*Valeur*],
    ["Nombre total de documents"], ["26 576 commentaires"],
    ["Taille totale sur disque"], ["~18,4 Mo"],
    ["Taille moyenne par document"], ["~692 octets"],
    ["Taille des index"], ["~2,1 Mo"],
    ["Ratio index/données"], ["11,4 %"],
  ),
)

#h(0.5cm) La taille moyenne de 692 octets par document s'explique par plusieurs facteurs techniques :

#list(
  [ La longueur variable des commentaires, allant de messages courts de 20 caractères à des plaintes détaillées de plus de 500 caractères, ],
  [ La présence systématique des métadonnées de traçabilité représentant environ 150 octets par document, ],
  [ L'encodage UTF-8 des caractères arabes nécessitant en moyenne 3 octets par caractère, contrairement au latin (1 octet), ],
  [ La surcharge BSON incluant les types de données, les longueurs de champs et les structures imbriquées. ],
)

#block(
  stroke: (left: 4pt + rgb("#059669")),
  inset: 10pt,
  fill: rgb("#ecfdf5"),
  radius: 4pt,
  width: 100%,
  [
    #align(left)[
      #text(fill: rgb("#059669"), weight: "bold", size: 11pt)[*Optimisation du stockage*]
    ]
    #v(4pt)
    #text(size: 9pt)[
      Le ratio index/données de 11,4 % est excellent, bien en dessous du seuil de 20 % considéré 
      comme optimal. Cela confirme que notre stratégie d'indexation est équilibrée : suffisamment 
      d'index pour les performances de requête, mais pas au point d'alourdir excessivement le 
      stockage sur notre serveur local.
    ]
  ]
)

#h(0.5cm) En conclusion, la modélisation du schéma documentaire MongoDB constitue un compromis réfléchi entre flexibilité NoSQL et rigueur relationnelle. Les choix techniques (stockage des dates en chaîne, métadonnées imbriquées, flags de workflow) sont documentés et justifiés par des contraintes fonctionnelles spécifiques au contexte algérien et aux particularités de notre corpus multilingue. La validation de schéma et l'indexation stratégique garantissent la qualité et la performance des données tout au long du pipeline d'analyse des sentiments en darija algérienne.
=== Prétraitement NLP Avancé 


 ==== Suppression des doublons

===== Problématique et méthodologies expérimentées

#h(0.5cm) Les commentaires dupliqués (messages identiques, reformulés ou quasi identiques, 
répétés à de nombreuses reprises) génèrent un bruit important pour tout processus 
d'apprentissage ultérieur. Sur les 26 576 interactions de notre ensemble de données initial, 
nous avons constaté un nombre significatif de commentaires dupliqués, il était donc essentiel 
de les identifier et de les supprimer avant d'entreprendre l'analyse lexicale ou toute phase 
d'entraînement.

===== Protocole expérimental

#h(0.5cm) Afin que les méthodes soient comparables, elles ont toutes été évaluées au moyen 
du même cadre d'évaluation standard basé sur les paramètres suivants :

- *Seuil de similarité* : un seuil de 85 % s'est avéré le plus satisfaisant après une phase 
  d'optimisation initiale.
- *Vérité terrain* : l'évaluation a été réalisée par rapport à un ensemble de référence de 
  36 enregistrements dupliqués isolés et confirmés.
- *Métriques* : Les métriques d’évaluation ont été calculées afin de mesurer la précision, le 
  rappel, le score F1 et le temps d’exécution de la solution de détection des doublons.

- *Échantillon* : toutes les expériences ont été menées sur un échantillon représentatif 
  de 1 000 commentaires.

#h(0.5cm) Cinq méthodes ont été évaluées : la distance de Levenshtein, le Jaccard 
Caractères, le Jaccard Mots, le TF-IDF seul et le Cosine TF-IDF (voir Chapitre 3 pour 
le détail des formules). Les résultats comparatifs et l'analyse détaillée de chaque 
méthode sont présentés au Chapitre 5.

===== Définition opérationnelle des doublons

#h(0.5cm) On considère qu'un commentaire est un doublon seulement s'il ressemble presque 
mot pour mot à un autre. Si le texte est juste reformulé, paraphrasé ou légèrement modifié, 
on regarde à quel point il est proche de l'original. Si la ressemblance dépasse un certain 
seuil, on traite ça comme un doublon.

On distingue trois niveaux de ressemblance :

- *Similarité de 99 % ou plus* : ce sont quasiment des copies, avec juste quelques détails 
  différents (une faute de frappe ou deux, par exemple).
- *Similarité entre 90 % et 99 %* : là, on a souvent affaire à des paraphrases, où l'ordre 
  change un peu, ou bien certains mots sont remplacés par des synonymes.
- *Similarité entre 85 % et 90 %* : ce sont des reformulations plus libres, mais au fond, 
  ça raconte vraiment la même chose.

#h(0.5cm) En fixant le seuil de détection à 85 %, on les prend toutes en compte. Par exemple, 
si quelqu'un écrit "Internet coupé depuis hier" et qu'un autre poste "La connexion est coupée 
depuis 24h", on mesure 87 % de ressemblance. C'est bien un doublon. Mais si on compare 
"Internet lent" à "Facturation erronée", la similarité tombe à 12 %. Là, ce n'est pas du tout 
le même sujet, donc on ne considère pas ça comme un doublon.

#h(0.5cm) *À l'issue de cette étape, une conclusion s'impose* : le nettoyage des données, 
et en particulier l'élimination des doublons, est une tâche fondamentale qu'il serait 
périlleux de bâcler. Chaque décision concernant les seuils ou les méthodologies adoptées 
joue un rôle clé dans la fiabilité du corpus final. Négliger cette étape reviendrait à 
intégrer du bruit dans l'ensemble des opérations analytiques ultérieures (vectorisation, 
classification, extraction de thèmes).



==== Nettoyage des commentaires 

===== Suppression des éléments parasites et filtrage des contenus non informatifs
Avant de procéder à l'analyse lexicale ou à l'entraînement des modèles, il est crucial de nettoyer les commentaires. En effet, les messages publiés par les clients sur les réseaux sociaux regorgent d'éléments indésirables, comme des URL, des mentions (@), des hashtags (\#), des emojis, une ponctuation excessive, des tirets inhabituels ou des espaces inutiles. Ces perturbateurs textuels nuisent à la performance des classificateurs et alourdissent inutilement la représentation vectorielle. De plus, certains commentaires sont dénués de valeur informative, tels que des interjections vides, des fragments de termes techniques, des prix isolés, des numéros de téléphone, des expressions de rire, du jargon incompréhensible, des questions vagues ou du contenu copié-collé. Le pipeline proposé prend en compte ces deux problématiques de manière intégrée.

Ce système de nettoyage est conçu pour un déploiement distribué sur Apache Spark avec un cluster composé de trois workers. Il parvient à traiter les  24 536 commentaires bruts en moins de 40 secondes. La suite d’opérations est méticuleusement organisée afin de conserver les informations pertinentes, comme les horaires, les dates, les prix ou les éléments techniques importants, tout en éliminant efficacement les perturbations textuelles.

===== Ordre des opérations de nettoyage

#figure(
  table(
    columns: (0.5fr, 3.5fr),
    inset: (x: 8pt, y: 6pt),
    align: (left, left),
    fill: (x, y) => if y == 0 {  } else if calc.rem(y, 2) == 1 {  } else { white },
    stroke: 0.5pt + black,
    [#text(fill: black)[*Ordre*]], [#text(fill: black)[*Opération*]],
    [1], [Mise en minuscules (*lowercasing*)],
    [2], [Conversion des dates avec espaces : $"من 18 10 2025"$ → $"من 18/10/2025"$],
    [3], [Préservation du $"Wi-Fi"$ → $"wifi"$ avant suppression des tirets],
    [4], [Réduction de la ponctuation répétée : $"!!!$" → $"!"$, $"؟؟؟$" → $"؟$"],
    [5], [Protection des dates et séparateurs numériques (tirets, slashes, deux-points)],
    [6], [Suppression des URLs, mentions (@), hashtags (\#) et underscores],
    [7], [Suppression des émojis après extraction et traduction sémantique],
    [8], [Suppression de la ponctuation indésirable et des tirets non numériques],
    [9], [Normalisation des espaces et restauration des éléments protégés],
    [10], [Filtrage des contenus non informatifs : interjections vides, termes techniques isolés, prix seuls, numéros de téléphone, bruits clavier, questions vagues, messages copiés-collés],
    [11], [Suppression des lignes résiduelles vides ou réduites à de la ponctuation],
  ),
  caption: [Ordre séquentiel des opérations de nettoyage appliquées à chaque commentaire],
  kind: table
)

===== Traitement des émojis : extraction et suppression

#h(0.5cm)Les émojis représentent une ressource précieuse pour saisir l'affectivité des utilisateurs. Plutôt que de les éliminer directement, ils sont d'abord isolés afin de préserver leur valeur sémantique, ce qui permet de les réutiliser comme attributs dans les analyses de sentiments.

Ce processus se déroule en trois étapes distinctes :

1. *Extraction* : Les émojis sont repérés grâce à leurs plages Unicode, en prenant en compte un large éventail de versions récentes et de variantes.

2. *Interprétation sémantique* : Chaque émoji est associé à une émotion spécifique—comme la colère, l'amour ou l'approbation—grâce à un dictionnaire dédié. Lorsque des émojis échappent à cette classification, ils sont regroupés sous une catégorie générique.

3. *Élimination* : Une fois identifiés et interprétés, les émojis sont supprimés du texte, générant ainsi un contenu épuré et prêt pour les étapes d'analyse ultérieures.

#figure(
  caption: [Exemple de traitement d’un commentaire contenant des émojis : suppression, extraction et association des sentiments.],
  kind: table,
  table(
    columns: (auto, auto),
    align: (left, left),
    stroke: 0.5pt,
    fill: (x, y) => {
      if y == 0 { }
      else if calc.rem(y, 2) == 1 {  }
      else { white }
    },
    [*Élément*], [*Valeur*],
    [*Texte original*], [#"خدمة ممتازة 😍🔥 جازاكم الله خيرا"],
    [*Émojis extraits*], [["😍", "🔥"]],
    [*Sentiments associés*], [["amour", "enthousiasme"]],
    [*Texte après suppression*], [#"خدمة ممتازة جازاكم الله خيرا"],
  )
)
===== Gestion sélective des informations numériques

#h(0.5cm) Les données numériques figurant dans les commentaires nécessitent un traitement différencié. Certaines constituent du "bruit" technique ou personnel sans intérêt analytique, tandis que d'autres détiennent une valeur sémantique essentielle.

La méthode suivie établit une distinction précise :
- **Éléments systématiquement éliminés** : numéros de téléphone, identifiants de réclamation, séquences numériques inutiles ou répétées. Ces données, dépourvues de pertinence contextuelle, sont écartées.
  
- **Éléments retenus** : prix, années, quantités, durées et heures. Ces informations enrichissent le contenu et facilitent la compréhension des opinions exprimées.

===== Filtrage des contenus non significatifs

#h(0.5cm) En complément du nettoyage syntaxique, certains commentaires, bien qu'exemptés d'éléments parasites formels, restent dépourvus d'intérêt analytique pour l'étude des sentiments. Une étape supplémentaire de filtrage sémantique est donc mise en œuvre pour analyser chaque message après nettoyage et statuer sur sa pertinence.

Les types de contenu rejetés incluent :

    #table(
      columns: (auto, auto),
      align: (left, left),
      stroke: 0.5pt,
      fill: (x, y) => {
        if y == 0 { } 
        else if calc.rem(y, 2) == 1 {  }
        else { white }
      },
      [#text(weight: "bold")[Catégorie]],
      [#text(weight: "bold")[Exemples types]],
      [Contenus vides],
      [interjections courtes : #emph[ok, merci, bravo, cool] ; termes en arabe : #emph[واش, علاش, لا, يخي]],
      [Termes techniques],
      [#emph[adsl, 4g, fibre, 60 mbps, ping]],
      [Références financières],
      [#emph[1500 da, سعر, prix, بشحال]],
      [Données personnelles],
      [#emph[numéros de téléphone]],
      [Parasites textuels],
      [#emph[hhhh, lol, ييييي]],
      [Questions floues],
      [#emph[هل هو 4g ?]  #emph[هل يوجد adsl ?]],
      [Contenus génériques],
      [#emph[FixRoutingAT]],
    )
    
Chaque suppression est répertoriée avec une justification pour garantir une traçabilité rigoureuse et ajuster les critères si nécessaire.

===== Résultats avant / après nettoyage

#h(0.5cm) Après application du filtrage des contenus non informatifs (interjections vides, termes techniques isolés, prix seuls, numéros de téléphone, etc.), 450 commentaires supplémentaires sont supprimés. Le corpus passe ainsi de 24 536 à 24 046 commentaires propres. Le tableau ci-dessous illustre des exemples concrets de commentaires avant et après l'application intégrale du pipeline.

#figure(
  table(
    columns: (1.7fr, 3.17fr, 2.95fr),
    inset: (x: 8pt, y: 6pt),
    align: (left, left, left),
    fill: (x, y) => if y == 0 {  } else if calc.rem(y, 2) == 1 {  } else { white },
    stroke: 0.5pt + black,
    [#text(fill: black)[*Type*]], [#text(fill: black)[*Commentaire original*]], [#text(fill: black)[*Après nettoyage*]],
    [*URL + mention*], [$"Visit https://ooredoo.dz @support "$], [$"visit"$],
    [*Hashtags + émojis*], [$"خدمة رائعة #ADSL 😍🔥"$], [$"خدمة رائعة"$],
    [*Ponctuation répétée*], [$"خدمة رديئة جداً ؟؟؟؟ !!!"$], [$"خدمة رديئة جداً ؟ !"$],
    [*Wi-Fi + heure*], [$"Wi-Fi 60 Mbps coupé depuis 18:00"$], [$"wifi 60 mbps coupé depuis 18:00"$],
    [*Date arabe*], [$"المشكلة من 18 10 2025"$], [$"المشكلة من 18/10/2025"$],
    [*Tiret non numérique*], [$"خدمة - رديئة جداً"$], [$"خدمة رديئة جداً"$],
    [*Contenu vide*], [$"ok merci "$], [$"(supprimé)"$],
    [*Terme technique seul*], [$"adsl 4g fibre"$], [$"(supprimé)"$],
  ),
  caption: [Exemples de transformations appliquées par le pipeline de nettoyage],
  kind: table
)
==== Normalisation du texte
#h(0.5cm) Après avoir supprimé les doublons et éliminé les parasites formels des commentaires, le corpus reste marqué par une profonde hétérogénéité linguistique. Les messages des clients d'Algérie Télécom mélangent en effet trois registres qui cohabitent souvent dans un même commentaire : l’arabe standard et dialectal (darija algérienne), le français oral, ainsi que l’arabizi. Ce dernier est une translittération phonétique de l'arabe en caractères latins, parfois combinée à des chiffres, largement répandue dans les interactions numériques en Algérie. À cette complexité s’ajoutent des fautes d’orthographe fréquentes, des abréviations spécifiques au domaine des télécoms, différentes variantes graphiques d’un même mot et des expressions typiquement dialectales, rendant leur traitement difficile pour les modèles de traitement automatique du langage naturel sans un prétraitement adapté.

#h(0.5cm) La phase de normalisation vise à relever ces défis en homogénéisant le vocabulaire du corpus. Cet effort se fait tout en évitant tout appauvrissement du contenu, afin d’optimiser la performance des modèles de classification des sentiments déployés par la suite. Compte tenu de la diversité des modèles cibles — qu’ils soient classiques, tels que la régression logistique, SVM, ou XGBoost, ou fondés sur des architectures Transformers comme AraBERT, DziriBERT ou MarBERT — nous avons conçu un système de normalisation unifié. Celui-ci génère trois versions normalisées pour chaque commentaire, permettant un meilleur ajustement aux besoins variés des modèles en aval.

===== Normalisation par dictionnaire (approche standard)
#h(0.5cm) La normalisation basée sur les dictionnaires constitue la première étape du processus. Cette approche symbolique s'appuie sur des dictionnaires et des ensembles de règles linguistiques, permettant de travailler de manière indépendante des modèles statistiques. Elle offre des bénéfices notables, notamment son caractère déterministe, sa capacité à être entièrement contrôlée et sa facilité d'interprétation, des attributs essentiels lors des phases de débogage et de validation du pipeline.

Le dictionnaire unifié, développé et affiné progressivement tout au long du projet, est structuré en huit catégories fonctionnelles distinctes. Les tableaux ci-dessous fournissent une vue d'ensemble des principales transformations mises en œuvre.

#figure(
  caption: [Normalisation des variantes orthographiques arabes],
  kind: table,
  table(
    columns: (1.5fr, 1.5fr, 1.8fr),
    inset: (x: 7pt, y: 6pt),
    align: (left, left, left),
    fill: (x, y) => if y == 0 {  } else if calc.rem(y, 2) == 1 {  } else { white },
    stroke: 0.5pt + black,
    [*Forme brute*], [*Forme normalisée*], [*Type de variante*],
    [أنا / إنا / آنا], [انا], [Alifs (أ/إ/آ → ا)],
    [كيف / کيف / گيف], [كيف], [Kâf (ک/گ → ك)],
    [هذا / هاذا], [هذا], [Alif surnuméraire],
    [مش / ميش], [مش], [Variante dialectale],
    [بزاف / بزاف], [بزاف], [Standardisation],
  ),
) <unicode_norm>

#figure(
  caption: [Conversion des émojis en étiquettes sémantiques arabes],
  kind: table,
  table(
    columns: (1fr, 1fr, 1fr),
    inset: (x: 9pt, y: 5pt),
    align: (left, left, left),
    fill: (x, y) => if y == 0 {  } else if calc.rem(y, 2) == 1 {  } else { white },
    stroke: 0.5pt + black,
    [*Émoji*], [*Signification*], [*Étiquette arabe*],
    [❤️], [amour], [حب],
    [👍], [approbation], [إعجاب],
    [😡], [colère], [غضب],
    [😂], [rire], [ضحك],
    [📶], [réseau], [شبكة],
    [⚡], [vitesse], [سرعة],
  ),
) <emoji_norm>

===== Traitement de l'arabizi : le défi linguistique central
#h(0.5cm) L'arabizi représente le principal défi linguistique de ce corpus. Il s'agit d'une écriture hybride mélangeant lettres latines, chiffres qui remplacent des phonèmes arabes ( #emph[ع = 3], #emph[ح = 7], #emph[ق = 9]) et des mots français, sans bénéficier d'une codification standardisée. Cette variabilité, propre à chaque utilisateur, est surmontée grâce à trois outils complémentaires : un dictionnaire regroupant plus de 300 termes arabizi courants, une table de correspondance pour les digrammes et monogrammes phonétiques, ainsi qu'une liste distincte des formes majuscules.

#figure(
  caption: [Conversion des mots arabizi complets vers l'arabe],
  kind: table,
  table(
    columns: (1.3fr, 1.5fr, 2fr),
    inset: (x: 7pt, y: 5pt),
    align: (center, center, center),
    fill: (x, y) => if y == 0 {  } else if calc.rem(y, 2) == 1 { } else { white },
    stroke: 0.5pt + black,
    [*Arabizi*], [*Normalisé*], [*Commentaire*],
    [nchalh / inchallah], [إن شاء الله], [Expression religieuse],
    [wlh / wallah], [والله], [Serment],
    [khouya / khoya], [خويا], [Vocatif dialectal],
    [bzaf / bzf], [بزاف], [Adverbe d'intensité],
    [sahbi], [صاحبي], ["Mon ami"],
    [rabi / rbnii], [ربي], ["Mon Dieu"],
    [hdra / hedra], [هدرة], ["Parole / discours"],
    [khdma / khedma], [خدمة], ["Service / travail"],
  ),
) <arabizi_words>

#figure(
  caption: [Conversion des digrammes et monogrammes phonétiques],
  kind: table,
  table(
    columns: (1fr, 1fr, 1fr, 1fr),
    inset: (x: 5pt, y: 5pt),
    align: (center, center, center, center),
    fill: (x, y) => if y == 0 { } else if calc.rem(y, 2) == 1 {  } else { white },
    stroke: 0.5pt + black,
    [*Code*], [*Phonème*], [*Lettre arabe*], [*Exemple*],
    [3], ['ayn], [ع], [3lach → علاش],
    [7], [ha'], [ح], [7na → حنا],
    [9], [qaf], [ق], [9ol → قول],
    [5], [kha'], [خ], [5atr → خطر],
    [gh], [ghayn], [غ], [ghir → غير],
    [kh], [kha'], [خ], [khir → خير],
    [sh / ch], [shin], [ش], [shwiya → شوية],
    [dh], [dhal], [ذ], [dhab → ذهب],
    [th], [tha'], [ث], [thalatha → ثلاثة],
  ),
) <phonetic_map>

#figure(
  caption: [Conversion des mots hybrides (lettres et chiffres)],
  kind: table,
  table(
    columns: (1fr, 1fr, 1fr),
    inset: (x: 7pt, y: 5pt),
    align: (center, center, center),
    fill: (x, y) => if y == 0 {  } else if calc.rem(y, 2) == 1 { } else { white },
    stroke: 0.5pt + black,
    [*Forme hybride*], [*Normalisé*], [*Décomposition*],
    [n9drou], [نقدرو], [n + 9 (ق) + drou],
    [nkhlsou], [نخلصو], [n + kh + l + s + ou],
    [nl9a], [نلقا], [n + l + 9 (ق) + a],
    [ytl3], [يطلع], [y + t + l + 3 (ع)],
    [3andek], [عندك], [3 (ع) + andek],
    [3andi], [عندي], [3 (ع) + andi],
  ),
) <hybrid_words>
===== Expansion des abréviations et termes techniques
#h(0.5cm) Les abréviations fréquemment utilisées dans les communications en ligne et dans le secteur des télécommunications sont développées afin de simplifier leur gestion par les modèles.

#figure(
  caption: [Expansion des abréviations françaises et techniques],
  kind: table,
  table(
    columns: (1fr, 1.5fr, 2.2fr),
    inset: (x: 7pt, y: 5pt),
    align: (center, center, center),
    fill: (x, y) => if y == 0 { } else if calc.rem(y, 2) == 1 {  } else { white },
    stroke: 0.5pt + black,
    [*Abréviation*], [*Forme développée*], [*Contexte*],
    [cnx / conx], [connexion], [Problèmes de réseau],
    [svp / stp], [s'il vous plaît / s'il te plaît], [Formules de politesse],
    [pb / prob], [problème], [Signalement d'incident],
    [pcq / pq], [parce que / pourquoi], [Justification],
    [rdv], [rendez-vous], [Intervention technique],
    [cv], [ça va], [État général],
    [4g / 3g / 5g], [4G / 3G / 5G], [Technologie mobile],
    [ftth], [FTTH], [Fibre optique],
    [qos], [QoS], [Qualité de service],
    [wifi / wify], [Wi-Fi], [Connexion sans fil],
  ),
) <abbrev_expansion>

===== Corrections linguistiques du français
#h(0.5cm) Une série de rectifications orthographiques se concentre sur les erreurs courantes présentes dans les commentaires, souvent dues à la frappe rapide sur mobile ou à l'influence de l'expression orale.

#figure(
  caption: [Corrections des fautes orthographiques fréquentes],
  kind: table,
  table(
    columns: (1.3fr, 1.5fr, 2fr),
    inset: (x: 7pt, y: 5pt),
    align: (center, center, center),
    fill: (x, y) => if y == 0 {  } else if calc.rem(y, 2) == 1 { } else { white },
    stroke: 0.5pt + black,
    [*Forme fautive*], [*Correction*], [*Type d'erreur*],
    [conexion / conection], [connexion], [Orthographe],
    [probleme / problem], [problème], [Accent / orthographe],
    [debit], [débit], [Accent oublié],
    [reseau / résau], [réseau], [Orthographe + accent],
    [abonement], [abonnement], [Consonne double manquante],
    [forfet / forfai], [forfait], [Orthographe],
    [couppure], [coupure], [Consonne double surnuméraire],
    [lanteur], [lenteur], [Orthographe],
    [c'est], [ce est], [Élision (mode full)],
    [j'ai], [je ai], [Élision (mode full)],
  ),
) <french_corrections>

===== Gestion des préfixes arabes et expressions composées protégées

#h(0.5cm) La morphologie arabe présente une difficulté supplémentaire : les préfixes de conjonction et de préposition (#emph[و، ف، ب، ك، ل، ال، وال، فال، بال]) sont collés au mot racine sans espace. Le normaliseur implémente une étape dédiée qui détecte et sépare ces préfixes.

#figure(
  caption: [Séparation des préfixes arabes],
  kind: table,
  table(
    columns: (1.3fr, 1.5fr, 2fr),
    inset: (x: 8pt, y: 5pt),
    align: (left, left, left),
    fill: (x, y) => if y == 0 {  } else if calc.rem(y, 2) == 1 {  } else { white },
    stroke: 0.5pt + black,
    [*Forme collée*], [*Forme séparée*], [*Analyse*],
    [والخدمة], [و الخدمة], [Préfixe "و" (et) + "الخدمة" (le service)],
    [فالخدمة], [ف الخدمة], [Préfixe "ف" (donc) + "الخدمة"],
    [بالخدمة], [ب الخدمة], [Préfixe "ب" (par/avec) + "الخدمة"],
    [كالخدمة], [ك الخدمة], [Préfixe "ك" (comme) + "الخدمة"],
    [للخدمة], [ل الخدمة], [Préfixe "ل" (à/pour) + "الخدمة"],
    [فالانترنت], [ف الانترنت], [Préfixe "ف" + "الانترنت"],
    [بالفيبر], [ب الفيبر], [Préfixe "ب" + "الفيبر" (la fibre)],
  ),
) <arabic_prefixes>

En parallèle, les #emph[expressions composées protégées] sont préservées dans leur intégrité pour éviter leur fragmentation par les étapes ultérieures.

#figure(
  caption: [Expressions composées protégées],
  kind: table,
  table(
    columns: (1.5fr, 2.2fr),
    inset: (x: 7pt, y: 5pt),
    align: (center, center),
    fill: (x, y) => if y == 0 {  } else if calc.rem(y, 2) == 1 { } else { white },
    stroke: 0.5pt + black,
    [*Expression*], [*Raison de la protection*],
    [my idoom], [Nom d'application produit],
    [fibre optique], [Terme technique composé],
    [core network], [Terme technique réseau],
    [tv box], [Nom d'appareil],
  ),
) <protected_compounds>
===== Version Full (modèles classiques)
#h(0.5cm) La version *Full* de normalisation est spécialement conçue pour les modèles de machine learning traditionnels tels que la régression logistique, les machines à vecteurs de support, les forêts aléatoires ou encore XGBoost, ainsi que pour des méthodes d'analyse statistique comme TF-IDF ou l'allocation de Dirichlet latente (LDA). Contrairement aux Transformers qui intègrent les relations contextuelles de manière implicite, ces modèles nécessitent un texte rigoureusement standardisé pour fonctionner efficacement.

Les opérations spécifiques à ce mode incluent :

*Suppression des stopwords* : élimination des mots très fréquents ayant une valeur sémantique limitée. La liste de stopwords utilisée est trilingue et soigneusement élaborée afin de conserver les éléments critiques comme les négations et certains marqueurs dialectaux.

#figure(
  caption: [Exemples de stopwords supprimés (mode Full)],
  kind: table,
  table(
    columns: (1.5fr, 1.5fr, 1.8fr),
    inset: (x: 7pt, y: 5pt),
    align: (center, center, center),
    fill: (x, y) => if y == 0 { } else if calc.rem(y, 2) == 1 {  } else { white },
    stroke: 0.5pt + black,
    [*Français*], [*Arabe*], [*Anglais*],
    [le, la, les, un, une], [من, عن, مع, كان], [the, a, an],
    [et, ou, mais, donc], [هذا, هذه, ذلك], [and, or, but],
    [je, tu, il, nous], [هو, هي, هم], [I, you, he, she],
    [très, plus, moins], [ثم, أو, إن], [for, with, to],
    [dans, sur, sous], [قد, أن, التي], [of, by, from],
  ),
) <stopwords>

#emph[Mise en minuscules] : tous les caractères latins sont convertis en minuscules, uniformisant les tokens.

#emph[Fusion des répétitions intentionnelles] : les répétitions expressives comme #emph[bzaf bzaf] sont conservées, tandis que les répétitions accidentelles (#emph[trèèèès]) sont réduites à leur forme canonique.
#block(
  inset: 10pt,
    stroke: 0.5pt + gray,
    radius: 4pt,
    fill: luma(248),
  width: 100%,
  [
    #align(center)[
      #text( weight: "bold", size: 11pt)[ Illustration d'une transformation en mode Full]
    ]
    #v(8pt)
    #align(center)[
      #text( size: 9pt, weight: "bold")[COMMENTAIRE ORIGINAL]
      #v(2pt)
      #text(size: 10pt, style: "italic")["Slt, cnx 4G trop lente, nchalh yt7sn!"]
    ]
    #v(6pt)
   
    #v(6pt)
    #grid(
      columns: (1fr, 2fr),
      gutter: 8pt,
      row-gutter: 6pt,
      [
        #text( weight: "bold")[ Dictionnaire :]
      ],
      [
        #text(style: "italic")["Salut, connexion 4G trop lente, إن شاء الله يتحسن !"]
      ],
      [
        #text( weight: "bold")[ Stopwords :]
      ],
      [
        #text(style: "italic")["Salut connexion 4G lente إن شاء الله يتحسن"]
      ],
      [
        #text( weight: "bold")[ Minuscules :]
      ],
      [
        #text(style: "italic")["salut connexion 4g lente إن شاء الله يتحسن"]
      ],
    )
  ]
)

===== Version BERT (AraBERT, DziriBERT)
#h(0.5cm) Les modèles Transformer tels qu'AraBERT, DziriBERT ou CAMeL-BERT reposent sur une architecture à base d'attention, leur permettant de saisir des relations contextuelles complexes. Par opposition aux modèles traditionnels, ces modèles tirent parti des éléments comme la ponctuation, la casse et certains mots fonctionnels pour construire des représentations contextualisées riches. Une normalisation excessive risquerait cependant de nuire à leurs performances.

Ainsi, la version de normalisation spécifique à BERT a été conçue pour adopter une approche minimaliste, présentant les caractéristiques suivantes :


- #emph[Homogénéisation de l'écriture arabe] (identique à la version Full).
- #emph[Conversion des emojis] en texte arabe.
- #emph[Expansion des abréviations courantes] (#emph[cnx → connexion], #emph[svp → s'il vous plaît]).
- #emph[Correction des fautes orthographiques fréquentes].
- #emph[Conversion sélective de l'arabizi] : seuls les mots à haute valeur sémantique (expressions religieuses, serments) sont convertis ; la Darja latine courante (#emph[khouya], #emph[sahbi], #emph[wakha]) est préservée en écriture latine.
- #emph[Absence de suppression des stopwords].
#block(
  inset: 10pt,
    stroke: 0.5pt + gray,
    radius: 4pt,
    fill: luma(248),
  width: 100%,
  [
    #align(center)[
      #text( weight: "bold", size: 11pt)[ Illustration d'une transformation en mode BERT]
    ]
    #v(8pt)
    #align(center)[
      #text( size: 9pt, weight: "bold")[COMMENTAIRE ORIGINAL]
      #text(size: 10pt, style: "italic")["Salam khouya, nchalh la connexion wifi tkhdm mliha"]
    ]
    #v(4pt)
    #v(4pt)
    #align(center)[
      #text( size: 9pt, weight: "bold")[ APRÈS NORMALISATION BERT]
      #text(size: 10pt, style: "italic")["Salam khouya, إن شاء الله la connexion wifi tkhdm mliha"]
    ]
    #v(8pt)
    #text(size: 9pt)[
      #text(weight: "bold")[*Observations*] : la structure syntaxique est préservée, les mots dialectaux 
      #text(style: "italic")[khouya] , #text(style: "italic")[tkhdm] , #text(style: "italic")[mliha] 
      sont conservés en latin, seul le mot à forte charge sémantique 
      #text(style: "italic")[nchalh] est converti en arabe.
    ]
  ]
)

#h(0.5cm) La normalisation par dictionnaire permet d'uniformiser le texte, mais elle ne suffit pas à résoudre le problème de la *haute dimensionnalité* des représentations vectorielles. En effet, après avoir appliqué la vectorisation TF-IDF au corpus normalisé, le vocabulaire reste très riche avec *21 371 mots distincts*. Une telle représentation entraîne un espace vectoriel extrêmement *creux*, ce qui accentue le bruit statistique et peut conduire au surajustement des modèles. Pour répondre à cette problématique, une seconde approche est introduite dans la section suivante, s'appuyant sur une sélection rigoureuse des caractéristiques à l'aide de critères statistiques comme Chi², la dissimilarité ou encore la fréquence.


==== Tokenisation pour les modèles classiques (mode Full)

#h(0.5cm) Après une normalisation complète ( suppression des mots vides, mise en minuscules et agrégation des répétitions ), la tokenisation parachève le processus de segmentation, immédiatement avant la vectorisation. Pour les modèles traditionnels (régression logistique, SVM, XGBoost), on privilégie une approche simple et robuste : une segmentation fondée sur les espaces et les signes de ponctuation, complétée par des #emph[*n-grammes*] afin de saisir un contexte local limité.


- #strong[Exemples concrets]

#figure(
  caption: [Application du tokenizer sur des commentaires après normalisation Full.],
  kind: table,
  table(
    columns: (1.4fr, 2.2fr, 2.2fr),
    inset: (x: 6pt, y: 5pt),
    align: (left, left, left),
    fill: (x, y) => if y == 0 {  } else if calc.rem(y, 2) == 1 {  } else { white },
    stroke: 0.5pt + black,
    [*Type*], [*Texte normalisé (Full)*], [*Tokens obtenus*],
    [Français + abrév.], [`salut connexion 4g lente améliorer svp`], [`["salut", "connexion", "4g", "lente", "améliorer", "svp"]`],
    [Darija (arabe)], [`خدمة الانترنت مقطعة بزاف راهي كارثة`], [`["خدمة", "الانترنت", "مقطعة", "بزاف", "راهي", "كارثة"]`],
    [Arabizi normalisé], [`n9drou nkhlsou had problème`], [`["n9drou", "nkhlsou", "problème"]`],
    [Mixte + négation], [`machi mliha service vraiment nul`], [`["machi", "mliha", "service", "vraiment", "nul"]`],
  ),
)<exemple_tokinization>

#v(1em)
- #strong[Bigrammes pour les modèles classiques]

#h(0.5cm)Les modèles linéaires ne capturent pas intrinsèquement les relations entre mots adjacents. Par conséquent, on intègre systématiquement les bigrammes les plus fréquents, à savoir ceux apparaissant dans au moins cinq documents. Quant aux trigrammes, ils sont exclus : ils augmentent excessivement la dimensionnalité pour un gain négligeable, comme l’ont démontré nos tests préliminaires.


#h(0.5cm)Cette tokenisation produit des séquences de tokens qui alimentent directement la vectorisation TF-IDF, décrite ultérieurement (* Ingénierie des features*). Aucune lemmatisation ni racinisation n'est appliquée en mode complet : les dictionnaires de normalisation ont déjà régulé les variations orthographiques de manière contrôlée.
=== Enrichissement Sémantique et Annotation
==== Annotation automatique avec l'API Gemini

===== Stratégie d'annotation

#h(0.5cm) L'API Gemini de Google a été choisie pour l'annotation des commentaires en raison de trois avantages principaux : sa polyvalence dans le traitement de textes multilingues (arabe, français, darija), ses performances en analyse de sentiment, et son accès gratuit au service pour la recherche académique.

Le message d'instruction destiné à Gemini a été élaboré avec précision afin de garantir des résultats exploitables. Les directives incluaient notamment :

- Production du résultat seul, sans texte superflu
- Attribution d'une étiquette de sentiment : positif, neutre ou négatif
- Association de chaque commentaire avec un score sentimental proportionnel, allant de -1 (très négatif) à +1 (très positif)
- Justification succincte et niveau de confiance exprimés en moins de 8 mots

Grâce à cette structuration rigoureuse, l'intégralité du corpus a pu être annotée automatiquement.

===== Validation par deux annotateurs humains

#h(0.5cm) Pour évaluer la fiabilité de Gemini, une simple analyse de ses réponses ne suffit pas ; il est nécessaire de les confronter aux données réelles du terrain. Nous avons donc constitué un échantillon de 3 944 commentaires, représentatif de la diversité du corpus. Deux annotateurs humains indépendants ont examiné cet échantillon, chacun attribuant une étiquette de sentiment sans connaître les prédictions de Gemini.

Nous avons utilisé le coefficient Kappa de Cohen comme métrique d'évaluation. Contrairement à la simple exactitude *accuracy*, cette mesure corrige les accords fortuits. Le résultat s'avère ainsi bien plus fiable.

#block(
  stroke: (left: 4pt + rgb("#dc2626")),  // Bordure gauche rouge
  inset: 12pt,
  fill: rgb("#fef2f2"),                   // Fond rouge très clair
  radius: 4pt,
  width: 100%,
  [
    #align(left)[
      #text(fill: rgb("#dc2626"), weight: "bold", size: 11pt)[*Rappel interprétatif :*]
    ]

    #align(left)[
      Un Kappa de $0$ signifie un accord purement aléatoire. Un Kappa de $1$ signifie un accord parfait. \
      Les valeurs entre $0,61$ et $0,80$ sont considérées comme un accord #emph{bon} selon l'échelle de Landis et Koch.
    ]
  ]
)


#h(0.5cm) Une fois le corpus annoté selon cette stratégie, il convient désormais d'en évaluer la fiabilité. Le chapitre 5 présente les résultats de cette évaluation ainsi que leur interprétation détaillée.




==== Traitement des flags — étiquetage sémantique
#h(0.5cm)  L'annotation automatique via l’*API Gemini* attribue une polarité de base ( *positif*,* neutre*,* négatif* ), mais cette granularité s’est avérée insuffisante pour refléter la richesse sémantique des commentaires en darija. L’expérience a montré qu’un client peut exprimer une satisfaction globale tout en formulant une critique ciblée, ou adresser une question polie sans intention négative manifeste – des cas que Gemini lui‑même peine à désambiguïser, et qui restent difficiles même pour un annotateur humain.

Afin d’affiner l’analyse, nous avons intégré un module d’étiquetage par règles (*rule-based*), fondé sur un dictionnaire centralisé d’expressions régulières. Ce module identifie des catégories sémantiques précises, permettant ainsi une évaluation multidimensionnelle de chaque avis.

Le système d'étiquetage analyse chaque commentaire pour y détecter la présence ou l'absence de six catégories sémantiques, résumées dans le tableau *@flags_categories*.

#figure(
  caption: [Catégories sémantiques détectées par le module d'étiquetage.],
  kind: table,
  table(
    columns: (1.2fr, 1.5fr, 3.5fr),
    inset: (x: 7pt, y: 8pt),
    align: (left, left, left),
    fill: (x, y) => if y == 0 {  } else if calc.rem(y, 2) == 1 {  } else { white },
    stroke: 0.5pt + black,
    [*Flag*], [*Type détecté*], [*Description logique*],
    [*`social`*], [Formule sociale], "Messages de vœux, remerciements ou bénédictions sans valeur sentimentale (`بالتوفيق`, `bon courage`, `ربي يوفقكم`).",
    [*`encouragement`*], [Encouragement], "Messages de soutien pur, souvent sans lien direct avec le service (`bravo`, `bonne continuation`).",
    [*`suggestion`*], [Suggestion / Positif conditionnel], "Satisfaction exprimée mais assortie d'une restriction ou d'une demande d'amélioration (`mliha ms tehseno`).",
    [*`plainte`*], [Plainte explicite], "Contient une frustration, un signalement de problème technique, ou une demande de contact au service client. L'intensité varie.",
    [*`negation`*], [Négation grammaticale], "Détecte la présence d'une négation (`machi`, `ما`, `ne...pas`), qu'elle annule un positif (`machi mliha`) ou double un négatif (`machi khaybe`).",
    [*`mixte`*], [Mixte / Contradiction], "Co-occurrence d'un terme positif et d'un terme négatif fort dans la même phrase (`connexion mliha ms coupure`)."
  ),
) <flags_categories>
=====  Architecture : dictionnaire + expressions régulières
#h(0.5cm) Face au caractère non structuré et imprévisible du dialecte algérien sur les réseaux sociaux, l'approche fondée sur des règles (rule-based) présente des avantages notables : une transparence complète, puisque les motifs de détection sont explicités dans un dictionnaire unique. Ce dernier est structuré en grandes catégories lexicales:
#figure(
  caption: [Exemples de motifs dans le dictionnaire centralisé des flags.],
  kind: table,
  table(
    columns: (1.6fr, 1.5fr, 2.5fr),
    inset: (x: 7pt, y: 7pt),
    align: (left, left, left),
    fill: (x, y) => if y == 0 {  } else if calc.rem(y, 2) == 1 {  } else { white },
    stroke: 0.5pt + black,
    [*Famille lexicale*], [*Flag associé*], [*Exemples de motifs*],
    [Mots positifs DZ], [positif], [ mliha , mzian , tamam , zwin ],
    [Mots négatifs forts], [ mixte , plainte ], [ nul , khaybe , كارثة ,  coupure ],
    [Connecteurs adversatifs], [suggestion], [ ms, bss , walakin , mais , par contre ],
    [ Verbes d'amélioration ], [suggestion ], [ tehseno , tzidou , améliorer , تحسين,  يزيدوا],
    [Négations DZ], [ negation], [machi , ma...sh , لا , ne...pas],
  ),
)

===== Logique de détection par flag (sous-types, priorités)

#h(0.5cm) La détection ne se limite pas à une simple présence lexicale. Pour chaque flag, une logique spécifique détermine le sous-type et applique des règles de priorité, comme l'illustre l'exemple du flag `suggestion` ci-dessous.

#figure(
  caption: [Logique de détection du flag `suggestion` s'appuyant sur 3 conditions (`A ∧ B ∧ C`).],
  kind: table,
  table(
    columns: (1.75fr, 3.5fr, 1.5fr),
    inset: (x: 7.5pt, y: 7pt),
    align: (left, left, left),
    fill: (x, y) => if y == 0 { } else if calc.rem(y, 2) == 1 {  } else { white },
    stroke: 0.5pt + black,
    [*Condition*], [*Description*], [*Exemple*],
    [A (Mot positif DZ)], "Présence d'un terme évaluatif positif.", [mliha],
    [B (Adversatif DZ)], "Présence d'un connecteur d'opposition.", [ms],
    [C (Amélioration DZ)], "Verbe ou demande d'action correctrice.", [tehseno],
  ),
) <suggestion_logic>

La combinaison de ces conditions génère un sous-type précis :
- `pur` (`A ∧ B ∧ C`) : Positif conditionnel pur ("connexion mliha ms tehseno", "l'appli zwina bss lukan tzidou fiha").
- `pos_adv` (`A ∧ B ∧ ¬C`) : Positif atténué, la suggestion est implicite ("mliha ms bezzaf", "c'est bien mais pas parfait").
- `masked_neg` (`A ∧ B ∧ C ∧ NEG`) : La suggestion est noyée dans un commentaire négatif fort ("machi barka nul ms tehseno"), le flag est supprimé pour laisser place au flag `mixte`.

D'autres flags intègrent des heuristiques spécifiques, par exemple :
- `flag_plainte` : un contact seul (*prv_implicit*) sans frustration explicite est considéré comme un négatif implicite, mais les messages contenant "repondiw prv" ou des références à un problème non résolu sont étiquetés "prv" (négatif fort). Les réponses de l'opérateur (type "ندعوكم للتواصل") sont exclues (`at_response`).
- `flag_negation` : distingue trois cas : `neg_pos` (négation + positif = négatif), `neg_neg` (double négation = positif faible), `neg_seule` (négation sans contexte clair).
- `flag_mixte` : se contente de détecter la co-occurrence `POS ∧ NEG_FORT` sans logique supplémentaire.
// ============================================================
// SECTION : Ingénierie des Features et Préparation Finale
// ============================================================

==== Sélection de features et rééquilibrage

===== Problématique de la haute dimensionnalité

#h(0.5cm) À l'issue des phases de normalisation et d'annotation automatique, le corpus présente une caractéristique commune à la plupart des projets de fouille de textes : une #emph[dimensionnalité excessivement élevée] couplée à une #emph[sparsité importante] de la matrice document-terme, configuration classiquement défavorable à l'apprentissage statistique.

#h(0.5cm) Ce phénomène, connu sous le nom de « fléau de la dimensionnalité » (#emph[curse of dimensionality]), a été formalisé par Bellman (1961) @bellman1961 et conduit, en classification de textes, à une dégradation des performances des classifieurs linéaires et à base de distance @joachims1998.

Cette situation engendre trois difficultés majeures :

1. *Amplification du bruit statistique* : La majorité des termes n'apparaissent que dans une fraction infime des documents. Ces mots rares, souvent des fautes de frappe ou des hapax, n'apportent pas de signal utile mais contribuent au risque de surapprentissage (#emph[overfitting]).

2. *Malédiction de la dimensionnalité* : Dans un espace de très haute dimension, la distance euclidienne entre deux documents tend à perdre sa significativité. Les classificateurs fondés sur des mesures de distance (SVM, k-plus proches voisins) voient leurs performances se dégrader.

3. *Coût computationnel* : L'entraînement de modèles Transformers sur des séquences de tokens reste viable, mais l'ajout de caractéristiques supplémentaires — comme les flags ou le TF‑IDF — nécessite une réduction drastique de la dimensionnalité pour éviter une explosion des paramètres.

Notre stratégie de réduction dimensionnelle s'articule autour de #emph[trois filtres séquentiels], appliqués dans un ordre précis : filtrage par fréquence, sélection par test du #emph[Chi²], puis filtrage par dissimilarité inter-classes. Chaque étape élimine une catégorie spécifique de bruit tout en préservant les termes véritablement discriminants.

===== Filtrage par fréquence (min_df / max_df)

#h(0.5cm) La première étape, la plus agressive, consiste à éliminer les mots trop rares ou trop fréquents selon des seuils définis empiriquement. Comme présenté au chapitre 3, les termes dont la fréquence documentaire $"df"(t) < "min_df"$ correspondent souvent à des hapax, tandis que ceux pour lesquels $"df"(t) > "max_df" times N$ sont généralement des mots-outils peu discriminants. Yang et Pedersen (1997) ont démontré l'efficacité de ce filtrage @yang1997.

====== Choix des seuils

#h(0.5cm) Après une série de tests sur un échantillon de validation, les seuils suivants ont été retenus :
- Un seuil bas (`min_df`) élimine les hapax et les fautes de frappe uniques.
- Un seuil haut (`max_df`) supprime les mots présents dans une très large majorité des documents, capturant ainsi les stop-words résiduels non couverts par les listes standard.
- Une liste noire de termes — articles, pronoms, conjonctions, chiffres isolés — vient parachever l'ensemble, éliminant les mots purement grammaticaux qui franchiraient néanmoins les seuils de fréquence.

Ces termes rares, souvent des noms propres (identifiants de clients, numéros de réclamation) ou des fautes de frappe idiosyncratiques, n'auraient fait qu'ajouter du bruit aux modèles. Leur suppression constitue donc un premier assainissement essentiel.

===== Sélection par test du Chi²

#h(0.5cm) Le filtrage par fréquence réduit le vocabulaire mais conserve encore de nombreux mots, dont beaucoup restent faiblement associés aux classes de sentiment. La sélection par test statistique du Chi² — dont le principe et la formulation sont présentés au chapitre 3 — permet d'identifier les termes les plus dépendants de la variable cible (`negatif`, `neutre`, `positif`) @forman2003.

Pour chaque terme, on retient son score maximal parmi les trois classes, puis on sélectionne les termes avec les scores les plus élevés. Ce mécanisme favorise les termes qui distinguent nettement au moins une classe des deux autres.

#block(
  fill: luma(240),
  inset: 8pt,
  radius: 4pt,
  [*Note* : Conformément aux observations de Manning et al. (2008) @manning2008, le test du Chi² peut sélectionner des termes thématiques (termes géographiques, prépositions résiduelles) dont le score est élevé non pour des raisons sentimentales, mais parce qu'ils sont sur-représentés dans une classe particulière. Cette limite justifie l'étape de filtrage par dissimilarité décrite ci-après.]
)

Toutefois, certains termes retenus sont davantage des marqueurs thématiques que des marqueurs sentimentaux. Le filtre suivant vise spécifiquement ce problème.

===== Filtrage par dissimilarité inter-classes

#h(0.5cm) Pour pallier la limite du χ² — qui sélectionne des termes thématiques non sentimentaux — nous proposons une métrique complémentaire, que nous nommons #emph[dissimilarité inter-classes]. À notre connaissance, cette approche n'a pas été décrite dans la littérature pour la sélection de termes en analyse de sentiments. Elle s'inspire toutefois du critère de variance inter-classes utilisé en analyse discriminante linéaire (Fisher, 1936) @fisher1936.

Le test du Chi² identifie les termes dont la distribution diffère entre classes, mais ne garantit pas que cette différence soit #emph[sémantiquement interprétable] comme un marqueur de sentiment. Un terme géographique ou thématique peut être effectivement distribué différemment entre les classes, sans pour autant être un marqueur de sentiment fiable.

Le filtre par #emph[dissimilarité inter-classes] vise à éliminer ces termes dont la moyenne TF‑IDF varie peu entre les classes, c'est-à-dire les termes qui sont #emph[présents de façon homogène] dans les trois catégories. L'hypothèse sous-jacente est qu'un bon marqueur de sentiment doit avoir une moyenne TF‑IDF significativement différente entre la classe qu'il caractérise et les deux autres.

====== Formalisation de la métrique de dissimilarité (rappel)

#h(0.5cm) La définition théorique de la métrique de dissimilarité $d(t)$ (moyennes TF‑IDF par classe, écart‑type) a été donnée au chapitre 3. Nous n'en rappelons ici que le principe : $d(t)$ mesure la dispersion des moyennes TF‑IDF d'un terme entre les trois classes de sentiment. Plus $d(t)$ est élevé, plus le terme est discriminant.

====== Choix du seuil de dissimilarité

#h(0.5cm) Le seuil de dissimilarité a été déterminé par optimisation sur un échantillon de validation de termes annotés manuellement comme "sentimentaux" ou "non sentimentaux". Le seuil retenu offre le meilleur compromis entre précision et rappel.

====== Prise en compte spécifique des marqueurs de négation

#h(0.5cm) Les marqueurs de négation constituent un cas particulier. L'importance des négations pour l'inversion de polarité en analyse des sentiments a été soulignée par plusieurs travaux. Pang et al. (2002) notent que leur prise en compte améliore significativement les performances @pang2002. Plus récemment, Koto et al. (2020) confirment ce résultat pour l'arabe dialectal @koto2020.

#h(0.5cm) Bien qu'ils puissent présenter une dissimilarité modérée (car présents aussi bien dans les négatifs que dans les neutres ou positifs sous forme de double négation), leur importance sémantique pour la détection de la polarité justifie leur préservation systématique. Une règle explicite a donc été ajoutée : tout terme contenant une négation forte est conservé quel que soit son score de dissimilarité.

#h(0.5cm) Les termes supprimés par ce filtre sont majoritairement des mots-outils, des termes géographiques et des termes thématiques non sentimentaux (noms de produits, types de connexion). Cette réduction drastique est délibérée : elle recentre le vocabulaire sur les seuls termes véritablement porteurs d'information sentimentale.

==== Métriques de qualité des données

#h(0.5cm) Pour quantifier l'impact de cette réduction sur la #emph[qualité intrinsèque des données] — indépendamment de tout modèle — trois métriques complémentaires ont été suivies à chaque étape :

1. *Sparsité* : proportion de zéros dans la matrice document‑terme. Une sparsité élevée indique une représentation creuse, où chaque document n'utilise qu'une infime fraction du vocabulaire.

2. *Nombre moyen de mots uniques par document* : indicateur de la densité sémantique. Une baisse de cette valeur signifie que les documents sont représentés par des termes plus fréquents et plus partagés, réduisant le bruit lexical.

3. *Score de silhouette* : mesure de la séparation entre classes dans l'espace vectoriel (après réduction PCA), dont la formulation est présentée au chapitre 3 @rousseeuw1987. Un score qui augmente (devient moins négatif) indique que les documents d'une même classe tendent à se regrouper.

===== Validation visuelle par t-SNE

#h(0.5cm) Pour appréhender qualitativement l'effet des filtres sur la structure des données, une projection t‑SNE (#emph[t-distributed Stochastic Neighbor Embedding]) a été réalisée à chaque étape. Cette technique de réduction non linéaire, introduite par van der Maaten et Hinton (2008) @vandermaaten2008, projette les documents dans un espace à deux dimensions tout en préservant les voisinages locaux.

*Interprétation* : L'amélioration progressive de la structuration visuelle, couplée à l'augmentation du score de silhouette, atteste que notre stratégie de filtrage séquentiel ne se contente pas de réduire la dimensionnalité — elle #emph[améliore activement la qualité du signal] en éliminant les caractéristiques non pertinentes.

===== Rééquilibrage du corpus

#h(0.5cm) Comme expliqué au chapitre 3, le sous‑échantillonnage (*undersampling*) consiste à réduire les classes majoritaires pour atteindre un effectif cible identique pour toutes les classes. Nous appliquons cette technique pour corriger le déséquilibre modéré observé dans notre corpus annoté.

#h(0.5cm) La distribution initiale présentait un déséquilibre modéré entre les trois classes. Nous avons fixé un effectif cible correspondant à la taille de la classe la moins représentée après filtrage.

#h(0.5cm) Après undersampling aléatoire sans remise, le corpus est parfaitement équilibré. Cette stratégie évite tout biais d'apprentissage en faveur de la classe majoritaire.

===== Vectorisation finale : flags + TF‑IDF

#h(0.5cm) La sélection de features présentée ci-dessus opère exclusivement sur le contenu textuel brut. Toutefois, notre pipeline enrichit chaque document de deux sources d'information supplémentaires : les #emph[flags sémantiques] (détectés par expressions régulières) et les #emph[subtypes] associés.

#h(0.5cm) Cette architecture hybride, combinant des caractéristiques issues de règles linguistiques (flags) et des caractéristiques issues de pondération statistique (TF‑IDF), s'inscrit dans la famille des systèmes hybrides pour l'analyse des sentiments. Awang et Mohd Nafis (2022) proposent une approche similaire où un TF‑IDF amélioré est couplé à une sélection par SVM‑RFE @awang2022. Notre architecture se distingue par l'ajout de subtypes qui capturent des nuances sémantiques fines. La pondération TF‑IDF utilisée est celle définie au chapitre 3 @salton1988.

====== Composition du vecteur final

Le vecteur représentant chaque document combine trois groupes de caractéristiques :

1. *Vecteur TF‑IDF des meilleurs termes* : Parmi les termes retenus après Chi² + dissimilarité, les premiers selon le score Chi² sont conservés. Chaque document est représenté par un vecteur TF‑IDF de dimension correspondante.

2. *Flags binaires* : Des indicateurs binaires signalent la présence ou l'absence de motifs sémantiques spécifiques : `positif`, `negation`, `mixte`, `social`, `encouragement`, `plainte`, `suggestion`.

3. *Subtypes* : Des caractéristiques supplémentaires encodent des nuances sémantiques fines :
   - `masked_neg` : négation masquée dans une suggestion
   - `prv` : plainte avec mention d'un problème antérieur non résolu
   - `produit` : encouragement ou critique portant spécifiquement sur un produit

====== Justification du choix du nombre de termes

#h(0.5cm) Le choix de conserver uniquement les meilleurs termes répond à deux contraintes opérationnelles :

1. *Compatibilité avec l'architecture du modèle* : Dans notre pipeline final, le vecteur TF‑IDF est concaténé aux embeddings produits par le modèle Transformer. L'ajout de dimensions supplémentaires reste raisonnable pour un classificateur linéaire ou un petit réseau dense.

2. *Conservation des termes les plus discriminants* : Les premiers termes de la liste Chi² concentrent l'essentiel du pouvoir discriminant. Au-delà d'un certain seuil, les gains marginaux en performance deviennent négligeables, comme l'a confirmé une validation croisée préliminaire.


== Conclusion
#h(0.5cm) Ce chapitre a posé les fondations techniques et méthodologiques sur lesquelles repose l'intégralité de la chaîne d'analyse. Nous avons établi que le passage d'un commentaire brut en dialecte algérien à un vecteur exploitable par un modèle de classification exige bien plus qu'un nettoyage superficiel : il nécessite une chaîne de décisions cohérentes, depuis le choix de l'infrastructure jusqu'à la formalisation de métriques de sélection de traits originales.

#h(0.5cm) L'infrastructure Docker/Spark, déployée sous les contraintes réelles du marché algérien, a démontré sa viabilité pour un traitement distribué à l'échelle visée. La stratégie de normalisation unification orthographique, conversion arabizi, expansion des abréviations télécom a permis de réduire significativement la fragmentation lexicale propre au dialecte.

 La réduction dimensionnelle séquentielle, articulée autour d'un filtre fréquentiel, d'un test du Chi² et d'une métrique de dissimilarité inter-classes que nous avons proposée, a amélioré la séparation entre classes sans sacrifier les marqueurs sentimentaux fins. Le vecteur final, combinant TF-IDF et flags binaires encodant des nuances sémantiques spécifiques (négation masquée, plainte récurrente, critique produit), constitue une représentation hybride adaptée aux spécificités du corpus télécom algérien. Ces fondations conditionnent directement les résultats expérimentaux que le chapitre 5 examine.