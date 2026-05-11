

// ====================================
// CHAPITRE 1 : Contexte du projet
// Fichier : chapitres/chapitre1.typ
// ====================================
#set par(justify: true)

= Contexte du projet et présentation du secteur télécom


== Introduction
#h(0.5cm) Ce premier chapitre établit le contexte organisationnel et métier du projet. Il débute par une présentation *d’Algérie Télécom*, acteur majeur du secteur, en exposant son historique, son organigramme, ainsi que son offre de services et sa stratégie digitale. Cette mise en perspective permet de situer l’environnement opérationnel du stage, dont nous détaillerons ensuite la structure d’accueil, ses missions et ses processus internes.

L’analyse se porte ensuite sur la problématique centrale : les limites de l’écoute client actuelle sur les réseaux sociaux face au volume et à la complexité linguistique des données (notamment en Darija). Après avoir identifié les impacts de ces contraintes sur la relation client, nous introduirons la solution technique proposée. Celle-ci vise à automatiser l’analyse des sentiments via le Big Data et l’IA, avec pour objectif d’optimiser la réactivité de l’entreprise et la satisfaction des abonnés.
== Présentation de l'organisme d'accueil


=== Historique et cadre juridique


#h(0.5cm) L'émergence D'algérie télécoms s'intègre à une réforme structurelle majeure du secteur des postes et communications, formalisé par le décret n°2000-03 du 05 août 2000. Cette réforme legislative marque une étape décisive Dans la séparation entre les activités postale et les activités de télécommunications ce qui a permis à des entité spéciale de naître. The institutionally Sa naissance institutionnelle a été officiellement consacrée par la décision du Conseil National De Participa tion de l’État (CNPE) le 1er mars 2001, dotant l'entreprise du statut d'Entreprise Publique Économique (EPE).

Algéria télécom a été constituée Dans la forme juridique d'une société par action (spa) à capitaux publics avec Un Capital Social De 115 milliards de dinars, elle bénéficie d'une Autonomie De gestion tout en restant sous la Tutelle De L'état. Bien que son cadre opérationnel ait été établi dès le 1er janvier 2003, le lancement effectif de ses acti vités commerciales a Eu Lieu Le 10 avril 2003.

À ses débuts, l'entreprise faisait face à Un défi De Taille avec Un réseau ne cou vrant qu'environ 6 % de la population. Depuis LorS, sa stratégie est construite autour De Trois piliers essentiels: la rentabilité économique, l'efficacité opérationnel et l'excellence en qualité de service. Aujourd'hui, Algérie Télécom s'impose comme L'acteur clé Des Technologies De L' Information Et De La Communication (TIC) en Algérie, dominant les Marchés De La téléphonie fixe et de l'accès Internet.@Lahmar2023.

*- Adresse du siège social :* Route Nationale n° 5, Cinq Maisons, Mohammedia, Algérie @ATPresentation2023.



*- Identité visuelle – Logo *
\
// Logo Algérie Télécom en haut à droite
#align(center)[
  #figure(
    block(
      stroke: 0pt + black,
      image("../images/Logo_Algérie_Télécom.svg", width: 6cm)
    ),
    caption: [Logo d'Algérie Télécom .],
    kind: image
  )
]
#v(0.5cm)
=== Chiffres clés et positionnement sur le marché
#h(0.5cm) Leader historique du secteur, Algérie Télécom dispose d’une infrastructure commerciale et technique couvrant l’ensemble du territoire national. Le réseau de l’entreprise s’appuie sur plus de *500 agences commerciales*, dont la majorité est labellisée *Fi Khidmatkoum*, garantissant une proximité physique avec la clientèle. Cette présence terrain est soutenue par une force de travail significative, le Groupe Télécom Algérie employant environ *25 000 collaborateurs*. @ATHistorique2023.

En termes de parts de marché, l’opérateur maintient sa dominance dans les segments fixes et haut débit. Les indicateurs récents (2023) témoignent de cette prépondérance :

