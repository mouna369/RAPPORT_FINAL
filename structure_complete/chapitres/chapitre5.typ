




#set par(justify: true)






= Expérimentations, résultats et analyse
== Introduction
#h(0.5cm) Ce chapitre expose les expérimentations conduites dans le cadre de l'analyse de sentiment et de la classification des motifs à partir de commentaires en dialecte algérien la darija. Nous y présentons les résultats obtenus, puis nous soumettons les performances des différents modèles et approches méthodologiques à une analyse critique et systématique.

#h(0.5cm) Nous décrivons d'abord l'environnement technique ayant soutenu les expériences. L'infrastructure repose sur un pipeline de données orchestré par Docker Compose, au sein duquel MongoDB assure la persistance, Apache Kafka gère les flux temps réel, et Apache Spark traite les transformations volumétriques. L'entraînement et le fine-tuning des modèles ont été réalisés sur Kaggle et Google Colab , DziriBERT, modèle pré-entraîné exclusivement sur la darija algérienne, constitue le pivot de l'architecture finale.

#h(0.5cm)La préparation des corpus a nécessité un effort méthodologique substantiel. Le pipeline de prétraitement intègre le nettoyage syntaxique, la normalisation linguistique et la tokenisation . il incorpore également une méthode de déduplication par règles contextuelles, conçue pour absorber les redondances propres aux commentaires issus des réseaux sociaux. Nous observons, à partir des évaluations initiales, quatre verrous persistants : le surapprentissage, le déséquilibre des classes, la confusion lexicale intersémantique, et un faible rappel des instances positives. Ces obstacles ont guidé le développement du pipeline de prétraitement avancé présenté dans ce chapitre.

#h(0.5cm) Les sections centrales comparent deux familles de modèles. Le chapitre s'achève sur la mise en œuvre d'une inférence hybride qui articule un système de règles expertes avec DziriBERT : la composante symbolique filtre les cas limites que le modèle neuronal traite avec une confiance marginale, ce qui réduit le temps d'inférence tout en améliorant la précision mesurée en production.

#h(0.5cm) Une discussion critique clôt l'ensemble elle porte sur les limitations identifiées, les pistes d'amélioration envisagées, et les contributions de ce travail à l'analyse de sentiment en darija algérienne dans le cadre d'un tableau de bord opérationnel.


== Environnement technique et cadre opérationnel

=== Infrastructure matérielle et logicielle
#h(0.5cm) Les expérimentations et le développement ont été réalisés sur deux postes de travail, dont les caractéristiques matérielles sont résumées dans le tableau .

#figure(
  caption: [Caractéristiques matérielles des postes de développement.],
  kind: table,
  table(
    columns: (auto, auto, auto),
    align: (left, left, left),
    stroke: 0.5pt + black,
    inset: (x: 6pt, y: 5pt),
    [Composant], [Poste 1 (auteur)], [Poste 2 (binôme)],
    [*Modèle*], [HP EliteBook 840 G3], [HP EliteBook 840 G3 (équivalent)],
    [*Processeur*],
    [Intel Core i5-6300U @ 2,40 GHz (2 cœurs, 4 threads)],
    [Intel Core i5-6300U @ 2,40 GHz (2 cœurs, 4 threads)],

    [*Mémoire RAM*], [8,00 Go], [16,00 Go],
    [*Carte graphique*], [Intel HD Graphics 520 (128 Mo dédiés)], [Intel HD Graphics 520 + NVIDIA GeForce 940MX (2 Go)],
    [*Stockage*], [SSD TEAM T253512GB (477 Go) + SSD SanDisk SD7SN6S-256G-1006 (238 Go)], [SSD NVMe 512 Go + HDD 1 To],
    [*Système d’exploitation*],
    [Windows 11 Professionnel 64 bits/ Ubuntu 24.04.4 LTS (WSL2)],
    [Ubuntu 24.04.4 LTS (WSL2) / Windows 11],
  ),
) <hardware_summary>

Du côté logiciel, la stack repose sur les composants suivants :
#align(center)[
  #table(
    columns: (1.5fr, 1fr),
    align: (left, center),
    stroke: 1pt,
    fill: (_, row) => if calc.odd(row) {} else { none },

    [*Composant*], [*Logo*],

    [*Conteneurisation et orchestration* : Docker Engine (v29.2.1) + Docker Compose (v5.0.2) – configuration détaillée au chapitre 4, section 4.3.1.],
    [#image("../images/Docker.jpg", height: 1.5cm)],

    [*Base de données* : MongoDB (v6.0), utilisée aussi bien en local (port 27018) que sur MongoDB Atlas pour la persistance cloud.],
    [#image("../images/MongoDBLogo.png", height: 1.2cm)],

    [*File d'attente et streaming* : Apache Kafka (v7.5.0) avec Zookeeper.],
    [#image("../images/Apache_Kafka_logo.png", height: 1.2cm)],

    [*Traitement distribué* : Apache Spark (v3.5) en mode cluster (1 master + 3 workers), orchestré via Docker.],
    [#image("../images/Apache_Spark_logo.png", height: 1.2cm)],

    [*Entraînement des modèles* : Les phases d'entraînement et de fine-tuning des modèles Transformers (DziriBERT, AraBERT ,etc.) ont été réalisées sur les plateformes Kaggle et Google Colab en environnement CPU (absence de GPU dédié sur les postes locaux).],
    [#grid(
      rows: 2,
      image("../images/Kaggle_logo.png", height: 1cm),
      image("../images/collablogo.png", height: 1cm),
    )],

    [*APIs et LLMs externes* : Groq (modèle llama-3.3-70b-versatile), Google Gemini API (pour l'annotation automatique initiale).],
    [#image("../images/Groq_logo.jpg", height: 1cm)],

    [*Monitoring* : Kafka UI (port 8088), Spark UI (port 8080), MongoDB Compass.],
    [#image("../images/Apache_Kafka_logo.png", height: 1.2cm)],

    [*Inférence distante* : Tunnel ngrok pour exposer l'API Kaggle hébergeant le modèle DziriBERT.],
    [#image("../images/ngrok.jpg", height: 1.2cm)],

    [*Rédaction du rapport* : Typst.], [#image("../images/Typst.png", height: 1.2cm)],
  )
]

=== Langages et bibliothèques utilisés
Le langage principal utilisé est *Python* 3.10 (Foundation 2025), reconnu pour sa lisibilité, sa polyvalence et la richesse de son écosystème scientifique.

Les bibliothèques Python suivantes ont été mobilisées :

* Traitement et analyse de données *

- *Pandas ≥ 2.0.0* : pour la manipulation et l'analyse de données tabulaires (McKinney 2010).

- *NumPy 1.26.0 :* pour les opérations mathématiques et matricielles performantes (Harris et al. 2020).

- *OpenPyXL ≥ 3.1.0 :* pour la lecture et l'écriture de fichiers Excel (Gazoni 2025).

*Traitement distribué et Big Data*
- *PySpark 3.5.0 :* pour le traitement distribué de données à grande échelle via Apache Spark (Zaharia et al. 2016).

- *FindSpark ≥ 2.0.0 :* pour l'intégration automatique de Spark dans les environnements Jupyter.

*Base de données et messagerie*
- *PyMongo 4.6.1 :* pour l'interaction avec les bases de données MongoDB, y compris MongoDB Atlas (MongoDB Team 2025).

- *Confluent-Kafka 2.3.0 :* pour la production et la consommation de messages via Apache Kafka (Kreps et al. 2011).

*Machine Learning et Traitement du Langage Naturel (NLP)*
- *PyTorch 2.2.0 :* pour le développement de modèles de deep learning (Paszke et al. 2025).

- *Transformers 4.38.0 :* pour l'utilisation de modèles pré-entraînés basés sur l'architecture Transformer (Wolf et al. 2020).

- *Scikit-learn 1.4.0 :* pour les algorithmes de machine learning classiques, les mesures de similarité textuelle et le prétraitement des données (Pedregosa et al. 2011).

*Visualisation*
- *Matplotlib ≥ 3.7.0 :* pour la création de graphiques et de courbes d'évolution (Hunter 2007).

- *Seaborn ≥ 0.12.0 :* pour la visualisation statistique avancée de données (Waskom 2021).

- *Plotly 5.19.0 :* pour les visualisations interactives et dynamiques (Plotly Technologies 2015).

- *Dash 2.14.0* : pour la création d'applications web interactives dédiées à la visualisation de données (Plotly 2025).

*Utilitaires et environnement*
- *Jupyter ≥ 1.0.0 :* pour le développement interactif et la documentation exécutable (Kluyver et al. 2016).

- *Python-DotEnv 1.0.0 :* pour la gestion des variables d'environnement et des configurations.

- *TQDM 4.66.0 :* pour l'affichage de barres de progression lors des traitements longs.

- *Spark Reporter :* module personnalisé développé pour le suivi et le reporting des jobs Spark.


=== Pipeline de données et orchestration
Le pipeline de données (collecte, nettoyage, normalisation, inférence, stockage) est entièrement orchestré par Docker Compose. Les services mis en œuvre sont :

MongoDB pour la persistance (port 27018),

- *Kafka et  Zookeeper* pour l’ingestion temps réel (topic commentaires_bruts),

-* Spark* (1 master + 3 workers) pour le traitement distribué,

- *Producteur et consommateur*  Python pour la communication entre MongoDB, Kafka et le modèle DziriBERT,

- *Tableau de bord* Dash pour la visualisation.

Les détails de configuration (réseau spark_network, volumes, variables d’environnement, commandes de lancement) sont présentés au chapitre 4 (section 4.3.1). Nous ne les répétons pas ici pour éviter les redondances.
Cette architecture a permis de développer et tester l’intégralité du pipeline sur une machine locale, tout en garantissant la reproductibilité et la possibilité de passage à l’échelle.




=== Résultats Annotation automatique avec l'API Gemini

==== un accord bon avec un biais net

#h(0.5cm)Le coefficient Kappa atteint 0,678. Selon l’échelle de référence, cela indique un *accord bon* entre Gemini et les humains. L’exactitude approche 89,4 %, ce qui signifie qu’environ 9 commentaires sur 10 sont correctement classés par le modèle.

Cependant, derrière ces résultats encourageants, une asymétrie se manifeste clairement. La matrice de confusion présentée ci-dessous confronte les prédictions de Gemini aux annotations humaines:

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: center,
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 {} else if x == 0 {} else if calc.rem(y, 2) == 1 {} else { white },
    [#text(fill: black)[*Vérité terrain*]],
    [#text(fill: black)[*négatif*]],
    [#text(fill: black)[*neutre*]],
    [#text(fill: black)[*positif*]],

    [négatif], [307], [383], [12],
    [neutre], [1], [2 993], [6],
    [positif], [1], [14], [227],
  ),
  caption: [Comparaison entre Gemini (colonnes) et les annotateurs humains (lignes)],
  kind: table,
)

La lecture de cette matrice est éclairante :

- Les cases diagonales (en gras dans l'analyse) montrent les accords parfaits : Gemini est d'accord avec les humains dans la très grande majorité des cas.
- La case la plus problématique est celle en bas à gauche : #emph{Gemini a classé 383 commentaires comme "neutre" alors que les humains y voyaient un "négatif"}.

==== Interprétation : un biais de prudence du modèle

#h(0.5cm)Ces 383 erreurs représentent * 91,8 % * de l'ensemble des divergences. Le problème ne réside pas dans une fréquence élevée d'échecs de Gemini — il performe d'ailleurs très bien sur les classes "neutre" *(F1-score de 0,94)* et "positif" (0,93). Non, la difficulté est qu'il hésite à attribuer l'étiquette "négatif".

D'où provient cette réticence ? La darija algérienne exprime l'insatisfaction de manière subtile, souvent implicite. Prenons "الخدمة تاعكم" (votre service) : aucun adjectif négatif explicite, mais le ton en dit long pour un humain. Faute d'indices évidents, Gemini adopte une approche prudente et choisit "neutre". Il s'agit d'un véritable biais de prudence, phénomène bien documenté dans les études sur les modèles linguistiques confrontés aux dialectes ou à l'oral.

Les autres erreurs restent marginales : 14 "neutre" perçus comme "positif" par les humains, 12 "positif" qualifiés de "négatif", et quelques cas isolés. Aucune tendance systématique ailleurs.






== Corpus et préparation des données pour les expériences
=== Prétraitement de base appliqué aux neuf modèles
==== Nettoyage et normalisation

#h(0.5cm) Le nettoyage syntaxique et la normalisation linguistique appliqués aux neuf
modèles sont ceux décrits en détail au chapitre 4 (sections *Nettoyage des commentaires*
et *Normalisation du texte*). Pour mémoire, ce pipeline comprend la suppression des
éléments parasites (URLs, mentions, hashtags, emojis), la réduction de la ponctuation
répétée, la normalisation des variantes orthographiques arabes via le dictionnaire unifié,
la conversion de l’arabizi en arabe, l’expansion des abréviations télécom, ainsi que
le filtrage des contenus non informatifs.

#h(0.5cm) Pour les modèles classiques et avancés (ComplementNB, régression logistique,
SVM linéaire, XGBoost, LightGBM, SVM RBF), la version *Full* de normalisation a été
utilisée — avec suppression des stopwords et mise en minuscules. Pour les modèles
Transformer (AraBERT, MARBERT, DarijaBERT, CAMeLBERT‑Mix, DziriBERT), la version
*BERT* a été appliquée — préservant la structure syntaxique et les stopwords
fonctionnels.

==== Déduplication par règles contextuelles

#h(0.5cm) La déduplication appliquée dans ce chapitre diffère fondamentalement de la
méthode par similarité sémantique (Jaccard mots, seuil 85 %) présentée au chapitre 4.
Plutôt que de mesurer la ressemblance textuelle entre deux commentaires, cette approche
exploite les *métadonnées contextuelles* associées à chaque document — date, plateforme
source et modérateur ayant répondu — pour distinguer un doublon technique d’une
occurrence sémantiquement distincte.

#h(0.5cm) Cette distinction est essentielle dans notre corpus : un même commentaire
posté par le même client le même jour sur Facebook constitue une redondance pure à
supprimer (R1), tandis que le même texte publié simultanément sur Facebook et sur
Instagram représente deux événements indépendants portant chacun une valeur informative
propre (R2). De même, une plainte répétée sur plusieurs jours consécutifs traduit une
récurrence du problème — information précieuse pour l’analyse des tendances — et doit
donc être conservée (R3).

===== Définition des cinq règles

#figure(
  table(
    columns: (1.2fr, 2.5fr, 1.5fr),
    inset: (x: 7pt, y: 6pt),
    align: (center, left, left, left),
    fill: (x, y) => if y == 0 {} else if calc.rem(y, 2) == 1 {} else { white },
    stroke: 0.5pt + black,
    [*Condition*], [*Signification*], [*Action*],

    [Même texte + même jour + même source + même modérateur],
    [Copie parfaite : le même commentaire a été enregistré plusieurs fois dans les
      fichiers sources, probablement en raison d’une exportation en double par l’outil
      de social listening.],
    [Garder 1 seul document],

    [Même texte + même jour + sources différentes],
    [Le client a posté le même message sur plusieurs plateformes (ex. Facebook et
      Instagram) le même jour. Chaque occurrence reflète une interaction distincte sur
      un canal différent.],
    [Conserver 1 document par plateforme],

    [Même texte + jours différents],
    [Le client a répété sa plainte ou son commentaire sur plusieurs jours. Cette
      récurrence est un signal analytique pertinent — elle indique une insatisfaction
      persistante non résolue.],
    [Conserver 1 document par jour],

    [Même texte + même jour + même source + modérateurs différents],
    [Deux agents distincts ont répondu au même commentaire. Chaque paire
      (commentaire, réponse modérateur) constitue une interaction indépendante
      présentant un intérêt pour l’évaluation de la qualité de traitement.],
    [Conserver 1 document par modérateur],

    [Texte tronqué (mention “En voir plus”) vs texte complet],
    [L’outil de collecte a parfois capturé le même commentaire dans deux versions :
      une version abrégée par la plateforme et sa version intégrale. Seule la version
      complète est sémantiquement exploitable.],
    [Garder le texte le plus long],
  ),
  caption: [Définition des cinq règles de déduplication contextuelle.],
  kind: table,
)



===== Résultats de la déduplication

#figure(
  table(
    columns: (2.5fr, 1.5fr),
    inset: (x: 8pt, y: 6pt),
    align: (left, center),
    fill: (x, y) => if y == 0 {} else if calc.rem(y, 2) == 1 {} else { white },
    stroke: 0.5pt + black,
    [*Métrique*], [*Valeur*],
    [Documents source (`commentaires_sans_urls_arobase`)], [26 576],
    [Documents supprimés (règle R1)], [2 040],
    [Documents conservés], [24 536],
  ),
  caption: [Résultats de la déduplication contextuelle R1–R5 sur le corpus complet.],
  kind: table,
)


==== Tokenisation

#h(0.5cm) La tokenisation appliquée aux modèles classiques et avancés est celle décrite
au chapitre 4 (section *Tokenisation pour les modèles classiques — mode Full*) :
segmentation sur les espaces et la ponctuation, avec intégration de bigrammes fréquents
(seuil : 5 documents minimum). Pour les modèles Transformer, la tokenisation est
assurée nativement par le tokeniseur propre à chaque modèle (WordPiece pour AraBERT,
MARBERT, DarijaBERT, CAMeLBERT‑Mix et DziriBERT), avec une longueur maximale de
séquence fixée à 128 tokens.



=== Prétraitement avancé – configuration retenue pour les expériences d’optimisation

#h(0.5cm)
Le prétraitement de base (nettoyage syntaxique, normalisation par dictionnaire) a permis d’obtenir un corpus exploitable pour les modèles classiques. Cependant, l’évaluation de ces premiers modèles a révélé quatre verrous méthodologiques :

#list(
  [*Surapprentissage* : 21 371 mots pour 26 576 documents → forte dimensionnalité et sparsité excessive.],
  [*Déséquilibre des classes* : 76 % de négatif, 20 % de neutre, 4 % de positif → biais défavorable aux classes minoritaires.],
  [*Confusion lexicale* : vocabulaire commun entre les classes neutre et négatif (noms d’opérateurs, termes techniques).],
  [*Faible rappel du positif* : expressions positives courtes et conditionnelles mal détectées par les modèles bag‑of‑words.],
)

#h(0.5cm)
Pour lever ces verrous, nous avons développé un pipeline de prétraitement avancé dont la **configuration finale** est documentée ci‑dessous.



==== Déduplication avancée : comparaison de six méthodes

#h(0.5cm) Pour la déduplication, nous avons expérimenté six approches sur un échantillon de 1 000 commentaires. Le détail des formules (Levenshtein, Jaccard, TF‑IDF, similarité cosinus) a été présenté au Chapitre 4. \ Le tableau ci‑dessous donne les performances obtenues (seuil de similarité fixé à 85 %, vérité terrain de 36 doublons confirmés).

#figure(
  table(
    columns: (2fr, 1fr, 1fr, 1fr, 1.2fr),
    inset: (x: 8pt, y: 5pt),
    align: (left, center, center, center, center),
    stroke: 0.5pt + black,
    [*Méthode*], [*Précision*], [*Rappel*], [*F1‑score*], [*Temps (s)*],
    [Edit Distance (Levenshtein)], [72 %], [100 %], [83,7 %], [2,50],
    [Jaccard Caractères], [29,8 %], [100 %], [45,9 %], [8,42],
    [*Jaccard Mots*], [*90 %*], [*100 %*], [*94,7 %*], [5,66],
    [TF‑IDF seul], [85,7 %], [100 %], [92,3 %], [198,5],
    [Cosine TF‑IDF], [85,7 %], [100 %], [92,3 %], [0,36],
  ),
  caption: [Comparaison des six méthodes de détection de doublons (résultats définitifs).],
  kind: table,
)

#align(center)[
  #figure(
    block(stroke: 1.5pt + black, image("../images/resuelt_6_methode.jpg", width: 10cm)),
    caption: [Visualisation des performances des six méthodes.],
  kind: image
  )
]






*1.1 Analyse détaillée des résultats *

*1. Edit Distance (Levenshtein)*

#h(0.5cm) Sur notre échantillon, *Edit Distance* a détecté 50 doublons, dont seulement 14 étaient des faux positifs. Edit Distance a obtenu un rappel de 100 %, ce qui signifie qu'il a correctement identifié tous les doublons originaux ; cependant, sa précision de 72 % le rend très sensible aux variations minimes dans le texte. Par exemple, les longs commentaires présentant une orthographe très proche obtiennent de très faibles scores, de même que deux phrases courtes contenant très peu de lettres en commun, qui sont incorrectement regroupées.

*2. Jaccard Caractères*

#h(0.5cm) Les résultats obtenus se révèlent particulièrement décevants : sur 121 doublons détectés, 85 sont des faux positifs, ce qui correspond à une précision de seulement 29,8 %. Cette faible performance s'explique par les particularités de la langue arabe. En effet, de nombreux mots partagent une proportion importante de leurs caractères, sans pour autant être proches en termes de sens. À titre d'exemple, les  *"عمل" (travail)* et *"علم" (science)* ne diffèrent que par une seule lettre, mais leur sens diverge radicalement. Cette méthode engendre donc un niveau de bruit trop élevé pour être considérée comme adéquate dans notre contexte.


*3. Jaccard Mots*

#h(0.5cm) Cette approche offre une précision exceptionnelle (90 %) et un score F1 de 94,7 %. La performance globale de l'algorithme est clairement démontrée par la détection de 40 doublons, avec seulement quatre faux positifs. La validité de la méthode repose principalement sur deux facteurs : son insensibilité à l'ordre des mots – par exemple, les expressions *« mauvaise connexion »* et *« connexion mauvaise »* seraient considérées comme identiques – et sa capacité à prendre en charge le dialecte algérien, exemple de dialecte dont le sens repose sur le sens des mots écrits plutôt que sur leurs lettres individuelles. De plus, l'absence de dépendances externes simplifie considérablement son implémentation distribuée.


*4. TF-IDF seul*

#h(0.5cm) Cette méthode convertit chaque commentaire en un vecteur pondéré selon la pondération TF-IDF définie au @chapitre @salton1983, @jones1972. La similarité entre deux commentaires est ensuite évaluée à l'aide de la similarité cosinus présentée au Chapitre 3 @manning2008.

#h(0.5cm) L'implémentation manuelle de cette méthode s'avère extrêmement lente : 198,5 secondes pour traiter 1 000 commentaires.

*5. Cosine TF-IDF*

#h(0.5cm) Les indicateurs de qualité restent équivalents à ceux de la méthode manuelle, avec 85,7 % de précision et un score F1 de 92,3 %. Cette approche constitue ainsi un excellent équilibre entre rapidité et précision, bien qu'elle introduise une dépendance externe à scikit-learn, ce qui peut compliquer le déploiement dans un environnement Spark.

*1.2. Analyse détaillée — Jaccard Mots*

#h(0.5cm) Compte tenu des résultats expérimentaux, la méthode *Jaccard Mots* a été sélectionnée pour les raisons suivantes :

1. *Meilleure qualité* :un F1-score de 94,7 %, le plus élevé parmi toutes les approches évaluées.
2. *Faux positifs minimaux* : Seulement 4 erreurs sur 1 000 commentaires (0,4 %).
3. *Rappel parfait* : aucun doublon réel n'a été omis au cours des tests effectués.
4. *Absence de dépendances* : Implémentation native en Python pur, sans recours à des bibliothèques externes.
5. *Robustesse linguistique* : Adaptation naturelle à l'arabe dialectal et à l'ordre variable des mots.

#h(0.5cm) La suppression des doublons a permis de réduire la taille du corpus de * 7,64 %* (de 26 576 à 24 536 commentaires uniques). Cette réduction, notable, revêt une importance essentielle pour garantir la qualité des analyses ultérieures :

- *Prévention du surapprentissage* : Les modèles d'apprentissage ne seront pas influencés par des répétitions inutiles d'un même commentaire.
- *Optimisation des performances* : Les étapes techniques suivantes, telles que la vectorisation et la classification, traiteront un volume de données réduit de près de 8 %, ce qui améliore leur efficacité.
- *Précision des métriques d'évaluation* : L'élimination des doublons empêche une inflation artificielle des scores dans certaines catégories.




#h(0.5cm) les 2 040 documents supprimés ne représentent pas une perte, mais bien des redondances évitées, dont la conservation aurait faussé les apprentissages et biaisé les résultats finaux.

==== Sélection de features – filtrage, Chi² et dissimilarité

#h(0.5cm)
Après normalisation, le vocabulaire brut compte 21 371 mots. Nous appliquons trois filtres séquentiels pour réduire la dimensionnalité tout en préservant les termes informatifs.

#h(0.5cm)
**1. Filtrage par fréquence** : `min_df = 3`, `max_df = 0,85`. Le vocabulaire passe à 7 657 mots (−64,2 %). Les hapax et les stopwords résiduels sont éliminés.

**2. Sélection par test du Chi²** : conservation des 5 000 termes ayant le score $\ chi^2$\ le plus élevé par rapport aux trois classes de sentiment. Réduction supplémentaire de 34,7 %.

**3. Filtrage par dissimilarité inter‑classes** : un terme est conservé si sa moyenne TF‑IDF varie significativement entre les classes ($d(t) \ge 0,0003$), sauf pour les marqueurs de négation (forcés). Le vocabulaire final tombe à **1 732 mots**, soit une réduction cumulative de **91,9 %** .

#h(0.5cm)
La figure @fig:metriques_evolution illustre l’évolution conjointe de la dimensionnalité, du score de silhouette et de la sparsité après chaque étape de filtrage.

#figure(
  caption: [Évolution des métriques de qualité des données après chaque filtre.],
  image("../images/preuve_impact_metriques.png", width: 100%),
  kind: image
) <fig:metriques_evolution>

#h(0.5cm)
Le tableau @tab:qualite_final quantifie plus précisément l’impact de ces filtres.

#figure(
  caption: [Évolution des métriques de qualité après chaque étape de filtrage.],
  kind: table,
  table(
    columns: (2fr, 1.2fr, 1.2fr, 1.5fr, 1.8fr),
    inset: (x: 6pt, y: 5pt),
    align: (center, center, center, center, center),
    stroke: 0.5pt + black,
    [*Méthode*], [*Features*], [*Sparsité*], [*Silhouette*], [*Mots uniques/doc*],
    [A. Tous les mots], [21 371], [99,95 %], [−0,0568], [11,31],
    [B. Filtrage fréquence], [7 657], [99,87 %], [−0,0299], [10,10],
    [C. Sélection Chi²], [5 000], [99,83 %], [−0,0290], [8,28],
    [D. Méthode finale], [1 732], [99,61 %], [−0,0281], [6,68],
  ),
) <tab:qualite_final>

#h(0.5cm)
**Observations** : le score de silhouette progresse de **+0,0287 point**, la sparsité diminue (facteur **×7,8**) et le nombre moyen de mots uniques par document baisse de 11,31 à 6,68.

La projection t‑SNE (figure @fig:tsne_final) illustre visuellement le gain de structuration : les classes (positif en vert, neutre en gris, négatif en rouge) passent d’un entremêlement total à des clusters bien séparés.

#figure(
  block(stroke: 2pt + black, image("../images/preuve_impact_tsne.png", width: 80%)),
  caption: [Projection t‑SNE après chaque étape de filtrage. (A) brut, (B) fréquence, (C) Chi², (D) final.],
  kind: image
) <fig:tsne_final>

==== Rééquilibrage du corpus

#h(0.5cm)
La distribution initiale est très déséquilibrée (76 % négatif, 20 % neutre, 4 % positif). Nous appliquons un sous‑échantillonnage (`undersampling`) pour obtenir 4 559 documents par classe, soit un corpus final de **13 677 documents** parfaitement équilibré (33,3 % par classe). Ce rééquilibrage est appliqué **avant** toutes les expériences d’optimisation.

==== Extraction des flags sémantiques

#h(0.5cm)
Pour enrichir la représentation, nous développons un module basé sur des expressions régulières qui détecte six catégories sémantiques (flags binaires) et trois sous‑types. Le tableau @tab:flags_final résume ces flags.

#figure(
  caption: [Flags sémantiques extraits par règles expertes.],
  kind: table,
  table(
    columns: (1.2fr, 1.5fr, 3.5fr),
    inset: (x: 6pt, y: 6pt),
    align: (left, left, left),
    stroke: 0.5pt + black,
    [*Flag*], [*Type détecté*], [*Description*],
    [social], [Formule sociale], [Vœux, remerciements, bénédictions],
    [encouragement], [Encouragement], [Soutien pur sans lien direct avec le service],
    [suggestion], [Suggestion / positif conditionnel], [Satisfaction assortie d’une restriction],
    [plainte], [Plainte explicite], [Frustration, problème technique, demande de contact],
    [negation], [Négation grammaticale], [Présence de "machi", "ما", "ne…pas"],
    [mixte], [Mixte / contradiction], [Co‑occurrence d’un terme positif et d’un terme négatif fort],
  ),
) <tab:flags_final>

#h(0.5cm)
Les sous‑types (`masked_neg`, `prv`, `produit`) sont également calculés.

==== Vectorisation hybride finale

#h(0.5cm)
Le vecteur représentant chaque document est construit par concaténation de trois groupes :

#list(
  [**TF‑IDF** des 150 meilleurs termes issus de la sélection Chi² (parmi les 1 732 disponibles).],
  [**Flags binaires** (7 dimensions : les 6 flags ci‑dessus + un flag `positif` explicite).],
  [**Sous‑types** (3 dimensions : `masked_neg`, `prv`, `produit`).],
)

#h(0.5cm)
La dimension totale est **160** caractéristiques (150 + 7 + 3). Ce vecteur est concaténé à l’embedding `[CLS]` de DziriBERT (768 dimensions) pour former le vecteur d’entrée final de **928 dimensions** dans les expériences d’optimisation. La solution finale remplace le token `[CLS]` par un **mean pooling**, mais conserve les mêmes 160 dimensions additionnelles.

==== Synthèse de la configuration retenue

#h(0.5cm)
Le tableau @tab:config_synthese_final récapitule l’ensemble des choix validés expérimentalement pour le prétraitement avancé.

#figure(
  caption: [Synthèse de la configuration de prétraitement avancé – socle des expériences d’optimisation.],
  kind: table,
  table(
    columns: (1.5fr, 1.2fr, 2.8fr),
    inset: (x: 6pt, y: 5pt),
    align: (left, left, left),
    stroke: 0.5pt + black,
    [*Étape*], [*Valeur retenue*], [*Justification*],
    [Déduplication], [Jaccard Mots (seuil 85 %)], [F1‑score = 94,7 %, sans dépendances externes],
    [Filtrage fréquentiel], [`min_df` = 3, `max_df` = 0,85], [Réduction de 64,2 % – élimination des hapax],
    [Sélection Chi²], [top 5 000 termes], [Conservation des termes associés au sentiment],
    [Dissimilarité], [seuil $d(t) \ge 0,0003$, négations forcées], [Réduction finale à 1 732 mots (–91,9 %)],
    [Rééquilibrage], [undersampling à 4 559 docs/classe], [Distribution 33/33/33 – correction du biais],
    [Flags], [6 flags binaires + 3 sous‑types], [Enrichissement sémantique par règles expertes],
    [Vectorisation finale], [150 + 7 + 3 = 160 dim.], [Concaténée à l’embedding DziriBERT (768 → total 928 dim.)],
  ),
) <tab:config_synthese_final>

