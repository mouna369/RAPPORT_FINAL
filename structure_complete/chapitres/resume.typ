// ====================================
// RÉSUMÉ
// Fichier : chapitres/resume.typ
// ====================================

#set par(justify: true)
= Résumé


#h(0.5cm) Ce mémoire présente la conception et l'implémentation d'une plateforme intelligente d'analyse des sentiments clients, développée pour Algérie Télécom dans le cadre d'un projet de fin d'études réalisé au sein de la Division des Systèmes d'Information. La problématique centrale tient à l'impossibilité de traiter manuellement les flux de commentaires multilingues — darija, arabizi, français — générés quotidiennement sur les réseaux sociaux par les abonnés de l'opérateur.

#h(0.5cm)L'architecture proposée repose sur un pipeline Big Data distribué : Apache Kafka pour l'ingestion en streaming, un cluster Apache Spark (1 master, 3 workers) conteneurisé sous Docker pour le traitement parallèle, et MongoDB comme base de stockage NoSQL. Le module de normalisation linguistique traite les spécificités du dialecte algérien — code-switching, arabizi, variations régionales — via un dictionnaire unifié et des règles de conversion phonético-graphique.

#h(0.5cm)La classification des sentiments s'appuie sur DziriBERT, modèle Transformer pré-entraîné sur 1,1 million de tweets algériens, fine-tuné sur un corpus de 24 046 commentaires annotés issus des pages sociales d'Algérie Télécom. L'intégration de flags sémantiques, d'une vectorisation TF-IDF à 150 dimensions et d'un rééquilibrage des classes permet d'atteindre une accuracy de 96,18 % et un F1-macro de 0,9617. Un classifieur secondaire identifie 12 motifs d'interaction (réseau, facturation, service client, etc.) avec une accuracy de 77,3 %.

#h(0.5cm)Les résultats sont restitués dans un tableau de bord Plotly Dash en quasi-temps réel, avec un système d'alertes à deux niveaux, un assistant conversationnel basé sur Groq LLaMA 3.3 et un moteur de recommandations métier. L'ensemble du corpus, réduit de 26 576 à 24 046 documents après déduplication par similarité Jaccard-Mots, est indexé sur 51 champs structurés.

*Mots-clés :* analyse de sentiments, darija algérien, Algérie Télécom, DziriBERT, Big Data, Apache Spark, NLP, tableau de bord interactif, réseaux sociaux.


#pagebreak()
