

#set heading(numbering: none)
// ====================================
// INTRODUCTION GÉNÉRALE
// Fichier : chapitres/introduction_generale.typ
// ====================================

= Introduction générale


#h(0.5cm) La transformation numérique des entreprises de *télécommunications* ne se mesure plus à la densité de leur réseau ou à la vitesse de leurs connexions. Elle se lit désormais dans leur capacité à comprendre, en temps réel, ce que leurs abonnés expriment sur les plateformes sociales. Ce déplacement du lieu de la relation client des agences physiques vers *les espaces numériques* ouverts génère un flux textuel continu d'une richesse analytique considérable, mais d'une complexité algorithmique redoutable.

#h(0.5cm)*Algérie Télécom*, opérateur historique à capital public, doté d'un réseau dépassant 500 agences commerciales et servant plus de *6,8 millions* d'abonnés internet, se trouve confronté à un paradoxe structurel. L'entreprise dispose d'une infrastructure convergente de premier plan fibre optique FTTH déployée auprès de 2,9 millions de foyers, technologie 4G Fixe couvrant 2 millions d'utilisateurs mais ses outils d'écoute client restent en deçà des exigences que ce volume impose. Chaque jour, des milliers *des commentaires* transitent sur Facebook, Instagram, YouTube et TikTok, rédigés dans un mélange de darija algérien, de français familier et d'arabizi cette transcription de l'arabe en caractères latins qui échappe aux tokeniseurs conventionnels.

#h(0.5cm)Les processus actuels de traitement de ces retours reposent encore, pour l'essentiel, sur des méthodes manuelles ou semi-automatisées. La saturation des équipes de modération, l'absence d'extraction automatique des thèmes récurrents, la dispersion des données sur plusieurs canaux sans agrégation centralisée : ces lacunes produisent une latence décisionnelle qui fragilise à la fois la réactivité opérationnelle et l'image de marque de l'opérateur. Un *pic d'insatisfaction* lié à une panne réseau sur Alger Est reste invisible pendant des heures , des signaux faibles précurseurs de crises passent sous le seuil de détection.

#h(0.5cm)C'est dans ce contexte précis que s'inscrit le présent travail. Nous proposons la conception et l'implémentation d'une *plateforme intelligente d'analyse de sentiments*, fondée sur une architecture Big Data distribuée et un moteur de traitement du langage naturel adapté aux spécificités linguistiques du dialecte algérien. Le système articule trois niveaux complémentaires : un pipeline d'ingestion automatisé collectant les commentaires depuis les réseaux sociaux et les stockant dans une base MongoDB via un cluster Apache Spark orchestré par Docker , un module de *classification* des sentiments reposant sur *DziriBERT*, modèle Transformer pré-entraîné sur 1,1 million de tweets algériens, fine-tuné sur un corpus télécom de commentaires annotés , et un tableau de bord interactif développé sous Plotly Dash, offrant aux décideurs une lecture en quasi-temps réel des indicateurs de satisfaction, des thèmes d'insatisfaction et des alertes de crise.

#h(0.5cm)Dès lors, une question centrale se pose : << *Comment concevoir une plateforme intelligente capable d'analyser en temps réel les sentiments exprimés en dialecte algérien sur les réseaux sociaux, afin de transformer les retours clients d'Algérie Télécom en leviers décisionnels proactifs ? *>>. 

#h(0.5cm)Le présent mémoire s'organise en cinq chapitres successifs, articulant contexte institutionnel, revue de la littérature, fondements théoriques, conception technique et validation expérimentale. Le premier chapitre établit *le cadre organisationnel* du projet, en présentant Algérie Télécom, son positionnement marché et la problématique métier à laquelle répond la solution proposée. Le deuxième chapitre dresse *un état de l'art* des approches d'analyse de sentiments des méthodes lexico-règles aux architectures Transformer et contextualise les travaux existants sur le dialecte algérien, ses ressources disponibles et ses contraintes linguistiques spécifiques. Le troisième chapitre approfondit *les fondements théoriques* retenus : représentations vectorielles, métriques de similarité, sélection de features, mécanismes d'attention et techniques d'adaptation des grands modèles de langage. Le quatrième chapitre expose en détail la conception architecturale et l'implémentation du pipeline distribué, de la normalisation du darija et de l'arabizi jusqu'à l'interface de visualisation. Enfin, le cinquième chapitre présente *les expérimentations menées, les résultats obtenus et leur analyse critique*.

#h(0.5cm) Notre objectif central est démontrable : faire passer Algérie Télécom d'une posture réactive  *gestion de crise* après coup à une posture proactive, où les signaux d'insatisfaction sont détectés et qualifiés avant que leur accumulation n'entraîne une dégradation mesurable de la *satisfaction client*.

#pagebreak()