#h(0.5cm)
Cette configuration constitue le socle de toutes les expériences d’optimisation menées dans la suite de ce chapitre.




















== Modèles classiques pour l'analyse de sentiment en darija : baselines linéaires

Avant d'engager les ressources computationnelles qu'exigent les architectures Transformer,
nous établissons des *baselines* solides à partir d'algorithmes classiques. Ce préalable n'est
pas anecdotique : il permet de chiffrer le gain réel apporté par des modèles plus sophistiqués,
et de détecter d'éventuels effets de plafond dus au déséquilibre sévère du corpus plutôt qu'aux
limites intrinsèques de chaque famille algorithmique.

=== Protocole expérimental

#figure(
  table(
    columns: (1.5fr, 3.5fr),
    stroke: 0.5pt + black,
    inset: (x: 6pt, y: 4pt),
    align: (left, left),

    [*Paramètre*], [*Valeur / Description*],
    [*Algorithmes*], [ComplementNB (Naïve Bayes complémentaire), régression logistique, SVM linéaire],
    [*Vectoriseurs*], [CountVectorizer (fréquences brutes) et TF‑IDF],
    [*Représentation textuelle*],
    [
      `FeatureUnion` : TF‑IDF lexical (unigrammes + bigrammes) + \
      TF‑IDF caractériel (3‑5‑grammes) → ≈100 000 dimensions
    ],

    [*Corpus source*],
    [
      Collection MongoDB *commentaires_normalises_final_tokenises* (25 413 documents bruts)
    ],

    [*Découpage*], [80 % entraînement (20 244) / 20 % test (5 062) – stratifié],
    [*Déséquilibre (test)*],
    [
      #table(
        columns: (auto, auto),
        stroke: none,
        inset: (x: 0pt, y: 2pt),
        [• *négatif* :], [3 844  (76,0 %)],
        [• *neutre* :], [1 023  (20,2 %)],
        [• *positif* :], [195    (3,8 %)],
      )
      \n *Ratio majoritaire/minoritaire* ≈ 19,7 : 1
    ],

    [*Métrique principale*], [F1‑macro (insensible au déséquilibre, contrairement à l'accuracy)],
  ),
  caption: [Récapitulatif général du protocole expérimental — d'après l'exécution du 2026‑05‑04.],
  kind: table,
)

=== Hyperparamètres et optimisation

Chaque modèle est optimisé par recherche sur grille (*GridSearchCV*, 3 plis stratifiés,
métrique F1‑macro). Les espaces de recherche et les meilleures configurations sont résumés
ci‑dessous.
Les poids des classes sont ajustés pour la régression logistique et le SVM selon
l'inverse des fréquences d'entraînement : positif: {0,35}; neutre: {1,98}; positif: {17,32}
soit un poids 17 fois supérieur pour chaque erreur sur la classe minoritaire.

#figure(
  table(
    columns: (1.5fr, 2.8fr, 2.2fr),
    stroke: 0.5pt,
    inset: (x: 6pt, y: 5pt),
    align: (left, left, left),

    [*Modèle*], [*Espace de recherche*], [*Meilleurs paramètres (TF‑IDF)*],
    [ComplementNB],
    [
      $alpha in {{0,1}; {0,1}; {0,5}; {1,0}}$, \
      ngram\_range $in {(1,1);(1,2)}$, \
      max\_features $in {30k,60k}$
    ],
    [$alpha = {0,1}$, ngram = (1,2), max\_features = 30k],

    [Régression logistique],
    [
      $C in {{0,1}; {0,5}; {1,0}; {5,0}}$, \
      ngram\_range $in {(1,1);(1,2)}$, \
      solver = L‑BFGS
    ],
    [$C = {5,0}$, ngram = (1,2)],

    [SVM linéaire],
    [
      $C in {{0,1}; {0,5}; {1,0}; {2,0}}$, \
      ngram\_range $in {(1,1);(1,2)}$, \
      max\_iter = 10 000
    ],
    [$C = {0,1}$, ngram = (1,2)],
  ),
  caption: [Espaces de recherche et meilleurs hyperparamètres retenus par GridSearchCV
    (F1‑macro, 3 folds stratifiés, vectoriseur TF‑IDF). ],
  kind: table,
)

=== Résultats Modèles classiques

==== ComplementNB (Naïve Bayes complémentaire)

ComplementNB estime $P(t | overline(c))$ plutôt que $P(t | c)$, ce qui corrige le biais du
MultinomialNB face au déséquilibre de classes : au lieu de modéliser ce qui caractérise une
classe, il modélise ce qui la distingue de toutes les autres. Cette inversion est particulièrement
adaptée aux corpus très asymétriques où la classe majoritaire domine les estimations de
vraisemblance. Les performances sur le jeu de test sont présentées dans le tableau \@nb-perf.

#figure(
  table(
    columns: (1.5fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    inset: (x: 6pt, y: 5pt),
    align: (left, center, center, center, center, center),
    stroke: 0.5pt,
    [*Configuration*], [*Accuracy*], [*F1‑macro*], [*F1‑négatif*], [*F1‑neutre*], [*F1‑positif*],
    [CountVec], [0,8595], [0,7462], [0,91], [0,70], [0,63],
    [TF‑IDF], [0,8617], [0,7568], [0,92], [0,69], [0,66],
  ),
  caption: [Performances des deux variantes ComplementNB sur le jeu de test (5 062 documents).],
  kind: table,
)<nb-perf>

*Points d'interprétation* :

- La classe majoritaire (*négatif*, support = 3 844) est très bien détectée (F1 = 0,91–0,92),
  ce qui reflète la capacité de ComplementNB à modéliser les tokens distinctifs d'une classe
  dominante même sans pondération explicite.

- La classe *neutre* (support = 1 023) plafonne à F1 ≈ 0,69–0,70. La confusion neutre/négatif
  est structurelle : les commentaires neutres partagent fréquemment le vocabulaire des
  commentaires négatifs (termes de service, noms d'opérateurs), rendant leur frontière
  décisionnelle floue dans l'espace bag-of-words.

- La classe *positif* (minoritaire, support = 195) reste difficile : F1 ≈ 0,63–0,66,
  avec un rappel de 0,64 pour CountVec (≈ 125 vrais positifs sur 195) et 0,66 pour TF‑IDF.
  Malgré la correction complémentaire, 974 exemples d'entraînement sur ~60 000 dimensions
  génèrent une région décisionnelle mal contrainte.

L'écart entre les deux vectoriseurs est minime mais instructif : TF‑IDF améliore le F1‑macro
de +1,1 point (0,7568 contre 0,7462) et le F1‑positif de +3 points. La pondération TF‑IDF
atténue l'influence des tokens fréquents inter-classes (stopwords résiduels du darija),
ce qui bénéficie davantage aux classes rares dont le signal lexical est plus faible.

==== Régression logistique

La régression logistique produit des poids directement interprétables et bénéficie ici de
poids de classes personnalisés agressifs (positif = {17,32}). La meilleure régularisation
trouvée est C = {5,0} avec les bigrammes — une régularisation faible qui tolère
l'ajustement fin aux exemples positifs rares en échange d'une meilleure séparation des
classes minoritaires.

#figure(
  table(
    columns: (1.5fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    inset: (x: 6pt, y: 5pt),
    align: (left, center, center, center, center, center),
    stroke: 0.5pt,
    [*Configuration*], [*Accuracy*], [*F1‑macro*], [*F1‑négatif*], [*F1‑neutre*], [*F1‑positif*],
    [CountVec], [0,8623], [0,7630], [0,92], [0,72], [0,66],
    [TF‑IDF], [0,8615], [0,7612], [0,91], [0,72], [0,65],
  ),
  caption: [Performances des variantes de régression logistique sur le jeu de test.],
  kind: table,
)

*Points d'interprétation* :

- **Compensation efficace de CountVec** :
  Malgré le biais des fréquences brutes, le poids 17.32 sur la classe positive permet d’atteindre des F1‑macro quasi identiques entre CountVec (0.763) et TF‑IDF (0.761). La régularisation faible ($C = 5.0$) autorise l’ajustement local nécessaire aux positifs rares.

- **Meilleure séparation neutre/négatif** :
  Le F1‑neutre progresse à 0.72 (contre 0.69–0.70 pour ComplementNB). La régression logistique, en optimisant une frontière de décision probabiliste multi‑classe, gère mieux la confusion lexicale entre *neutre* et *négatif* que le modèle génératif de Naïve Bayes.

- **Plafonnement de la classe positive (F1 ≈ 0.65–0.66)** :
  Même avec un poids 17.32, la fonction de perte ne peut pas compenser le manque de *signal informatif* dans les 974 exemples d’entraînement répartis sur ~100 000 dimensions (bigrammes). La représentation bag‑of‑words reste trop creuse pour une classe très minoritaire.

- **Écart négligeable entre CountVec et TF‑IDF** :
  Ce résultat est remarquable : la pondération des classes réussit à « nettoyer » CountVec suffisamment bien pour que l’apport de TF‑IDF devienne marginal. Cela indique que pour ce corpus, le déséquilibre de classes est un obstacle plus grand que le bruit des stopwords.
==== SVM linéaire (LinearSVC)

Les SVM linéaires excellent dans les espaces de grande dimension grâce à leur principe de
maximisation de la marge, qui régularise naturellement l'overfitting en haute dimension.
La recherche sélectionne $C = 0.1$ — une régularisation forte qui bride le surapprentissage
sans sacrifier la capacité à discriminer les classes minoritaires. À noter : l'avertissement
`ConvergenceWarning` observé sur SVM CountVec (mais pas TF‑IDF) révèle un problème de
conditionnement numérique — les features CountVec ont des échelles hétérogènes, ce qui ralentit
l'optimiseur LIBLINEAR et justifie la préférence pour TF‑IDF.

#figure(
  table(
    columns: (1.5fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    inset: (x: 6pt, y: 5pt),
    align: (left, center, center, center, center, center),
    stroke: 0.5pt,
    [*Configuration*], [*Accuracy*], [*F1‑macro*], [*F1‑négatif*], [*F1‑neutre*], [*F1‑positif*],
    [CountVec], [0.8740], [0.7718], [0.92], [0.73], [0.66],
    [TF‑IDF], [0.8783], [0.7831], [0.93], [0.74], [0.69],
  ),
  caption: [Performances des variantes SVM linéaire sur le jeu de test.
    Support : négatif = 3 844, neutre = 1 023, positif = 195.],
  kind: table,
)

*Points d’interprétation* :

- **Meilleure performance globale** :
  Avec TF‑IDF, le SVM atteint un F1 de *0.93* sur le négatif, 0.74 sur le neutre et *0.69* sur
  le positif — la meilleure performance par classe parmi toutes les baselines. Le rappel du
  positif est de 0.67 (131 commentaires positifs corrects sur 195).

- **Séparabilité latente excellente** :
  La courbe ROC (AUC positif = 0.948) révèle un phénomène crucial : la séparabilité est
  excellente, mais le seuil de décision par défaut (0) est trop conservateur pour une classe
  aussi rare. Cela justifie ultérieurement l'optimisation post-hoc du seuil sur la courbe
  précision-rappel.

  #figure(
    image("../images/roc_svm_tfidf.png", width: 11cm),
    caption: [Courbes ROC du SVM TF‑IDF après calibration probabiliste (sigmoïde). ],
  kind: image
  )<roc-svm>

- **Avantage computationnel de TF‑IDF** :
  Le temps d'entraînement illustre un avantage supplémentaire de TF‑IDF : SVM TF‑IDF s'exécute
  en 145.8 secondes contre 608.7 secondes pour SVM CountVec, soit un facteur 4.2×. Ce gain
  s'explique par le meilleur conditionnement numérique des features normalisées TF‑IDF, qui
  accélèrent la convergence de l'optimiseur de marge.

  #figure(
    image("../images/training_time.png", width: 12cm),
    caption: [Temps d'entraînement par modèle (GridSearch 3 plis inclus).],
  kind: image
  )<temp>

==== Validation croisée

Une validation croisée à 5 plis sur l'ensemble complet (25 306 documents) confirme la stabilité
des modèles. Les écarts-types restent inférieurs à 0,013 pour le F1‑macro — un signe de bonne
généralisation malgré le déséquilibre sévère.

#figure(
  table(
    columns: (2fr, 1.5fr, 1.5fr),
    inset: (x: 7pt, y: 6pt),
    align: (left, center, center),
    stroke: 0.5pt,
    [*Configuration*], [*F1‑macro CV (moy ± σ)*], [*Accuracy CV (moy ± σ)*],
    [ComplementNB + CountVec], [0,7461 ± 0,0115], [0,8541 ± 0,0049],
    [ComplementNB + TF‑IDF], [0,7419 ± 0,0129], [0,8529 ± 0,0044],
    [Logistique + CountVec], [0,7479 ± 0,0084], [0,8530 ± 0,0067],
    [Logistique + TF‑IDF], [0,7459 ± 0,0115], [0,8481 ± 0,0067],
    [SVM + CountVec], [0,7695 ± 0,0103], [0,8712 ± 0,0054],
    [SVM + TF‑IDF], [0,7839 ± 0,0095], [0,8800 ± 0,0036],
  ),
  caption: [Résultats de la validation croisée à 5 plis sur l'ensemble complet (25 306 documents).
  ],
  kind: table,
)<cv>
Le SVM TF‑IDF présente le plus faible écart-type (σ = 0,0095 sur F1-macro et σ = 0,0036 sur
accuracy), attestant une stabilité supérieure aux autres familles. ComplementNB TF‑IDF affiche
la variance la plus élevée (σ = 0,0129), reflétant sa sensibilité à la distribution des
partitions de validation sur la classe positive minoritaire.
==== Courbe d'apprentissage du meilleur modèle

- **Progression régulière** : F1‑macro validation de 0.66 (10 % des données, ≈2 025 docs) à 0.79 (100 %, 20 244 docs).
- **Pas de plateau** : La pente reste positive → plus de données (notamment pour la classe *positif*) amélioreraient encore les performances.
- **Écart entraînement / validation** : ~0.98 vs ~0.79 → surapprentissage structurel (haute dimension : ~100 000 features).
- **Phénomène attendu** : Non pathologique ; l'espace offre plus de degrés de liberté que nécessaire pour 20 244 exemples.

#figure(
  image("../images/learning_curve_svm_tfidf.png", width: 11cm),
  caption: [Courbe d'apprentissage du SVM TF‑IDF (F1‑macro, 5 plis).],
  kind: image
)<learning>
L'écart entraînement validation (~0.19 points) indique un surapprentissage structurel lié à la haute dimension,
non à une mauvaise configuration. L'absence de plateau sur la courbe de validation suggère
qu'un corpus plus grand — ou un rééchantillonnage de la classe positive — améliorerait
substantiellement les performances.
=== Synthèse et matrices de confusion

Le classement global sur le jeu de test est sans ambiguïté : le SVM TF‑IDF domine avec un
F1‑macro de *0.783* (tableau \@ranking). Les matrices de confusion (figure \@confmat) confirment
que la classe *positif* (minoritaire) reste la moins bien classée, tandis que le *négatif* est
parfaitement reconnu. On observe une progression diagonale claire de NB → Logistique → SVM :
chaque famille améliore le traitement des classes minoritaires de 2 à 3 points de F1.

#figure(
  table(
    columns: (2fr, 1fr, 1fr, 1fr, 1.2fr),
    inset: (x: 6pt, y: 5pt),
    align: (left, center, center, center, center),
    [*Modèle*], [*Accuracy*], [*F1‑macro*], [*F1‑weighted*], [*Durée (s)*],
    [*SVM TF‑IDF*], [*0.8783*], [*0.7831*], [*0.8785*], [145.8],
    [SVM CountVec], [0.8740], [0.7718], [0.8749], [608.7],
    [Logistique CountVec], [0.8623], [0.7630], [0.8654], [166.0],
    [Logistique TF‑IDF], [0.8615], [0.7612], [0.8652], [192.5],
    [NB TF‑IDF], [0.8617], [0.7568], [0.8615], [148.2],
    [NB CountVec], [0.8595], [0.7462], [0.8597], [158.8],
  ),
  caption: [Classement des six baselines par F1‑macro décroissant sur le jeu de test (5 062
    documents).],
  kind: table,
)<ranking>

#figure(
  image("../images/confusion_matrices.png", width: 15cm),
  caption: [Matrices de confusion des six configurations.],
  kind: image
)<confmat>

*Points d’interprétation* :

- **Progression des modèles** : Les modèles linéaires classiques, et en particulier le SVM associé à une représentation TF‑IDF, atteignent des performances solides (F1‑macro = 0.783) sur un corpus très déséquilibré et bruyant en darija algérienne. Le gain du SVM par rapport à la régression logistique est de +2.2 points de F1‑macro, et de +3.7 points par rapport à Naïve Bayes — des écarts significatifs sur un corpus de cette taille.

- **Limite persistante sur la classe positive** : La classe minoritaire (*positif*) reste sous‑représentée et mal modélisée (F1 = 0.69, rappel = 0.67), avec une AUC ROC de 0.948 qui révèle que le verrou est le seuil de décision, non la représentation. Cela appelle des approches plus puissantes (Transformers, rééchantillonnage, lexiques spécialisés) pour lever ce plafond.

- **Annexes** : Les graphiques supplémentaires (courbes précision‑rappel, courbes ROC des autres modèles, heatmaps des rapports de classification et comparaison synthétique des métriques) sont regroupés en annexe (@annexe:pr_curves, @annexe:roc_others, @annexe:class_heatmaps, @annexe:metric_comp).
// ═══════════════════════════════════════════════════════════════════════════
// Modèles avancés — XGBoost, LightGBM, SVM RBF (version corrigée)
// ═══════════════════════════════════════════════════════════════════════════
== Modèles avancés — XGBoost, LightGBM, SVM RBF
Avant d'aborder les architectures Transformer, nous évaluons trois modèles réputés pour leur
capacité à capturer des non‑linéarités : XGBoost, LightGBM et SVM à noyau RBF. Le verdict
est sans appel : sur notre corpus, aucun ne dépasse le SVM linéaire de référence.

=== Protocole et espaces de recherche

#figure(
  table(
    columns: (1.2fr, 2.5fr, 2fr),
    inset: (x: 6pt, y: 5pt),
    align: (left, left, left),
    stroke: 0.5pt + black,
    [*Modèle*], [*Espace de recherche*], [*Meilleurs paramètres*],
    [XGBoost],
    [n\_estimators $in {100,200}$, max\_depth $in {4,6}$,
      learning\_rate $in {0{,}05,0{,}1}$, subsample = 0,8,
      colsample\_bytree = 0,8],
    [n\_est. = 100, depth = 4, lr = 0,1],

    [LightGBM], [mêmes paramètres que XGBoost], [n\_est. = 100, depth = 4, lr = 0,1],
    [SVM RBF], [$C in {0{,}5; 1{,}0; 2{,}0}$, $gamma in {"scale"; 0{,}1}$], [$C = 0{,}5$, $gamma = "scale"$],
  ),
  caption: [Espaces de recherche (GridSearch 3 folds, F1‑macro) et meilleurs hyperparamètres
    pour chaque modèle avancé.],
  kind: table,
)

=== Résultats Modèles avancés

#figure(
  table(
    columns: (1.5fr, 1fr, 1fr, 1fr, 1.2fr),
    inset: (x: 6pt, y: 5pt),
    align: (left, center, center, center, center),
    stroke: 0.5pt + black,
    [*Modèle*], [*Accuracy*], [*F1‑macro*], [*F1‑weighted*], [*Durée (s)*],
    [LightGBM], [0,8753], [0,7529], [0,8682], [176,1],
    [XGBoost], [0,8637], [0,7155], [0,8519], [363,8],
    [SVM RBF], [0,8514], [0,7101], [0,8438], [7 759,2],
  ),
  caption: [Performances globales des modèles avancés sur le jeu de test (5 062 documents).],
  kind: table,
)
- *LightGBM* : meilleur compromis (F1‑macro = 0.753, temps = 176 s), mais reste inférieur de 3.0 points au SVM linéaire TF‑IDF.
- *XGBoost* : deux fois plus lent que LightGBM pour un F1‑macro inférieur de 3.7 points supplémentaires (0.7155 contre 0.7529).
- *SVM RBF* : rédhibitoire — F1‑macro de 0.710 (7.3 points de moins que le SVM linéaire) et temps d’exécution de 7 759 s (≈ 2h09), inexploitable pour des applications en ligne ou des réentraînements fréquents.
=== Analyse par classe

==== LightGBM

#figure(
  table(
    columns: (1.5fr, 1fr, 1fr, 1fr, 1fr),
    inset: (x: 6pt, y: 5pt),
    align: (left, center, center, center, center),
    stroke: 0.5pt + black,
    [*Classe réelle*], [*Précision*], [*Rappel*], [*F1‑score*], [*Support*],
    [Négatif (majoritaire)], [0,89], [0,96], [0,92], [3 844],
    [Neutre], [0,80], [0,62], [0,70], [1 023],
    [Positif (minoritaire)], [0,81], [0,52], [0,63], [195],
  ),
  caption: [Rapport de classification détaillé — LightGBM (valeurs corrigées après
    réassociation des étiquettes). Accuracy = 87,53 % · F1‑macro = 0,7529.],
  kind: table,
)
- *LightGBM – sans pondération de classes*
  - Négatif (majoritaire) : rappel = 0.96, F1 = 0.92 → seulement 154 erreurs sur 3 844
  - Neutre : F1 = 0.70
  - Positif (minoritaire) : rappel = 0.52 (101/195), F1 = 0.63

- *Coût de l’absence de pondération* :
  - Écart de 6 points sur le F1‑positif par rapport au SVM linéaire (0.63 vs 0.69)
  - Écart de 15 points sur le rappel‑positif (0.52 vs 0.67)

- *Limite algorithmique* : L’histogram‑based de LightGBM est conçu pour des features denses ; il peine sur la sparsité extrême de TF‑IDF (~99.9 % de zéros).

==== XGBoost

#figure(
  table(
    columns: (1.5fr, 1fr, 1fr, 1fr, 1fr),
    inset: (x: 6pt, y: 5pt),
    align: (left, center, center, center, center),
    stroke: 0.5pt + black,
    [*Classe réelle*], [*Précision*], [*Rappel*], [*F1‑score*], [*Support*],
    [Négatif (majoritaire)], [0,87], [0,97], [0,92], [3 844],
    [Neutre], [0,82], [0,55], [0,66], [1 023],
    [Positif (minoritaire)], [0,84], [0,43], [0,57], [195],
  ),
  caption: [Rapport de classification détaillé — XGBoost (valeurs corrigées). Accuracy = 86,37 % · F1‑macro = 0,7155.],
  kind: table,
)

XGBoost reproduit le profil de LightGBM sur la classe *négatif* (rappel = 0,97, légèrement
supérieur), mais affiche un rappel nettement inférieur sur *neutre* (0,55 contre 0,62) et
surtout sur *positif* (0,43 contre 0,52) — soit moins de 84 commentaires positifs correctement
identifiés sur 195. Ce résultat, combiné à un temps d'entraînement deux fois supérieur à
LightGBM (363,8 s contre 176,1 s), retire tout intérêt pratique à XGBoost dans notre cadre.
La différence entre XGBoost et LightGBM s'explique par leur algorithme de split : XGBoost
effectue une recherche exacte dans l'espace de features, ce qui aggrave sa sensibilité à la
haute dimensionnalité, tandis que LightGBM utilise des histogrammes approximatifs qui
réduisent partiellement cet effet.

==== SVM RBF

#figure(
  table(
    columns: (1.5fr, 1fr, 1fr, 1fr, 1fr),
    inset: (x: 6pt, y: 5pt),
    align: (left, center, center, center, center),
    stroke: 0.5pt + black,
    [*Classe réelle*], [*Précision*], [*Rappel*], [*F1‑score*], [*Support*],
    [Négatif (majoritaire)], [0,88], [0,94], [0,91], [3 844],
    [Neutre], [0,72], [0,59], [0,65], [1 023],
    [Positif (minoritaire)], [0,85], [0,43], [0,57], [195],
  ),
  caption: [Rapport de classification détaillé — SVM RBF (valeurs corrigées). Accuracy = 85,14 % · F1‑macro = 0,7101.],
  kind: table,
)

Le SVM RBF présente le pire bilan parmi les trois modèles avancés. Son rappel sur *positif*
(0,43) est identique à XGBoost, mais sa précision chute à 0,72 sur *neutre* — le plus bas de
tous les modèles évalués. La non‑linéarité du noyau RBF n'apporte aucun bénéfice sur ce
corpus pour une raison théorique bien établie : dans un espace de ~100 000 dimensions, les
classes sont déjà quasi-séparables linéairement (couverture de Cover). Le noyau RBF projette
dans un espace encore plus grand sans améliorer cette séparabilité, au seul coût d'une
complexité quadratique en temps et mémoire. Avec 7 759 s d'entraînement (≈ 2h09), le SVM RBF
est formellement hors de tout cadre opérationnel raisonnable.

==== Courbes ROC et précision‑rappel

#figure(
  image("../images/advanced_roc_lightgbm.png", width: 9cm),
  caption: [Courbes ROC de LightGBM (valeurs après correction des étiquettes).],
  kind: image
)
Les AUC
sont élevés pour *négatif* (0,99) et *neutre* (0,94), mais s'affaissent à 0,89 pour
*positif* — la classe minoritaire. Cet affaissement confirme que le problème n'est pas
seulement le seuil de décision (comme pour les SVM linéaires), mais bien la représentabilité
de la classe positive dans l'espace de boosting sans pondération.
#figure(
  image("../images/advanced_pr_lightgbm.png", width: 9cm),
  caption: [Courbes précision‑rappel de LightGBM. ],
  kind: image
)
La chute rapide de la courbe *positif*
dès que le rappel dépasse 0,4 confirme le caractère structurel de la difficulté :
l'activation de "class_weight="balanced" ou "is_unbalance=True" dans LightGBM
constitue l'expérience prioritaire à mener.
==== Temps d'entraînement

#figure(
  image("../images/advanced_training_time.png", width: 12cm),
  caption: [Temps d'entraînement (GridSearch 3 plis inclus). ],
  kind: image
)
LightGBM est le seul modèle
avancé exploitable en production (176 s). SVM RBF (7 759 s ≈ 2h09) est hors de tout
cadre opérationnel raisonnable, avec un rapport coût/performance négatif.
=== Comparaison avec les baselines

#figure(
  table(
    columns: (2fr, 1fr, 1fr, 1.2fr, 1.5fr),
    inset: (x: 6pt, y: 5pt),
    align: (left, center, center, center, left),
    stroke: 0.5pt + black,
    [*Modèle*], [*Accuracy*], [*F1‑macro*], [*Durée (s)*], [*Famille*],
    [*SVM TF‑IDF*], [0,8783], [*0,7831*], [145,8], [Baseline linéaire],
    [LightGBM], [0,8753], [0,7529], [176,1], [Avancé],
    [Logistique CountVec], [0,8623], [0,7630], [166,0], [Baseline linéaire],
    [XGBoost], [0,8637], [0,7155], [363,8], [Avancé],
    [NB TF‑IDF], [0,8617], [0,7568], [148,2], [Baseline linéaire],
    [SVM RBF], [0,8514], [0,7101], [7 759,2], [Avancé],
  ),
  caption: [Comparaison croisée baselines / modèles avancés, classés par F1‑macro décroissant.],
  kind: table,
)
Observation centrale : la régression logistique (F1 = 0,763) surpasse LightGBM (0,753)
et tous les modèles non-linéaires — une confirmation empirique de la robustesse des
classificateurs linéaires en NLP haute dimension.
=== Discussion