- *Clientèle Internet *: Plus de 6,8 millions d’abonnés au total.
 @ATPresentation2023. 
- *Fibre Optique (FTTH) *: 2,9 millions de foyers connectés, reflétant l’accélération du déploiement du très haut débit. @ATPresentation2023. 
- *ADSL/VDSL :* 2 millions d’abonnés, constituant le socle historique de l’offre internet. @ATPresentation2023. 
- *4G Fixe (Idoom 4G) *: 2 millions d’utilisateurs, répondant aux besoins en mobilité et aux zones non éligibles à la fibre.
 @ATPresentation2023. 

Cette base installée massive place Algérie Télécom en position de force pour capter les flux de données sociaux, justifiant ainsi la nécessité d’outils analytiques performants pour gérer la relation client à cette échelle.

=== Mission, vision et valeurs

#h(0.5cm) Les missions stratégiques de l’Algérie Télécom sont organisées autour de quelques axes essentiels : 

- *Offre des services de télécommunications *: Transporter et échanger la voix, le texte, les données informatiques et les services audiovisuels en se souciant de leur qualité, sécurité et accessibilité sur l’ensemble du territoire.
- *Construction et exploitation d'infrastructures* : concevoir, construire, exploiter et entretenir les réseaux publics et privés de télécommunications, en s'appuyant sur une démarche continue de modernisation pour faire face aux nouveaux usages.
- *Interconnexion et coopération*: négocier et mettre en œuvre les interconnexions techniques et commerciales avec les autres fournisseurs au niveau national et international conformément aux règlements.
- *Affaires étrangères et logistique *: Gérer le commerce extérieur (achats, paiements, logistique interface export / import) et assumer les risques correspondants (financiers, réglementaires) afin de garantir un approvisionnement constant en équipements et en technologies.
Ces missions s’inscrivent dans une logique globale dont le point d’orgue est de positionner Algérie Télécom en levier d’une société algérienne connectée.
Cette ambition se construit à partir des valeurs :
- L’innovation technologique pour anticiper les évolutions du marché.
- L’inclusion numérique pour démocratiser l’accès aux services pour tous.
- L’excellence opérationnelle et la satisfaction client comme priorité absolue. 

=== Structure organisationnelle et filiales du groupe

#h(0.5cm) Afin d’optimiser la gouvernance et de renforcer sa compétitivité, le secteur des télécommunications en Algérie a connu une restructuration majeure avec la création du Groupe Télécom Algérie en novembre 2017. Cette holding publique, organisée sous forme de Société Par Actions (SPA), a pour mission de piloter, coordonner et harmoniser les stratégies des différentes entités opérant dans le secteur, sous la direction de son Président-Directeur Général.

Algérie Télécom s’inscrit dans cet écosystème intégré, qui repose sur une spécialisation complémentaire de ses filiales :

- *Algérie Télécom :* L’opérateur historique, leader sur les marchés de la téléphonie fixe, de l’internet haut débit (ADSL, Fibre Optique) et des solutions pour les entreprises.
- *Mobilis (Algérie Télécom Mobile) :* La filiale dédiée aux services de téléphonie mobile et à l’internet sans fil, comptant parmi les plus grands réseaux mobiles du pays.
- * Algérie Télécom Satellite (ATS) *: Spécialisée dans la gestion des infrastructures satellitaires et des câbles sous-marins internationaux (comme ORVAL/ALVAL), assurant la connectivité internationale de l’Algérie.
- * COMINATAL SPA :* Entité chargée du déploiement, de la maintenance et de l’exploitation des réseaux de fibre optique, jouant un rôle clé dans le plan national de très haut débit.
- *SATICOM SPA : *Filiale orientée vers les solutions technologiques avancées, l’intégration de systèmes et les services à valeur ajoutée pour les professionnels et les grandes entreprises.

