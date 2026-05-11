// ====================================
// RÉSUMÉ — VERSION CORRIGÉE
// ====================================

#set par(justify: true)

= Résumé

#v(1cm)

#h(0.5cm)
Ce mémoire présente la conception et le développement d’une plateforme intelligente d’analyse des sentiments clients, réalisée pour Algérie Télécom dans le cadre d’un projet de fin d’études mené au sein de la Division des Systèmes d’Information. La problématique principale réside dans la difficulté de traiter manuellement les flux massifs de commentaires multilingues — darija algérienne, arabizi et français — publiés quotidiennement par les abonnés sur les réseaux sociaux.

#h(0.5cm)
L’architecture proposée repose sur un pipeline Big Data distribué intégrant Apache Kafka pour l’ingestion des données en streaming, un cluster Apache Spark conteneurisé sous Docker pour le traitement parallèle distribué, ainsi qu’une base de données NoSQL MongoDB pour le stockage flexible des données. Le module de normalisation linguistique prend en charge les spécificités du dialecte algérien, notamment le code-switching, l’arabizi et les variations régionales, à l’aide d’un dictionnaire unifié et de règles de conversion phonético-graphique.

#h(0.5cm)
La classification des sentiments s’appuie sur DziriBERT, un modèle Transformer pré-entraîné sur 1,1 million de tweets algériens, puis affiné sur un corpus de 24 046 commentaires annotés issus des pages sociales d’Algérie Télécom. L’intégration de caractéristiques sémantiques, d’une vectorisation TF-IDF et d’un mécanisme de rééquilibrage des classes a permis d’atteindre une accuracy de 96,18 % ainsi qu’un score F1-macro de 0,9617. Un classifieur secondaire identifie également 12 catégories d’interactions, telles que les problèmes réseau, la facturation ou le service client, avec une accuracy de 77,3 %.

#h(0.5cm)
Les résultats sont restitués à travers un tableau de bord interactif développé avec Plotly Dash et fonctionnant en quasi-temps réel. La plateforme intègre également un système d’alertes à deux niveaux, un assistant conversationnel fondé sur le modèle Groq LLaMA 3.3, ainsi qu’un moteur de recommandations destiné au support décisionnel. Après une phase de déduplication basée sur la similarité lexicale, le corpus a été réduit de 26 576 à 24 046 commentaires exploitables.

*Mots-clés :* analyse des sentiments, darija algérienne, Algérie Télécom, DziriBERT, Big Data, Apache Spark, traitement automatique du langage naturel, tableau de bord interactif, réseaux sociaux.

#pagebreak()