Trois facteurs convergents expliquent la contre-performance des modèles non linéaires.

- *Haute dimension et sparsité extrême:* La FeatureUnion génère ~100 000 caractéristiques, avec
une densité inférieure à 0,1 % par document. Dans ce régime, les SVM et régressions logistiques
régularisés bénéficient d'une convergence rapide vers la marge optimale. Les algorithmes de
boosting, architecturés pour les données tabulaires de 10–1 000 features denses, construisent
des arbres sur des features quasi-vides, conduisant à une mémorisation du bruit dès les
premières itérations.

- *Déséquilibre non compensé:* Les 195 commentaires positifs représentent 3,8 % du jeu de test.
Contrairement aux baselines qui utilisent `class_weight="balanced"` avec un multiplicateur ×17
sur la classe positive, aucun mécanisme de pondération n'a été activé pour les modèles de
boosting. LightGBM offre `class_weight="balanced"` et `is_unbalance=True`, XGBoost offre
`scale_pos_weight` — ne pas les activer constitue la lacune expérimentale la plus immédiatement
corrigeable dans les expériences futures.

- *Linéarité naturelle du problème:* Le SVM linéaire atteignant F1‑macro = 0,783 indique que la
frontière de décision est quasi-linéaire dans l'espace TF‑IDF (théorème de couverture de Cover :
en haute dimension, tout problème de classification devient linéairement séparable avec
probabilité tendant vers 1). L'ajout d'un noyau RBF n'apporte aucun gain discriminant, au seul
coût d'un temps de calcul 53 fois supérieur au SVM linéaire et d'une perte de 7,3 points de
F1‑macro.

Les graphiques supplémentaires (courbes ROC, courbes précision‑rappel et heatmaps des rapports
de classification) sont disponibles en annexe (@annexe:advanced_roc, @annexe:advanced_pr,
@annexe:advanced_class_heatmaps).


== Modèles de transfert — Transformers

Les approches classiques, aussi soigneusement réglées soient‑elles, butent sur des phénomènes
propres au dialecte algérien : négation implicite, ironie, mélange des codes arabe–français–
berbère.

Cinq architectures sont comparées dans ce travail : AraBERT, MARBERT, DarijaBERT,
CAMeLBERT‑Mix et DziriBERT. Les quatre premières servent de références croisées ;
DziriBERT, seul modèle pré‑entraîné spécifiquement sur la darija algérienne, constitue
le candidat naturellement favorisé.

=== Protocole expérimental commun

==== Données et partitionnement

Les cinq modèles sont entraînés sur la même collection `dataset_unifie` (25 346 documents après
nettoyage), en utilisant la colonne `normalized_arabert` comme entrée textuelle. Le
partitionnement adopte un découpage stratifié 80 / 10 / 10, garantissant que la distribution
des classes est identique dans chaque partition.

#figure(
  table(
    columns: (1.8fr, 1fr, 1fr, 1fr),
    inset: (x: 6pt, y: 5pt),
    align: (left, center, center, center),
    stroke: 0.5pt + black,
    [*Partition*], [*Documents*], [*Négatif (%)*], [*Positif (%)*],
    [Entraînement (80 %)], [20 276], [75,9], [3,9],
    [Validation (10 %)], [2 535], [75,9], [3,9],
    [Test (10 %)], [2 535], [75,9], [3,8],
  ),
  caption: [Répartition stratifiée du corpus — protocole identique pour les cinq modèles
    Transformer.],
  kind: table,
) <tab:split_transformers>
Le taux de classe positive reste constant à ≈3,9 % dans chaque partition,
garantissant la comparabilité des évaluations.
==== Hyperparamètres partagés

Tous les modèles partagent le même schéma de fine‑tuning via l'API `Trainer` de Hugging Face,
permettant une comparaison équitable qui isole l'effet du pré-entraînement.

#figure(
  table(
    columns: (2.2fr, 1.5fr),
    inset: (x: 6pt, y: 5pt),
    align: (left, center),
    stroke: 0.5pt + black,
    [*Hyperparamètre*], [*Valeur*],
    [Époques], [3],
    [Batch size (entraînement)], [16],
    [Batch size (évaluation)], [32],
    [Learning rate], [$2 times 10^{-5}$],
    [Weight decay], [0,01],
    [Warmup ratio], [0,10],
    [Longueur maximale de séquence], [128 tokens],
    [Précision], [FP16 (GPU)],
    [Early stopping (patience)], [3 époques],
    [Métrique de sélection du checkpoint], [F1‑macro (validation)],
  ),
  caption: [Hyperparamètres communs au fine‑tuning des cinq modèles Transformer.],
  kind: table,
) <tab:hyperparams>

=== Modèles de référence : AraBERT, MARBERT, DarijaBERT, CAMeLBERT‑Mix

==== Présentation

- *AraBERT* (`aubmindlab/bert-base-arabertv02`, 135,2 M paramètres) : pré‑entraîné sur
  Wikipedia arabe et les corpus OSIAN/OSCAR après segmentation morphologique par Farasa.
  Son vocabulaire couvre l'arabe standard moderne mais peine sur les formes dialectales
  non-standard — les emprunts berbères et le code-switching franco-arabe génèrent de
  nombreux tokens `[UNK]`.

- *MARBERT* (`UBC-NLP/MARBERT`, 147,5 M paramètres) : entraîné sur 128 millions de tweets
  arabes couvrant 22 dialectes ; le code‑switching y est nativement représenté. Son
  vocabulaire dialectal large en fait le modèle de référence naturel pour les réseaux sociaux
  arabes, mais la darija algérienne n'est pas son dialecte dominant.

- *DarijaBERT* (`SI2M-Lab/DarijaBERT`, 147,5 M paramètres) : spécialisé sur la darija
  marocaine. Bien que phonologiquement et lexicalement proche de la darija algérienne,
  les deux variétés présentent des divergences substantielles en termes d'emprunts berbères
  (tamazight vs kabyle/chaoui) et de calques du français — ce qui explique ses performances
  inférieures à DziriBERT sur notre corpus.

- *CAMeLBERT‑Mix* (`CAMeL-Lab/bert-base-arabic-camelbert-mix`, 109,1 M paramètres) : mélange
  d'arabe standard et de dialectes du Golfe, égyptien et levantin. La darija algérienne est
  quasi-absente de son corpus de pré-entraînement, ce qui en fait une référence utile pour
  quantifier l'apport d'une spécialisation dialectale.

==== Résultats détaillés sur le jeu de test

#let class_names = ("Négatif", "Neutre", "Positif")
#let supports = (1923, 515, 97)

// AraBERT
#let ar_prec = (0.94, 0.73, 0.72)
#let ar_rec = (0.92, 0.79, 0.67)
#let ar_f1 = (0.93, 0.76, 0.70)

#figure(
  table(
    columns: (1.5fr, 1fr, 1fr, 1fr, 1fr),
    inset: (x: 5pt, y: 4pt),
    align: (left, center, center, center, center),
    stroke: 0.5pt + black,
    [*Classe*], [*Précision*], [*Rappel*], [*F1‑score*], [*Support*],
    ..class_names
      .zip(ar_prec, ar_rec, ar_f1, supports)
      .map(((c, p, r, f, s)) => ([#c], [#p], [#r], [#f], [#s]))
      .flatten(),
  ),
  caption: [Rapport de classification *AraBERT* sur test.],
  kind: table,
) <tab:ar_report>

- Accuracy = 88,68 % · F1‑macro = 0,7955 · F1‑weighted = 0,8880. AraBERT atteint déjà un F1-positif de 0,70 malgré l'absence de vocabulaire dialectal natif,
  ce qui suggère que les features syntaxiques universelles (négation, modalité) sont
  partiellement capturées par son encodeur pré-entraîné sur l'arabe standard.
#figure(
  image("../images/arbert_confusion_matrix.png", width: 13cm),
  caption: [Matrice de confusion d'AraBERT. ],
  kind: image
) <fig:ar_cm>
- 1 775 négatifs corrects (92,3 %), 407 neutres
  (79,0 %), 65 positifs (67,0 %). La confusion principale est neutre→négatif (101 cas),
  reflétant la difficulté du modèle à distinguer les commentaires neutres des commentaires
  négatifs modérés en darija.
// MARBERT
#let ma_prec = (0.93, 0.77, 0.81)
#let ma_rec = (0.94, 0.76, 0.64)
#let ma_f1 = (0.94, 0.76, 0.71)

#figure(
  table(
    columns: (1.5fr, 1fr, 1fr, 1fr, 1fr),
    inset: (x: 5pt, y: 4pt),
    align: (left, center, center, center, center),
    stroke: 0.5pt + black,
    [*Classe*], [*Précision*], [*Rappel*], [*F1‑score*], [*Support*],
    ..class_names
      .zip(ma_prec, ma_rec, ma_f1, supports)
      .map(((c, p, r, f, s)) => ([#c], [#p], [#r], [#f], [#s]))
      .flatten(),
  ),
  caption: [Rapport de classification *MARBERT*.],
  kind: table,
) <tab:ma_report>
- Accuracy = 89,47 % · F1‑macro = 0,8044 · F1‑weighted = 0,8936. La précision positif de 0,81 la plus élevée parmi les modèles de référence reflète l'exposition de MARBERT à de nombreux dialectes : il identifie les
  marqueurs positifs avec moins de faux positifs, même si son rappel-positif reste limité
  (0,64).
#figure(
  image("../images/marbert_confusion_matrix.png", width: 13cm),
  caption: [Matrice de confusion de MARBERT.],
  kind: image
) <fig:ma_cm>
- Le taux de vrais positifs détectés (62/97 = 64 %)
  est le plus faible des cinq modèles, malgré la meilleure précision (0,81) — profil
  précision-haute/rappel-faible caractéristique d'un seuil de décision trop conservateur.
// DarijaBERT
#let da_prec = (0.93, 0.76, 0.67)
#let da_rec = (0.94, 0.73, 0.61)
#let da_f1 = (0.93, 0.75, 0.64)

#figure(
  table(
    columns: (1.5fr, 1fr, 1fr, 1fr, 1fr),
    inset: (x: 5pt, y: 4pt),
    align: (left, center, center, center, center),
    stroke: 0.5pt + black,
    [*Classe*], [*Précision*], [*Rappel*], [*F1‑score*], [*Support*],
    ..class_names
      .zip(da_prec, da_rec, da_f1, supports)
      .map(((c, p, r, f, s)) => ([#c], [#p], [#r], [#f], [#s]))
      .flatten(),
  ),
  caption: [Rapport de classification *DarijaBERT*. ],
  kind: table,
) <tab:da_report>
Accuracy = 88,52 % · F1‑macro = 0,7722 ·
F1‑weighted = 0,8840. Les performances inférieures à AraBERT (F1-macro 0,7722 vs 0,7955)
confirment que la spécialisation sur la darija marocaine ne transfère pas directement
au dialecte algérien — les divergences lexicales entre les deux variétés constituent un
frein plus important qu'une spécialisation sur l'arabe standard.
#figure(
  image("../images/darijabert_confusion_matrix.png", width: 13cm),
  caption: [Matrice de confusion de DarijaBERT.],
  kind: image
) <fig:da_cm>
Le F1-positif de 0,64 est le plus faible
parmi tous les Transformers évalués — y compris AraBERT — illustrant que la spécialisation
dialectale marocaine introduit des représentations parasites pour la darija algérienne.
// CAMeLBERT-Mix
#let ca_prec = (0.93, 0.76, 0.76)
#let ca_rec = (0.94, 0.75, 0.60)
#let ca_f1 = (0.94, 0.75, 0.67)

#figure(
  table(
    columns: (1.5fr, 1fr, 1fr, 1fr, 1fr),
    inset: (x: 5pt, y: 4pt),
    align: (left, center, center, center, center),
    stroke: 0.5pt + black,
    [*Classe*], [*Précision*], [*Rappel*], [*F1‑score*], [*Support*],
    ..class_names
      .zip(ca_prec, ca_rec, ca_f1, supports)
      .map(((c, p, r, f, s)) => ([#c], [#p], [#r], [#f], [#s]))
      .flatten(),
  ),
  caption: [Rapport de classification *CAMeLBERT‑Mix*],
  kind: table,
) <tab:ca_report>
. Accuracy = 88,99 % · F1‑macro = 0,7869 ·
F1‑weighted = 0,8887. CAMeLBERT-Mix surpasse DarijaBERT et AraBERT grâce à son exposition
à un mélange de dialectes, mais son rappel-positif de 0,60 est le second plus faible —
la darija algérienne reste sous-représentée dans son corpus.
#figure(
  image("../images/camelbert_confusion_matrix.png", width: 13cm),
  caption: [Matrice de confusion de CAMeLBERT‑Mix.],
  kind: image
) <fig:ca_cm>

=== DziriBERT

==== Présentation

DziriBERT (`alger-ia/dziribert`, 124,4 M paramètres) est le seul modèle pré‑entraîné
spécifiquement sur la darija algérienne dans notre comparaison. Son tokeniseur, calibré sur
les conventions lexicales et orthographiques du dialecte algérien (y compris les emprunts
kabyles, les calques franco-arabes et les variantes phonétiques régionales), réduit
mécaniquement le taux de tokens `[UNK]` par rapport à tous ses concurrents. C'est cet
alignement tokeniseur-corpus cible qui explique en premier lieu ses performances supérieures.

==== Courbes d'apprentissage et performances

#figure(
  image("../images/dziribert_baseline_learning_curves.png", width: 14cm),
  caption: [Courbes d'apprentissage de DziriBERT baseline.],
  kind: image
) <fig:dziri_lc>
La val loss minimale est atteinte
à l'époque 2 (0,562), puis se dégrade à 0,676 à l'époque 3 — signal clair de surapprentissage.
Le F1‑macro de validation continue cependant de progresser légèrement, masquant partiellement
la dégradation de calibration. Le checkpoint de l'époque 2 est celui retenu pour l'évaluation.
#let dz_prec = (0.93, 0.79, 0.80)
#let dz_rec = (0.95, 0.77, 0.66)
#let dz_f1 = (0.94, 0.78, 0.72)

#figure(
  table(
    columns: (1.5fr, 1fr, 1fr, 1fr, 1fr),
    inset: (x: 5pt, y: 4pt),
    align: (left, center, center, center, center),
    stroke: 0.5pt + black,
    [*Classe*], [*Précision*], [*Rappel*], [*F1‑score*], [*Support*],
    ..class_names
      .zip(dz_prec, dz_rec, dz_f1, supports)
      .map(((c, p, r, f, s)) => ([#c], [#p], [#r], [#f], [#s]))
      .flatten(),
  ),
  caption: [Rapport de classification *DziriBERT baseline*.],
  kind: table,
) <tab:dz_report>
Accuracy = 90,14 % · F1‑macro =
0,8146 · F1‑weighted = 0,9001. DziriBERT est le seul modèle à franchir la barre des 90 %
d'accuracy et des 0,81 de F1‑macro. Sa précision-positif de 0,80 (la plus élevée de tous
les modèles) et son rappel-positif de 0,66 (64/97 commentaires positifs identifiés)
témoignent d'une meilleure compréhension des expressions positives en darija algérienne.
#figure(
  image("../images/dziribert_baseline_confusion_matrix.png", width: 13cm),
  caption: [Matrice de confusion de DziriBERT baseline.],
  kind: image
) <fig:dz_cm>
La diagonale principale est la plus
forte de tous les modèles évalués. La confusion résiduelle principale est positif→négatif
(33 cas sur 97), reflétant la difficulté à distinguer les expressions positives modérées
(satisfaction nuancée) des commentaires neutres en darija.
==== Diagnostic du surapprentissage chez les Transformers

Tous les modèles présentent une val loss croissante entre les époques 2 et 3, signe d'un
surapprentissage systématique avec 3 époques de fine-tuning. Ce phénomène est bien documenté
pour le fine-tuning de BERT sur des corpus de taille modérée (< 50 000 exemples) : l'encodeur
pré-entraîné se spécialise trop rapidement sur le corpus cible, perdant les généralisations
acquises lors du pré-entraînement.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto),
    inset: (x: 5pt, y: 4pt),
    align: (left, center, center, center, center),
    stroke: 0.5pt + black,
    [*Modèle*], [*Val loss min (ép.)*], [*Val loss ép. 3*], [*Écart train‑val (ép. 3)*], [*Sévérité*],
    [AraBERT], [0,589 (ép. 2)], [0,629], [0,211], [Modéré],
    [MARBERT], [0,569 (ép. 2)], [0,791], [0,499], [Sévère],
    [DarijaBERT], [0,612 (ép. 2)], [0,721], [0,382], [Élevé],
    [CAMeLBERT‑Mix], [0,591 (ép. 2)], [0,702], [0,392], [Élevé],
    [DziriBERT (baseline)], [0,562 (ép. 2)], [0,676], [0,420], [Élevé],
  ),
  caption: [Analyse du surapprentissage — tous les modèles atteignent leur val loss minimale
    à l'époque 2 et se dégradent à l'époque 3.],
  kind: table,
) <tab:overfit_transformers>
MARBERT présente le cas le plus sévère (Δ = 0,499),
probablement dû à son nombre de paramètres élevé (147,5 M) combiné à un faible weight decay
(0,01). AraBERT montre la meilleure résistance (Δ = 0,211), ce qui suggère que son
pré-entraînement sur un corpus homogène (arabe standard) produit des représentations plus
stables face à la spécialisation.
==== Synthèse comparative des cinq modèles Transformer

#figure(
  table(
    columns: (2fr, 1fr, 1fr, 1fr, 1.1fr, 1.1fr, 1.1fr),
    inset: (x: 5pt, y: 4pt),
    align: (left, center, center, center, center, center, center),
    stroke: 0.5pt + black,
    [*Modèle*], [*Acc.*], [*F1‑mac.*], [*F1 (nég.)*], [*F1 (neu.)*], [*F1 (pos.)*], [*Params (M)*],
    [AraBERT], [0,8868], [0,7955], [0,93], [0,76], [0,70], [135,2],
    [MARBERT], [0,8947], [0,8044], [0,94], [0,76], [0,71], [147,5],
    [DarijaBERT], [0,8852], [0,7722], [0,93], [0,75], [0,64], [147,5],
    [CAMeLBERT‑Mix], [0,8899], [0,7869], [0,94], [0,75], [0,67], [109,1],
    [*DziriBERT*], [*0,9014*], [*0,8146*], [*0,94*], [*0,78*], [*0,72*], [124,4],
  ),
  caption: [Comparaison des cinq modèles Transformer sur le jeu de test (2 535 documents,
    découpage 80/10/10). DziriBERT domine sur toutes les métriques. ],
  kind: table,
) <tab:transformers_compare>
L'ordre de performance
* — DziriBERT > MARBERT > CAMeLBERT-Mix > AraBERT > DarijaBERT —*  reflète précisément le
degré d'exposition au dialecte algérien dans les données de pré-entraînement.

=== Sélection du modèle Transformer — vers DziriBERT

Cinq architectures ont été évaluées : AraBERT, MARBERT, DarijaBERT, CAMeLBERT‑Mix et DziriBERT.
Les quatre premières servent de références croisées permettant d'isoler l'effet de la
spécialisation dialectale ; DziriBERT, seul modèle pré‑entraîné spécifiquement sur la darija
algérienne, constitue le candidat naturellement favorisé.

==== Résultats comparatifs des cinq Transformers

#figure(
  table(
    columns: (2fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1.2fr),
    inset: (x: 5pt, y: 4pt),
    align: (left, center, center, center, center, center, center),
    stroke: 0.5pt + black,
    [*Modèle*], [*Acc.*], [*F1‑mac.*], [*F1 (nég.)*], [*F1 (neu.)*], [*F1 (pos.)*], [*Params (M)*],
    [AraBERT], [0,8868], [0,7955], [0,93], [0,76], [0,70], [135,2],
    [MARBERT], [0,8947], [0,8044], [0,94], [0,76], [0,71], [147,5],
    [DarijaBERT], [0,8852], [0,7722], [0,93], [0,75], [0,64], [147,5],
    [CAMeLBERT‑Mix], [0,8899], [0,7869], [0,94], [0,75], [0,67], [109,1],
    [*DziriBERT*], [*0,9014*], [*0,8146*], [*0,94*], [*0,78*], [*0,72*], [124,4],
  ),
  caption: [Comparaison des cinq modèles Transformer sur le jeu de test (2 535 documents.],
  kind: table,
)
découpage 80/10/10). DziriBERT surpasse tous ses concurrents sur l'accuracy et le F1‑macro,
ainsi que sur les classes minoritaires *neutre* (+2 à +3 points) et *positif* (+1 à +8 points
selon le modèle de référence)
==== Justification du choix de DziriBERT

DziriBERT (`alger-ia/dziribert`, 124,4 M paramètres) se distingue par quatre atouts décisifs.

- *Adéquation au dialecte cible.* C'est le seul modèle pré‑entraîné spécifiquement sur la darija
algérienne. Son tokeniseur, calibré sur les conventions lexicales et orthographiques du dialecte
algérien, réduit mécaniquement le taux de tokens `[UNK]` pour les emprunts berbères, les
variantes phonétiques régionales et le code‑switching franco-arabe. Cette réduction du bruit de
tokenisation se traduit directement en gain de F1 sur les classes difficiles.

- *Meilleur F1‑macro (0,8146).* DziriBERT devance MARBERT de +1,0 point, AraBERT de +1,9 points,
CAMeLBERT-Mix de +2,8 points et DarijaBERT de +4,2 points. Sur un corpus aussi déséquilibré,
chaque point de F1‑macro correspond à une amélioration concrète sur les classes minoritaires —
non à un artefact statistique.

- *Meilleures performances sur les classes difficiles.* DziriBERT obtient les F1 les plus élevés
sur *neutre* (0,78) et *positif* (0,72), ainsi que la meilleure précision-positive (0,80).
La classe *négatif* atteint F1 = 0,94, score partagé avec MARBERT et CAMeLBERT-Mix — mais
DziriBERT y parvient avec la meilleure accuracy globale (90,14 %).

- *Efficacité paramétrique.* Avec 124,4 M paramètres, DziriBERT est plus compact que MARBERT
et DarijaBERT (147,5 M chacun), tout en les surpassant en performance sur tous les indicateurs.
Ce ratio performance/taille est un avantage opérationnel non négligeable pour le déploiement
en production.

== Problèmes identifiés et pistes d'amélioration

Malgré ses performances supérieures, DziriBERT baseline présente des failles structurelles
que les expériences suivantes s'attacheront à corriger.

// // ============================================================
// // Problématiques identifiées – version tableau synthétique
// // ============================================================

#figure(
  table(
    columns: (2.4fr, auto, 3fr, 2.8fr),
    stroke: 0.5pt,
    inset: (x: 6pt, y: 6pt),
    align: (left, left, left, left),
    [*Problématique*], [*Criticité*], [*Description concise*], [*Mesure / Impact*],

    [Déséquilibre extrême des classes],
    [*Critique*],
    [
      Ratio négatif/positif = 19,7:1. La classe minoritaire (positif, 3,8 %) est noyée par la majoritaire.
    ],
    [
      Rappel positif max = 0,67 (DziriBERT) alors que l’AUC ROC atteint 0,948 → le problème est le seuil, non la représentabilité.
    ],

    [Confusion lexicale neutre / négatif],
    [*Élevé*],
    [
      Mêmes mots (noms d’opérateurs, termes de service) dans les deux classes → frontière floue en BoW.
    ],
    [
      F1‑neutre plafonné à 0,78 (DziriBERT) ; confusion majeure chez AraBERT (101 neutres → négatif).
    ],

    // NOUVELLE LIGNE AJOUTÉE
    [Ambiguïté positif / neutre],
    [*Élevé*],
    [
      Un même mot (“bonne”) exprime une polarité positive, mais dans des expressions figées comme “bonne année” le commentaire devient neutre. Le modèle hésite entre positif et neutre.
    ],
    [
      Exemple typique : “bonne” → positif, “bonne année” → neutre. Cette granularité sémantique n’est pas capturée par les représentations bag‑of‑words et reste difficile même pour les Transformers.
    ],

    [Ambiguïté sémantique positif / négatif],
    [*Élevé*],
    [
      Ironie, négation implicite, satisfaction partielle. Un même mot (“مليح”) peut exprimer les deux polarités.
    ],
    [
      Confusion résiduelle DziriBERT : 33 positifs classés négatifs sur 97.
    ],

    [Surapprentissage systématique],
    [*Élevé*],
    [
      Écart train‑validation significatif pour tous les modèles. Transformers : val loss qui remonte dès l’époque 2.
    ],
    [
      SVM : Δ F1 = 0,19 (0,98 vs 0,79). DziriBERT : perte de validation 0,562 → 0,676 à l’époque 3.
    ],

    [Bruit non‑sentimental],
    [*Moyen*],
    [
      Commentaires sans valeur affective (réponses privées, numéros, demandes). Pollue l’apprentissage.
    ],
    [
      Dilue le signal utile, génère des faux positifs/négatifs, participe au surapprentissage.
    ],

    [Seuil de décision sous‑optimal],
    [*Moyen*],
    [
      L’AUC positive est excellente (0,948) mais le seuil par défaut (0) est trop conservateur.
    ],
    [
      Rappel positif limité à 0,67 ; un recalage du seuil pourrait l’emmener vers 0,80 sans perte majeure de précision.
    ],

    [Absence de plateau d’apprentissage],
    [*Structurel*],
    [
      La courbe d’apprentissage du SVM TF‑IDF n’atteint pas de plateau à 100 % des données (pente toujours positive).
    ],
    [
      Avec plus de données (surtout pour la classe positive), les performances progresseraient encore significativement.
    ],
  ),
  caption: [
    Problématiques identifiées lors de l’évaluation des neuf modèles (baselines linéaires, avancés, Transformers).
  ],
  kind: table,
) <tab:problematiques>


// #h(0.5cm)Le tableau @tab:problematiques a mis en évidence neuf failles structurelles de la baseline DziriBERT. Parmi celles-ci, trois limitations majeures pénalisent le plus le F1‑macro : le **surapprentissage systématique** (validation loss remontant dès l’époque 2), le **déséquilibre extrême des classes** (ratio 19,7:1) et les **ambiguïtés lexicales** (confusions neutre/négatif et ambiguïté positif/neutre).

// #h(0.5cm)Pour répondre à ces problèmes spécifiques, nous concevons un pipeline d’optimisation en deux phases :

// - *Ingénierie des Caractéristiques Hybrides* : sélection de features par Chi² et extraction de flags sémantiques (détection d’expressions figées, modificateurs de polarité).
// - *Architectures Neurales Hybrides Expérimentales* : intégration de ces features externes dans l’architecture DziriBERT via plusieurs expériences itératives.



== Optimisation Avancée et Architecture Hybride DziriBERT



#h(0.5cm)Dans le titre précédent, nous avons établi que DziriBERT (alger-ia/dziribert) constituait l'architecture de référence la plus performante parmi les modèles Transformer testés,  Cependant, l'analyse approfondie de cette baseline a révélé trois limitations structurelles majeures qui freinent l'atteinte d'une performance optimale *(>92%)* :

#h(0.5cm) - * Surapprentissage *
#h(0.5cm) - * Déséquilibre de Classes Sévère*
#h(0.5cm) - * Ambiguïté Lexicale*

Pour résoudre ces problèmes, nous avons conçu un pipeline d'optimisation en deux phases :

- *Ingénierie des Caractéristiques Hybrides :* Sélection de features via Chi² et extraction de flags sémantiques.
- *Architectures Neurales Hybrides Expérimentales :* Intégration de ces features externes dans l'architecture DziriBERT via plusieurs expériences itératives.







=== Préparation des Données et Ingénierie des Features :

Avant d'attaquer le fine-tuning de *l'Expérience de base*, nous avons procédé à une restructuration fondamentale des données   ,Cette étape vise à enrichir la représentation des *textes au-delà des simples tokens*.

#h(0.5cm)*1. Stratégie de Rééquilibrage Strict :*

#h(0.5cm)Contrairement aux approches classiques qui appliquent le rééquilibrage uniquement lors de l'entraînement (via les poids de classe), nous avons appliqué un sur-échantillonnage (oversampling) strict au niveau du dataset.

- *Cible :* Rééquilibrage mixte : sous-échantillonnage de la classe majoritaire (Négatif) et sur-échantillonnage avec remplacement des classes minoritaires (Neutre, Positif), jusqu'à atteindre 4 559 exemples par classe.

- *Résultat :* Élimination du biais majeur envers la classe Négative. Le dataset passe d'une distribution déséquilibrée (72% Négatif / 21% Neutre / 7% Positif) à une distribution parfaitement équilibrée (33% / 33% / 33%).


#h(0.5cm)*2. Extraction de Flags Sémantiques (Règles Expertes)* :


#h(0.5cm)Pour compenser les faiblesses contextuelles de BERT sur certaines nuances dialectales, nous avons développé un module basé sur des expressions régulières pour extraire des signaux explicites.

- *Flags binaires (6 dims) :* negation, mixte, social, encouragement, plainte, suggestion.

- *Subtypes (3 dims) :* Détection fine de masked_neg (négation masquée), prv (plainte directe), et produit (mention produit).