Cette structure en groupe permet une synergie forte entre les infrastructures fixes, mobiles et internationales. \
L’organisation hiérarchique et fonctionnelle est synthétisée dans l’organigramme ci-dessous :


\
// Logo Algérie Télécom en haut à droite
#align(center)[
  #figure(
    block(
      stroke: 0pt + black,
      image("../images/organigramme_telecon.png", width: 15cm)
    ),
    caption: [Organigramme d’Algérie Télécom],
  kind: image
  )
]




=== Portefeuille de produits et services

#h(0.5cm) L’offre d’Algérie Télécom répond à tous les besoins en termes de connectivité, autour de trois grands volets :

- * Téléphonie Fixe et Internet :* Activité principale de l’opérateur avec le service ADSL/VDSL en couverture large et le service Fibre Optique (FTTH) en très haut débit. La gamme comprend par ailleurs la 4G Fixe (Idoom 4G) pour les régions peu voisines.
- * Solutions Convergentes :* Packs téléphone + internet + TV (Idoom TV), pour une expérience unifiée & simplifiée.
- *Offres Entreprises (B2B) :* Liaisons spécialisées, cloud, cybersécurité et hébergement, services avancés répondant aux besoins des professionnels et des grandes entreprises.

Cette variabilité permet à l’opérateur de couvrir la transformation numérique de tous les types de clients, des particuliers aux très grandes sociétés. 



=== Présence sur les réseaux sociaux

#h(0.5cm) Algérie Télécom a mis en place une stratégie multicanale pour améliorer la proximité avec ses clients et moderniser son service apres-vente. L’opérateur est présent sur les grandes plateformes sociales qui ont toutes un rôle à jouer :

- *Facebook et Instagram* sont essentiellement dédiées au support client et à la relation quotidienne
- *LinkedIn* est la plateforme dans la communication institutionnelle et professionnelle. \
- *Les supports vidéos comme YouTube et TikTok* sont utilisés pour organiser des tutoriels et ainsi rejoindre une audience jeune.

Cette omniprésence digitale entraîne un flux permanent d’avis clients, faisant des réseaux sociaux une importante source de données pour l’écoute et l’amélioration continue des services. 
@ATReseaux2023.





== Cadre du stage : Département et Service d’accueil

=== Rôle et responsabilités du département

Ce projet de fin d’études a été réalisé au sein de la *Division des Systèmes d’Information (DSI)*, et plus spécifiquement au sein de la *Direction du Développement des Systèmes d’Information*. Cette direction joue un rôle transversal stratégique en concevant, développant et maintenant les solutions logicielles qui soutiennent les métiers d’Algérie Télécom.

L’organigramme ci-dessous illustre la position du service d’accueil au sein de la structure informatique de l’entreprise :

#align(center)[
  #figure(
    block(
      stroke: 0pt + black,
      image("../images/organigramme_division.png", width: 15cm)
    ),
    caption: [Organigramme de la Division des Systèmes d’Information],
  kind: image
  )
]

*La mission principale* de cette direction est d’assurer l’alignement entre les besoins opérationnels des métiers (comme la Relation Client) et les solutions technologiques mises en œuvre.

Dans ce contexte, notre service a pour responsabilité de proposer des *architectures innovantes *capables de traiter des volumes massifs de données, afin d’améliorer l’efficacité des processus internes et la qualité de service offerte aux abonnés.

=== Activités et processus du service

Le service intervient comme maître d’œuvre technique sur les projets de transformation digitale. Le déroulement type d’un projet, tel que celui qui nous a été confié, suit les étapes clés suivantes :

1. *Analyse des besoins :* Identification des lacunes des systèmes existants et définition des spécifications fonctionnelles et techniques en collaboration avec les équipes métier.
2. *Conception architecturale :* Choix des technologies (Big Data, IA, Cloud) et modélisation des flux de données pour garantir scalabilité et performance.
3. *Développement et Intégration :* Implémentation des modules logiciels, configuration des pipelines de données (ETL) et intégration des modèles d’intelligence artificielle.
4. *Tests et Validation :* Vérification de la cohérence des résultats, tests de charge et validation de la précision des algorithmes d’analyse.
5. *Déploiement et Maintenance :* Mise en production de la solution et suivi continu des performances pour assurer la stabilité du service.