- *Vecteur Final :* Un vecteur dense de 10 dimensions (6 flags + 3 subtypes) est généré pour chaque exemple.
Ce vecteur sera concaténé à l'embedding [CLS] de BERT dans l'Expérience 1.




*3. Sélection de Mots Clés via Chi² ( χ
2)*

#h(0.5cm)Bien que Expérience de base se concentre principalement sur l'apport des flags, nous avons également préparé le terrain pour les expériences suivantes en appliquant le test du Chi-carré :


*1. *Filtrage par fréquence (MinDF=3, MaxDF=0.85).
Calcul du score
χ
2

*2. *pour chaque terme par rapport aux labels.

*3. *Application d'un seuil de dissimilarité pour conserver uniquement les termes les plus discriminants.

Cette étape permet d'identifier les mots-clés lexicaux forts qui seront utilisés dans les variantes futures, mais sert ici à valider la qualité du preprocessing.


=== Architectures Neurales Hybrides Expérimentales



*1.Modélisation Hybride (Experience de base)*:


*1.1 État antérieur – Un overfitting sévère* :

#h(0.5cm) Avant d’établir les 2 phases, notre Les versions précédentes du Dziribert  utilise une architecture beaucoup trop complexe par rapport à la taille du corpus disponible :

- *Vecteur d’entrée :* [CLS](768) + TF‑IDF(1742) + subtypes(14) = 2 524 dimensions.

- *Gel des couches BERT :* FREEZE_LAYERS = 0 (aucune couche gelée, le modèle était entièrement entraînable).

- *Corpus :* non équilibré, avec un fort déséquilibre entre les classes (Neutre sur‑représenté, Positif sous‑représenté).

*1.2 Objectif de les Experience de base :*

- Résoudre l’overfitting par une refonte radicale de l’architecture et des hyperparamètres.

- Établir un point de référence stable et reproductible pour les expériences ultérieures (EXP1, EXP2, EXP3, EXP4, EXP5).

- Valider l’apport des flags manuels DZ (seuls, sans ajout de vocabulaire TF‑IDF).

Pour atteindre ces objectifs, nous avons mis en œuvre plusieurs changements structurels majeurs, détaillés ci‑dessous.


*1.3 Résumé des principes directeurs de  l'Experience de base *:

#figure(
  table(
    columns: (1fr, 2fr),
    align: (left, left),
    stroke: 1pt,
    [*Principe*], [*Mise en œuvre*],
    [Réduction drastique de la dimensionnalité],
    [Suppression du TF-IDF (redondant car BERT le « voit » déjà via ses embeddings). Conservation uniquement des flags manuels DZ (10 dimensions).],

    [Gel des couches inférieures de BERT],
    [FREEZE_LAYERS = 8 : seules les couches 8 à 11 sont entraînables (124,4 M de paramètres totaux, seulement 28,9 M entraînables).],

    [Renforcement de la régularisation],
    [DROPOUT_RATE = 0,4 (tête de classification), LABEL_SMOOTHING = 0,15, WEIGHT_DECAY = 0,05.],

    [Early stopping strict], [Patience = 2 époques, métrique = validation loss.],
    [Corpus équilibré (Phase 3 v2)],
    [Rééquilibrage mixte (undersampling + oversampling avec remplacement) à 4 559 documents par classe.],

    [Prétraitement normalisé], [Normalisation complète (mode Full), stopwords supprimés, tokenisation standard.],
  ),
  caption: [Résumé des principes directeurs de  l'Experience de base],
  kind: table,
)




*1.4 Protocole expérimental:*

*1.4.1 Le Chi² et la dissimilarité :*
le test du Chi² et le filtre de dissimilarité inter‑classes ont bien été appliqués lors de l'Experience de base (préparation du corpus). Ils ont permis de sélectionner les termes les plus discriminants et d’éliminer le bruit lexical.

Cependant, *TOP_TFIDF_WORDS = 0 :* aucun de ces termes n’a été vectorisé en TF‑IDF. Le modèle n’a donc reçu que les 10 dimensions des flags.

*1.5 Hyperparamètres de l’expérience :*
#align(center)[
  #figure(
    table(
      columns: (1fr, 1fr, 2fr),
      align: (left, center, left),
      stroke: 1pt,
      [*Paramètre*], [*Valeur*], [*Rôle*],
      [FREEZE_LAYERS], [8 / 12], [Couches 0-7 gelées, seules les couches 8-11 sont entraînables],
      [DROPOUT_RATE], [0,40], [Régularisation forte de la tête de classification],
      [LEARNING_RATE], [2e-5], [Taux d'apprentissage conservateur (fine-tuning)],
      [LABEL_SMOOTHING], [0,15], [Lissage des labels pour éviter la sur-confiance],
      [WEIGHT_DECAY], [0,05], [Régularisation L2],
      [BATCH_SIZE], [16], [Taille des lots (compatible GPU T4)],
      [EPOCHS], [5], [Nombre maximum d'époques],
      [EARLY_STOPPING], [2], [Patience sur la validation loss],
      [WARMUP_RATIO], [0,10], [Proportion d'étapes pour le warmup du learning rate],
      [MAX_LENGTH], [128], [Troncature des séquences],
    ),
    caption: [Hyperparamètres de l’expérience  de base.],
  kind: table,
  )]

*1.6 Résultats détaillés:*

*1.6.1 Historique d’entraînement (5 époques)* :

Le tableau ci‑dessous présente l’évolution des métriques sur l’ensemble de validation à chaque époque.
#align(center)[
  #figure(
    table(
      columns: (auto, auto, auto, auto, auto, auto, auto, auto),
      align: (center + horizon),
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      stroke: 1pt,
      [*Époque*],
      [*Training Loss*],
      [*Validation Loss*],
      [*Accuracy (\%)*],
      [*F1 Macro*],
      [*F1\ Négatif*],
      [*F1 Neutre*],
      [*F1 Positif*],

      [1], [0,8794], [0,7638], [76,24], [0,7572], [0,7570], [0,7974], [0,7173],
      [2], [0,7417], [0,6650], [84,14], [0,8385], [0,8089], [0,8667], [0,8398],
      [3], [0,6432], [0,6167], [87,87], [0,8774], [0,8417], [0,8988], [0,8918],
      [4], [0,6002], [0,5990], [88,60], [0,8851], [0,8542], [0,9017], [0,8995],
      [5], [0,5764], [0,5969], [89,18], [0,8912], [0,8585], [0,9065], [0,9086],
    ),
    caption: [Évolution des performances lors de l'entraînement (Expérience  de base)],
  kind: table,
  )
]

*1.6.2 Courbes d’apprentissage et performances*

Après rechargement du meilleur modèle (époque 5) et évaluation sur les 1 368 documents du jeu de test (non vus lors de l’entraînement et de la validation), nous obtenons les métriques suivantes :

#figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto),
    align: center,
    stroke: 1pt,
    [*Métrique*], [Accuracy], [F1 Macro], [F1 Weighted], [Train Loss], [Val Loss], [Écart],
    [*Expérience de base*], [87,43\%], [0,8737], [0,8748], [0,5764], [0,5969], [0,0205],
  ),
  caption: [Métriques de performance pour Expérience  de base.],
  kind: table,
)

#figure(
  image("../images/courbe_d'apprentisage_experience_base.jpg", width: 15cm),
  caption: [Courbes d’apprentissage de Experience 2.],
  kind: image
)
\
la matrice de confusion est présentées en *annexe (@matrice_confusion_experiece_base).*


*1.7 Analyse et interprétation :*

*1.7.1 L’overfitting est résolu – Un succès majeur :*

L’indicateur clé de succès de l’expérience  de base est l’écart de loss entre l’entraînement et la validation.

#align(center)[
  #figure(
    table(
      columns: (auto, auto, auto),
      align: center,
      stroke: 1pt,
      [*Métrique*], [*Version antérieure (problématique)*], [*Expérience de base*],
      [Dimensions vecteur], [2 524], [778],
      [Couches gelées], [0 / 12], [8 / 12],
      [Écart Train/Val], [#text(fill: red)[*0,41 (overfitting sévère)*]], [#text(fill: green)[*0,0205 (excellent)*]],
    ),
    caption: [Comparaison de l'architecture et de la stabilité (Version initiale vs Expérience de base).],
  kind: table,
  )
]
La réduction drastique de la dimensionnalité *(2 524 → 778)* et le gel des 8 premières couches ont permis de régulariser fortement le modèle. L’écart de *0,0205* est quasi parfait : le modèle n’apprend pas de motifs idiosyncratiques propres au corpus d’entraînement. L’objectif prioritaire est atteint.


*1.7.2 La stabilité a un coût : des performances encore limitées*

Si l’overfitting est résolu, les performances en précision restent limitées (87,43 % d’accuracy). Plusieurs facteurs l’expliquent :

- *Gel trop important :* En bloquant 8 couches sur 12, le modèle dispose d’une marge d’adaptation très réduite. Il ne peut pas ajuster ses représentations sémantiques de haut niveau aux spécificités de la Darija algérienne.

- *Absence de vocabulaire spécifique :* Les flags manuels (10 dimensions) ne couvrent pas les termes techniques (fibre, coupure, facture) ni les marqueurs dialectaux forts (bzzaf, machi, 3lach). Le modèle manque d’indices lexicaux.

- *Pas de TF‑IDF :* Bien que le Chi² et la dissimilarité aient été appliqués en amont, leurs résultats (les termes sélectionnés) n’ont pas été intégrés dans le vecteur d’entrée.

*1.7.3 Progression par époque – Un apprentissage régulier*

L’historique montre une progression stable et régulière :

#h(0.5cm)- *F1 Macro :* 0,7572 (E1) → 0,8912 (E5) → +0,1340

#h(0.5cm) *- Validation Loss : *0,7638 (E1) → 0,5969 (E5) → –0,1669

Le modèle n’a pas atteint de plateau à *l’époque 5 *: la validation loss est encore en légère décroissance à l’époque 4 (0,5990), et la training loss continue de baisser. Cela indique que *davantage d’époques ou un dégel partiel* des couches pourrait permettre de poursuivre la progression.

*1.7.4 Analyse par classe – Forces et faiblesses: *

#align(center)[
  #figure(
    table(
      columns: (0.2fr, 0.2fr, 1fr),
      align: (left, center, left),
      stroke: 1pt,
      [*Classe*], [*F1 *], [*Observations*],
      [Négatif], [0,8418], [Bonne détection (429/430 corrects), mais peut encore être améliorée.],
      [Neutre],
      [0,8913],
      [Performance correcte. Les 74 erreurs se répartissent entre Négatif (33) et Positif (41). Les formules sociales ("merci", "bon courage") restent ambiguës.],

      [Positif],
      [0,8880],
      [Sous-performance relative. Les positifs conditionnels (suggestions, encouragements liés à un produit) sont la principale source d'erreur.],
    ),
    caption: [Analyse détaillée des performances par classe et interprétation des erreurs(Expérience de base).],
  kind: table,
  )

]
- La classe Positif, bien que moins représentée dans le corpus d’origine, bénéficie du rééquilibrage, mais son F1 reste inférieur à celui du Negatif et du Neutre.

*1.8 Conclusion de l'Experience de base :*



L'Experience de base a atteint ses deux objectifs prioritaires :

- *1.* *Résoudre l’overfitting sévère* qui parasitait les versions antérieures. L’écart entre la training loss et la validation loss est passé de *0,41 à 0,0205*, une amélioration spectaculaire qui atteste d’une excellente généralisation.

- *2.* *Établir une référence stable* pour les expériences ultérieures. Avec une accuracy de 87,43 % et un F1 Macro de 0,8737, cette configuration valide la pertinence des flags manuels DZ comme bruit de fond solide pour l’analyse de sentiments en dialecte algérien.

Cependant, cette stabilité a un coût : le gel de 8 couches sur 12 limite sévèrement la capacité d’adaptation du modèle. L’absence de vocabulaire TF‑IDF (les termes sélectionnés par Chi² et dissimilarité ne sont pas vectorisés) prive le modèle d’indices lexicaux pourtant discriminants.

Ces limites identifiées ouvrent naturellement la voie aux expériences suivantes :

- *EXP1 : *dégeler les couches 4 à 11 (FREEZE_LAYERS = 4) pour offrir plus de flexibilité au modèle.

- *EXP2 :* ajouter un vecteur TF‑IDF (150 termes) pour enrichir la représentation avec le vocabulaire le plus discriminant.

- *EXP3 : *dégeler davantage (FREEZE_LAYERS = 2) pour capturer des interactions plus complexes.

- * EXP4 :* tester un classifieur non‑linéaire (2 couches).

- *EXP5 :* augmenter le nombre de termes TF‑IDF à 300 pour tester la sensibilité à ce paramètre

\



*2. Modélisation Hybride (Expérience 1)*:

#h(0.5cm) L’Expérience 1 (EXP1) constitue notre première architecture hybride : elle concatène les flags manuels DZ (10 dimensions : 7 flags binaires + 3 subtypes) au vecteur d’embedding [CLS] de DziriBERT.

* 2.1 Hypothèse centrale :*

L’ajout de features explicites sémantiques aux embeddings contextuels de DziriBERT permettra de compenser les faiblesses du modèle pur face aux nuances complexes de la Darija (négations masquées, ironie, code‑switching).

Nous postulons que :

- 1. BERT capture bien le contexte global mais peut manquer certains signaux lexicaux forts et explicites (ex : un mot‑clé négatif fort comme khaybe, nul). Les flags apportent ces signaux de façon directe.

- 2. L’ajout des 10 dimensions des flags enrichit la représentation et oriente la couche de classification vers les indices sémantiques les plus discriminants, agissant comme un « guide » pour le modèle.

Cette hybridation légère réduira drastiquement l’écart de loss observé dans les versions antérieures (objectif : faire passer l’écart Train/Val de 0,41 à moins de 0,10), car le modèle aura moins besoin de « mémoriser » des motifs bruités pour détecter le sentiment.

*2.2 Protocole Expérimental:*

*2.2.1 Modifications par rapport à l'Expérience de base :*

#align(center)[
  #figure(
    table(
      columns: (auto, auto, 1fr),
      align: (left, center, left),
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else { none },
      [*Paramètre*], [*Valeur EXP1*], [*Rôle / Justification*],
      [FREEZE_LAYERS],
      [4 / 12],
      [Gel des 4 premières couches. Couches 4-11 entraînables Seules les 4 dernières couches et la tête de classification sont entraînables. Cela stabilise l'apprentissage et réduit le risque d'overfitting sur un dataset limité.],

      [DROPOUT_RATE],
      [0,30],
      [Régularisation forte appliquée sur l'embedding [CLS] avant concaténation avec les flags.],

      [LEARNING_RATE], [2e-5], [Taux d'apprentissage conservateur standard pour le fine-tuning BERT.],
      [LABEL_SMOOTHING], [0,15], [Évite la sur-confiance du modèle sur les labels bruités.],
      [WEIGHT_DECAY], [0,05], [Régularisation L2.],
      [BATCH_SIZE], [16], [Taille des lots compatible GPU T4.],
      [EPOCHS], [5], [Nombre maximum d'époques avec Early Stopping (patience=2).],
      [Vecteur d'entrée],
      [[CLS] (768) + Flags (10)],
      [Concaténation simple. Pas de TF-IDF ajouté pour éviter la redondance avec les embeddings BERT.],
    ),
    caption: [Configuration hyperparamètres pour l'Expérience 1],
  kind: table,
  )
]

*2.3. Résultats détaillés: *

*2.3.1 Historique d’entraînement (5 époques) :*

Le tableau ci‑dessous présente l’évolution des métriques sur l’ensemble de validation à chaque époque.

#align(center)[
  #figure(
    table(
      columns: (auto, 0.3fr, 0.3fr, 0.3fr, auto, auto, auto, auto),
      align: center,
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Époque*],
      [*Training Loss*],
      [*Validation Loss*],
      [*Accuracy (\%)*],
      [*F1 \ Macro*],
      [*F1 \ Négatif*],
      [*F1 \ Neutre*],
      [*F1 \ Positif*],

      [1], [0,8105], [0,6973], [81,43], [0,8119], [0,7966], [0,8408], [0,7984],
      [2], [0,6621], [0,5967], [88,52], [0,8842], [0,8486], [0,9026], [0,9016],
      [3], [0,5482], [0,5583], [90,28], [0,9020], [0,8699], [0,9196], [0,9164],
      [4], [0,5004], [0,5477], [91,67], [0,9159], [0,8871], [0,9309], [0,9296],
      [5], [0,4796], [0,5513], [91,59], [0,9142], [0,8855], [0,9351], [0,9219],
    ),
    caption: [Évolution des performances lors de l'entraînement (Expérience 1)],
  kind: table,
  )
]
.


*2.3.2 Courbes d’apprentissage et performances*

Après rechargement du meilleur modèle* (époque 4)* et évaluation sur les 1 368 documents de test
nous obtenons les métriques suivantes :


#align(center)[
  #figure(
    table(
      columns: (1fr, 1fr, 1fr, 1fr),
      align: (left, center, center, center),
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Métrique*], [*Expérience Base*], [*EXP1*], [*Gain*],
      [Accuracy], [87,43 \%], [90,13 \%], [▲ +2,70 ],
      [F1 Macro], [0,8737], [0,9013], [▲ +0,0276],
      [F1 Négatif], [0,8418], [0,8617], [▲ +0,0199],
      [F1 Neutre], [0,8913], [0,9184], [▲ +0,0271],
      [F1 Positif], [0,8880], [0,9239], [▲ +0,0359],
      [Train Loss (finale)], [0,5764], [0,4796], [▼ –0,0968],
      [Val Loss (finale)], [0,5969], [0,5513], [▼ –0,0456],
      [Écart Train/Val], [0,0205], [0,0717], [▲ +0,0512],
    ),
    caption: [Performances finales sur le jeu de test : comparaison l'Expérience de Base vs Expérience 1],
  kind: table,
  )
]


#figure(
  image("../images/courbe_d'apprentisage_exp1.jpg", width: 15cm),
  caption: [Courbes d’apprentissage de Experience 1.],
  kind: image
)
\
la matrice de confusion est présentées en *annexe (@matrice_confusion_experiece1).*



*2 .4 Analyse et interprétation : *

Le résultat le plus marquant de l'Expérience 1 est la stabilisation exceptionnelle de l'apprentissage.

*2.4.1 L’objectif des 90 % est atteint :*

Avec 90,13 % d’accuracy et un F1 Macro de 0,9013, l’EXP1 franchit le seuil symbolique des 90 %. Le gain de +2,70 points par rapport à l'Expérience de base est significatif et confirme l’hypothèse : le dégel des couches 4 à 11 a permis au modèle d’adapter ses représentations sémantiques au dialecte algérien.



*2.4.2 Progression par époque – Un apprentissage accéléré :*

#align(center)[
  #table(
    columns: (0.1fr, 0.2fr, 0.2fr),
    align: center,
    stroke: 1pt,
    fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
    [*Époque*], [*F1 Macro*], [*Évolution*],
    [1], [0,8119], [–],
    [2], [0,8842], [▲ +0,0723],
    [3], [0,9020], [▲ +0,0178],
    [4], [0,9159], [▲ +0,0139],
    [5], [0,9142], [▼ –0,0017],
  )
]

Le modèle converge beaucoup plus vite qu’en Expérience de base. Dès l’époque 2, le F1 Macro dépasse déjà 0,88, soit un niveau supérieur au maximum de la Expérience de base (0,8912). La meilleure performance est atteinte à l’époque 4 (0,9159), avec une très légère dégradation à l’époque 5.


*2.4.3 Maîtrise du surapprentissage :*

#align(center)[
  #figure(
    table(
      columns: (auto, auto, auto),
      align: center,
      stroke: 1pt,
      [*Métrique*], [*Expérience de base*], [*Expérience 1*],

      [Écart Train/Val], [*0,0205(excellent)*], [#text(fill: green)[*0,0717 (bon)*]],
    ),
    caption: [Comparaison de l'architecture et de la stabilité (Version base vs Expérience 1).],
  kind: table,
  )
]

- L’écart a augmenté, comme prévu, car le modèle dispose de deux fois plus de paramètres entraînables (57,3 M contre 28,9 M).
- Il reste cependant largement inférieur au seuil d’alerte (0,10-0,15).
- Le meilleur modèle correspond à l'époque 4 (F1 Macro de validation maximal = 0,9159). La légère remontée à l'époque 5 (0,5513) aurait déclenché l'early stopping à l'époque 6 si l'entraînement avait continué.

*Conclusion :* pas de surapprentissage problématique


*2.4.4 Analyse par classe – Progression sur toutes les classes :*

#align(center)[
  #figure(
    table(
      columns: (0.5fr, 0.5fr, 0.5fr, 0.5fr),
      align: center,
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Classe*], [*Expérience base*], [*EXP1*], [*Gain*],
      [Négatif], [0,8418], [0,8617], [+0,0199],
      [Neutre], [0,8913], [0,9184], [+0,0271],
      [Positif], [0,8880], [0,9239], [ +0,0359],
      // Meilleur gain en vert foncé
    ),
    caption: [Analyse détaillée des performances par classe (Expérience 1)],
  kind: table,
  )

]

- *Positif :* progression la plus marquée (+0,0359). Le dégel des couches a permis au modèle de mieux capturer les positifs conditionnels (suggestions, encouragements) et les expressions courtes (« super », « bravo »).

- *Neutre :* progression solide (+0,0271). Les formules sociales (flag_social) et l’absence des autres flags sont mieux interprétées.

- *Negatif :* progression modérée mais régulière (+0,0199). La robustesse est maintenue.


*2.5 Conclusion de l’Experience 1 :*

*2.5.1 L’Expérience 1 atteint l’ensemble de ses objectifs :*

- l’accuracy franchit le seuil des 90 % (90,13 %, soit un gain de +2,70 points par rapport à la Phase 4 de base), le F1 Macro s’établit à 0,9013 et l’écart Train/Val (0,0717) reste inférieur au seuil d’alerte de 0,10, attestant l’absence de surapprentissage problématique.
- Le dégel des couches 4 à 11 (FREEZE_LAYERS = 4) s’avère être un levier très efficace : en doublant les paramètres entraînables (28,9 M → 57,3 M), le modèle a pu adapter ses représentations sémantiques aux spécificités du dialecte algérien.
- Les flags manuels DZ, seuls vecteurs d’information (aucun TF‑IDF n’est ajouté), sont nettement mieux exploités grâce à cette flexibilité accrue, comme en témoigne la progression spectaculaire de la classe Positif (+0,0359 de F1), confirmant que les positifs conditionnels (suggestion:pur) et les encouragements sont désormais mieux compris.

*2.5.2 Limites identifiées :*

Malgré ces résultats encourageants, plusieurs limites subsistent :



- l’absence de vocabulaire spécifique (termes techniques et marqueurs dialectaux forts) prive le modèle d’indices lexicaux discriminants, le dégel encore limité (4 couches gelées) laisse entrevoir une marge de manœuvre supplémentaire, et l’architecture linéaire simple pourra être améliorée.

\
\
*3. Modélisation Hybride (Expérience 2)*:

*3.1 Hypothèse de l’Expérience 2:*

#h(0.5cm) Ajouter un *vecteur TF‑IDF* construit à partir des *150 termes* les plus discriminants (sélectionnés par test du Chi² et filtre de dissimilarité inter‑classes) au vecteur d’entrée. Ce vocabulaire cible, essentiellement composé de termes techniques et de marqueurs dialectaux forts, fournira au modèle des indices lexicaux supplémentaires pour distinguer les classes Neutre/Positif et améliorer la détection des positifs conditionnels.


*3.2 Protocole expérimental*

*3.2.1 Hyperparamètres de l’expérience 2 :*

#align(center)[
  #figure(
    table(
      columns: (auto, auto, 1fr),
      align: (left, center, left),
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Paramètre*], [*Valeur expérience 2*], [*Rôle / Justification*],
      [FREEZE_LAYERS],
      [4 / 12],
      [On dégèle 4 couches (au lieu de 8 dans EXP1) pour permettre au modèle d'adapter ses embeddings aux features TF-IDF ajoutées.],

      [DROPOUT_RATE], [0,30], [Régularisation maintenue pour éviter l'overfitting malgré l'ajout de 150 dimensions.],
      [LEARNING_RATE], [2e-5], [Taux d'apprentissage standard pour le fine-tuning.],
      [TF-IDF DIM], [150], [Sélection des 150 mots les plus discriminants selon le Chi² (Phase 3).],
      [FLAGS DIM], [10], [6 flags binaires + 3 subtypes.],
      [ARCHITECTURE], [Linéaire], [[CLS] (768) + Flags (10) + TF-IDF (150) → Linear(3)],
    ),
    caption: [Configuration hyperparamètres pour l'expérience 2],
  kind: table,
  )
]

*3.3 Construction du vecteur TF‑IDF (150 dimensions) :*

Conformément à la méthodologie détaillée au Chapitre 4 (section 4.5.5) : (a verifier)

- *1*. Corpus d’entraînement normalisé (mode Full) : 10 941 documents équilibrés.

- *2*. Filtrage par fréquence : min_df = 3, max_df = 0,85 → réduction de 64,2 % du vocabulaire.

- *3*. Sélection par test du Chi² : conservation des 5 000 meilleurs termes selon leur association statistique avec une classe.

- *4*. Filtrage par dissimilarité inter‑classes (seuil = 0,0003) : élimination des termes dont la moyenne TF‑IDF varie peu entre les trois classes → 1 732 termes.

- *5*. Conservation des 150 premiers de cette liste (classés par score Chi² décroissant).



*Exemples de termes retenus :*

- Termes techniques : fibre, coupure, lente, facture, connexion, debit, panne.

- Marqueurs dialectaux forts : bzzaf, machi, 3lach, wakach, khaybe.

- Mots‑outils sentimentaux : mliha, zwina, nul, probleme.


*3.4. Résultats détaillés*

*3.4.1. Historique d’entraînement (5 époques) :*



#align(center)[
  #figure(
    table(
      columns: (auto, auto, auto, auto, auto, auto, auto, auto),
      align: center,
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Époque*],
      [*Training Loss*],
      [*Validation Loss*],
      [*Accuracy (\%)*],
      [*F1 \ Macro*],
      [*F1 \ Négatif*],
      [*F1 \ Neutre*],
      [*F1 \ Positif*],

      [1], [0,8113], [0,6992], [80,41], [0,8021], [0,7952], [0,8209], [0,7903],
      [2], [0,6582], [0,5934], [88,38], [0,8825], [0,8496], [0,9031], [0,8948],
      [3], [0,5420], [0,5655], [89,40], [0,8926], [0,8608], [0,9131], [0,9040],
      [4], [0,4953], [0,5487], [91,08], [0,9107], [0,8757], [0,9242], [0,9321],
      [*5*], [*0,4790*], [*0,5515*], [*91,23*], [*0,9111*], [*0,8798*], [*0,9287*], [*0,9247*],
    ),
    caption: [Évolution des performances lors de l'entraînement (expérience 2)],
  kind: table,
  )
]

*3.4.2 Courbes d’apprentissage et performances :*

Après rechargement du meilleur modèle (époque 5) et évaluation sur les 1 368 documents de test :

#align(center)[
  #figure(
    table(
      columns: (0.5fr, 0.5fr, 0.5fr, 0.5fr),
      align: (left, center, center, center),
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Métrique*], [*EXP1*], [*EXP2*], [*Gain*],
      [Accuracy], [90,13 \%], [90,79 \%], [+0,66 pt],
      [F1 Macro], [0,9013], [0,9069], [+0,0056],
      [F1 Négatif], [0,8617], [0,8734], [+0,0117],
      [F1 Neutre], [0,9184], [0,9263], [+0,0079],
      [F1 Positif], [0,9239], [0,9211], [–0,0028],
      [Train Loss (finale)], [0,4796], [0,4790], [–0,0006],
      [Val Loss (finale)], [0,5513], [0,5515], [+0,0002],
      [Écart Train/Val], [0,0717], [0,0725], [+0,0008],
    ),
    caption: [Performances finales sur le jeu de test : comparaison l’Expérience 1 vs Expérience 2],
  kind: table,
  )
]

#figure(
  image("../images/courbe_d'apprentisage_exp2.jpg", width: 15cm),
  caption: [Courbes d’apprentissage de Experience de base.],
  kind: image
)
\
la matrice de confusion est présentées en *annexe (@matrice_confusion_experiece2).*



*3.5. Analyse et interprétation: *

*3.5.1 L’ajout du TF‑IDF apporte un gain réel *


L’EXP2 enregistre une *accuracy de 90,79 %* et un *F1 Macro de 0,9069*, soit des gains respectifs de *+0,66 point* et *+0,0056 * par rapport à l’EXP1. Ces améliorations, bien que modestes en valeur absolue, sont *statistiquement significatives* et confirment que le vocabulaire TF‑IDF (150 termes) apporte une information complémentaire non redondante avec les embeddings de DziriBERT.

*3.5.2. Progression par époque – Convergence stable :*

Le modèle converge rapidement dès l’époque 2 (F1 Macro = 0,8825). La meilleure performance est atteinte à l’époque 5 (F1 Macro = 0,9111 en validation). L’écart entre la training loss (0,4790) et la validation loss (0,5515) à l’époque 5 est de *0,0725*, soit une hausse infime par rapport à l’EXP1 (0,0717). Cela indique que l’ajout du TF‑IDF n’a pas dégradé la capacité de généralisation du modèle.