C’est dans ce cadre rigoureux que s’inscrit notre travail, visant à doter l’entreprise d’un outil d’analyse automatisée des sentiments clients sur les réseaux sociaux.


== Étude de la problématique métier

La digitalisation transforme la relation client en opportunité stratégique décisive. Elle soumet Algérie Télécom à des contraintes opérationnelles extrêmes issues des flux sociaux dévorants. L'audit de l'existant met au jour des freins structurels qui étouffent toute réactivité.

=== Complexité et volume des données
Le premier défi réside dans l’hétérogénéité et le volume massif des données générées. Avec une présence active sur multiple plateformes (Facebook, Instagram, LinkedIn, TikTok, etc.), l’entreprise fait face à un flux continu de commentaires et de messages privés. Cette diversité multicanale s’accompagne d’une complexité linguistique notable : les interactions sont rédigées dans un mélange de langues (arabe standard, français) et de dialectes (darija algérien), utilisant parfois des caractères latins ou arabes de manière interchangeable. Cette variabilité rend l’analyse automatique traditionnelle inefficace, nécessitant une intervention humaine lourde pour la qualification et le tri des sollicitations.
=== Limites des processus actuels
Actuellement, le traitement de ces retours repose majoritairement sur des méthodes manuelles ou semi-automatisées, ce qui engendre plusieurs dysfonctionnements :

- *Saturation opérationnelle :* Le volume de données dépasse la capacité de traitement manuel des équipes, entraînant des délais de réponse allongés et un risque accru de non-prise en compte de certaines réclamations.
- Absence d’analyse stratégique : Faute d’outils dédiés, il est difficile d’extraire automatiquement les thèmes récurrents, de mesurer le sentiment global (positif/négatif/neutre) ou de détecter en temps réel les pics d’insatisfaction liés à des incidents techniques ou commerciaux.
- Manque de centralisation : La dispersion des données sur plusieurs plateformes empêche une vision unifiée et consolidée de la satisfaction client.
=== Impact sur la relation client et l’image de marque
Ces limitations ont des conséquences directes sur la performance de l’entreprise. Les délais de traitement et le manque de personnalisation des réponses génèrent de la frustration chez les abonnés, dont les attentes en matière de réactivité digitale sont élevées. De plus, la visibilité publique des échanges négatifs peut altérer l’image de marque d’Algérie Télécom. Enfin, l’absence d’exploitation systématique de ces données prive l’entreprise d’un levier stratégique majeur : la transformation des retours clients en insights actionnables pour l’amélioration continue des services et l’innovation.

=== Besoins identifiés

Pour répondre à ces enjeux, il apparaît nécessaire de mettre en place une solution technique capable de :
- Centraliser et structurer les flux de données issus des différents réseaux sociaux.
- Automatiser le prétraitement linguistique, notamment pour la normalisation et l’analyse du darija et de l’arabe dialectal.
- Analyser intelligemment le contenu via le NLP (détection de sentiment, extraction de thèmes).
- Visualiser les indicateurs clés through un tableau de bord interactif, permettant un suivi temporel de la satisfaction et une aide à la décision pour les responsables métier.

== Présentation de la solution proposée

#h(0.5cm)Pour pallier les limites du traitement manuel et exploiter le potentiel des données sociales, nous proposons le développement d’une plateforme d’analyse intelligente de la relation client. Cette solution ne se contente pas de centraliser les messages ; elle transforme des flux textuels non structurés en indicateurs stratégiques actionnables.