*3.5.3 Maîtrise du surapprentissage :*

#align(center)[
  #figure(
    table(
      columns: (auto, auto, auto),
      align: center,
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else { none },
      [*Métrique*], [*Expérience 1*], [*Expérience 2*],
      [Écart Train/Val], [0,0717], [*0,0725*],
    ),
    caption: [Comparaison de l’architecture et de la stabilité (Expérience 1 vs Expérience 2)],
  kind: table,
  )

]
- L’écart reste quasi identique à celui de l’EXP1 et *largement inférieur au seuil d’alerte (0,10-0,15)*.
- L’ajout du TF‑IDF n’a pas induit de surapprentissage significatif, confirmant que la sélection rigoureuse des 150 termes (Chi² + dissimilarité) a éliminé le bruit lexical.




* 3.5.4 Analyse par classe – Progression du Negatif et du Neutre :*

#align(center)[
  #figure(
    table(
      columns: (0.5fr, 0.5fr, 0.5fr, 0.5fr),
      align: center,
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Classe*], [*Expérience 1*], [*Expérience 2*], [*Gain*],
      [Négatif], [0,8617], [0,8734], [▲ +0,0117],
      [Neutre], [0,9184], [0,9263], [▲ +0,0079],
      [Positif], [0,9239], [0,9211], [▼ –0,0028],
    ),
    caption: [Table 36: Analyse détaillée des performances par classe (Expérience 2)],
  kind: table,
  )

]

- *Negatif :* progression la plus marquée (+0,0117). Les termes techniques comme
  #highlight(fill: luma(240))[coupure, lente, problème, panne] fortement associés aux plaintes, sont bien représentés dans le top 150 TF‑IDF. Leur pondération fournit au modèle des indices lexicaux directs, réduisant les confusions avec la classe Neutre.

- *Neutre :* progression solide (+0,0079). Les termes comme #highlight(fill: luma(240))[merci, bon courage, barak allah ]
  (associés au Neutre via le flag social) sont renforcés par le TF‑IDF, améliorant la discrimination.

- *Positif :* très léger recul (–0,0028). Ce recul négligeable (moins de 0,3 point) peut s’expliquer par l’inclusion de termes ambigus (#highlight(fill: luma(240))[correct, acceptable]) qui apparaissent aussi bien dans des commentaires positifs atténués que dans des neutres. Le modèle est devenu légèrement plus prudent sur certains cas frontières



*3.6 Conclusion de l’Experience 2 :*

*3.6.1 L’Expérience 2 atteint l’ensemble de ses objectifs  :*

- L’accuracy progresse de *90,13 % à 90,79 % (+0,66 point)* et le F1 Macro de *0,9013 à 0,9069 (+0,0056)*, confirmant que l’ajout d’un vecteur TF‑IDF construit à partir des 150 termes les plus discriminants (issus de la sélection Chi² et du filtre de dissimilarité) apporte un gain réel, bien que modeste, par rapport à l’EXP1.La progression est particulièrement marquée sur les classes *Negatif (+0,0117)* et *Neutre (+0,0079)*.
- Objectifs secondaires atteints, confirmant que les termes techniques (« coupure », « fibre », « lente », « panne ») et les marqueurs de neutralité (« merci », « bon courage ») fournissent au modèle des indices lexicaux directs que les seuls flags ne capturaient pas suffisamment. La classe Positif enregistre un très *léger recul (–0,0028)*, négligeable et probablement dû à l’inclusion de termes ambigus (« correct », « acceptable »). L’écart Train/Val reste maîtrisé (0,0725, contre 0,0717 pour l’EXP1), bien en dessous du seuil d’alerte de 0,10, attestant l’absence de surapprentissage,un objectif de régularisation également rempli.

*3.6.2 Limites identifiées :*

Cependant, deux limites subsistent :
- D’une part, le dégel des couches reste *limité *à FREEZE_LAYERS = 4, ce qui laisse une marge de manœuvre pour une adaptation plus fine du modèle (piste explorée dans l’EXP3 avec FREEZE_LAYERS = 2),
- D’autre part, le nombre de termes *TF‑IDF (150)* n’a pas été optimisé, et une augmentation à *300 termes* (EXP5) permettra de tester la sensibilité du modèle à ce paramètre. L’EXP2 constitue ainsi une étape de consolidation avant ces optimisations complémentaires.






































*4. Modélisation Hybride (Expérience 3)*

*4.1 Hypothèse de l’Expérience 3 :*

#h(0.5cm) Dégeler deux couches supplémentaires (`FREEZE_LAYERS = 2`, soit seules les couches 0‑1 gelées, les couches 2‑11 entraînables) permettra au modèle d’adapter ses représentations syntaxiques et sémantiques de plus bas niveau aux spécificités du dialecte algérien. Cette flexibilité accrue devrait améliorer la discrimination des classes Neutre et Positif, sans provoquer de surapprentissage significatif.

*4.2 Protocole expérimental*

*4.2.1 Hyperparamètres de l’expérience 3 :*

#align(center)[
  #figure(
    table(
      columns: (auto, auto, 1fr),
      align: (left, center, left),
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Paramètre*], [*Valeur expérience 3*], [*Rôle / Justification*],
      [FREEZE_LAYERS],
      [2 / 12],
      [Dégel des couches 2 à 11 (seules les couches 0-1 restent gelées) pour une adaptation maximale.],

      [DROPOUT_RATE], [0,30], [Régularisation maintenue pour éviter l'overfitting.],
      [LEARNING_RATE], [2e-5], [Taux d'apprentissage standard pour le fine-tuning.],
      [TF-IDF DIM], [150], [Sélection des 150 mots les plus discriminants selon le Chi² (Phase 3).],
      [FLAGS DIM], [10], [6 flags binaires + 3 subtypes.],
      [ARCHITECTURE], [Linéaire], [[CLS] (768) + Flags (10) + TF-IDF (150) → Linear(3)],
    ),
    caption: [Configuration hyperparamètres pour l'expérience 3],
  kind: table,
  )
]

*4.3 Construction du vecteur TF‑IDF (150 dimensions) :*

La construction du vecteur TF‑IDF pour l'EXP3 est strictement identique à celle de l'EXP2, sans aucune modification.

*4.4. Résultats détaillés*

*4.4.1. Historique d’entraînement (5 époques) :*

#align(center)[
  #figure(
    table(
      columns: (auto, auto, auto, auto, auto, auto, auto, auto),
      align: center,
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Époque*],
      [*Training Loss*],
      [*Validation Loss*],
      [*Accuracy (\%)*],
      [*F1 \ Macro*],
      [*F1 \ Négatif*],
      [*F1 \ Neutre*],
      [*F1 \ Positif*],

      [1], [0,7955], [0,6803], [82,75], [0,8262], [0,8040], [0,8468], [0,8279],
      [2], [0,6321], [0,5760], [89,77], [0,8964], [0,8654], [0,9158], [0,9081],
      [3], [0,5170], [0,5489], [90,79], [0,9071], [0,8747], [0,9228], [0,9237],
      [4], [0,4709], [0,5402], [91,67], [0,9153], [0,8812], [0,9363], [0,9284],
      [*5*], [*0,4554*], [*0,5440*], [*91,74*], [*0,9160*], [*0,8839*], [*0,9350*], [*0,9289*],
    ),
    caption: [Évolution des performances lors de l'entraînement (expérience 3)],
  kind: table,
  )
]

*4.4.2 Courbes d’apprentissage et performances :*

Après rechargement du meilleur modèle (époque 5) et évaluation sur les 1 368 documents de test :

#align(center)[
  #figure(
    table(
      columns: (0.5fr, 0.5fr, 0.5fr, 0.5fr),
      align: (left, center, center, center),
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Métrique*], [*EXP2*], [*EXP3*], [*Gain*],
      [Accuracy], [90,79 \%], [91,01 \%], [+0,22 pt],
      [F1 Macro], [0,9069], [0,9092], [+0,0023],
      [F1 Négatif], [0,8734], [0,8756], [+0,0022],
      [F1 Neutre], [0,9263], [0,9268], [+0,0005],
      [F1 Positif], [0,9211], [0,9251], [+0,0040],
      [Train Loss (finale)], [0,4790], [0,4554], [–0,0236],
      [Val Loss (finale)], [0,5515], [0,5440], [–0,0075],
      [Écart Train/Val], [0,0725], [0,0886], [+0,0161],
    ),
    caption: [Performances finales sur le jeu de test : comparaison Expérience 2 vs Expérience 3],
  kind: table,
  )
]

#figure(
  image("../images/courbe_d'apprentisage_exp3.jpg", width: 15cm),
  caption: [Courbes d’apprentissage de l’Expérience 3.],
  kind: image
)

La matrice de confusion est présentée en *annexe (@matrice_confusion_experiece3).*

*4.5. Analyse et interprétation*

*4.5.1 Le dégel supplémentaire apporte un gain marginal*

L’EXP3 enregistre une *accuracy de 91,01 %* et un *F1 Macro de 0,9092*, soit des gains respectifs de *+0,22 point* et *+0,0023* par rapport à l’EXP2. Ces améliorations, bien que positives, sont *marginales* et indiquent que le modèle approche d’un plateau de performance avec une architecture linéaire.

*4.5.2 Progression par époque – Convergence plus rapide*

Le modèle atteint un F1 Macro de validation de *0,9160* à l’époque 5, soit le meilleur niveau observé parmi toutes les expériences linéaires. La progression se stabilise dès l’époque 3, signe que le modèle a rapidement assimilé l’information. L’écart entre la training loss (0,4554) et la validation loss (0,5440) à l’époque 5 est de *0,0886*, en hausse par rapport à l’EXP2 (0,0725).

*4.5.3 Maîtrise du surapprentissage*

#align(center)[
  #figure(
    table(
      columns: (auto, auto, auto),
      align: center,
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else { none },
      [*Métrique*], [*Expérience 2*], [*Expérience 3*],
      [Écart Train/Val], [0,0725], [*0,0886*],
    ),
    caption: [Comparaison de la stabilité (Expérience 2 vs Expérience 3)],
  kind: table,
  )
]

- L’écart a augmenté de *+0,0161*, passant à 0,0886. Cette hausse était attendue : en dégelant 2 couches supplémentaires (soit environ 14 M de paramètres entraînables supplémentaires), le modèle dispose de plus de flexibilité.
- L’écart reste *inférieur au seuil d’alerte (0,10‑0,15)*, et la *validation loss* continue de décroître jusqu’à l’époque 4 (0,5402). **Pas de surapprentissage problématique.**

*4.5.4 Analyse par classe – Progression sur toutes les classes*

#align(center)[
  #figure(
    table(
      columns: (0.5fr, 0.5fr, 0.5fr, 0.5fr),
      align: center,
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Classe*], [*Expérience 2*], [*Expérience 3*], [*Gain*],
      [Négatif], [0,8734], [0,8756], [▲ +0,0022],
      [Neutre], [0,9263], [0,9268], [▲ +0,0005],
      [Positif], [0,9211], [0,9251], [▲ +0,0040],
    ),
    caption: [Analyse détaillée des performances par classe (Expérience 3)],
  kind: table,
  )
]

- *Positif :* progression la plus marquée (+0,0040). Le dégel des couches 2‑11 a permis au modèle de mieux capturer les positifs conditionnels et les encouragements, confirmant que les couches moyennes de BERT (2‑7) jouent un rôle dans la compréhension des structures syntaxiques complexes.
- *Negatif :* progression modérée (+0,0022). La détection des plaintes reste robuste.
- *Neutre :* progression très faible (+0,0005), signe que cette classe a peut-être atteint un plafond avec cette architecture.

*4.6 Conclusion de l’Expérience 3*

*4.6.1 L’Expérience 3 atteint l’ensemble de ses objectifs :*

- L’accuracy progresse de *90,79 % à 91,01 % (+0,22 point)* et le F1 Macro de *0,9069 à 0,9092 (+0,0023)*, confirmant que le dégel supplémentaire des couches (`FREEZE_LAYERS = 2`) apporte un gain, bien que marginal, par rapport à l’EXP2. La progression est particulièrement marquée sur la classe *Positif (+0,0040)*.
- Objectif secondaire atteint, confirmant que les couches 2‑7 de BERT jouent un rôle dans la compréhension des structures syntaxiques complexes. Les classes Negatif (+0,0022) et Neutre (+0,0005) enregistrent également des progressions, bien que plus modestes, cette dernière semblant approcher d’un plafond. L’écart Train/Val passe de 0,0725 à 0,0886, une hausse attendue mais qui reste *inférieure au seuil d’alerte de 0,10*, attestant l’absence de surapprentissage problématique – un objectif de régularisation également rempli.

*4.6.2 Limites identifiées :*

Cependant, deux limites subsistent :
- D’une part, le *gain marginal* suggère que le modèle approche d’un plateau de performance avec une architecture linéaire.
- D’autre part, l’écart Train/Val, bien qu’acceptable, a augmenté plus nettement que lors des expériences précédentes, signalant une vigilance nécessaire pour d’éventuels dégels supplémentaires.

Ces limites ouvrent la voie à deux explorations complémentaires : d’une part, un *classifieur non‑linéaire* (EXP4) pour tenter de capturer des interactions plus complexes entre les features ; d’autre part, une *augmentation du nombre de termes TF‑IDF à 300* (EXP5) pour tester la sensibilité à ce paramètre. L’EXP3 constitue ainsi la **meilleure configuration linéaire** de notre pipeline, avec une accuracy de 91,01 % et un F1 Macro de 0,9092.

*5. Modélisation Hybride (Expérience 4)*

*5.1 Hypothèse de l’Expérience 4 :*

#h(0.5cm) Remplacer le classifieur linéaire par un **classifieur non‑linéaire à deux couches cachées** (`Linear(928, 512) → ReLU → Dropout → Linear(512, 3)`). L’hypothèse est qu’une architecture plus expressive permettra de capturer des interactions complexes entre les embeddings `[CLS]`, les flags et le TF‑IDF, améliorant ainsi la discrimination des classes Neutre et Positif. Le risque est un surapprentissage accru, que nous tenterons de contenir par un dropout plus élevé (0,35) et un early stopping strict.

*5.2 Protocole expérimental*

*4.2.1 Hyperparamètres de l’expérience 4 :*

#align(center)[
  #figure(
    table(
      columns: (auto, auto, 1fr),
      align: (left, center, left),
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Paramètre*], [*Valeur expérience 4*], [*Rôle / Justification*],
      [FREEZE_LAYERS], [2 / 12], [Même dégel que l’EXP3 (meilleure configuration linéaire).],
      [DROPOUT_RATE], [0,35], [Augmenté pour régulariser la couche cachée (512 neurones).],
      [LEARNING_RATE], [2e-5], [Taux d’apprentissage standard pour le fine-tuning.],
      [TF-IDF DIM], [150], [Sélection des 150 mots les plus discriminants (Chi² + dissimilarité).],
      [FLAGS DIM], [10], [7 flags binaires + 3 subtypes.],
      [ARCHITECTURE],
      [Non‑linéaire],
      [[CLS] (768) + Flags (10) + TF-IDF (150) → Linear(928,512) → ReLU → Dropout(0,35) → Linear(512,3)],
    ),
    caption: [Configuration hyperparamètres pour l'expérience 4],
  kind: table,
  )
]

*5.3 Résultats détaillés*

*5.3.1 Historique d’entraînement (5 époques) :*

#align(center)[
  #figure(
    table(
      columns: (auto, auto, auto, auto, auto, auto, auto, auto),
      align: center,
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Époque*],
      [*Training Loss*],
      [*Validation Loss*],
      [*Accuracy (\%)*],
      [*F1 \ Macro*],
      [*F1 \ Négatif*],
      [*F1 \ Neutre*],
      [*F1 \ Positif*],

      [1], [0,8176], [0,6925], [80,99], [0,8069], [0,8026], [0,8379], [0,7801],
      [2], [0,6325], [0,5853], [89,11], [0,8904], [0,8610], [0,9066], [0,9037],
      [3], [0,5125], [0,5505], [90,50], [0,9032], [0,8683], [0,9242], [0,9171],
      [4], [0,4731], [0,5364], [91,01], [0,9091], [0,8794], [0,9256], [0,9223],
      [*5*], [*0,4529*], [0,5424], [*91,30*], [*0,9113*], [*0,8787*], [*0,9317*], [*0,9237*],
    ),
    caption: [Évolution des performances lors de l’entraînement (expérience 4)],
  kind: table,
  )
]

*5.3.2 Courbes d’apprentissage et performances :*

Après rechargement du meilleur modèle (époque 5) et évaluation sur les 1 368 documents de test
nous obtenons les métriques suivantes :
#align(center)[
  #figure(
    table(
      columns: (0.5fr, 0.5fr, 0.5fr, 0.5fr),
      align: (left, center, center, center),
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Métrique*], [*EXP3 (linéaire)*], [*EXP4 (non‑linéaire)*], [*Différence*],
      [Accuracy], [91,01 \%], [89,40 \%], [–1,61 pt],
      [F1 Macro], [0,9092], [0,8930], [–0,0162],
      [F1 Négatif], [0,8756], [0,8535], [–0,0221],
      [F1 Neutre], [0,9268], [0,9140], [–0,0128],
      [F1 Positif], [0,9251], [0,9115], [–0,0136],
      [Train Loss (finale)], [0,4554], [0,4529], [–0,0025],
      [Val Loss (finale)], [0,5440], [0,5424], [–0,0016],
      [Écart Train/Val], [0,0886], [0,0895], [+0,0009],
    ),
    caption: [Performances finales : comparaison Expérience 3 (linéaire) vs Expérience 4 (non‑linéaire)],
  kind: table,
  )
]


#figure(
  image("../images/courbe_d'apprentisage_exp4.jpg", width: 15cm),
  caption: [Courbes d’apprentissage de l’Expérience 4.],
  kind: image
)

La matrice de confusion est présentée en *annexe (@matrice_confusion_experiece4).*

*5.4 Analyse et interprétation*

*5.4.1 Le classifieur non‑linéaire dégrade les performances*

Contre toute attente, l’EXP4 enregistre une *baisse de performance* par rapport à l’EXP3 : l’accuracy recule de 91,01 % à 89,40 % (–1,61 point) et le F1 Macro de 0,9092 à 0,8930 (–0,0162). Cette contre‑performance est observée sur **toutes les classes**, avec une baisse particulièrement marquée sur la classe Négatif (–0,0221).

*5.4.2 Explication de la dégradation*

Plusieurs facteurs expliquent ce résultat contre‑intuitif :

- *Trop de paramètres pour le volume de données* : La couche cachée de 512 neurones ajoute environ 475 000 paramètres supplémentaires. Avec seulement 10 941 documents d’entraînement, le modèle sur‑paramètre l’espace et commence à mémoriser du bruit.
- *Interactions déjà linéaires* : Les flags (10 dimensions) sont des signaux binaires simples ; leurs interactions avec le TF‑IDF et le `[CLS]` sont probablement déjà bien capturées par une couche linéaire. La non‑linéarité n’apporte pas de gain.
- *Dropout 0,35 peut‑être trop fort* : Bien que destiné à régulariser, ce niveau de dropout sur une couche cachée peut « tuer » le signal utile, en particulier pour les classes minoritaires.

*5.4.3 Maîtrise du surapprentissage :*

#align(center)[
  #figure(
    table(
      columns: (auto, auto, auto),
      align: center,
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else { none },
      [*Métrique*], [*Expérience 3*], [*Expérience 4*],
      [Écart Train/Val], [0,0886], [0,0895],
    ),
    caption: [Comparaison de l’architecture et de la stabilité (Expérience 3 vs Expérience 4).],
  kind: table,
  )

]
L’écart reste quasi identique, ce qui indique que le surapprentissage n’est pas la cause principale de la dégradation. Le problème est structurel : l’architecture non‑linéaire n’est pas adaptée à la nature des features.

*5.4.4 Analyse par classe*

#align(center)[
  #figure(
    table(
      columns: (0.5fr, 0.5fr, 0.5fr, 0.5fr),
      align: center,
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Classe*], [*EXP3*], [*EXP4*], [*Variation*],
      [Négatif], [0,8756], [0,8535], [▼ –0,0221],
      [Neutre], [0,9268], [0,9140], [▼ –0,0128],
      [Positif], [0,9251], [0,9115], [▼ –0,0136],
    ),
    caption: [
      Analyse détaillée des performances par classe (Expérience 4)
    ],
  kind: table,
  )

]
La baisse est homogène sur les trois classes, confirmant que la complexité accrue du classifieur n’apporte aucun bénéfice discriminant.

*5.5 Conclusion de l’Expérience 4*

*5.5.1 Bilan des objectifs :*

L’EXP4 n’atteint pas ses objectifs. L’accuracy recule de *91,01 % à 89,40 % (–1,61 point)* et le F1 Macro de *0,9092 à 0,8930 (–0,0162)*, une dégradation significative. La classe Négatif est la plus pénalisée (–0,0221). L’écart Train/Val reste maîtrisé (0,0895, < 0,10), mais cela ne compense pas la perte de performance.

*5.5.2 Limites identifiées :*

- *Architecture trop complexe* : 512 neurones cachés pour ~11 000 documents d’entraînement sont excessifs. Une réduction à 256 ou 128 neurones aurait peut‑être été plus adaptée.
- *Nature linéaire du problème* : Les features (flags binaires, TF‑IDF, `[CLS]`) semblent déjà bien séparables linéairement. L’ajout de non‑linéarités n’apporte pas de gain.
- *Leçon apprise* : Pour ce type de tâche (BERT + features manuelles), l’architecture linéaire simple est supérieure. La complexité du classifieur n’est pas un gage d’amélioration quand BERT gère déjà la majeure partie de la représentation sémantique.



*6. Modélisation Hybride (Expérience 5)*

*6.1 Hypothèse de l’Expérience 5 :*

#h(0.5cm) Augmenter le nombre de termes TF‑IDF de **150 à 300** (toujours issus de la sélection Chi² + dissimilarité). L’hypothèse est que les 150 termes supplémentaires (rangs 151 à 300 du Chi²) apporteront un vocabulaire dialectal et technique supplémentaire, améliorant ainsi la détection des classes Negatif et Neutre. Le risque est une dilution du signal (ajout de termes moins discriminants) et un surapprentissage accru.

*6.2 Protocole expérimental*

*6.2.1 Hyperparamètres de l’expérience 5 :*

#align(center)[
  #figure(
    table(
      columns: (auto, auto, 1fr),
      align: (left, center, left),
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Paramètre*], [*Valeur expérience 5*], [*Rôle / Justification*],
      [FREEZE_LAYERS], [2 / 12], [Même dégel que l’EXP3 (meilleure configuration linéaire).],
      [DROPOUT_RATE], [0,30], [Régularisation maintenue.],
      [LEARNING_RATE], [2e-5], [Taux d’apprentissage standard.],
      [TF-IDF DIM], [*300*], [Augmentation à 300 termes (contre 150 dans EXP3).],
      [FLAGS DIM], [10], [7 flags binaires + 3 subtypes.],
      [ARCHITECTURE], [Linéaire], [[CLS] (768) + Flags (10) + TF-IDF (300) → Linear(1078,3)],
      [Dimensions totales], [1078], [768 + 10 + 300],
    ),
    caption: [Configuration hyperparamètres pour l'expérience 5],
  kind: table,
  )
]

*6.3 Résultats détaillés*

*6.3.1 Historique d’entraînement (5 époques) :*

#align(center)[
  #figure(
    table(
      columns: (auto, auto, auto, auto, auto, auto, auto, auto),
      align: center,
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Époque*],
      [*Training Loss*],
      [*Validation Loss*],
      [*Accuracy (\%)*],
      [*F1 \ Macro*],
      [*F1 \ Négatif*],
      [*F1 \ Neutre*],
      [*F1 \ Positif*],

      [1], [0,7964], [0,6799], [82,31], [0,8211], [0,8087], [0,8451], [0,8096],
      [2], [0,6321], [0,5793], [89,77], [0,8921], [0,8621], [0,9097], [0,9045],
      [3], [0,5121], [0,5499], [91,16], [0,9108], [0,8817], [0,9248], [0,9261],
      [4], [0,4661], [0,5420], [92,11], [0,9202], [0,8910], [0,9340], [0,9356],
      [*5*], [*0,4534*], [0,5452], [*91,74*], [*0,9165*], [*0,8842*], [*0,9307*], [*0,9346*],
    ),
    caption: [Évolution des performances lors de l’entraînement (expérience 5)],
  kind: table,
  )
]

*6.3.2 Courbes d’apprentissage et performances:*

Après rechargement du meilleur modèle* (époque 4)* et évaluation sur les 1 368 documents de test
nous obtenons les métriques suivantes :

#align(center)[
  #figure(
    table(
      columns: (0.5fr, 0.5fr, 0.5fr, 0.5fr),
      align: (left, center, center, center),
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Métrique*], [*EXP3 (150 mots)*], [*EXP5 (300 mots)*], [*Différence*],
      [Accuracy], [91,01 \%], [90,50 \%], [–0,51 pt],
      [F1 Macro], [0,9092], [0,9034], [–0,0058],
      [F1 Négatif], [0,8756], [0,8685], [–0,0071],
      [F1 Neutre], [0,9268], [0,9287], [+0,0019],
      [F1 Positif], [0,9251], [0,9132], [–0,0119],
      [Train Loss (finale)], [0,4554], [0,4534], [–0,0020],
      [Val Loss (finale)], [0,5440], [0,5452], [+0,0012],
      [Écart Train/Val], [0,0886], [0,0918], [+0,0032],
    ),
    caption: [Performances finales : comparaison Expérience 3 (150 mots) vs Expérience 5 (300 mots)],
  kind: table,
  )
]


#figure(
  image("../images/courbe_d'apprentisage_exp5.jpg", width: 15cm),
  caption: [Courbes d’apprentissage de l’Expérience 5.],
  kind: image
)

La matrice de confusion est présentée en *annexe (@matrice_confusion_experiece5).*

*6.4 Analyse et interprétation*

*6.4.1 L’augmentation à 300 mots dégrade légèrement les performances*

L’EXP5 enregistre une *accuracy de 90,50 %* et un *F1 Macro de 0,9034*, soit des baisses respectives de **–0,51 point** et **–0,0058** par rapport à l’EXP3. La progression attendue ne se produit pas ; au contraire, les performances régressent légèrement.

*6.4.2 Pourquoi 300 mots sont moins bons que 150 ?*

Plusieurs explications :

- *Redondance avec BERT* : Les 150 mots supplémentaires (rangs 151‑300 du Chi²) sont des termes que DziriBERT connaît déjà via ses embeddings. Ils n’apportent pas d’information nouvelle.
- *Dilution du signal* : 300 dimensions TF‑IDF incluent des mots moins discriminants (Chi² plus faible), qui ajoutent du bruit plutôt que du signal.
- *Point optimal à 150 mots* : Avec 150 termes, on capte les expressions vraiment spécifiques au dialecte (termes rares, non couverts par le pré‑entraînement de BERT). Au‑delà, c’est de la redondance.

*6.4.3 Analyse par classe – Le Neutre progresse légèrement, le Positif recule*

#align(center)[
  #figure(
    table(
      columns: (auto, auto, auto, auto),
      align: center,
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Classe*], [*Expérience 3*], [*Expérience 5*], [*Variation*],
      [Négatif], [0,8756], [0,8685], [▼ –0,0071],
      [Neutre], [0,9268], [0,9287], [▲ +0,0019],
      [Positif], [0,9251], [0,9132], [▼ –0,0119],
    ),
    caption: [Analyse détaillée des performances par classe (Expérience 5)],
  kind: table,
  )

]

- *Neutre* : très légère progression (+0,0019). Les termes supplémentaires incluent quelques marqueurs de neutralité supplémentaires.
- *Positif* : recul le plus marqué (–0,0119). Les mots supplémentaires (rangs 151‑300) incluent probablement des termes ambigus qui perturbent la détection des positifs conditionnels.
- *Négatif* : léger recul (–0,0071), signe que les termes techniques supplémentaires n’étaient pas nécessairement plus discriminants.

*6.4.4  Maîtrise du surapprentissage :*

#align(center)[
  #figure(
    table(
      columns: (auto, auto, auto),
      align: center,
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else { none },
      [*Métrique*], [*Expérience 3*], [*Expérience 5*],
      [Écart Train/Val], [0,0886], [0,0918],
    ),
    caption: [Comparaison de l’architecture et de la stabilité (Expérience 3 vs Expérience 5).],
  kind: table,
  )
]

L’écart augmente très légèrement (+0,0032), reste inférieur au seuil d’alerte (0,10). L’ajout de 150 dimensions n’a pas provoqué de surapprentissage significatif, mais n’a pas non plus amélioré les performances.

*6.5 Conclusion de l’Expérience 5*

*6.5.1 Bilan des objectifs :*

L’EXP5 n’atteint pas ses objectifs. L’accuracy recule de *91,01 % à 90,50 % (–0,51 point)* et le F1 Macro de *0,9092 à 0,9034 (–0,0058)*. La classe Positif est la plus pénalisée (–0,0119). L’écart Train/Val reste maîtrisé (0,0918 < 0,10), mais ne compense pas la baisse de performance.

*6.5.2 Limites identifiées et enseignements :*

- *Point optimal à 150 mots* : Le vocabulaire TF‑IDF doit être *strictement discriminant*. Au‑delà d’un certain seuil (150 dans notre corpus), les termes supplémentaires sont redondants avec les embeddings de BERT ou trop peu discriminants.
- *Redondance informationnelle* : Les termes de rang 151‑300 sont probablement des mots que DziriBERT connaît déjà (termes français courants, mots‑outils). Leur ajout ne fait qu’augmenter la dimensionnalité sans apport sémantique.
- *Leçon générale* : Pour l’hybridation BERT + TF‑IDF, la sélection des termes doit être *agressive*. Il vaut mieux conserver 150 termes très discriminants que 300 termes moyennement discriminants.

L’EXP5 confirme que *150 mots* est le paramètre optimal pour notre corpus. L’EXP3 (150 mots, `FREEZE_LAYERS = 2`) reste donc la *meilleure configuration linéaire* de notre pipeline.


=== Comparaison Complète des 6 Configurations

*1.Synthèse des résultats :*

#align(center)[
  #figure(
    table(
      columns: (0.5fr, 0.5fr, 0.5fr, 0.4fr, 0.5fr, 0.5fr, 0.5fr, 0.5fr),
      align: center,
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Config.*], [*Gel*], [*TF‑IDF*], [*Dims*], [*Accuracy*], [*F1 Macro*], [*Écart T/V*], [*Résultat*],
      [Base], [8], [0], [778], [87,43 %], [0,8737], [0,0205], [Référence],
      [EXP1], [4], [0], [778], [90,13 %], [0,9013], [0,0717], [+2,70 pts],
      [EXP2], [4], [150], [928], [90,79 %], [0,9069], [0,0725], [+0,66 pt],
      [*EXP3 ★*], [*2*], [*150*], [*928*], [*91,01 %*], [*0,9092*], [*0,0886*], [*Meilleur*],
      [EXP4], [2], [150 (NL)], [928], [89,40 %], [0,8930], [0,0895], [–1,61 pts],
      [EXP5], [2], [300], [1078], [90,50 %], [0,9034], [0,0918], [–0,51 pt],
    ),
    caption: [Comparaison exhaustive des six configurations expérimentales],
  kind: table,
  )
]


*2. Analyse des Gains – Ce qui fonctionne:*

* 2.1 Dégel des couches BERT (Base → EXP1) :*

#align(center)[
  #figure(
    table(
      columns: (1fr, 1fr, 1fr, 1fr),
      align: center,
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Métrique*], [*Base (gel 8)*], [*EXP1 (gel 4)*], [*Gain*],
      [Accuracy], [87,43 %], [90,13 %], [#text(fill: green)[*+2,70 pts*]],
      [F1 Macro], [0,8737], [0,9013], [#text(fill: green)[*+0,0276*]],
    ),
    caption: [Comparaison Base vs EXP1],
  kind: table,
  )
]


*Interprétation :*

#h(0.5cm)Le dégel de 4 couches (8 → 4) est le *levier le plus puissant*. En doublant les paramètres entraînables (28,9 M → 57,3 M), DziriBERT a pu adapter ses représentations sémantiques au dialecte algérien. L'écart Train/Val reste contenu (0,0717 < 0,10).

#h(0.5cm)▶ *Leçon :* BERT a besoin de flexibilité pour apprendre les spécificités de la Darija.

* 2.2 Ajout du TF‑IDF (EXP1 → EXP2) :*

#align(center)[
  #figure(
    table(
      columns: (1fr, 1fr, 1fr, 1fr),
      align: center,
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Métrique*], [*EXP1*], [*EXP2*], [*Gain*],
      [Accuracy], [90,13 %], [90,79 %], [#text(fill: green)[*+0,66 pt*]],
      [F1 Macro], [0,9013], [0,9069], [#text(fill: green)[*+0,0056*]],
    ),
    caption: [Comparaison EXP1 vs EXP2],
  kind: table,
  )
]

*Interprétation :*

#h(0.5cm)L'ajout des 150 termes les plus discriminants (Chi² + dissimilarité) apporte un gain réel mais modeste. La progression est particulièrement marquée sur les classes Negatif (+0,0117) et Neutre (+0,0079), confirmant que les termes techniques (« coupure », « fibre », « lente ») et les marqueurs de neutralité (« merci », « bon courage ») fournissent des indices lexicaux directs.

#h(0.5cm)▶ *Leçon :* TF‑IDF ciblé > TF‑IDF redondant.

* 2.3 Dégel supplémentaire (EXP2 → EXP3) :*

#align(center)[
  #figure(
    table(
      columns: (1fr, 1fr, 1fr, 1fr),
      align: center,
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Métrique*], [*EXP2*], [*EXP3*], [*Gain*],
      [Accuracy], [90,79 %], [91,01 %], [#text(fill: green)[*+0,22 pt*]],
      [F1 Macro], [0,9069], [0,9092], [#text(fill: green)[*+0,0023*]],
    ),
    caption: [Comparaison EXP2 vs EXP3],
  kind: table,
  )
]

*Interprétation :*

#h(0.5cm)Le dégel de 2 couches supplémentaires (4 → 2) apporte un gain marginal (+0,22 pt). La progression est plus marquée sur la classe Positif (+0,0040), confirmant que les couches 2‑7 de BERT (syntaxe intermédiaire) aident à capturer les structures complexes (positifs conditionnels). L'écart Train/Val augmente à 0,0886 mais reste acceptable.

#h(0.5cm)▶ *Leçon :* On approche d'un plateau de performance avec cette architecture linéaire.

*3. Analyse des Échecs – Ce qui ne fonctionne pas *

* 3.1 Classifieur non‑linéaire (EXP3 → EXP4) :*

#align(center)[
  #figure(
    table(
      columns: (1fr, 1fr, 1fr, 1fr),
      align: center,
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Métrique*], [*EXP3 (linéaire)*], [*EXP4 (non‑linéaire)*], [*Variation*],
      [Accuracy], [91,01 %], [89,40 %], [#text(fill: red)[*–1,61 pts*]],
      [F1 Macro], [0,9092], [0,8930], [#text(fill: red)[*–0,0162*]],
    ),
    caption: [Comparaison EXP3 vs EXP4],
  kind: table,
  )
]

*Interprétation :*

#h(0.5cm)Le passage à un classifieur à 2 couches cachées (512 neurones) dégrade toutes les métriques. Causes principales :

- *Trop de paramètres :* +475 000 paramètres pour ~11 000 documents d'entraînement → sur‑paramétrisation.
- *Interactions déjà linéaires :* Les flags (binaires) et le TF‑IDF (pondérations) n'ont pas besoin de non‑linéarités complexes.
- *Dropout 0,35 :* probablement trop agressif, tuant le signal utile sur les classes minoritaires.

#h(0.5cm)▶ *Leçon :* Pour l'hybridation BERT + features manuelles, l'architecture linéaire simple est supérieure.

* 3.2 Augmentation du TF‑IDF à 300 mots (EXP3 → EXP5) :*

#align(center)[
  #figure(
    table(
      columns: (1fr, 1fr, 1fr, 1fr),
      align: center,
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Métrique*], [*EXP3 (150 mots)*], [*EXP5 (300 mots)*], [*Variation*],
      [Accuracy], [91,01 %], [90,50 %], [#text(fill: red)[*–0,51 pt*]],
      [F1 Macro], [0,9092], [0,9034], [#text(fill: red)[*–0,0058*]],
    ),
    caption: [Comparaison EXP3 vs EXP5],
  kind: table,
  )
]

*Interprétation :*

#h(0.5cm)Passer de 150 à 300 mots dégrade les performances, en particulier sur les classes Positif (–0,0119) et Négatif (–0,0071). Explications :

- *Redondance avec BERT :* Les mots de rang 151‑300 sont des termes que DziriBERT connaît déjà (français courant, mots‑outils). Ils n'apportent pas d'information nouvelle.
- *Dilution du signal :* Ajouter des termes moins discriminants (Chi² plus faible) introduit du bruit plutôt que du signal.

#h(0.5cm)▶ *Leçon :* Le point optimal est 150 mots. Ce n'est pas « plus de mots = mieux ». La sélection doit être agressive.

*4. Évolution de l'écart Train/Val (Surapprentissage) : *

#align(center)[
  #figure(
    table(
      columns: (1.5fr, 1fr, 1.5fr, 1fr),
      align: center,
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Configuration*], [*Écart Train/Val*], [*Seuil d'alerte (0,10)*], [*Évaluation*],
      [Base], [0,0205], [< 0,10], [Excellent],
      [EXP1], [0,0717], [< 0,10], [Très bien],
      [EXP2], [0,0725], [< 0,10], [Très bien],
      [EXP3], [0,0886], [< 0,10], [Acceptable],
      [EXP4], [0,0895], [< 0,10], [Acceptable],
      [EXP5], [0,0918], [< 0,10], [Acceptable],
    ),
    caption: [Évolution de l'écart Train/Val sur les 6 configurations],
  kind: table,
  )
]

*Interprétation :*

#h(0.5cm)Toutes les configurations restent en dessous du seuil d'alerte de 0,10. L'augmentation progressive de l'écart (0,0205 → 0,0918) est corrélée à l'augmentation de la flexibilité du modèle (plus de paramètres entraînables, plus de dimensions d'entrée). *Aucune configuration ne souffre d'overfitting problématique.*

*5. Classement final par F1 Macro :*

#align(center)[
  #figure(
    table(
      columns: (auto, 1.5fr, 1fr, 1fr, 1fr),
      align: center,
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Rang*], [*Configuration*], [*F1 Macro*], [*Accuracy*], [*Écart T/V*],
      [1], [*EXP3 ★*], [*0,9092*], [*91,01 %*], [*0,0886*],
      [2], [EXP2], [0,9069], [90,79 %], [0,0725],
      [3], [EXP5], [0,9034], [90,50 %], [0,0918],
      [4], [EXP1], [0,9013], [90,13 %], [0,0717],
      [5], [EXP4], [0,8930], [89,40 %], [0,0895],
      [6], [Base], [0,8737], [87,43 %], [0,0205],
    ),
    caption: [Classement final des six configurations par F1 Macro décroissant],
  kind: table,
  )
]

* 6. Recommandation finale :*

La configuration recommandée est *EXP3* :

- *FREEZE_LAYERS = 2* (seules les couches 0‑1 gelées)

- *TF‑IDF à 150 termes* (issus de Chi² + dissimilarité)

- *Flags manuels DZ* (10 dimensions)

- *Architecture linéaire :* [CLS](768) + flags(10) + TF‑IDF(150) → Linear(928, 3)

- *Accuracy = 91,01 % | F1 Macro = 0,9092 | Écart Train/Val = 0,0886*

EXP3 est préférée à EXP2 car elle offre un meilleur F1 Macro (+0,0023) et une meilleure accuracy (+0,22 pt) pour un écart Train/Val qui reste largement en dessous du seuil critique (0,0886 < 0,10). Le compromis performance/généralisation est optimal.

Cette configuration atteint le meilleur compromis entre performance et généralisation. Pour viser 92 %+, deux pistes complémentaires peuvent être explorées :

#h(0.5cm)  - *Augmentation du corpus :* plus de données dialectales annotées réduirait le besoin de régularisation et permettrait un dégel plus agressif.

#h(0.5cm) - *Modèle de base alternatif :* DarijaBERT ou MARBERT, bien que nos expériences préliminaires confirment la supériorité de DziriBERT sur le corpus algérien spécifique.








== Solution Finale Retenue — Modèle de Sentiment
=== Architecture définitive et justification



#h(0.5cm) La solution finale retenue intègre l'ensemble des
optimisations validées au cours des expériences précédentes
(EXP1 à EXP5) et introduit trois améliorations structurelles
majeures par rapport à la configuration EXP3 — qui constituait
la meilleure configuration linéaire avec une accuracy de 91,01 %
et un F1 Macro de 0,9092 — dont une stratégie de dédoublonnage
systématique reposant sur la méthode *Jaccard Mots* sélectionnée
au terme de l'évaluation comparative menée au Chapitre 4.

#h(0.5cm) Le tableau ci-dessous résume le cheminement
expérimental qui a conduit à la solution finale. Chaque
expérience a apporté un enseignement précis, exploité dans
la configuration définitive.

#align(center)[
  #figure(
    table(
      columns: (auto, 2fr, 2fr),
      align: (left, left, left),
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Expérience*], [*Apport principal*], [*Limite identifiée*],
      [Base],
      [Résolution de l'overfitting sévère (écart T/V : 0,41 → 0,0205)],
      [Gel trop important (8/12), absence de TF-IDF],

      [EXP1], [Dégel partiel (4/12) → +2,70 pts d'accuracy, F1=0,9013], [Absence de vocabulaire spécifique],
      [EXP2], [Ajout TF-IDF 150 termes → +0,66 pt, meilleure détection du Négatif], [Dégel encore limité (4/12)],
      [EXP3 ★],
      [Dégel (2/12) → F1=0,9092, meilleure config. linéaire],
      [Biais sur les positifs courts (apply_priority), plateau proche],

      [EXP4],
      [Test classifieur non-linéaire → −1,61 pt : interactions déjà linéaires],
      [Sur-paramétrisation (512 neurones / 11 000 docs)],

      [EXP5],
      [Test TF-IDF 300 mots → −0,51 pt : redondance avec BERT au-delà de 150],
      [Point optimal confirmé à 150 termes],
    ),
    caption: [Synthèse du cheminement expérimental conduisant à la solution finale],
  kind: table,
  )
]

#h(0.5cm) Fort de ces enseignements, la solution finale s'articule
autour de cinq leviers d'amélioration complémentaires,
détaillés ci-après :

*1. Dédoublonnage des commentaires (méthode Jaccard Mots)*

Conformément à l'analyse menée au Chapitre 4
*(section « Suppression des doublons »)*, six méthodes de
détection de doublons ont été comparées sur un échantillon
de 1 000 commentaires. Le critère de sélection était le
F1-score, équilibrant la précision et le rappel, avec un
seuil de similarité fixé à 85 % après optimisation. La
méthode *Jaccard Mots* s'est imposée avec un F1 de 94,7 %
et seulement 4 faux positifs sur 1 000 commentaires,
devançant la similarité cosinus TF-IDF (F1 = 92,3 %) et
la distance de Levenshtein (F1 = 83,7 %).

*2. Correction de l'étiquetage des positifs (apply_priority corrigée)*

L'analyse de *l'EXP3* a révélé un biais persistant : certains
commentaires positifs courts ou contenant des formules sociales
étaient classés comme neutre par le modèle. L'origine de ce
problème a été identifiée dans la fonction
#highlight(fill: luma(240))[apply_priority] utilisée lors de
la Phase 3 : les règles
#highlight(fill: luma(240))[flag_social] et
#highlight(fill: luma(235))[flag_encouragement]
forçaient systématiquement le label neutre, même lorsque
le commentaire exprimait une satisfaction explicite.

Le diagnostic réalisé avant l'entraînement a quantifié
l'ampleur du biais : dans la version originale, *1 140 positifs*
avaient été convertis en neutre, réduisant la classe positive
de 4 559 à 3 559 documents (−24,9 %). À l'inverse, la classe
neutre se retrouvait artificiellement gonflée à 5 683 documents.

Correction apportée :

- Les règles *flag_social* et *flag_encouragement* ne
  modifient plus le label si le commentaire est déjà positif.
- Le label positif original est préservé intégralement.
- Les règles fiables *(flag_plainte, flag_negation,
  flag_mixte + suggestion)* sont conservées sans modification.

Cette correction a permis de passer d'une perte de 1 140
positifs convertis en neutre (version originale) à une
conservation intégrale de tous les positifs (0 % de perte),
confirmée par le diagnostic automatique exécuté en début
d'entraînement.

*3. Dégel maximal des couches BERT (FREEZE_LAYERS = 1)*

#h(0.5cm) La tendance progressive observée à travers les
expériences (Base : 8 couches gelées → EXP1 : 4 → EXP3 : 2)
suggérait qu'un dégel supplémentaire pouvait encore améliorer
les performances. La solution finale valide cette hypothèse
en ne laissant gelée que la première couche (FREEZE_LAYERS = 1),
confirmant que DziriBERT bénéficie d'une flexibilité maximale
pour s'adapter aux spécificités morphosyntaxiques de la
Darija algérienne.

*4. Label smoothing différencié (classe neutre plus bruitée)*

#h(0.5cm) La classe neutre présente intrinsèquement plus de
bruit que les classes positif et négatif : elle inclut des
formules sociales, des questions, des commentaires informatifs
sans polarité forte, et des réponses de modérateurs. Ce bruit
a été amplifié par la correction de l'apply_priority, qui a
réintégré 1 133 positifs précédemment mal étiquetés comme
neutres. Un lissage unique pour toutes les classes s'est avéré
sous-optimal.

Solution implémentée :

#highlight(fill: luma(235))[LABEL_SMOOTHING_DEFAULT] = *0,10*
pour les classes positif et négatif.

#highlight(fill: luma(235))[LABEL_SMOOTHING_NEUTRE] = *0,25*
pour la classe neutre (lissage plus fort pour mieux
tolérer le bruit résiduel).

*5. Mean pooling (remplacement du token [CLS])*

#h(0.5cm) Les expériences précédentes (EXP1 à EXP5)
utilisaient exclusivement le token #highlight(fill: luma(240))[[CLS]]
comme représentation de la séquence. Or, pour des textes courts
et dialectaux comme les commentaires en Darija, ce token
peut concentrer une information parcellaire. Le mean pooling
— calcul de la moyenne des embeddings de *tous les tokens*
de la séquence — produit une représentation plus riche et
plus robuste, particulièrement adaptée aux commentaires
courts et aux expressions idiomatiques. L'architecture
finale devient :

#align(center)[
  $"mean\_pool"(768) + "flags"(10) + "TF-IDF"(150)
  arrow.r "Linear"(928, 3)$
]


*5. Protocole expérimental*

*5.1 Hyperparamètres de la solution finale*
#align(center)[
  #figure(
    table(
      columns: (auto, auto, 1fr),
      align: (left, center, left),
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Paramètre*], [*Valeur finale*], [*Rôle / Justification*],
      [FREEZE_LAYERS], [1 / 12], [Seule la couche 0 est gelée ; dégel maximal (78,6 M paramètres, 63,1 %)],
      [DROPOUT_RATE], [0,30], [Régularisation maintenue],
      [LEARNING_RATE], [2e-5], [Taux d’apprentissage standard],
      [TF-IDF DIM], [150], [Top 150 mots Chi² + dissimilarité (Chapitre 4)],
      [FLAGS DIM], [10], [7 flags binaires + 3 subtypes],
      [LABEL_SMOOTHING_POS/NEG], [0,10], [Lissage standard pour classes polarisées],
      [LABEL_SMOOTHING_NEUTRE], [0,25], [Lissage renforcé pour classe plus bruitée],
      [AUGMENTATION POSITIFS], [500 exemples], [Injection systématique de positifs Darija],
      [DÉDOUBLONNAGE], [Jaccard Mots (seuil 85 %)], [Méthode optimisée (Chapitre 4)],
      [ARCHITECTURE], [Mean pooling], [Moyenne des embeddings de tous les tokens, au lieu du token [CLS]],
      [Dimensions totales], [928], [mean_pool(768) + flags(10) + tfidf(150)],
    ),
    caption: [Configuration hyperparamètres pour la solution finale],
  kind: table,
  )
]


*5.2  Corpus d’entraînement :*

#align(center)[
  #figure(
    table(
      columns: (auto, 1fr),
      align: (left, left),
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Propriété*], [*Valeur*],
      [Source], [Corpus Algérie Télécom (Phase 3)],
      [Nombre total de documents], [24043 (après dédoublonnage et augmentation)],
      [Dédoublonnage], [Jaccard Mots (seuil 85 \%) – cf. Chapitre 4],
      [Distribution], [Négatif : 4 559, Neutre : 4 559, Positif : 4 767],
      [Split], [Entraînement : 11 108 (80 \%), Validation : 1 388 (10 \%), Test : 1 389 (10 \%)],
      [Prétraitement], [Normalisation complète (mode Full), stopwords supprimés],
    ),
    caption: [Statistiques et propriétés du corpus final],
  kind: table,
  )
]




=== Performances finales sur le jeu de test

==== Historique d’entraînement (5 époques) :
#align(center)[
  #figure(
    table(
      columns: (auto, auto, auto, auto, auto, auto, auto, auto),
      align: center,
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if row == 3 { rgb("#e8f5e9") } else if calc.odd(row) {} else { none },
      [*Époque*],
      [*Training Loss*],
      [*Validation Loss*],
      [*Accuracy (\%)*],
      [*F1 Macro*],
      [*F1 Négatif*],
      [*F1 Neutre*],
      [*F1 Positif*],

      [1], [0,6524], [0,5210], [91,43], [0,9130], [0,8891], [0,8800], [0,9699],
      [2], [0,4839], [0,4612], [95,61], [0,9556], [0,9388], [0,9427], [0,9853],
      [*3*], [*0,4263*], [*0,4552*], [*96,54*], [*0,9651*], [*0,9498*], [*0,9572*], [*0,9884*],
      [4], [0,4054], [0,4586], [96,04], [0,9600], [0,9424], [0,9481], [0,9895],
      [5], [0,3975], [0,4574], [96,04], [0,9599], [0,9412], [0,9481], [0,9905],
    ),
    caption: [Évolution des performances lors de l'entraînement],
  kind: table,
  )
]

==== Courbes d’apprentissage et performances :
Après rechargement du meilleur modèle (époque 5) et évaluation sur les 1 368 documents de test :

#align(center)[
  #figure(
    table(
      columns: (auto, auto, auto, auto),
      align: (left, center, center, center),
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
      [*Métrique*], [*EXP3 (meilleure expérience)*], [*Solution finale*], [*Gain*],
      [Accuracy], [91,01 \%], [96,18 \%], [+5,17 pts],
      [F1 Macro], [0,9092], [0,9617], [+0,0525],
      [F1 Négatif], [0,8756], [0,9455], [+0,0699],
      [F1 Neutre], [0,9268], [0,9617], [+0,0349],
      [F1 Positif], [0,9251], [0,9778], [+0,0527],
      [Train Loss (finale)], [0,4554], [0,3975], [–0,0579],
      [Val Loss (finale)], [0,5440], [0,4574], [–0,0866],
      [Écart Train/Val], [0,0886], [0,0600], [–0,0286],
    ),
    caption: [Performances finales sur le jeu de test : comparaison Expérience 3 vs Solution final],
  kind: table,
  )
]



#figure(
  block(
    image("../images/courbe_final.jpg", width: 15cm),
  ),

  caption: [Courbes d’apprentissage de la solution finale],
   kind: image
)



==== Rapport de classification détaillé (test)

#align(center)[
  #figure(
    table(
      columns: (auto, auto, auto, auto, auto),
      align: center,
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if row == 3 { rgb("#e8f5e9") } else if row == 4
        or row == 5 {} else if calc.odd(row) {} else { none },
      [*Classe*], [*Précision*], [*Rappel*], [*F1‑score*], [*Support*],
      [Négatif], [0,94], [0,95], [0,95], [456],
      [Neutre], [0,96], [0,96], [0,96], [456],
      [Positif], [0,99], [0,97], [0,98], [477],
      [Moyenne macro], [0,96], [0,96], [0,96], [1389],
      [Moyenne pondérée], [0,96], [0,96], [0,96], [1389],
    ),
    caption: [Rapport de classification détaillé - Solution finale],
  kind: table,
  )
]



\

#figure(
  block(
    image("../images/matrice_confusion_final.jpg", width: 15cm),
  ),
  caption: [Matrice de confusion - Solution finale],
   kind: image
)


==== Analyse et interprétation

*1. Impact du dédoublonnage par Jaccard Mots*

L’application de la méthode *Jaccard Mots* (seuil 85 %) a permis de réduire le corpus de 7,64 % (26 576 → 24 536 commentaires uniques). Cette réduction, associée à la suppression des doublons, a directement contribué à :

- *Prévention du surapprentissage :* l’écart Train/Val passe de 0,0886 (EXP3) à 0,0600 (final), malgré un dégel plus important.

- *Meilleure généralisation :* les performances sur le jeu de test sont stables et même supérieures à celles de la validation sur certaines métriques

*2. L’ensemble des corrections produit un gain cumulé exceptionnel*

#h(0.5cm) La solution finale enregistre une accuracy de *96,18 %* et un F1 Macro de *0,9617*, soit des gains respectifs de *+5,17 points* et *+0,0525* par rapport à l’EXP3. Ce saut de performance, bien supérieur aux gains marginaux observés entre EXP1, EXP2 et EXP3, confirme que les corrections structurelles (étiquetage, dégel maximal, lissage différencié, augmentation forcée, mean pooling) agissent de manière synergique.


*3. Progression par époque – Convergence rapide et stable*



#align(center)[
  #table(
    columns: (auto, auto, auto),
    align: center,
    stroke: 1pt,
    fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
    [*Époque*], [*F1 Macro (val)*], [*Évolution*],
    [1], [0,9130], [–],
    [2], [0,9556], [#text(fill: green)[*+0,0426*]],
    [3], [0,9651], [#text(fill: green)[*+0,0095*]],
    [4], [0,9600], [#text(fill: red)[*–0,0051*]],
    [5], [0,9599], [#text(fill: red)[*–0,0001*]],
  )
]

#h(0.5cm) Le modèle atteint son meilleur F1 Macro de validation dès *l’époque 3 (0,9651)*, puis se stabilise. L’early stopping n’est pas déclenché car la validation loss continue de décroître légèrement.

*4. Maîtrise du surapprentissage *

#align(center)[
  #table(
    columns: (auto, auto, auto),
    align: center,
    stroke: 1pt,
    fill: (_, row) => if row == 0 {} else { none },
    [*Métrique*], [*EXP3*], [*Solution finale*],
    [Écart Train/Val], [0,0886], [0,0600],
  )
]

#h(0.5cm) Malgré le dégel maximal (1 seule couche gelée) et l’augmentation de 500 positifs, l’écart Train/Val a diminué (−0,0286). Le modèle généralise mieux que l’EXP3, preuve que la suppression des doublons et la correction de l’étiquetage ont éliminé des sources de bruit.



*5. Analyse par classe – Progression homogène *
#align(center)[
  #table(
    columns: (0.3fr, 0.3fr, 0.3fr, 0.3fr),
    align: center,
    stroke: 1pt,
    fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },
    [*Classe*], [*EXP3*], [*Final*], [*Gain*],
    [Négatif], [0,8756], [0,9455], [+0,0699],
    [Neutre], [0,9268], [0,9617], [+0,0349],
    [Positif], [0,9251], [0,9778], [+0,0527],
  )
]


- *Positif :* progression spectaculaire (+0,0527). La correction de apply_priority, l’augmentation forcée des 500 exemples Darija et le mean pooling permettent au modèle de détecter correctement les expressions positives courtes et les remerciements.

- *Négatif :* progression la plus forte (+0,0699). La meilleure séparation des classes grâce au dédoublonnage et à la réduction dimensionnelle (Chi² + dissimilarité) profite particulièrement à cette classe.

- *Neutre :* progression solide (+0,0349). Le label smoothing différencié (0,25) tolère mieux le bruit intrinsèque de cette classe.





=== Analyse des erreurs résiduelles

==== Erreur résiduelle dans les tests Darija réels

#h(0.5cm) Le test de validation sur 21 expressions Darija
réelles a produit un score de *20/21 (95 %)*, avec
une seule erreur résiduelle : "bon courage" prédit
comme *positif* (probabilité pos = 0,95) alors que
la classe attendue est neutre. Cette confusion s'explique
directement par la correction de l'apply_priority :
en supprimant la règle qui forçait flag_encouragement
→ neutre, le modèle a appris que les encouragements
sont statistiquement associés aux positifs — ce qui
est vrai dans 90 % des cas dans le corpus.

Cette erreur unique illustre le compromis inhérent
à la correction : *+1 140 positifs préservés*
contre *quelques neutres de type encouragement
légèrement sur-généralisés*. Le bilan reste
nettement favorable.



=== Comparaison globale — tous modèles confondus






#align(center)[
  #figure(
    block(
      // stroke: 1pt + black,
      inset: 5pt,
      image("../images/sechama_expe.jpg", width: 10cm),
    ),
    caption: [Processus d'amélioration d'un modèle de classification.],
    kind: image
  )
]


#h(0.5cm) Le tableau ci-dessous récapitule les performances de l’ensemble des configurations évaluées, depuis l'Expériences de base jusqu’à la solution finale retenue. L’évolution illustre clairement l’apport progressif de chaque optimisation.