L’architecture repose sur trois piliers technologiques complémentaires :
- *Pipeline Big Data (ETL) : *Un système d’ingestion automatisé collecte les commentaires sur une période de trois mois des réseaux sociaux. Les données sont nettoyées, dédupliquées et stockées dans une base NoSQL (MongoDB) pour assurer scalabilité et flexibilité.
- *Moteur d’Analyse NLP spécialisé : *Au cœur du système, un modèle de langue (LLM) adapté au contexte algérien traite la spécificité linguistique. Par des techniques de fine-tuning sur des corpus en darija et arabe dialectal, le moteur effectue deux tâches majeures :
  -  *L’analyse de sentiment :* Classification automatique des interactions en positives, négatives ou neutres.
  - *L’extraction de thématiques :* Identification non supervisée des sujets récurrents (pannes, facturation, qualité de service) 

- *Interface de Visualisation Interactive :* Un tableau de bord (développé avec Streamlit ou Plotly Dash) restitue les résultats sous forme graphique. Il permet aux décideurs de filtrer les données par période, par plateforme ou par sentiment, et de corréler les pics d’insatisfaction avec des événements spécifiques.
Cette approche hybride, combinant la puissance de traitement du Big Data à la finesse sémantique de l’IA, offre une vision temps réel de la satisfaction abonné. Elle permet ainsi de passer d’une logique réactive (gestion de crise) à une logique proactive (amélioration continue).

=== Objectifs spécifiques du projet
La mise en œuvre de cette solution vise à atteindre sept objectifs techniques et fonctionnels précis :

- *Constitution d’un corpus de référence :* Rassembler et annoter trois ans de données historiques pour servir de base d’apprentissage et de validation.
- *Adaptation linguistique : *Optimiser la performance d’un modèle sur le darija, en mesurant le gain de précision par rapport aux modèles standards.
- *Précision classificatoire : *Atteindre un taux de précision supérieur à 85 % sur la détection de sentiment, validé par un jeu de test annoté manuellement.
- *Cartographie thématique : *Identifier automatiquement les principaux motifs de contact clients sans a priori, pour détecter les problèmes émergents.
- *Détection d’anomalies temporelles : *Repérer les variations brutales de sentiment pour alerter les équipes en cas d’incident majeur.
- *Expérience utilisateur métier : *Fournir une interface intuitive, accessible aux non-techniciens, pour l’exploration autonome des données.
- *Automatisation du flux : * Déployer un pipeline CI/CD capable d’intégrer les nouveaux commentaires quotidiennement sans intervention humaine.

== Conclusion
#h(0.5cm) Ce premier chapitre fixe le cadre contextuel et organisationnel du projet. L’analyse d’Algérie Télécom met au jour un paradoxe structurel : l’opérateur, leader technologique doté d’un réseau fibre et d’infrastructures convergentes, reste exposé à la complexité linguistique du darija et au volume massif des interactions sociales. Les flux de commentaires, mélange de langue arabe, de français et de codes numériques, échappent aux processus manuels et déclenchent une latence critique dans la prise de décision.

#h(0.5cm) Cette saturation engendre une latence préjudiciable, occulte les tendances émergentes et ouvre la porte à des risques réputationnels mal maîtrisés. Les équipes de relation client analysent des milliers de posts par jour, mais manquent des signaux faibles qui précèdent les crises de service. Face à cette double contrainte technique (données volumineuses, multilingues) et stratégique (image de marque, satisfaction client), la solution proposée dépasse la simple collecte de hashtags. Elle vise à structurer intelligemment les flux via une architecture Big Data intégrée à un moteur NLP adapté au darija, capable de transformer le bruit social en signaux décisionnels exploitables en temps réel.

Les objectifs fixés  précision classificatoire élevée (au‑delà de 85 %), automatisation complète du pipeline d’ingestion et de prétraitement, et visualisation temps réel intégrée dans un tableau de bord métier ,traduisent directement ce cahier des charges technique. Ces exigences guideront les choix d’implémentation dans les chapitres suivants, en particulier le choix de collecte, des modèles de langage fine‑tunés et de la plateforme de visualisation temps réel

#pagebreak()