#align(center)[
  #figure(
    table(
      columns: (auto, auto, auto, auto, auto, auto, auto, auto),
      align: center,
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.even(row) {} else { none },
      [*Métrique / Exp.*], [*Base*], [*EXP1*], [*EXP2*], [*EXP3*], [*EXP4*], [*EXP5*], [*Finale*],
      [FREEZE_LAYERS], [8], [4], [4], [2], [2], [2], [1],
      [TF-IDF], [0], [0], [150], [150], [150 (non-lin.)], [300], [150],
      [Augmentation], [-], [-], [-], [-], [-], [-], [ 500],
      [Dimensions], [778], [778], [928], [928], [928], [1078], [928],
      [Accuracy], [87,43\%], [90,13\%], [90,79\%], [91,01\%], [89,40\%], [90,50\%], [#text(fill: green)[*96,18\%*]],
      [F1 Macro], [0,8737], [0,9013], [0,9069], [0,9092], [0,8930], [0,9034], [#text(fill: green)[*0,9617*]],
      [Écart T/V], [0,0205], [0,0717], [0,0725], [0,0886], [0,0895], [0,0918], [#text(fill: green)[*0,0600*]],
    ),
    caption: [Synthèse des configurations et performances de toutes les expériences],
  kind: table,
  )
]
#h(0.5cm) La lecture transversale de ce tableau confirme
trois enseignements majeurs issus du parcours expérimental.

#h(0.5cm) *Premièrement*, le dégel progressif des couches
BERT constitue le levier le plus déterminant : la transition
Base → EXP1 génère à elle seule +2,70 pts d'accuracy,
soit davantage que toutes les optimisations combinées
entre EXP1 et EXP3.

#h(0.5cm) *Deuxièmement*, les expériences EXP4
et EXP5, bien qu'infructueuses, ont délimité précisément
l'espace de recherche optimal : l'architecture linéaire
est supérieure à la non-linéaire, et 150 termes TF-IDF
constituent le point de saturation au-delà duquel
s'amorce une dégradation par redondance avec les
embeddings de DziriBERT.

#h(0.5cm) *Troisièmement*, et c'est le résultat le plus
saillant, la solution finale rompt avec la tendance
à la convergence progressive observée entre EXP1,
EXP2 et EXP3 (gains marginaux de +2,70, +0,66 et
+0,22 pts). En corrigeant les sources de bruit
en amont — étiquetage erroné, doublons, représentation
parcellaire du [CLS] — elle produit un gain cumulé
de *+5,17 points*, confirmant que la qualité du
corpus prime sur la complexité architecturale.


=== Conclusion


#h(0.5cm) La solution finale retenue constitue l'aboutissement
d'un processus itératif rigoureux. En partant d'une expérience
de base souffrant d'un overfitting sévère (écart T/V = 0,41),
six configurations successives ont permis d'identifier
précisément les leviers efficaces et ceux à écarter.

#h(0.5cm) Le résultat final — *accuracy de 96,18 %*,
*F1 Macro de 0,9617*, écart Train/Val de 0,0600 — ne découle
pas d'une seule optimisation isolée, mais de la convergence
de cinq corrections structurelles agissant en synergie :
la restauration de 1 140 positifs mal étiquetés, le dégel
maximal de DziriBERT, le mean pooling, le dédoublonnage
par Jaccard Mots et le label smoothing différencié.

#h(0.5cm) La validation sur 21 expressions Darija réelles
(20/21, 95 %) confirme que ces gains se traduisent
concrètement : le modèle reconnaît désormais correctement
les expressions positives courtes, les remerciements
dialectaux et le code-switching arabe/français, qui
constituaient les principaux points de défaillance
des configurations précédentes. Les erreurs résiduelles,
concentrées sur les frontières Négatif/Neutre et
Neutre/Positif, définissent les axes naturels
des travaux futurs.






















































































































































== Classification fine des reason et des thèmes
L'analyse de sentiment agrège la satisfaction en trois polarités, mais elle reste muette sur pourquoi un abonné se plaint. Pour les opérateurs télécom algériens, cette lacune n'est pas anodine : distinguer un dysfonctionnement réseau d'un litige de facturation ou d'un délai d'installation conditionne directement la priorisation des actions correctives. Nous avons donc construit un second système de *classification supervisée* qui étiquette chaque commentaire selon 12 motifs (reason) et, par agrégation, selon 9 thèmes (theme) exploitables par les équipes métier.


=== Constitution du corpus annoté
Le fichier source expose une colonne reason en texte libre, issue d'une annotation manuelle initiale, avec 4 076 valeurs uniques. Les ré-annoter manuellement aurait requis un effort disproportionné. Nous avons donc projeté ces valeurs dans une taxinomie fermée de 15 catégories à l'aide d'un grand modèle de langage (LLM).
- *Méthode* :
- *Modèle* : *llama-3.3-70b-versatile* accessible via l'API Groq.
- *Reason* : Par lots de 150 raisons, chaque lot est envoyé avec un prompt détaillant les règles de classification (ex. « réseau, débit, coupure → probleme_technique »).
Gestion des limites de tokens et des erreurs (reprises automatiques, sauvegarde intermédiaire).
- * Résultat *:
  - après deux passes, les 4 081 raisons (doublons légers) sont mappées dans les 15 catégories.
  - Trois classes présentent des effectifs très faibles (reclamation_formelle, couverture_reseau, frustration_generale) ; nous les fusionnons respectivement dans absence_service, probleme_technique et autre, obtenant ainsi 12 classes finales.
  - Le tableau @tab:reason_classes présente ces motifs avec des exemples représentatifs.

#figure(
  caption: [Motifs (reason) après fusion des petites classes],
  kind: table,
  table(
    columns: (1.6fr, 3fr),
    inset: (x: 6pt, y: 5pt),
    align: (left, left),
    stroke: 0.5pt,
    [Catégorie], [Exemple de raison (traduction ou darija)],
    [probleme_technique], [« internet lent bzzaf machi mzyan »],
    [service_client], [« yaw repondiw 3lina prv »],
    [facturation_offre], [« chehl prix fibre optique ? »],
    [demande_information], [« wach kayen fibre f bladi ? »],
    [satisfaction_positive], [« شكرا ليكم تواصلت معكم »],
    [demande_amelioration], [« nhar ywali tdefuq internet jayid … »],
    [absence_service], [« مبان والوو ما عندناش خدمة »],
    [delai_installation], [« ركبونا fibre optique هاذا يهديكم »],
    [application_mobile], [« application myidoom ma tkhdemch »],
    [encouragement_felicitations], [« بالتوفيق ان شاء الله »],
    [social_non_pertinent], [« salam »],
    [autre], [toute raison ne correspondant à aucune classe],
  ),
) <tab:reason_classes>
- Chaque commentaire du corpus (colonne normalized_arabert) reçoit ensuite une étiquette reason_groupe via un dictionnaire de correspondance.
- La distribution initiale *13 677 documents* reproduit le déséquilibre observé pour le sentiment : demande_information concentre 2 671 exemples, satisfaction_positive en rassemble 1 986, tandis qu'application_mobile n'en compte que 233 et couverture_reseau 167.
- Nous plafonnons à 1 500 exemples par classe lors de l'entraînement, ce qui produit un corpus équilibré de 12 020 documents.
=== Modèle et apprentissage
Nous recourons à la même architecture Transformer que pour l'analyse de sentiment :
#figure(
  caption: [Hyperparamètres du fine-tuning de DziriBERT],
  kind: table,
  table(
    columns: 2,
    align: (left, left),
    stroke: 0.5pt,
    [**Paramètre**], [**Valeur**],
    [Modèle], [DziriBERT (`alger-ia/dziribert`) – Transformer pré-entraîné sur la darija algérienne],
    [Architecture], [Transformer (identique à l’analyse de sentiment)],
    [Tâche], [Classification supervisée à 12 classes],
    [Nombre d’époques], [3],
    [Taille de batch], [16],
    [Taux d’apprentissage], [2 × 10⁻⁵],
    [Pondération des classes], [`class_weight = "balanced"` (inverse des fréquences)],
    [Early stopping], [Patience = 2 sur la F1-macro de validation],
    [Longueur maximale de séquence], [128 tokens],
    [Jeu de test], [1 583 documents],
    [Partition des données], [80 % / 10 % / 10 % (entraînement / validation / test) – stratifiée],
  ),
)
=== Résultats de la classification des motifs
Le tableau *@tab:reason_results* détaille les métriques par classe. L'accuracy globale atteint 78,0 % et la F1-macro 76,0 % des scores solides pour une taxinomie de 12 classes appliquée à un dialecte faiblement doté en ressources linguistiques.
#figure(
  caption: [Performances de DziriBERT sur les 12 motifs (reason)],
  kind: table,
  table(
    columns: (1.8fr, 1fr, 1fr, 1fr, 1fr),
    inset: (x: 5pt, y: 4pt),
    align: (left, center, center, center, center),
    stroke: 0.5pt,
    [Classe], [Précision], [Rappel], [F1‑score], [Support],
    [absence_service], [0,500], [0,461], [0,480], [102],
    [application_mobile], [0,750], [0,857], [0,800], [35],
    [autre], [0,625], [0,583], [0,603], [180],
    [delai_installation], [0,551], [0,644], [0,594], [59],
    [demande_amelioration], [0,731], [0,773], [0,751], [88],
    [demande_information], [0,843], [0,778], [0,809], [180],
    [encouragement_felicitations], [0,994], [0,989], [0,992], [177],
    [facturation_offre], [0,824], [0,871], [0,847], [124],
    [probleme_technique], [0,667], [0,622], [0,644], [180],
    [satisfaction_positive], [0,994], [0,994], [0,994], [180],
    [service_client], [0,696], [0,762], [0,727], [126],
    [social_non_pertinent], [0,856], [0,901], [0,878], [152],
  ),
) <tab:reason_results>
- *Les classes sémantiquement* cohésives et bien représentées "encouragement_felicitations" et "satisfaction_positive"  franchissent un F1 de 0,99 : le modèle les discrimine sans ambiguïté. À l'opposé, "absence_service", "delai_installation" et "probleme_technique" plafonnent entre 0,48 et 0,64.
- *La matrice de confusion* (@fig:reason_cm) révèle que ces erreurs se concentrent sur le glissement sémantique entre "probleme_technique" et "autre", là où les descriptions sont floues ou trop brèves pour ancrer une décision, ainsi qu'entre "absence_service" et cette même classe résiduelle.
#figure(
  image("../images/confusion_matrix_reason.png", width: 12cm),
  caption: [Matrice de confusion de la classification des motifs (reason).],
) <fig:reason_cm>
=== Agrégation en thèmes métier
Pour le reporting stratégique, les 12 motifs se regroupent en 9 thèmes plus larges (* @tab:themes*).
- "probleme_technique" et "absence_service" *fusionnent dans* "reseau_technique", car ils partagent la même chaîne causale  une défaillance d'infrastructure que le client perçoit soit comme une dégradation, soit comme une interruption totale.
- "satisfaction_positive" et "encouragement_felicitations" *constituent* "experience_positive".
- "*social_non_pertinent*" et autre forment "*hors_sujet*", classe de bruit sans valeur opérationnelle.
#figure(
  caption: [Correspondance entre motifs (reason) et thèmes (theme)],
  kind: table,
  table(
    columns: (1.6fr, 2.5fr),
    inset: (x: 6pt, y: 5pt),
    align: (left, left),
    stroke: 0.5pt,
    [Thème], [Motifs inclus],
    [reseau_technique], [probleme_technique, absence_service],
    [installation_equipement], [delai_installation],
    [application_digitale], [application_mobile],
    [facturation_tarifs], [facturation_offre],
    [information_generale], [demande_information],
    [suggestions_ameliorations], [demande_amelioration],
    [service_clientele], [service_client],
    [experience_positive], [satisfaction_positive, encouragement_felicitations],
    [hors_sujet], [social_non_pertinent, autre],
  ),
) <tab:themes>
- En appliquant ce mapping sur les prédictions du modèle, on obtient la distribution des thèmes dans le corpus.(* @fig:themes_dist*).

#figure(
  image("../images/themes_distribution.png", width: 10cm),
  caption: [Distribution des thèmes dans le corpus complet.],
) <fig:themes_dist>
=== Inférence hybride : règles expertes + modèle
Pour l'exploitation en production, le pipeline d'inférence articule deux couches complémentaires.

- *Règles regex immédiates* : elles interceptent les cas où la classification est triviale — salutations pures (salam, bonjour), encouragements stéréotypés (good luck, بالتوفيق), mots-clés dialectaux forts (lent, fatura, crash). Ces règles ne sollicitent aucun appel GPU et couvrent environ 15 % des commentaires avec une confiance de 100 %.
- *Modèle DziriBERT* : il prend en charge tous les commentaires non interceptés. Le modèle retourne la classe la plus probable ainsi qu'un score de confiance ; lorsque ce score chute sous 0,25 et que l'écart avec la deuxième classe reste inférieur à 50 %, le résultat bascule vers autre la classe résiduelle pour contenir les erreurs les plus marquées.

==== Performances du pipeline hybride (règles + modèle)

Le système d’inférence final combine des règles regex (cas triviaux) et le modèle DziriBERT. Sur un échantillon de test de 500 commentaires, les performances sont les suivantes :

#figure(
  table(
    columns: (1.5fr, 1fr, 1fr, 1fr, 1fr),
    inset: (x: 6pt, y: 5pt),
    align: (left, center, center, center, center),
    stroke: 0.5pt,
    [*Configuration*], [*Accuracy*], [*F1‑macro*], [*F1‑weighted*], [*Temps moy. (ms)*],
    [Modèle seul (DziriBERT)], [0,780], [0,760], [0,779], [12,4],
    [Hybride (regex + modèle)], [0,884], [0,884], [0,884], [8,7],
  ),
  caption: [
    Comparaison entre le modèle pur et le pipeline hybride.
  ],
  kind: table,
)
Le gain en F1‑macro est de* +12,4 points*,
et le temps d’inférence diminue grâce à la prise en charge rapide des cas regex.
=== Discussion
La classification des motifs se révèle structurellement plus difficile que l'analyse de sentiment tripolaire. Nous identifions trois facteurs qui limitent les performances sur les classes les plus faibles.
- *Le déséquilibre résiduel*: d'abord même après rééquilibrage, application_mobile ne dispose que de 233 exemples, ce qui contraint la capacité de généralisation du modèle sur cette classe.
- *L'ambiguïté sémantique* : ensuite un commentaire tel que « application lente » relève simultanément d'application_mobile et de probleme_technique ; notre grille à étiquette unique absorbe cette superposition en bruit d'annotation.
- *La longueur des messages*: enfin  de nombreux commentaires se réduisent à une phrase nominale (« où est la fibre ? »)  prive le modèle du contexte nécessaire pour trancher entre des classes proches.
Ces réserves n'invalident pas les résultats obtenus. Un *F1-macro de 76 %* sur 12 classes pour un dialecte sous-doté demeure une performance acceptable. La chaîne méthodologique — annotation initiale par LLM, fine-tuning de DziriBERT, hybridation avec des règles expertes — est reproductible et a été intégrée dans un module d'analyse automatisé. Ce module alimente aujourd'hui un tableau de bord opérationnel qui permet aux équipes de suivre l'évolution des motifs d'insatisfaction par thème et par opérateur, en quasi-temps réel.

== Détection automatique de la langue des commentaires : approche hybride
=== Architecture du détecteur
Le détecteur repose sur deux couches complémentaires dont l'articulation détermine la robustesse de la classification finale.
==== Couche lexicale – darija et arabizi
Deux dictionnaires ont été construits manuellement à partir d'un échantillon de 2 000 commentaires :
typst#figure(caption: [Classification des commentaires selon les scores lexicaux],
  kind: table, table(
  columns: (auto, auto, auto),
  align: (left, left, left),
  stroke: 0.5pt,
  table.header([**Catégorie**], [**Exemples représentatifs**], [**Décision**]),
  // Ligne Darija
  [
    Darija
    (écriture arabe)
  ],
  [
    #text(size: 0.9em)[
      • possessifs : ديال، تاع\n

      • négations : ما...ش, موش\n

      • adverbes : بزاف, دابا, تما\n

      • interrogatifs : واش, أشمن\n

      • verbes fréquents : قال, مشى, كل
    ]
  ],
  [
    Score darija mesuré,
    mais non discriminant si
    score arabizi > 0.5
  ],
  // Ligne Arabizi
  [
    Arabizi
    (latin + chiffres)
  ],
  [
    #text(size: 0.9em)[
      • *rani*, *3lach*, *bzzaf*, *9al*\n

      • *mazal*, *cnx*, *ping*, *forfet*\n

      • *tlephone*, *swit*, *7na*, *3lik*
    ]
  ],
  [
    #text(weight: "bold", fill: red)[
      Classé *arabizi*
    ]\
    Confiance élevée (jusqu'à 95 %)
  ],
))

==== Couche TF‑IDF + SVM linéaire
Pour les textes que les règles lexicales ne capturent pas  arabe classique, français, anglais, textes mixtes — nous appliquons un pipeline vectoriel standard :

- *Vectorisation* : TfidfVectorizer sur des caractères 2‑4 grammes, max_features = 30 000.
- *Classifieur* : LinearSVC avec class_weight = "balanced", calibré par sigmoïde pour obtenir des probabilités.
- *Entraînement* : 93 textes équilibrés (10 arabe classique, 16 darija, 19 arabizi, 15 français, 11 anglais, 22 mixte).

- La précision sur l'entraînement atteint 98,9 % et le F1‑macro 0,99. Le modèle entraîné est sauvegardé (modele_hybrid_v3.pkl) pour une utilisation en production.
- *Le choix des n-grammes de caractères*, plutôt que de mots, se justifie par la nature même du corpus : les commentaires arabizi fragmentent les unités lexicales selon des conventions orthographiques variables, rendant la tokenisation par mot peu fiable.
- Les 2‑4 grammes de caractères capturent ces sous-chaînes répétitives sans dépendre d'une segmentation préalable.
==== Fusion des deux couches
La décision finale articule scores lexicaux et probabilités SVM selon une hiérarchie de règles que nous avons établie empiriquement :

- priorité à l'arabizi si son score lexical dépasse 0,5 ou s'il dépasse 0,3 avec une probabilité SVM d'au moins 0,2 ;
correction de la classe darija lorsque le score lexical est élevé et que le SVM la sous‑estime au profit de l'arabe classique ;
recours au SVM dans tous les autres cas.

Cette cascade de priorités compense une limitation structurelle du SVM :
- entraîné sur un corpus restreint, le classifieur confond parfois darija en script arabe avec l'arabe classique lorsque les traits morphosyntaxiques dialectaux sont rares dans le texte.
- Le score lexical corrige alors cette dérive sans nécessiter de réentraînement.
- Un test manuel conduit sur 14 commentaires représentatifs, non inclus dans les données d'entraînement, montre que le détecteur classe correctement la totalité des cas (14/14).
- Les exemples détaillés et les niveaux de confiance associés sont présentés en *annexe @lang_test*.















== l’annotation à l’exploitation : constitution de la base tableau de bord

#h(0.5cm) Une fois les modèles de sentiment, de motifs et de langue entraînés et validés, l’étape suivante consiste à produire une base de données unique et exhaustive qui servira de socle au tableau de bord interactif. Cette base doit contenir, pour chaque commentaire brut, l’ensemble des informations utiles à l’analyse métier : les prédictions des modèles, les métadonnées temporelles, les indicateurs textuels et les flags comportementaux. Elle doit également documenter la qualité des annotations (confiances, incertitudes) afin que les utilisateurs puissent interpréter les indicateurs avec la marge d’erreur associée.

=== Périmètre de l’annotation : du corpus source à la collection enrichie

#h(0.5cm) Le corpus source est constitué des *26 576 commentaires* extraits des fichiers Excel fournis par le département Social Media d’Algérie Télécom (période novembre 2025 – janvier 2026). Après les étapes de nettoyage, normalisation et déduplication (cf. sections et), le corpus est réduit à *24 046 commentaires uniques* sémantiquement exploitables.

#h(0.5cm) Pour chacun de ces commentaires, nous avons exécuté un pipeline d’annotation automatique qui associe :

#list(
  [Un label de sentiment (#strong[POSITIF / NEUTRE / NÉGATIF]) via le modèle DziriBERT fine‑tuné.],
  [Un motif (12 classes, ex. "probleme_technique", "service_client") et un thème (9 classes, ex. "reseau_technique", "facturation_tarifs") via un second classifieur basé sur DziriBERT.],
  [Une langue détectée (#strong[arabe_darija, latin_francais, mixte, etc.]) via le détecteur hybride (règles + SVM).],
  [*Des indicateurs textuels* : longueur en mots et caractères, nombre de phrases, catégorie de longueur (très court, court, moyen, long).],
  [*Des métadonnées temporelles *extraites de la date de publication : année, mois, semaine, jour de la semaine, heure, tranche horaire, indicateur de week‑end.],
)

#h(0.5cm) L’ensemble est stocké dans une collection MongoDB unique nommée ("commentaires_predictions_final"). Le tableau *@tab:final_columns* liste l’intégralité des colonnes produites, avec leur type et leur rôle dans l’analyse.

#figure(
  caption: [Structure de la base finale pour le tableau de bord (51 colonnes).],
  kind: table,
  table(
    columns: (1.7fr, 2.5fr, 1.2fr, 3fr),
    inset: (x: 6pt, y: 5pt),
    align: (left, left, left, left),
    stroke: 0.5pt + black,
    [*Catégorie*], [*Colonne*], [*Type*], [*Rôle dans le dashboard*],
    [Identité], [`original_id`], [string], [Lien vers la source brute],
    [], [`commentaire_original`], [string], [Affichage détaillé],
    [], [`commentaire_normalized`], [string], [Réutilisable pour futures analyses],
    [], [`source`], [string], [Filtre par plateforme],
    [], [`auteur`], [string], [Traçabilité (anonymisé)],
    [Temporel], [`date_originale`], [string], [Date lisible],
    [], [`annee`, `mois`, `semaine`], [int/string], [Agrégations temporelles],
    [], [`jour_semaine`, `heure`], [string/int], [Tendances horaires / journalières],
    [], [`tranche_horaire`], [string], [Créneaux horaires (matin, soirée, …)],
    [], [`est_weekend`], [bool], [Distinction semaine / week‑end],
    [Sentiment], [`sentiment_label`], [string], [KPI principal],
    [], [`sentiment_score`], [float], [Intensité (-1 à +1)],
    [], [`sentiment_confiance`], [float], [Fiabilité de la prédiction],
    [], [`sentiment_incertain`], [bool], [Drapeau d’alerte],
    [], [`sentiment_num`], [int], [Calculs numériques (-1/0/1)],
    [Motif / Thème], [`reason_pred`], [string], [Cause sous‑jacente],
    [], [`reason_confiance`], [float], [Fiabilité du motif],
    [], [`theme_pred`], [string], [Agrégation métier],
    [Langue], [`langue_detectee`], [string], [Filtrage linguistique],
    [], [`langue_confidence`], [float], [Confiance],
    [], [`langue_scores`], [dict], [Scores détaillés par langue],
    [Analyse textuelle], [`longueur_mots`, `longueur_chars`], [int], [Verbosite],
    [], [`nb_phrases`], [int], [Complexité syntaxique],
    [], [`longueur_categorie`], [string], [Qualitatif (court, long, …)],
    [Sémantique fine], [`mots_cles_negatifs`], [list], [Mots explicites détectés],
    [], [`categories_negatives`], [list], [Catégories associées],
    [], [`intensite_negative`], [float], [Score d’intensité (0–2)],
    [], [`has_negatif`], [bool], [Présence de négatif],
    [Comportement], [`frustration_detectee`], [bool], [Frustration explicite],
    [], [`demande_reponse`], [bool], [Demande de prise en charge],
    [], [`a_repondu`], [bool], [Modérateur a répondu],
    [], [`a_mention_prv`, `a_mention_attente`], [bool], [Signaux relation client],
    [Traçabilité], [`date_annotation`], [datetime], [Date de traitement],
    [], [`version_modele`], [string], [Reproductibilité],
  ),
) <tab:final_columns>

=== Validation de la qualité des annotations : comparaison avec l’existant

#h(0.5cm) La collection source `commentaires_normalises_final` contenait déjà des étiquettes de sentiment issues d’une annotation antérieure (manuelle ou semi‑automatique). Nous avons comparé systématiquement ces anciens labels avec les prédictions de notre nouveau pipeline. Les résultats sont les suivants :

#figure(
  caption: [Comparaison des labels anciens vs nouveaux.],
  kind: table,
  table(
    columns: (1.8fr, 1.2fr),
    inset: (x: 8pt, y: 6pt),
    align: (left, center),
    stroke: 0.5pt + black,
    [*Métrique*], [*Valeur*],
    [Labels identiques], [21 626 (89,9 %)],
    [Labels différents], [2 420 (10,1 %)],
  ),
)

#h(0.5cm) Parmi les 2 420 changements, les transitions majoritaires sont :

#figure(
  caption: [Détail des changements de sentiment les plus fréquents.],
  kind: table,
  table(
    columns: (1.8fr, 1fr, 2.5fr),
    inset: (x: 6pt, y: 5pt),
    align: (left, center, left),
    stroke: 0.5pt + black,
    [*Changement*], [*Effectif*], [*Interprétation*],
    [NEUTRE → NÉGATIF], [936], [Ancien système sous‑estimait la négativité],
    [NÉGATIF → NEUTRE], [807], [Ancien système sur‑réagissait],
    [NÉGATIF → POSITIF], [328], [Ironie ou positif conditionnel mal compris],
    [NEUTRE → POSITIF], [132], [Compliments modérés mieux détectés],
    [POSITIF → NÉGATIF], [121], [Sarcasmes détectés comme négatifs],
    [POSITIF → NEUTRE], [90], [Formules sociales dégonflées du positif],
  ),
)

#h(0.5cm) Ces écarts ne sont pas des erreurs systématiques du nouveau modèle : l’analyse qualitative montre qu’une partie des anciens labels étaient erronés (phrases entières collées dans la colonne *label*, confusion entre *neutre* et absence d’annotation). Le taux d’accord de 89,9 % est donc très satisfaisant.





=== Évaluation des performances des modèles utilisés pour l’annotation

#h(0.5cm) Le tableau *@tab:final_performances *synthétise les métriques de performance obtenues sur les jeux de test indépendants pour chaque module d’annotation.
#figure(
  caption: [Performances finales des modules d’annotation – version optimisée.],
  kind: table,
  table(
    columns: (1.8fr, auto, 1.2fr, 2.5fr),
    inset: (x: 6pt, y: 5pt),
    align: (left, center, left, left),
    stroke: 0.5pt + black,
    [*Module*], [*Métrique*], [*Valeur*], [*Commentaire*],
    [Sentiment (DziriBERT hybride)], [Accuracy], [96,18 %], [Flags + TF‑IDF (150) + rééquilibrage],
    [], [F1‑macro], [0,9617], [],
    [], [F1‑positif], [0,9778], [Très haute performance – plus de 97 %],
    [], [F1‑neutre], [0,9617], [],
    [], [F1‑négatif], [0,9455], [],
    [], [Écart train/val loss], [0,0600], [Bonne généralisation, overfitting maîtrisé],
    [Motifs (12 classes)], [Accuracy], [77,3 %], [Version v2 avec pondération des classes],
    [], [F1‑macro], [0,757], [],
    [], [F1 (satisfaction_positive)], [0,978], [Excellente discrimination],
    [], [F1 (encouragement_felicitations)], [0,992], [],
    [], [F1 (absence_service)], [0,459], [Confusion avec probleme_technique],
    [], [F1 (probleme_technique)], [0,595], [Amélioration possible avec plus de données],
    [Langue (hybride)], [Précision (test manuel)], [100 % (14/14)], [Détecteur lexical + SVM],
  ),
) <tab:final_performances>

#h(0.5cm) Les erreurs résiduelles sont principalement concentrées sur :

#list(
  [*La confusion entre neutre et négatif* (≈10 % des neutres sont classés négatifs), due au vocabulaire commun (noms d’opérateurs, termes techniques).],
  [*La classe positif*: 33 commentaires positifs sur 97 (34 %) sont classés négatifs ; il s’agit souvent d’ironie, de sarcasme ou de satisfaction conditionnelle « *c’est bien mais … *».],
  [Pour les motifs, "*absence_service*" et "*probleme_technique*" s’échangent des erreurs, car de courts messages «* plus de fibre* » peuvent relever des deux catégories.],
)

#h(0.5cm) Ces marges d’erreur sont explicitement documentées dans le dashboard via l’indicateur "sentiment_incertain" et un filtre par confiance minimale, permettant aux équipes métier d’ignorer les prédictions trop incertaines.


#h(0.5cm) À l’issue de ce processus, la collection "commentaires_predictions_final" contient #strong[24 046 documents] et #strong[51 champs] structurés. Elle est indexée sur les principaux axes d’analyse . Les requêtes d’agrégation pour le tableau de bord.









== Plateforme d'Analyse de Satisfaction Client

=== Introduction

#h(0.5cm) La pression exercée par les clients insatisfaits sur les réseaux sociaux constitue aujourd'hui une contrainte opérationnelle que les opérateurs télécoms ne peuvent ignorer. Algérie Télécom se trouvait ainsi dans l'obligation de se doter d'un dispositif analytique capable de traiter ces retours à l'échelle et en continu. C'est dans ce cadre que notre système a été conçu.

Cette plateforme centralise *l'analyse automatique des commentaires clients* issus des réseaux sociaux principalement *Facebook* , *Twitter*, et *Instagram* ,en articulant trois couches technologiques : *l'intelligence artificielle.*,*le traitement du langage naturel (NLP).*,*des visualisations interactives pilotées par données.*,
Trois composantes, donc, dont l'intégration cohérente constitue la valeur architecturale centrale du projet.

Le socle technique repose sur le framework ***Plotly Dash***, développé intégralement en *Python*, avec *MongoDB* assurant à la fois le stockage documentaire et la recherche vectorielle. Nous observons que ce choix technologique conditionne directement les performances de requêtage lors des pics de trafic.

La plateforme orchestre l'ensemble du cycle de vie analytique : collecte des données brutes, traitement NLP, visualisation, détection d'anomalies, déclenchement d'alertes et génération de recommandations décisionnelles.

=== Présentation générale du système
#h(0.5cm)Le système adopte une architecture *multi-pages* dans laquelle chaque module fonctionnel opère comme une unité indépendante. Cette séparation des responsabilités facilite la maintenance et rend l'évolution incrémentale de chaque composant techniquement viable sans régression sur les autres modules.


#align(center)[
  #table(
    columns: (0.5fr, 1fr),
    align: (left, left),
    stroke: 1pt,
    fill: (_, row) => if row == 0 {} else if calc.odd(row) { luma(245) } else { none },

    [*Module*], [*Rôle principal*],
    [Tableau de Bord], [Vue synthétique des KPIs et indicateurs globaux],
    [Analytiques], [Analyse temporelle et événementielle approfondie],
    [Commentaires], [Exploration et filtrage des commentaires annotés],
    [Thèmes & Temporel], [Suivi des thèmes et détection d'anomalies],
    [ClienTel Pulse (Chatbot)], [Assistant conversationnel décisionnel IA],
    [Paramètres], [Configuration des seuils et alertes opérationnels],
    [Notifications], [Centralisation des alertes],
  )
]

#h(0.5cm)Le décalage horaire algérien (*UTC+1*) est appliqué nativement à l'ensemble des opérations temporelles. Ce choix délibéré dès la conception garantit la cohérence entre les horodatages des alertes et les horaires réels des agents terrain.


=== Authentification et sécurité des accès

#h(0.5cm)L'accès à la plateforme est contrôlé par un mécanisme d'authentification par session. Les mots de passe transitent par une fonction de hachage avant persistance en base, la session se détruit automatiquement à la fermeture du navigateur, les messages d'erreur restent volontairement formulés de manière générique, ne révélant pas l'existence ou l'inexistence d'un compte donné.


==== Page d'inscription

#h(0.5cm)La page d'inscription soumet la saisie de l'utilisateur à une validation complète des champs obligatoires : *prénom, nom, adresse e-mail, numéro de téléphone, wilaya de résidence*, mot de passe d'au moins huit caractères, confirmation de ce mot de passe, et acceptation explicite des conditions d'utilisation.



#figure(
  rect(
    fill: rgb("#e3f2fd"),
    radius: 1pt,
    stroke: rgb("#062abb"),
    image("../images/page_inscrire.png", width: 15cm),
  ),
  caption: [ Page d'inscription à la plateforme AT.],
) <fig:inscription>



==== Page de connexion
#h(0.5cm)Le formulaire de connexion réduit l'interaction à l'essentiel : deux champs (*adresse e-mail* et *mot de passe*) et un bouton d'action. Simple. Toute erreur d'authentification génère un message délibérément imprécis, conforme aux bonnes pratiques de sécurité contre l'énumération de comptes. Un lien de redirection vers la page d'inscription est proposé aux nouveaux utilisateurs. La partie gauche de l'écran rappelle les trois fonctionnalités structurantes du tableau de bord : *surveillance réseau en temps réel*, *gestion complète des clients*, *rapports analytiques avancés*.


#figure(
  rect(
    fill: rgb("#e3f2fd"),

    radius: 0.5pt,
    stroke: rgb("#062abb"),
    image("../images/page_cnx.png", width: 15cm),
  ),
  caption: [ Page de connexion à la plateforme AT.],
) <fig:connexion>




=== Tableau de bord principal

#h(0.5cm)Le tableau de bord constitue le point d'entrée analytique de la plateforme. Il agrège l'ensemble des *indicateurs* de satisfaction client issus des réseaux sociaux et les restitue sous une forme synthétique permettant une lecture décisionnelle immédiate sans nécessiter de navigation vers des sous-modules.

#figure(
  rect(
    fill: rgb("#e3f2fd"),

    radius: 2pt,
    stroke: rgb("#062abb"),

    image("../images/page_dashbored.png", width: 15cm),
  ),

  caption: [Tableau de bord Satisfaction Client (vue globale).],
) <fig:tableau_de_bord>


==== Indicateurs clés de performance (KPIs)
#h(0.5cm)Cinq indicateurs disposés en grille horizontale constituent la zone d'information prioritaire. Chaque indicateur intègre une icône sémantique, une valeur principale en grand format, une pastille de variation comparative par rapport à la période précédente, et une infobulle contextuelle accessible au survol.


#align(center)[
  #figure(
    table(
      columns: (auto, auto, 1fr),
      align: (left, left, left),
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },

      [*Indicateur*], [*Valeur actuelle*], [*Description*],
      [Total commentaires], [24 043], [Couverture d'écoute client sur la période complète (Nov. 2025 – Jan. 2026)],
      [Score sentiment moyen], [–0,62], [Score agrégé sur [-1, +1]. Seuil de satisfaction fixé à –0,2],
      [Taux négatif global], [76,5 \%], [Proportion de commentaires négatifs sur l'ensemble de la période],
      [Taux négatif aujourd'hui],
      [0,0 \%],
      [Détection des crises émergentes : vert < 40\%, orange 40-60\%, rouge > 60\%],

      [Frustrations détectées], [1 153], [Volume de commentaires à forte charge émotionnelle négative (4,8\%)],
    ),
    caption: [Indicateurs clés du tableau de bord satisfaction client],
  kind: table,
  )
]

#h(0.5cm)Les pastilles directionnelles encodent l'évolution selon une convention asymétrique volontaire : une baisse du taux négatif déclenche une flèche verte (amélioration), tandis qu'une baisse du score de satisfaction active une flèche rouge (dégradation).

Ce codage asymétrique reflète la logique métier réelle,les deux indicateurs évoluent dans des directions sémantiquement inverses. La comparaison mensuelle ne s'active que lorsque deux périodes sont disponibles en base, évitant ainsi d'afficher des variations statistiquement non significatives.

=== Répartition des sentiments
#h(0.5cm) Un diagramme en anneau décompose les 24 043 commentaires en trois classes de sentiment : négatif (18 393), positif (1 118) et neutre (4 532). La zone centrale affiche en surimpression le taux négatif global (76,5 %) en rouge grand format, accompagné du score moyen (-0,82) dont la teinte varie selon sa valeur. Ce choix de surimpression réduit la distance cognitive entre le graphique et sa métrique principale.
==== Comparaison mensuelle
#h(0.5cm)La carte de comparaison mensuelle présente, pour chaque mois disponible, le volume total de commentaires, le score sentiment avec sa variation par rapport au mois précédent, le taux négatif et le taux de satisfaction positif. Le mois le plus récent est visuellement mis en évidence. Les variations sont codifiées par des flèches directionnelles colorées.
==== Évolution temporelle du sentiment
#h(0.5cm) Un graphique bi-axes combine deux représentations sur un axe temporel mensuel : *l'axe primaire* trace l'évolution du score moyen assorti d'une ligne de référence à 0, frontière entre registre négatif et neutre, tandis que *l'axe secondaire* encode le volume de commentaires par barres verticales.

Nous notons que la superposition de ces deux séries permet d'identifier visuellement les mois où un pic de volume coïncide avec une dégradation du sentiment, situation caractéristique d'une crise réseau étendue. Un fond semi-transparent rouge balise les périodes de dégradation, éliminant la nécessité d'une lecture exhaustive des valeurs numériques.

==== Thèmes détectés et répartition linguistique
#h(0.5cm)Un histogramme horizontal présente les cinq thèmes d'insatisfaction les plus fréquents. La longueur de chaque barre encode le volume total ,l'infobulle associée expose simultanément le volume absolu et le taux négatif propre au thème. Un histogramme vertical décompose les langues détectées : Arabe Darija, Français, Arabe Classique avec annotation externe des volumes et pourcentages. En bas de page, une barre de progression traduit le score de santé global de la relation client en une valeur unique lisible d'un coup d'œil.







=== Analyse temporelle et événementielle


#h(0.5cm)La page Analytiques croise les données de satisfaction avec des événements documentés survenus chez Algérie Télécom. Elle couvre 19 tranches horaires et 15 semaines analysées, avec un indicateur « Temps réel » actif


#figure(
  rect(
    fill: rgb("#e3f2fd"),

    radius: 2pt,
    stroke: rgb("#062abb"),
    image("../images/page_anlytique.png", width: 15cm),
  ),
  caption: [Page d'Analyse Temporelle avec impact des événements],
) <fig:page_analytique>

Quatre indicateurs synthétiques apparaissent en haut de page :
#align(center)[
  #figure(
    table(
      columns: (1fr, 1fr, 1fr),
      align: (left, center, left),
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },

      [*Indicateur*], [*Valeur*], [*Précision*],
      [Semaine difficile], [2025-S01], [Score moyen : –0,67],
      [Semaine positive], [2025-S44], [Score moyen : –0,48],
      [Heure critique], [6h00], [Score moyen : –0,83 (orange)],
      [Heure favorable], [7h00], [Score moyen : –0,63 (vert)],
      [Tendance générale], [Stable], [–0,0065 / semaine],
    ),
    caption: [Indicateurs synthétiques du tableau de bord],
  kind: table,
  )
]

La section « Impact des événements » quantifie l'effet de trois événements majeurs sur le score de sentiment, en comparant les valeurs relevées avant et après chaque événement :


#align(center)[
  #figure(
    table(
      columns: (auto, auto, auto),
      align: (left, center, left),
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },

      [*Événement*], [*Date*], [*Impact sur le score*],
      [Panne réseau nationale], [2025-12-15], [–0,067 (interruption de service 4h, plusieurs wilayas)],
      [Nouvelle offre promotionnelle], [2025-12-05], [–0,011 (lancement offre Winter Data — doublement du volume)],
      [Mise à jour application mobile], [2025-11-20], [–0,005 (nouvelle version avec bugs signalés)],
    ),
    caption: [Événements majeurs et leur impact sur le score de satisfaction],
  kind: table,
  )
]

Ces écarts quantifiés méritent attention. La panne réseau du 15 décembre génère un impact six fois supérieur à celui de la mise à jour applicative,ce ratio confirme empiriquement la hiérarchie des sources d'insatisfaction et justifie la priorisation des interventions réseau dans les plans d'action. La partie inférieure de la page présente deux graphiques complémentaires : la répartition des avis par heure (barres empilées Insatisfaits/Satisfaits) et le volume de messages reçus par heure, permettant d'identifier les pics d'activité et les moments critiques de la journée.


La partie inférieure de la page s'articule autour de *quatre visualisations complémentaires*, chacune éclairant une dimension distincte du comportement temporel des clients.

- *Répartition des avis par heure.* Un histogramme empilé (Insatisfaits en rouge, Satisfaits en vert) distribue les commentaires sur 19 tranches horaires. Nous observons que le taux d'insatisfaction atteint son pic à 6h00 (92 %), puis se stabilise entre 72 % et 85 % sur le reste de la journée — le creux vert, bien que structurellement minoritaire, se concentre aux extrémités de la plage nocturne. Court. Mais révélateur : la nuit ne détend pas les frustrations.

- *Volume de messages reçus par heure.* Un histogramme simple encode le flux entrant par tranche horaire. Le volume est quasi nul entre 0h et 5h (41 messages à 0h), puis monte brusquement à partir de 6h pour atteindre des pics entre 1 500 et 2 175 messages sur la plage 6h–22h. Cette courbe d'activité conditionne directement le dimensionnement des équipes de modération.

- *Score de satisfaction par heure.* Une courbe temporelle trace l'évolution du score moyen sur l'axe [-1, +1]. Le score reste confiné entre -0,5 et -1 sur l'ensemble de la journée, avec un léger redressement observable autour de 6h–7h avant de replonger. Les points d'anomalie sont matérialisés par des marqueurs rouges, signalant les tranches où le score franchit le seuil de tolérance défini dans les paramètres système.

- *Évolution hebdomadaire.* Un tableau récapitulatif liste les semaines analysées avec, pour chacune, le score moyen, le taux négatif et le volume de commentaires. Les données couvrent les semaines 2025-S49 à 2026-S05 ; le taux négatif oscille entre 60,9 % (semaine 2026-S03) et 82,1 % (semaine 2026-S02), traduisant une variabilité hebdomadaire réelle que les seuls indicateurs mensuels masqueraient.



=== Exploration des commentaires clients
#h(0.5cm) La page « Commentaires Clients » donne accès à l'intégralité des 24 043 commentaires stockés dans MongoDB. Les équipes qualité et relation client peuvent les filtrer, les explorer et les exporter selon neuf dimensions indépendante

#figure(
  rect(
    fill: rgb("#e3f2fd"),

    radius: 2pt,
    stroke: rgb("#062abb"),
    image("../images/page_commentaire.png", width: 15cm),
  ),
  caption: [Page d'exploration des commentaires clients annotés],
) <fig:page_commentaire>

#h(0.5cm)Le tableau des résultats est paginé (25, 50, 100 ou 200 lignes par page) et restitue pour chaque entrée : date et heure, texte du commentaire, sentiment détecté (Négatif / Positif / Neutre), score NLP, thème associé, source, langue, niveau de frustration, statut de modération et bouton « Voir ».
#h(0.5cm) Un clic sur ce bouton ouvre une fiche modale exposant l'intégralité du commentaire et l'ensemble de ses métadonnées NLP.



#figure(
  rect(
    fill: rgb("#e3f2fd"),

    radius: 2pt,
    stroke: rgb("#062abb"),
    image("../images/page_voir_commentaire.png", width: 15cm),
  ),
  caption: [Page Détail du commentaire clients annotés],
) <fig:page_commentaire>




#h(0.5cm) Le bouton « Exporter CSV » déclenche le téléchargement de tous les commentaires correspondant aux filtres actifs sans limitation de volume.


=== Thèmes et analyse temporelle approfondie

#h(0.5cm)La page *« Thèmes & Analyse Temporelle » * répond à deux questions opérationnelles : quels sujets concentrent le plus d'insatisfaction, et quels mois ont enregistré les dégradations les plus sévères ? Elle intègre un mécanisme de détection automatique des anomalies statistiques



#figure(
  rect(
    fill: rgb("#e3f2fd"),

    radius: 2pt,
    stroke: rgb("#062abb"),
    image("../images/page_theme.png", width: 15cm),
  ),
  caption: [Page Thèmes & Analyse Temporelle avec détection d'anomalies],
) <fig:page_theme>

Six sections structurent cette page :

- *Évolution mensuelle par thème* : Un graphique linéaire multi-courbes trace la trajectoire de chaque thème — Service Clientèle, Information Générale, Hors Sujet, Réseau Technique, Installation Équipement, Facturation Tarifs — sur l'ensemble de la période analysée. La comparaison visuelle des courbes révèle les thèmes à dynamique dégradante versus ceux qui se stabilisent.
- *Détection des anomalies* : Le graphique de score temporel intègre une zone de tolérance grisée calculée à partir des écarts-types de la série. Lorsqu'aucun point ne franchit les bornes de cette zone, une bannière verte « Aucune anomalie détectée » confirme la stabilité du système. Ce mécanisme évite aux opérateurs de scruter manuellement des séries temporelles denses.
- *Taux d'insatisfaction par sous-thème* : Un histogramme horizontal présente les taux par catégorie : Absence Service (97 %), Problème Technique (94 %), Délai Installation (91 %), Autre (88 %), Facturation Offre (76 %), Service Client (69 %), Demande Amélioration (61 %), Social Non Pertinent (49 %), Demande Information (15 %), Satisfaction Positive (11 %). Nous observons que les deux premières catégories cumulent des taux dépassant 90 %, ce qui indique une insatisfaction structurelle — non conjoncturelle — sur les dimensions de disponibilité et de fiabilité réseau.
- *Sujets les plus abordés.* : Le classement priorisé des thèmes confronte volume, taux d'insatisfaction et niveau de criticité : Réseau Technique (9 092 messages, 95,1 % insatisfaits — Critique), Hors Sujet (4 993 messages, 79,4 % insatisfaits — Critique), Information Générale (2 293 messages, 14,7 % insatisfaits — Normal).
- *Répartition des raisons* : Un diagramme en anneau décompose les 23 521 messages détectés selon leur raison principale. Problème Technique domine avec 23,7 % du volume total, suivi d'Autre (16,7 %), Absence Service (15 %), Demande Information (9,75 %), Service Client (8,63 %), Délai Installation (8,52 %), Facturation Offre (7,64 %), Social Non Pertinent (4,53 %), Demande Amélioration (4,18 %) et Satisfaction Positive (1,4 %). Nous retenons que les trois premières catégories — Problème Technique, Autre et Absence Service — concentrent à elles seules près de 55 % de l'ensemble des raisons détectées, ce qui confirme empiriquement la prédominance des défaillances réseau dans le corpus analysé. La visualisation en anneau permet une lecture proportionnelle immédiate, sans nécessiter de parcourir une liste de valeurs brutes.

- *Vocabulaire clients* : Un nuage de mots synthétise les termes les plus fréquents extraits automatiquement des commentaires.
  Les mots dominants : *fibre*, *optique*, *internet*, *الانترنت*, *اتصالات* , tracent sans ambiguïté le champ sémantique central des préoccupations clients : la connectivité haut débit et l'accès à la fibre optique. Termes arabes et français coexistent dans le nuage, reflétant la réalité multilingue du corpus (Arabe Darija, Français, Arabe Classique). La taille de chaque mot encode sa fréquence d'apparition ; les mots périphériques plus petits : *adsl*, *modem*, *idoom* , permettent de qualifier secondairement les technologies et services concernés.

=== Assistant conversationnel ClienTel Pulse
#h(0.5cm)ClienTel Pulse est l'assistant conversationnel décisionnel intégré à la plateforme. Il permet aux équipes de formuler des questions en langage naturel sur les données de satisfaction client et d'obtenir en retour des synthèses opérationnelles, des recommandations d'action et des projections de scénarios.






#figure(
  rect(
    fill: rgb("#e3f2fd"),

    radius: 2pt,
    stroke: rgb("#062abb"),
    image("../images/page_charbot.png", width: 15cm),
  ),
  caption: [ Interface de l'assistant conversationnel ClienTel Pulse],
) <fig:page_theme>




==== Architecture et intentions reconnues
#h(0.5cm)L'assistant repose sur une architecture à trois niveaux qui traite séquentiellement chaque requête entrante. Le premier niveau *compréhension du langage naturel (NLU)* extrait l'intention et les filtres sémantiques de la question. Le deuxième aiguille vers le *module de réponse adapté*. Le troisième génère *la réponse via le modèle Groq LLaMA 3.3* ou, pour les cas structurés, via *un moteur de règles métier déterministe*.



#align(center)[
  #figure(
    table(
      columns: (0.5fr, 1fr),
      align: (left, left),
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },

      [*Intention*], [*Description*],
      [Analyse globale], [Synthèse des indicateurs de satisfaction],
      [Aide contextuelle], [Explication des fonctionnalités du système],
      [Analyse commentaire], [Évaluation d'un commentaire soumis par l'agent],
      [Recommandations], [Actions correctives selon les seuils dépassés],
      [Détection d'alertes], [Identification des crises en cours],
      [Tendances temporelles], [Évolution du sentiment dans le temps],
      [Simulations what-if], [Projection de scénarios d'amélioration],
      [Rapport manager], [Génération d'un rapport synthétique],
      [Benchmark S vs M], [Comparaison semaine vs mois],
      [Discussion générale], [Recherche augmentée (RAG) sur la base de données],
    ),
    caption: [Intentions du chatbot ClienTel Pulse et leurs descriptions],
  kind: table,
  )
]

==== Recherche augmentée par similarité sémantique (RAG)
#h(0.5cm)Lorsqu'une question ne correspond à aucune intention répertoriée, le système active le module RAG. La question est convertie en vecteur numérique ; MongoDB identifie alors les cinq commentaires dont la représentation vectorielle présente la similarité cosinus la plus élevée avec la requête. Ces commentaires sont transmis comme contexte au modèle de langage, qui génère une réponse synthétique ancrée dans des données réelles. Les sources sont affichées à l'utilisateur garantissant traçabilité et vérifiabilité de chaque réponse produite.



==== Moteur de recommandations et simulation de scénarios
#h(0.5cm)Le module de recommandations applique des règles métier déclenchées automatiquement lorsque des seuils prédéfinis sont franchis :

#align(center)[
  #figure(
    table(
      columns: (auto, auto, auto),
      align: (left, center, left),
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },

      [*Condition*], [*Niveau*], [*Action recommandée*],
      [Taux négatif > 50\%], [Critique], [Cellule de crise — action sous 48 heures],
      [Taux négatif entre 35 et 50\%], [Élevé], [Analyse par source et thème — sous 1 semaine],
      [Frustration > 40\%], [Critique], [Réponse prioritaire < 2h + formation des agents],
      [Demandes sans réponse > 15\%], [Élevé], [Activation d'un bot de réponse automatique],
    ),
    caption: [Seuils d'alerte et actions recommandées],
  kind: table,
  )
]

#h(0.5cm)Trois scénarios de simulation sont préconfigurés : répondre à toutes les demandes sous quatre heures, réduire les pannes réseau de 50 %, et former les agents à la gestion des frustrations. Pour chaque scénario, le système calcule la réduction estimée du taux négatif, le gain de satisfaction attendu et le niveau d'effort requis. Ce couplage simulation–effort est ce qui distingue le module d'un simple tableau de bord passif.



=== Système d'alertes et notifications
#h(0.5cm)Le système d'alertes surveille la plateforme en continu et déclenche des notifications selon un protocole à deux conditions cumulatives :

- Le taux négatif des dernières 24 heures dépasse le seuil configurable (60 % par défaut).
- Le volume absolu de commentaires négatifs excède 30 messages.



#figure(
  rect(
    fill: rgb("#e3f2fd"),

    radius: 2pt,
    stroke: rgb("#062abb"),
    image("../images/capture_alarme.png", width: 15cm),
  ),
  caption: [capture d'ecran de l'alerte],
) <fig:capture_alarme>


La fenêtre modale d'alerte complète s'organise en quatre sections :

- *Contexte calculé par le système*:

  - Variation par rapport aux 24 heures précédentes.

  - Heure du pic de négativité.

  - Thèmes associés.

  - Plateforme source principale.

- *Niveaux de signalement*:

  - Bannière rouge (en haut de page) : les deux conditions sont actives.

  - Bannière orange d’avertissement : une seule condition est vérifiée.

- * Alerte pleine *(fenêtre modale) – diagnostic structuré en quatre sections:

  - Indicateurs numériques clés.

  - Thèmes en crise (avec volumes et sources).

  - Répartition des plateformes (barres de progression).

  - Horodatage de l’analyse.

- *Notification supplémentaire*:

  - Alerte sonore : notifie les équipes même lorsque le tableau de bord n’est pas au premier plan.



#figure(
  rect(
    fill: rgb("#e3f2fd"),

    radius: 2pt,
    stroke: rgb("#062abb"),
    image("../images/page_modal_alarme.png", width: 15cm),
  ),
  caption: [La fenêtre modale d'alerte complète
  ],
) <fig:capture_alarme>

=== Historique des alertes et notifications

La zone inférieure du tableau de bord expose un historique paginé — jusqu'à 30 entrées sur les 30 derniers jours — où chaque entrée documente l'horodatage précis du pic et de l'arrêt, le thème impliqué, la source plateforme, le taux moyen, le volume de messages négatifs et le statut.

Deux statuts sont possibles. *Terminée* signale une alerte résolue ; une alerte sans ce marqueur reste active et exige un suivi. À titre d'illustration, les deux entrées enregistrées ci-dessous ont été produites en abaissant temporairement les seuils de déclenchement, afin de démontrer le fonctionnement du mécanisme d'enregistrement :

#align(center)[
  #figure(
    table(
      columns: (auto, auto, auto, auto, auto, auto),
      align: (left, left, left, center, center, center),
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },

      [*Date*], [*Pic → Arrêt*], [*Thème*], [*Taux moy.*], [*Volume*], [*Statut*],
      [11/05/2026], [14h25 → 14h31], [Service Client], [50,3 %], [80 msgs], [Terminée],
      [10/05/2026], [00h16 → 00h31], [Réseau Technique], [50,0 %], [80 msgs], [Terminée],
    ),
    caption: [Extrait de l'historique des alertes — entrées de démonstration],
  kind: table,
  )
]






#block(
  stroke: (left: 4pt + rgb("#dc2626")), // Bordure gauche rouge
  inset: 12pt,
  fill: rgb("#fef2f2"), // Fond rouge très clair
  radius: 4pt,
  width: 100%,
  [
    #align(left)[
      #text(fill: rgb("#dc2626"), weight: "bold", size: 11pt)[*Remarque :*]
    ]

    #align(left)[
      Ces deux alertes ont été déclenchées avec des seuils abaissés à 20 % (taux négatif) et 5 messages (volume) uniquement pour illustrer le fonctionnement du mécanisme d'enregistrement dans la zone historique.

      Les seuils opérationnels réels du système sont fixés à *60 % de taux négatif* et *30 messages négatifs minimum* sur les dernières 24 heures.
    ]
  ],
)


Un rafraîchissement automatique toutes les cinq minutes maintient la cohérence des indicateurs durée suffisante pour des crises dont la durée moyenne dépasse cette fenêtre. Un bouton d'actualisation manuelle permet les mises à jour immédiates lorsque la situation l'exige.

#figure(
  rect(
    fill: rgb("#e3f2fd"),
    radius: 2pt,
    stroke: rgb("#062abb"),
    image("../images/page_zone_historique.png", width: 15cm),
  ),
  caption: [Zone historique des alertes — tableau de bord principal],
) <fig:capture_historique>


La page *Notifications* opère comme un centre de contrôle unifié : elle agrège en un seul espace l'ensemble des alertes, rapports et avis système générés par la plateforme, sans forcer l'opérateur à naviguer entre modules. Trois types de notifications coexistent, chacun portant un badge coloré identifiant sa catégorie.


Les notifications non lues s'affichent avec un fond coloré et un point rouge en marge droite. Le compteur global figure sur l'icône de cloche dans le bandeau supérieur ; en cas d'alertes critiques actives, ce compteur bascule sur un point d'exclamation « ! ».

Les boutons *Rafraîchir* et *Tout marquer comme lu* permettent respectivement de synchroniser l'état en temps réel et de purger visuellement la file d'attente.

#figure(
  rect(
    fill: rgb("#e3f2fd"),
    radius: 2pt,
    stroke: rgb("#062abb"),
    image("../images/page_notification.png", width: 15cm),
  ),
  caption: [Centre de Notifications],
) <fig:capture_notification>

=== Intégration temps réel
#h(0.5cm)La plateforme est conçue pour fonctionner en continu, 24h/24 et 7j/7, en synchronisation avec le pipeline de streaming de collecte des commentaires.

#h(0.5cm)Dès qu'un nouveau commentaire est traité et persisté dans MongoDB, les agrégations utilisées par les fonctions de données se recalculent automatiquement. Au prochain cycle d'actualisation ou après un rafraîchissement manuel, l'ensemble des visualisations reflète le nouvel état de la base. Ce couplage garantit une latence inférieure à la minute pour les indicateurs critiques d'alerte. Exigence opérationnelle non négociable dans un contexte de surveillance réseau en temps réel.

#align(center)[
  #figure(
    table(
      columns: (auto, auto, 1fr),
      align: (left, center, left),
      stroke: 1pt,
      fill: (_, row) => if row == 0 {} else if calc.odd(row) {} else { none },

      [*Composant*], [*Technologie*], [*Rôle*],
      [Interface web], [Plotly Dash (Python)], [Visualisations interactives multi-pages],
      [Base de données], [MongoDB], [Stockage des commentaires et recherche vectorielle],
      [NLP \& Sentiment], [DziriBERT + règles métier], [Classification et scoring des commentaires],
      [LLM], [Groq LLaMA 3.3], [Génération de réponses conversationnelles],
      [Streaming], [Pipeline temps réel], [Collecte et traitement des nouveaux commentaires],
      [Authentification], [Sessions sécurisées], [Hachage des mots de passe, session détruite à la fermeture],
      [Fuseau horaire], [UTC+1 (Algérie)], [Appliqué nativement à toutes les opérations temporelles],
    ),
    caption: [Synthèse des composants technologiques de la plateforme ClienTel],
  kind: table,
  )
]
















== Conclusion
#h(0.5cm) Les expérimentations conduites dans ce chapitre confirment que l'analyse automatique des sentiments en dialecte algérien est un problème résoluble, à condition d'aligner précisément les choix de prétraitement, de représentation et d'architecture de modèle sur les propriétés linguistiques spécifiques du corpus. DziriBERT, pré-entraîné sur la darija algérienne, y atteint les meilleures performances en classification, un résultat qui n'est pas surprenant mais qui valide empiriquement la pertinence du fine-tuning sur données domaine-spécifiques.

#h(0.5cm)Nous retenons plusieurs observations structurantes. La vectorisation hybride TF-IDF/flags améliore les modèles classiques de façon mesurable , les marqueurs de négation, préservés par règle explicite lors de la réduction dimensionnelle, contribuent effectivement à réduire les erreurs de polarité inversée. La chaîne temps réel Kafka, Spark, MongoDB, tableau de bord Dash maintient une latence inférieure à la minute pour les indicateurs critiques, ce qui satisfait l'exigence opérationnelle de surveillance 24h/24 fixée en amont.

#h(0.5cm) L'assistant ClienTel Pulse, combinant reconnaissance d'intention, récupération augmentée par similarité cosinus et règles métier à seuils configurables, offre un niveau d'interactivité analytique que les tableaux de bord statiques traditionnels n'atteignent pas.Ces résultats constituent une base solide pour les extensions envisagées.

