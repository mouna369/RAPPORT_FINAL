// ====================================
// CHAPITRE 2 : État de l'art
// Fichier : chapitres/chapitre2.typ
// ====================================
#set par(justify: true)

=  État de l'art et revue de la littérature

== Introduction 

#h(0.5cm) Avec 5,04 milliards d'utilisateurs actifs sur les réseaux sociaux, qui produisent chaque jour un torrent de données textuelles, ces plateformes sont devenues des tribunes idéales où les consommateurs déballent sans filtre leurs avis et frustrations sur les produits ou services @kaplan2010users. Dans le domaine des télécommunications, décortiquer ces échanges représente un atout stratégique clé : cela permet de repérer les pannes de service, de jauger la satisfaction des clients et même d'anticiper les départs @yadav2020sentiment. Mais transformer ce flot incessant en insights utilisables ? Ça pose des défis techniques énormes, et c'est ce qui a donné naissance à un domaine de recherche hybride, à la croisée du traitement automatique du langage naturel et du Big Data @cambria2013new.

En Algérie, la donne se complique encore avec la langue des données : un dialecte algérien dominant, pauvre en ressources numériques, qui mélange arabe, français, berbère, avec du code-switching et de l'arabizi à tous les coins de rue @samih2016detecting. Du coup, les modèles standards patinent sérieusement @maalej2021dialectes.

Ce chapitre retrace l'évolution des méthodes d'analyse de sentiments, des approches purement lexicales aux puissantes architectures Transformer. Il met l'accent sur les modèles arabes comme AraBERT, MARBERT ou DZiriBERT, et leurs usages dans les télécoms, avant de pointer du doigt les manques dans la recherche actuelle.
== Analyse et suivi des interactions clients sur les réseaux sociaux

#h(0.5cm) L'analyse et le suivi des interactions clients sur les réseaux sociaux, également appelés Social Media Analytics ou Social Listening, désignent le processus structuré de collecte, d'analyse et d'interprétation des données générées par les utilisateurs (likes, partages, commentaires, mentions) sur des plateformes comme Facebook, Twitter et Instagram, afin de mesurer l'engagement client, identifier les tendances et optimiser les stratégies business @kaplan2010users. Gartner définit cette approche comme « le suivi, l'analyse, la mesure et l'interprétation des interactions numériques entre personnes, sujets et contenus » via des techniques avancées incluant NLP, analyse de sentiments et Social Network Analysis @gartner2023social. L'objectif principal est de transformer les données conversationnelles non structurées en insights exploitables permettant de détecter les signaux d'insatisfaction, d'anticiper le churn et d'améliorer l'expérience client en temps réel @yadav2020sentiment. Cette discipline s'étend à l'identification des influenceurs, à la gestion de crise et à la segmentation comportementale, devenant un avantage concurrentiel majeur dans les secteurs à forte orientation client comme les télécommunications @ganis2015. Les entreprises leaders comme Google, Microsoft et Salesforce ont développé des capacités internes d'analyse sociale pour suivre les tendances de marché et optimiser leurs décisions stratégiques @insightsoftware2024.
== Analyse de sentiments : évolution des approches

=== Approches traditionnelles : le paradigme des lexico-règles

Les méthodes dites *lexico-règles* constituent le socle historique de l'analyse de sentiments. Elles reposent sur une mécanique à double niveau : l'usage de dictionnaires sémantiques, où chaque terme reçoit un score de polarité (positif, négatif ou neutre), couplé à des règles linguistiques capables de capturer les nuances contextuelles comme les négations ou les intensificateurs @pang2008opinion.

*1.Méthodes lexicales et scores affectifs *
    
    Au cœur de cette approche, les méthodes lexicales fondamentales assignent des scores aux mots en s'appuyant sur deux grands cadres théoriques :
    - *Les théories des émotions de base* (joie, tristesse, colère) ;
- *Les théories dimensionnelles* (valence et arousal) @JurafskyMartin2026.
La construction de ces lexiques peut suivre différentes méthodologies @JurafskyMartin2026 :

    // 
    + *Manuelle* : comme pour le dictionnaire ANEW ;
    + *Semi-supervisée* : via des outils comme Word2Vec ;
    + *Supervisée* : à partir de corpus (ex. tweets) annotés par émoticônes.
    
    Des ressources comme #strong[SentiWordNet] @baccianella2010sentiwordnet ou #strong[VADER] illustrent bien ce fonctionnement. 

    #figure(
      table(
        columns: (1.5fr, 1fr, 1fr),
        inset: 8pt,
        align: (left, center, center),
        fill: (x, y) => 
          if y == 0 {  }          // En-tête bleu
          else if calc.rem(y, 2) == 1 {  } // Lignes impaires gris clair
          else { white },                       // Lignes paires blanches
        stroke: 0.5pt + black,
        [*Phrase d'exemple*], [*Terme clé*], [*Score / Polarité*],
        [Service 4G excellent], [#text[excellent]], [#text[*+0.875 (Positif)*]],
        [Connexion vraiment instable], [#text[instable]], [#text[*-0.650 (Négatif)*]],
        [Produit absolument horrible], [#text[horrible]], [#text[*-0.920 (Négatif)*]],
        [Interface utilisateur intuitive], [#text[intuitive]], [#text[*+0.780 (Positif)*]]
      ),
      caption: [Exemples de classification par approche lexicale ],
  kind: table
    )

*2.De la syntaxe aux systèmes hybrides*
    
    Cependant, le lexique seul ne suffit pas à déchiffrer des structures syntaxiques complexes. C'est là qu'interviennent les *approches par règles* : elles appliquent une logique formelle pour ajuster les scores selon le contexte @riloff1996little. 
    
    La synergie entre ces deux stratégies a mené à la création de systèmes hybrides plus robustes, tels que #strong[OpinionFinder] @wiebe2005automating, capables de traiter des contrastes et des modificateurs de sens @pang2002thumbs.

    #figure(
      table(
        columns: (1.9fr, 1.5fr, 1.8fr),
        inset: 7pt,
        align: (left, center, left),
        fill: (x, y) => 
          if y == 0 {  }              // En-tête terre cuite
          else if calc.rem(y, 2) == 1 {  } // Lignes impaires gris clair
          else { white },                            // Lignes paires blanches
        stroke: 0.5pt + black,
        [*Construction syntaxique*], [*Règle appliquée*], [*Résultat / Impact*],
        [Service NON excellent], [#text(fill: rgb("000000"))[Négation]], [Inversion de la polarité (positif $arrow$ négatif)],
        [Produit très bon], [#text(fill: rgb("000000"))[Intensification]], [Amplification du score positif],
        [Le réseau est excellent MAIS la connexion saute !], [#text(fill: rgb("000000"))[Contraste]], [Pondération vers un score global négatif],
        [Adorer ce service], [#text(fill: rgb("000000"))[Connotation]], [Agent positif / Thème agréable]
      ),
      caption: [Impact des règles syntaxiques et hybrides ],
  kind: table
    )
#v(0.5cm)
*3.Limites des approches traditionnelles*
    
    Malgré leur sophistication, ces méthodes se heurtent à des obstacles structurels qui limitent leur efficacité dans des contextes réels @liu2012sentiment :

   #figure(
  table(
    columns: (1fr, 2.2fr),
    inset: 7pt,
    align: (left, left),
    fill: (x, y) => 
      if y == 0 {  }              // En-tête rouge brique
      else if calc.rem(y, 2) == 1 {  } // Lignes impaires gris très clair
      else { white },                            // Lignes paires blanches
    stroke: 0.5pt + black,
    [#text(fill: black)[*Limite*]], [#text(fill: black)[*Description*]],
    [Sarcasme et ironie], [Incapacité à détecter le second degré et les oppositions implicites comme *"Super service, j'ai attendu 3 heures !"*],
    [Couverture lexicale], [Mots manquants, néologismes (slang), expressions non répertoriées],
    [Sensibilité au bruit], [Fausses polarités dues aux ambiguïtés lexicales et contextuelles],
    [Domaines spécifiques], [Nécessité d'adapter les lexiques à chaque nouveau métier (ex: jargon médical, juridique)],
    [Portabilité], [Faible transférabilité entre différentes langues et cultures]
  ),
  caption: [Principales limitations des systèmes lexico-règles.],
  kind: table
)
#v(0.5cm)
    Ce "plafond de verre", notamment face à l'ironie, a naturellement motivé le passage vers des méthodes plus flexibles fondées sur l'apprentissage automatique @liu2012sentiment.

=== Approches par apprentissage automatique (Machine Learning)

#h(0.5cm) À mesure que l'apprentissage automatique progressait, l'analyse de sentiments a basculé vers des méthodes supervisées, qui s'appuient sur des corpus bien annotés. L'idée est simple : on entraîne un modèle statistique pour qu'il prédise la polarité d'un texte en se basant sur ses traits linguistiques. Les bases théoriques viennent des pionniers en reconnaissance de formes et en apprentissage statistique @Bishop2006 @Hastie2009, et ces fondations se sont vite étendues au traitement automatique du langage naturel @Manning2008.

*1.Classifieur Naïve Bayes*
    
   #h(0.5cm) Parmi les modèles les plus utilisés figure le *classifieur Naïve Bayes*, fondé sur le théorème de Bayes et l'hypothèse d'indépendance conditionnelle des variables explicatives. Ce modèle estime les probabilités conditionnelles associées aux caractéristiques d'indépendance. Naïve Bayes s'est révélé notamment efficace lorsque les documents sont représentés sous forme de vecteurs de fréquences de termes @Bishop2006 @Manning2008.
    
    L'efficacité de cette approche dans un contexte opérationnel a été démontrée par Fitri et al. @fitri2019sentiment, qui ont utilisé Naïve Bayes pour analyser les sentiments de la population indonésienne sur une campagne spécifique. Leurs résultats ont montré que Naïve Bayes (avec une précision de 86,43%) surpassait d'autres classifieurs comme l'arbre de décision et la forêt aléatoire pour cette tâche de classification ternaire (positif, négatif, neutre).

    

*2.Régression logistique*
    
   #h(0.5cm) La régression logistique constitue une autre méthode linéaire largement employée pour les tâches de classification binaire. Contrairement aux modèles génératifs, elle adopte une approche discriminative en modélisant directement la probabilité conditionnelle d'appartenance à une classe. Son fondement théorique repose sur la fonction logistique et l'interprétation des coefficients à travers les log-odds @Hastie2009 @Bishop2006. Cette méthode est appréciée pour sa robustesse et son interprétabilité.

*3.Machines à vecteurs de support (SVM)*
    
  #h(0.5cm)  Les *Support Vector Machines (SVM)*, introduites par @CortesVapnik1995, représentent une avancée majeure dans le domaine de la classification supervisée. Leur principe consiste à déterminer un hyperplan optimal maximisant la marge entre les classes. Grâce à l'utilisation de fonctions noyau, les SVM peuvent traiter des données non linéairement séparables en les projetant dans un espace de dimension supérieure. Leur capacité à gérer efficacement des espaces de caractéristiques de grande dimension explique leur succès dans la classification de documents textuels @Hastie2009 @Manning2008.
    
    Leur robustesse en haute dimension les rend particulièrement adaptés à la classification de textes, comme l'ont confirmé Ebrah et Elnasir @ebrah2019churn dans leur étude comparative sur la prédiction de *churn*. Leurs résultats ont montré que les modèles SVM et d'arbres de décision pouvaient atteindre des performances très élevées (AUC jusqu'à 0,99) sur des données de qualité, mais que la performance dépendait fortement du jeu de données et des phases de prétraitement.

*4.Méthodes d'ensemble*
    
  #h(0.5cm)  Pour aller plus loin que les classifieurs uniques, les méthodes d'ensemble combinent plusieurs modèles pour améliorer la robustesse et la précision. Ankita et Saleena @ankita2018ensemble ont proposé un système d'*apprentissage d'ensemble (ensemble learning)* à vote pondéré, combinant plusieurs classifieurs (Naïve Bayes, SVM, Régression Logistique, Forêt Aléatoire).
    
    Leurs expériences sur quatre jeux de données Twitter ont démontré que cette combinaison améliorait significativement la robustesse et la précision de la classification des sentiments par rapport aux classifieurs individuels, un atout majeur pour le *social listening* dans les télécommunications où la variété des expressions sur les réseaux sociaux est considérable.

#v(0.3cm)

Ces méthodes ont dominé la littérature en analyse de sentiments pendant plusieurs années, en raison de leur solidité théorique, de leur efficacité computationnelle et de leurs performances sur des données textuelles représentées par des modèles vectoriels classiques tels que TF-IDF.

#figure(
  table(
    columns: (1.4fr, 1.5fr, 1.4fr),
    inset: 10pt,
    align: (left,left , left),
    fill: (x, y) => 
      if y == 0 { }
      else if calc.rem(y, 2) == 1 {  } // Lignes impaires gris clair
      else { white },                       // Lignes paires blanches
    stroke: 0.5pt + black,
    [#text(fill: black)[*Méthode*]], [#text(fill: black)[*Fondement théorique*]], [#text(fill: black)[*Caractéristiques*]],
    [*Naïve Bayes*], [Théorème de Bayes + hypothèse d'indépendance conditionnelle ], [Probabiliste, génératif, efficace en grande dimension],
    [*Régression logistique*], [Fonction logistique, modélisation directe de $P(Y|X)$ ], [Discriminatif, linéaire, interprétable],
    [*SVM*], [Hyperplan à marge maximale, fonctions noyau ], [Discriminatif, non linéaire, robuste en haute dimension]
  ),
  caption: [Comparaison des méthodes d'apprentissage automatique pour l'analyse de sentiments],
  kind: table
)

=== Approches par apprentissage profond (Deep Learning)

L'avènement de l'apprentissage profond (deep learning) a marqué un tournant décisif dans le domaine du traitement automatique des langues (TAL) et, par extension, dans l'analyse des sentiments. Contrairement aux approches d'apprentissage automatique traditionnelles qui reposent sur une représentation des textes sous forme de sacs-de-mots (TF-IDF) et des caractéristiques souvent définies manuellement, les modèles profonds apprennent des représentations hiérarchiques et contextualisées des données. Cette capacité à capturer des structures linguistiques complexes, des dépendances à long terme et des nuances sémantiques a permis des progrès significatifs dans la classification de sentiments, en particulier pour des textes informels comme ceux issus des réseaux sociaux @JurafskyMartin2026.


*1.Les réseaux de neurones feedforward et les embeddings statiques*

    
#h(0.5cm)Les premières applications du deep learning en TAL ont vu l'émergence des *embeddings de mots statiques*, dont le représentant le plus célèbre est *Word2Vec* @Mikolov2013. Cette méthode, basée sur une architecture neuronale simple, a introduit l'idée fondamentale de la *sémantique vectorielle* (vector semantics) : le sens d'un mot peut être représenté par un vecteur dense de quelques centaines de dimensions, appris à partir de ses contextes d'apparition dans de grands corpus @JurafskyMartin2026.
    
    L'hypothèse distributionnelle sous-jacente postule que des mots apparaissant dans des contextes similaires tendent à avoir des significations proches. Word2Vec, notamment via l'architecture skip-gram avec échantillonnage négatif, a fourni des représentations riches et a montré que des opérations arithmétiques sur ces vecteurs pouvaient capturer des relations sémantiques (ex: *roi* - *homme* + *femme* ≈ *reine*) @JurafskyMartin2026.
    
 #figure(
  table(
    columns: (1.2fr, 1.5fr, 1fr),
    inset: 8pt,
    align: (left, center, center),
    fill: (x, y) => 
      if y == 0 {  }
      else if calc.rem(y, 2) == 1 { }
      else { white },
    stroke: 0.5pt + black,
    [*Relation sémantique*], [*Opération vectorielle*], [*Résultat*],
    
    [Roi - Homme + Femme], 
    [$("roi") - ("homme") + ("femme")$], 
    [$approx bold("reine")$],
    
    [Paris - France + Italie], 
    [$("Paris") - ("France") + ("Italie")$], 
    [$approx bold("Rome")$],
    
    [Meilleur - Bon + Mauvais], 
    [$("meilleur") - "bon") + ("mauvais")$], 
    [$approx bold("pire")$]
  ,
),
  caption: [Exemples de relations sémantiques capturées par Word2Vec ],
  kind: table
)
    Parallèlement, les *réseaux de neurones feedforward* ont été utilisés pour des tâches de classification de textes. En prenant en entrée la moyenne (pooling) des embeddings des mots d'un document, ces réseaux, composés d'une ou plusieurs couches cachées avec des fonctions d'activation non linéaires (ReLU, tanh), peuvent apprendre des frontières de décision plus complexes que la régression logistique @JurafskyMartin2026.
    
    // Commenté car l'image peut ne pas exister
    // #figure(
    //   image("figures/feedforward-architecture.png", width: 80%),
    //   caption: [Architecture d'un réseau feedforward pour la classification de sentiments (adapté de @JurafskyMartin2026)]
    // )
    
    Toutefois, leur principale limite réside dans leur incapacité à modéliser l'ordre séquentiel des mots, traitant le document comme un sac de mots, ce qui constitue une perte d'information importante pour l'analyse de sentiments où la structure et la succession des termes sont cruciales.

 #quote(block: true)[
      *Limite des modèles feedforward* : "Pas mal" est traité comme ["pas", "mal"] $arrow.r$ risque de polarité négative (mal = négatif) alors que l'expression est positive.
    ]

*2.Les réseaux de neurones récurrents (RNN) et leurs variantes (LSTM)*

   #h(0.5cm) Pour pallier cette limite, les *réseaux de neurones récurrents (RNN)* ont été introduits comme une solution naturelle pour traiter les données séquentielles @Elman1990. Leur architecture, dotée d'une connexion récurrente, leur confère une mémoire leur permettant de prendre en compte l'historique des mots précédents pour influencer le traitement du mot courant.
    
    #figure(
      table(
        columns: (1.8fr, 2.2fr),
        inset: 8pt,
        align: (left, left),
        fill: (x, y) => 
          if y == 0 { }
          else if calc.rem(y, 2) == 1 {  }
          else { white },
        stroke: 0.5pt + black,
        [*Phrase*], [*Traitement séquentiel RNN*],
        [Le service est excellent], [$h_1("Le") -> h_2("service") -> h_3("est") -> h_4("excellent") -> "classification"$],
        [Je ne suis pas satisfait], [$h_1("Je") -> h_2("ne") -> h_3("suis") -> h_4("pas") -> h_5("satisfait") -> "classification"$],
        [Produit correct mais cher], [$h_1("Produit") -> h_2("correct") -> h_3("mais") -> h_4("cher") -> "classification"$]
      ),
      caption: [Traitement séquentiel des phrases par un RNN],
  kind: table
    )
    
    Cependant, les RNNs simples souffrent du problème de *disparition du gradient (vanishing gradient)* lors de l'entraînement sur de longues séquences, ce qui les rend incapables d'apprendre des dépendances à long terme @JurafskyMartin2026.
    
   #figure(
  grid(
    columns: 2,
    gutter: 1em,
    [
      #block(
        fill: luma(250),
        inset: 0.8em,
        radius: 0.3em,
        stroke: 0.5pt + red,
        [
          #set text(size: 0.9em)
          *RNN simple* : \
          "Le film commençait bien, les acteurs étaient convaincants, la musique était agréable, mais la fin était ..." $arrow.r$ perte du contexte initial
        ]
      )
    ],
    [
      #block(
        fill: luma(250),
        inset: 0.8em,
        radius: 0.3em,
        stroke: 0.5pt + green,
        [
          #set text(size: 0.9em)
          *LSTM* : \
          "Le film commençait bien, les acteurs étaient convaincants, la musique était agréable, mais la fin était décevante" $arrow.r$ maintien de la mémoire du contexte
        ]
      )
    ]
  ),
  caption: [Comparaison RNN vs LSTM sur les dépendances longues]
)
    
    Pour remédier à cela, les *LSTMs (Long Short-Term Memory)* ont été proposés @HochreiterSchmidhuber1997. Grâce à un mécanisme de portes (porte d'oubli, porte d'entrée, porte de sortie) et un état de cellule dédié, les LSTMs peuvent contrôler de manière explicite le flux d'information.
    
    #figure(
  table(
    columns: (1.2fr, 1.2fr, 1fr),
    inset: 8pt,
    align: (left, center, center),
    fill: (x, y) => 
      if y == 0 {  }
      else if calc.rem(y, 2) == 1 {  }
      else { white },
    stroke: 0.5pt + black,
    [*Porte LSTM*], [*Fonction*], [*Rôle*],
    [Porte d'oubli (forget gate)], [$sigma(W_f dot [h_{t-1}, x_t] + b_f)$], [Décide quelle information oublier],
    [Porte d'entrée (input gate)], [$sigma(W_i dot [h_{t-1}, x_t] + b_i)$], [Décide quelle information stocker],
    [Porte de sortie (output gate)], [$sigma(W_o dot [h_{t-1}, x_t] + b_o)$], [Décide quelle information produire]
  ),
  caption: [Mécanisme des portes dans un LSTM],
  kind: table
)
    
    En analyse de sentiments, les LSTMs, souvent utilisés en version bidirectionnelle (*BiLSTM*) pour capturer le contexte à la fois à gauche et à droite d'un mot, ont montré d'excellentes performances @JurafskyMartin2026.
    
    #figure(
      table(
        columns: (1.5fr, 1fr, 1.5fr),
        inset: 8pt,
        align: (left, center, center),
        fill: (x, y) => 
          if y == 0 {  }
          else if calc.rem(y, 2) == 1 {  }
          else { white },
        stroke: 0.5pt + black,
        [#text(fill: black)[*Opérateur*]], [#text(fill: black)[*Modèle*]], [#text(fill: black)[*Précision*]],
        [STC (Saudi Telecom)], [BiLSTM], [97.2%],
        [Mobily], [BiLSTM], [96.8%],
        [Zain], [BiLSTM], [97.1%],
        [*Moyenne*], [*BiLSTM*], [*97.03%*]
      ),
      caption: [Performance du modèle BiLSTM sur les tweets des opérateurs saoudiens ],
  kind: table
    )
    
    Dans le secteur des télécommunications, Alshamari @alshamari2023evaluating a appliqué avec succès une architecture BiLSTM pour analyser la satisfaction des clients des trois principaux opérateurs saoudiens (STC, Mobily, Zain) à partir d'un corpus de tweets en arabe (*AraCust*). Son étude a révélé une tendance globalement négative des opinions et a démontré la supériorité du modèle LSTM (précision de test de 97,03%) par rapport aux autres architectures neuronales testées (GRU, BiLSTM, CNN-LSTM).

*3.L'architecture Transformer et les modèles de langue contextuels*

   #h(0.5cm) Une avancée majeure a été réalisée avec l'introduction de l'architecture *Transformer* @Vaswani2017. Celle-ci abandonne la récurrence au profit d'un mécanisme d'*attention* (et plus précisément de l'*auto-attention*), qui permet de pondérer l'importance de tous les mots d'une séquence pour construire la représentation de chaque mot.
    
    #figure(
      table(
        columns: (2.1fr, 1fr, 2fr),
        inset: 8pt,
        align: (left, center, left),
        fill: (x, y) => 
          if y == 0 {  }
          else if calc.rem(y, 2) == 1 {  }
          else { white },
        stroke: 0.5pt + black,
        [#text(fill: black)[*Phrase*]], [#text(fill: black)[*Mot focus*]], [#text(fill: black)[*Mots avec forte attention*]],
        ["Le service client est très lent"], ["lent"], ["service", "très", "lent"],
        ["La connexion 4G fonctionne bien"], ["bien"], ["connexion", "fonctionne", "bien"],
        ["Produit cher mais de qualité"], ["mais"], ["cher", "qualité", "mais"]
      ),
      caption: [Mécanisme d'auto-attention : poids d'attention sur différents mots],
  kind: table
    )
    
    Deux grandes familles de modèles, pré-entraînés sur d'immenses corpus, ont émergé de cette architecture :

    *a) Les modèles de type BERT* (Bidirectional Encoder Representations from Transformers) @Devlin2019. BERT est un *encodeur bidirectionnel* qui utilise un *apprentissage par masquage (masked language modeling)* : il apprend en prédisant des mots aléatoirement masqués dans une phrase, en utilisant le contexte gauche ET droit.
    
    #figure(
      table(
        columns: (1.8fr, 2.2fr),
        inset: 8pt,
        align: (left, left),
        fill: (x, y) => 
          if y == 0 {  }
          else if calc.rem(y, 2) == 1 {  }
          else { white },
        stroke: 0.5pt + black,
        [#text(fill: black)[*Phrase avec masque*]], [#text(fill: black)[*Prédictions BERT*]],
        ["Le service [MASK] est excellent"], ["client", "technique", "après-vente"],
        ["La connexion est vraiment [MASK]"], ["lente", "rapide", "instable"],
        ["Je [MASK] cet opérateur"], ["recommande", "déteste", "choisis"]
      ),
      caption: [Apprentissage par masquage (Masked Language Modeling) de BERT ],
  kind: table
    )

    *b) Les modèles de type GPT* (Generative Pre-trained Transformer). Ce sont des *décodeurs causals* (ou autorégressifs) qui apprennent à prédire le mot suivant dans une séquence, en ne voyant que le contexte gauche.
    
    #figure(
      table(
        columns: (1.5fr, 2.5fr),
        inset: 8pt,
        align: (left, left),
        fill: (x, y) => 
          if y == 0 { }
          else if calc.rem(y, 2) == 1 {  }
          else { white },
        stroke: 0.5pt + black,
        [#text(fill: black)[*Prompt*]], [#text(fill: black)[*Génération GPT*]],
        ["Le sentiment de ce texte est : 'Super service' →"], [" positif. Le mot 'super' indique une appréciation."],
        ["Explique pourquoi ce tweet est négatif : 'Connexion lente' →"], [" Le tweet exprime une insatisfaction concernant la vitesse de connexion."],
        ["Ce commentaire est-il positif ou négatif ? 'Prix correct' →"], [" Plutôt neutre, 'correct' n'est ni très positif ni très négatif."]
      ),
      caption: [Capacité de génération et d'explication des modèles GPT],
  kind: table
    )

*4.Modèles hybrides et optimisation*

    Face au volume massif des données sociales, des architectures hybrides ont été proposées pour optimiser les performances. Ye et Zhao @ye2025scalable ont développé *SVS-IAdaBoost*, un modèle combinant un algorithme d'optimisation par vortex (Vortex Search) avec un boosting adaptatif intelligent (IAdaBoost).
    
    #figure(
      table(
        columns: (1fr, 1fr, 1.5fr),
        inset: 7pt,
        align: (left, center, center),
        fill: (x, y) => 
          if y == 0 { }
          else if calc.rem(y, 2) == 1 {  }
          else { white },
        stroke: 0.5pt + black,
        [#text(fill: black)[*Modèle*]], [#text(fill: black)[*Volume de données*]], [#text(fill: black)[*Précision*]],
        [SVM], [1M tweets], [87.3%],
        [LSTM], [1M tweets], [91.8%],
        [BERT], [1M tweets], [93.5%],
        [SVS-IAdaBoost], [1M tweets], [#text[*95.1%*]]
      ),
      caption: [Performance comparative du modèle hybride SVS-IAdaBoost ],
  kind: table
    )
    
    Testé sur plus d'un million de tweets, ce modèle a atteint une précision de 95,1%, illustrant le potentiel des méthodes hybrides pour traiter le volume et le déséquilibre des données, des défis centraux pour les opérateurs télécoms.

*5.Des représentations statiques aux modèles de fondation*

    L'évolution de l'apprentissage profond en TAL a ainsi suivi une trajectoire claire :
    
    #figure(
      table(
        columns: (1fr, 1.65fr, 1.5fr, 1.9fr),
        inset: 8pt,
        align: (left, left, left, left),
        fill: (x, y) => 
          if y == 0 {  }
          else if calc.rem(y, 2) == 1 {  }
          else { white },
        stroke: 0.5pt + black,
        [#text(fill: black)[*Époque*]], [#text(fill: black)[*Type de modèle*]], [#text(fill: black)[*Représentation*]], [#text(fill: black)[*Exemple*]],
        [2013-2017], [Embeddings statiques], [Vecteur fixe par mot], [Word2Vec, GloVe, FastText],
        [2017-2019], [RNN/LSTM contextuels], [Contexte local], [ELMo, BiLSTM],
        [2019-2022], [Transformers (encodeurs)], [Contexte bidirectionnel profond], [BERT, RoBERTa, XLNet],
        [2022-présent], [Grands modèles de langue], [Génération + contexte], [GPT-3/4, Llama, Claude]
      ),
      caption: [Évolution des représentations en TAL.],
  kind: table
    )
    
    - Des *représentations statiques* (Word2Vec, GloVe), où chaque mot a un vecteur fixe, quel que soit le contexte.
    - Aux *représentations contextuelles* (LSTM, BERT), où le vecteur d'un mot est dynamique et fonction de la phrase.
    - Enfin, à l'émergence des *grands modèles de langue (LLMs)*, comme GPT-3 ou Llama, constituant aujourd'hui des *modèles de fondation* capables de réaliser une multitude de tâches sans entraînement spécifique, grâce à des techniques d'apprentissage en contexte (in-context learning).


== Traitement du Langage Naturel pour l'Arabe et le Dialecte Algérien
#h(0.5cm) L'évolution des modèles de langage pour la langue arabe a connu un développement significatif ces dernières années. La langue arabe présente plusieurs défis pour le traitement automatique, notamment :

- Une morphologie riche (dérivations, flexions et conjugaisons complexes)
- Une variation dialectale importante entre l'arabe standard moderne (MSA) et les dialectes locaux
- Une complexité syntaxique et orthographique élevée

Ces spécificités rendent nécessaires l'adaptation de modèles de langage pré-entraînés pour capturer efficacement les structures linguistiques de l'arabe et ses variantes.

=== Modèles pour l'arabe standard (AraBERT, MARBERT, CAMeLBERT)


* 1. AraBERT*

#h(0.5cm) AraBERT est l'un des premiers modèles basés sur l'architecture BERT spécifiquement adaptés à l'arabe standard moderne. Il a été pré-entraîné sur de larges corpus comprenant des articles de presse et du contenu web, permettant des performances élevées sur des tâches de classification et de reconnaissance d'entités nommées (NER) @antoun2020arabert.

*Caractéristiques principales :*

- Architecture BERT-base : 12 couches, 768 dimensions cachées, 12 têtes d'attention
- 110 millions de paramètres
- Vocabulaire SentencePiece de 64 000 tokens
- Segmentation morphologique préalable via Farasa pour gérer racines, préfixes et suffixes

*Performances notables :*

#figure(
  table(
   columns: (1fr, 1fr, 0.75fr, 0.75fr,0.75fr),
        inset: 8pt,
        align: (left, left, left, left, left),
        fill: (x, y) => 
          if y == 0 {  }
          else if calc.rem(y, 2) == 1 {  }
          else { white },
        stroke: 0.5pt + black,
    [*Tâche*], [*Dataset*], [*AraBERT*], [*mBERT*], [*Gain*],
    [Sentiment Analysis], [HARD], [96.2 %], [95.7 %], [+0.5 %],
    [NER], [ANERcorp], [84.2 F1], [78.4 F1], [+5.8]
  ),
  caption: "Comparaison des performances AraBERT vs mBERT",
  kind: table
)

L'utilisation de la segmentation morphologique améliore les performances en SA et QA mais peut réduire légèrement la précision en NER en raison de la fragmentation des entités.

* 2. MARBERT*

#h(0.5cm) MARBERT est un modèle pré-entraîné sur des données issues des réseaux sociaux, incluant divers dialectes arabes, ce qui le rend particulièrement adapté à l'analyse de textes informels et de sentiments dialectaux @abdul2021arbert.

*Points forts :*

- Optimisé pour les tweets et textes courts
- Robuste au bruit linguistique (abréviations, fautes, emojis)
- Performances supérieures sur les tâches d'analyse de sentiments dialectales


*Benchmark ARLUE (42 datasets) :*

#figure(
  table(
     columns: (0.73fr, 0.7fr),
        inset: 7pt,
        align: (left, left),
        fill: (x, y) => 
          if y == 0 {  }
          else if calc.rem(y, 2) == 1 {  }
          else { white },
        stroke: 0.5pt + black,
    [*Modèle*], [*Score ARLUE*],
    [MARBERT-v2], [77.40],
    [XLM-R Large], [76.55],
    [ARBERT], [76.07],
    [MARBERT], [75.99],
    [AraBERT], [73.91]
  ),
  caption: "Scores ARLUE des principaux modèles ",
  kind: table
)

L'efficacité du modèle dépend fortement de la proximité variétale entre les données de pré-entraînement et les données de fine-tuning.

* 3. CAMeLBERT*

#h(0.5cm)Développé par le laboratoire CAMeL (NYU Abu Dhabi), CAMeLBERT propose plusieurs variantes adaptées à l'arabe standard, aux dialectes et à l'arabe classique @inoue2021interplay.

*Variantes :*

#figure(
  table(
     columns: (0.73fr, 0.7fr, 1.2fr),
        inset: 7pt,
        align: (left, left, left),
        fill: (x, y) => 
          if y == 0 {  }
          else if calc.rem(y, 2) == 1 {  }
          else { white },
        stroke: 0.5pt + black,
    [*Variante*], [*Données principales*], [*Utilisation recommandée*],
    [$"CAMeLBERT-MSA"$], [Presse, Wikipedia], [Texte MSA formel],
    [$"CAMeLBERT-DA"$], [Tweets, forums], [Dialectes arabes],
    [$"CAMeLBERT-CA"$], [Livres anciens], [Arabe classique],
    [$"CAMeLBERT-Mix"$], [Combinaison de tous les corpus], [Cas mixtes si ressources limitées]
  ),
  caption: "Variantes de CAMeLBERT",
  kind: table
)

Les expériences montrent que l'adéquation de la variante linguistique entre le pré-entraînement et la tâche spécifique est plus importante que la taille totale du corpus.

=== Modèles multilingues (mBERT, XLM-R)


#h(0.5cm)Lorsque les ressources spécifiques à l'arabe sont limitées, des modèles multilingues comme mBERT ou XLM-R peuvent être utilisés. Bien qu'ils ne soient pas spécialisés pour l'arabe, ils offrent une couverture cross-linguale et peuvent servir de base pour le fine-tuning sur des tâches MSA ou dialectales @conneau2020xlm.

#h(0.5cm)Le tableau suivant synthétise les caractéristiques des principaux modèles de langage pour l’arabe, d’après les résultats des benchmarks ARLUE et les études comparatives (Abdul-Mageed et al., 2021 ; Inoue et al., 2021).
#figure(
  table(
   columns: (0.73fr, 0.7fr, 1.2fr, 1fr),
        inset: 8pt,
        align: (left, left, left, left),
        fill: (x, y) => 
          if y == 0 {  }
          else if calc.rem(y, 2) == 1 {  }
          else { white },
        stroke: 0.5pt + black,
    [*Modèle*], [*Variantes*], [*Points forts*], [*Points faibles*],
    [AraBERT], [MSA], [Bon équilibre performance/formalité], [Limité pour les dialectes],
    [ARBERT], [MSA], [Excellente performance MSA formel], [Faible pour dialectes],
    [MARBERT], [Dialectes], [Idéal pour social media], [Moins performant en QA longue],
    [MARBERT-v2], [Mixte], [Meilleur score ARLUE global], [Plus lourd à entraîner],
    [CAMeLBERT], [MSA / DA / CA / Mix], [Spécialisé selon la variante], [Taille corpus parfois réduite],
    [mBERT / XLM-R], [Multilingue], [Polyvalent, bonne couverture cross-lingual], [Moins performant sur tâches spécifiques à l'arabe]
  ),
  caption: "Synthèse comparative des modèles de langage pour l'arabe",
  kind: table
)

=== État des lieux sur le dialecte algérien (Darija) 
#h(0.5cm) Le dialecte algérien, communément appelé *Darija*, constitue une variété linguistique complexe qui pose des défis majeurs pour le Traitement Automatique du Langage Naturel (TALN). Contrairement à l'arabe standard moderne (MSA), la Darija n'est pas standardisée, principalement orale, et caractérisée par une grande variabilité régionale et sociale (Benali et al., 2025). Cette section dresse un état des lieux des caractéristiques linguistiques, des ressources disponibles et des travaux de recherche existants.

==== Caractéristiques linguistiques

Le traitement automatique de la Darija algérienne se heurte à plusieurs phénomènes linguistiques spécifiques qui limitent l'application directe des modèles pré-entraînés sur l'arabe standard ou les langues européennes (Maâlej et al., 2021 ; Samih & Maier, 2016).

*1. Code-switching (alternance codique)*

Le code-switching désigne l'alternance entre plusieurs langues au sein d'un même énoncé. En Algérie, les utilisateurs des réseaux sociaux mélangent fréquemment l'arabe dialectal, le français, l'anglais et parfois le berbère (Tamazight) dans un même commentaire. Par exemple 
  
#let lang-box(text, lang) = {
  box(
    fill: if lang == "ar" { rgb("#fef9c3") }
          else if lang == "fr" { rgb("#dbeafe") }
          else if lang == "ber" { rgb("#f3f4f6") }
          else { rgb("#e5e7eb") },
    inset: (x: 8pt, y: 4pt),
    radius: 8pt,
    text
  )
}

#block(
  stroke: (left: 4pt + rgb("#2c7a3e")),
  inset: 12pt,
  fill: rgb("#f0fdf4"),
  radius: 4pt,
  width: 100%,
  [
    #align(center)[
      #lang-box("Wah", "ar")
      #h(2pt)
      #lang-box("يا أخي", "ar")
      #h(4pt)
      #lang-box("la connexion", "fr")
      #h(4pt)
      #lang-box("مازال", "ar")
      #h(4pt)
      #lang-box("coupée", "fr")
      #h(4pt)
      #lang-box("depuis 3 jours", "fr")
    ]
    #v(6pt)
    #align(center)[
      #text(size: 9pt, style: "italic", fill: gray)[
        *Wah ya akhi, la connexion mazal coupée depuis 3 jours*
      ]
    ]
    #v(4pt)
    #align(center)[
      #text(size: 9pt, fill: gray)[
        🟨 Arabe dialectal  🟦 Français
      ]
    ]
    #v(8pt)
    #text(size: 9pt)[
      *Traduction* : "Mon frère, la connexion est toujours coupée depuis 3 jours"
    ]
  ]
)

Cette hybridation complique la tokenisation et la représentation vectorielle, car les modèles monolingues ne peuvent pas capturer les relations sémantiques entre les mots de langues différentes (Samih & Maier, 2016). Selon Benali et al. (2025), plus de 67% des tweets algériens contiennent au moins une alternance codique.

*2. Arabizi (transcription latine)*

L'Arabizi est une pratique courante consistant à transcrire l'arabe en caractères latins, avec l'utilisation de chiffres pour représenter les phonèmes arabes inexistants en français/anglais :
#figure(
  table(
   columns: (0.75fr, 0.9fr, 0.9fr, 1fr),
        inset: 7pt,
        align: (center, center, center, center),
        fill: (x, y) => 
          if y == 0 {  }
          else if calc.rem(y, 2) == 1 {  }
          else { white },
        stroke: 0.5pt + black,
    [#text(fill: black)[*Chiffre*]], [#text(fill: black)[*Phonème arabe*]], [#text(fill: black)[*Exemple Arabizi*]], [#text(fill: black)[*Transcription arabe*]],
    [3], [ع], [3lik], [على],
    [7], [ح], [7al], [حال],
    [5], [خ], [5li], [خلي],
    [9], [ق], [9al], [قال],
    [2], [ء], [sa2el], [سائل]
  ),
   caption: [Correspondance chiffres-phonèmes en Arabizi ],
  kind: table
)


Cette variation orthographique multiplie les formes d'un même mot, augmentant la sparsité des représentations et réduisant les performances des modèles (Benali et al., 2025).

*3. Variations régionales et sociolectales*

La Darija varie considérablement selon les régions algériennes (Alger, Oran, Constantine, Sud), avec des différences lexicales, phonétiques et syntaxiques :
#figure(
  table(
    columns: (0.5fr, 0.9fr, 0.9fr),
        inset: 7pt,
        align: (center, center, center),
        fill: (x, y) => 
          if y == 0 {  }
          else if calc.rem(y, 2) == 1 {  }
          else { white },
        stroke: 0.5pt + black,
    [#text(fill: black)[*Région*]], [#text(fill: black)[*Exemple (Merci)*]], [#text(fill: black)[*Exemple (Comment ça va ?)*]],
    [Alger], [Yessahh], [Ça va ? / Rak labas ?],
    [Oran], [Baraka], [Ça va ? / Koulchi mzyan ?],
    [Constantine], [Choukran], [Ça va ? / Rak hani ?],
    [Sud], [Allah ykhalik], [Ça va ? / Labas 3lik ?]
  ),
  caption: [Variations régionales du dialecte algérien],
  kind: table
)



*4. Sarcasme et expressions figurées*

Le sarcasme et l'ironie sont fréquents dans les commentaires sur les réseaux sociaux, particulièrement dans le contexte des réclamations télécom. Par exemple :

  
#block(
 stroke: (left: 4pt + rgb("#2c7a3e")),
  inset: 12pt,
  fill: rgb("#f0fdf4"),
  radius: 4pt,
  width: 100%,
  [
    #align(center)[
      #text(style: "italic", weight: "medium")[
        "Super service, j'ai attendu seulement 3 heures pour parler à un agent !"
      ]
    ]
    #v(8pt)
    #text(size: 9pt, fill: gray)[
      *Ironie* : Le contraste entre le ton élogieux et la réalité décrite (3h d'attente) 
      révèle l'insatisfaction réelle du client.
    ]
  ]
)
#v(0.5cm)
Ces expressions nécessitent une compréhension contextuelle profonde que les approches lexicales traditionnelles ne peuvent pas capturer (Liu, 2012). Des approches plus récentes basées sur les transformers (BERT, RoBERTa) ont montré des performances améliorées pour la détection du sarcasme dans les langues peu dotées (Kumar et al., 2023).


==== Ressources disponibles (corpus, lexiques)




// ============================================================
// RESSOURCES DISPONIBLES (CORPUS, LEXIQUES)
// ============================================================


Contrairement à l'arabe standard, les ressources annotées pour la Darija algérienne restent limitées. Cependant, plusieurs initiatives récentes ont commencé à combler ce manque.

*1. Corpus annotés*
#figure(
  table(
    columns: (0.9fr, 1.3fr, 1.2fr, 1.5fr,0.9fr),
    inset: 9pt,
    align: (left, left, left, left),
    fill: (x, y) => 
      if y == 0 {  }
      else if calc.rem(y, 2) == 1 {  }
      else { white },
    stroke: 0.5pt + black,
    table.header(
      [*Corpus*], [*Taille*], [*Type de données*], [*Annotation*], [*Disponibilité*]
    ),
    [TWIFIL], [9 000 tweets], [Tweets algériens], [Sentiment + Émotions], [Publique],
    [DzSentiA], [50 000 posts], [Réseaux sociaux DZ], [Sentiment (Pos/Neg)], [Publique ],
    [Algérie Télécom DZ], [~10 000 commentaires], [Télécom DZ], [Sentiment + Urgence], [Publique],
    [Algerian Dialect], [45 000 commentaires], [YouTube DZ], [Sentiment 5 classes], [Publique],
    [DZDialect], [117 569 commentaires], [Social media], [Sentiment], [Publique],
  ),
  caption: [Principaux corpus pour le dialecte algérien ],
  kind: table
)

*2. Lexiques et dictionnaires*
#figure(
  table(
   columns: (1fr, 0.8fr, 0.8fr, 1.2fr),
    inset: 7pt,
    align: (left, left, left),
    fill: (x, y) => 
      if y == 0 {  }
      else if calc.rem(y, 2) == 1 {  }
      else { white },
    stroke: 0.5pt + black,
    table.header(
      [*Ressource*], [*Type*], [*Couverture*], [*Limitations*]
    ),
    [AraLex], [Lexique arabe], [~50 000 mots], [MSA uniquement],
    [DziriBERT Vocab], [Embeddings], [~30 000 tokens], [Spécifique DZ, pas lexique pur],
    [Darija DZ App], [Phrases courantes], [~2 000 expressions], [Didactique, non académique],
  ),
  caption: [Lexiques et vocabulaires pour Darija algérienne],
  kind: table
)



// ============================================================
// TRAVAUX DE RECHERCHE EXISTANTS
// ============================================================
#v(0.5cm)
==== Travaux de recherche existants

Plusieurs recherches récentes ont exploré l'adaptation des modèles de langage pour le dialecte algérien.


*1. DZiriBERT*

DZiriBERT est le premier modèle Transformer pré-entraîné sur 1,1 million de tweets algériens 
(Arabizi + arabe) @abdaoui2021dziribert. Disponible sur HuggingFace, il surpasse MARBERT sur les tâches DZ 
(F1 ~86%). Fine-tuné avec succès sur datasets télécom (précision +89%).


*2. Benchmarks récents*

L'étude de Benali et al. (2025) a établi le premier benchmark complet pour l'analyse de sentiments en Darija algérienne :
#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: (left, left, center, center),
    inset: 7pt,
    stroke: 0.5pt+ black,
    fill: (x, y) => if y == 0 { } else if calc.rem(y, 2) == 0 {  } else { white },
    table.header(
      [*Modèle*], [*Architecture*], [*Précision*], [*F1-Score*]
    ),
    [SVM], [ML classique], [78.5%], [0.74],
    [LSTM], [Deep Learning], [84.7%], [0.82],
    [DziriBERT], [Transformer], [86.2%], [0.86],
    [MARBERT], [Transformer], [87.1%], [0.87],
    [DziriBERT + LoRA], [PEFT hybride], [89.3%], [0.89]
  ),
  caption: [Benchmarks récents sur Darija algérienne ],
  kind: table
)



// ============================================================
// TECHNIQUES D'ADAPTATION DES LLM
// ============================================================

=== Techniques d'adaptation des LLM (Fine-tuning, PEFT, LoRA)

L'adaptation des grands modèles de langage (LLM) à des domaines ou langues spécifiques est devenue une pratique courante en TALN. Cette section présente les principales techniques d'adaptation pertinentes pour notre projet.

*1. Fine-tuning classique*

#h(0.5cm)Le *fine-tuning* consiste à reprendre un modèle pré-entraîné (ex: MARBERT) et à continuer son entraînement sur un dataset spécifique à la tâche cible (ex: tweets télécom algériens).
#grid(
  columns: (1fr, 1.1fr),
  gutter: 16pt,
  [
    #block(
      stroke: (top: 2pt + rgb("#2c7a3e"), bottom: 0.5pt + luma(200), left: 0.5pt + luma(200), right: 0.5pt + luma(200)),
      inset: 12pt,
      radius: 4pt,
      [
        #text(weight: "bold", size: 10pt,)[Avantages]
        #v(8pt)
        #text(size: 9.5pt)[
          • Capture les spécificités du domaine cible ;#v(0.001cm)
          • Améliore les performances (gain de 5 à 15 %) ;#v(0.001cm)
          • Relativement simple à implémenter.
        ]
      ]
    )
  ],
  [
    #block(
      stroke: (top: 2pt +red, bottom: 0.5pt + luma(200), left: 0.5pt + luma(200), right: 0.5pt + luma(200)),
      inset: 12pt,
      radius: 4pt,
      [
        #text(weight: "bold", size: 10pt,)[Limitations]
        #v(8pt)
        #text(size: 9.5pt)[
          • Nécessite un corpus annoté ;#v(0.001cm)
          • Coûteux en ressources computationnelles (GPU) ;#v(0.001cm)
          • Risque d'oubli catastrophique.
        ]
      ]
    )
  ]
)

*2. PEFT (Parameter-Efficient Fine-Tuning)*

Le PEFT regroupe un ensemble de techniques visant à adapter les LLM en modifiant uniquement un petit sous-ensemble de paramètres, réduisant ainsi les coûts computationnels (Hu et al., 2021).

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: (left, center, center, center),
    inset: 7pt,
    stroke: 0.5pt+black,
    fill: (x, y) => if y == 0 { } else if calc.rem(y, 2) == 0 { } else { white },
    table.header(
      [*Méthode*], [*Paramètres modifiés*], [*Mémoire requise*], [*Performance relative*]
    ),
    [Fine-tuning], [100%], [Élevée], [100% (référence)],
    [Adapter], [3-5%], [Moyenne], [95-98%],
    [LoRA], [1-2%], [Faible], [97-99%],
    [Prefix Tuning], [0,5-1%], [Très faible], [94-97%],
  ),
  caption: [Comparaison des techniques PEFT ],
  kind: table
) <peft-comparison>

*3. LoRA (Low-Rank Adaptation)*

LoRA est actuellement la technique PEFT la plus populaire pour l'adaptation des transformers. Elle fonctionne en ajoutant des matrices de rang faible aux couches attention du modèle original (Hu et al., 2021).

// ______________________________________
// == Applications NLP dans le secteur télécom
// === Études académiques sur l'analyse client télécom
// === Implémentations industrielles
// === Monitoring de marque et gestion de crise sur les réseaux sociaux
// ________________________________________
// ============================================================
// ARCHITECTURES BIG DATA POUR DONNÉES SOCIALES
// ============================================================

// ________________________________________
== Systèmes Existants

L'analyse de sentiments a donné lieu au développement de nombreux outils et plateformes, allant des bibliothèques open source aux solutions commerciales intégrées. Cette section propose une revue systématique des principales ressources disponibles, en les catégorisant selon leur approche fondatrice et leur domaine d'application.

=== Outils Open Source et Bibliothèques

==== Basés sur Lexiques

*1.SentiWordNet*

    SentiWordNet est une ressource lexicale construite à partir de WordNet, où chaque synset (ensemble de synonymes) se voit attribuer trois scores : positivité, négativité et objectivité, dont la somme est égale à 1 @baccianella2010sentiwordnet. Développé à l'Université de Pise, cet outil a été largement adopté pour l'analyse de sentiments en raison de sa couverture lexicale étendue.
    
    #figure(
      table(
        columns: (1.5fr, 1fr, 1fr, 1fr),
        inset: 7pt,
        align: (left, center, center, center),
        fill: (x, y) => 
          if y == 0 {  }
          else if calc.rem(y, 2) == 1 {  }
          else { white },
        stroke: 0.5pt + black,
        [#text(fill: black)[*Synset*]], [#text(fill: black)[*POS*]], [#text(fill: black)[*PosScore*]], [#text(fill: black)[*NegScore*]],
        ["good#1"], ["a"], [0.375], [0.125],
        ["excellent#1"], ["a"], [0.75], [0.0],
        ["terrible#1"], ["a"], [0.0], [0.75],
        ["love#1"], ["v"], [0.625], [0.0]
      ),
      caption: [Exemples d'entrées dans SentiWordNet ],
  kind: table
    )
    
    Une implémentation Node.js, `sentiword`, permet d'utiliser cette ressource avec analyse grammaticale (POS tagging) pour améliorer la précision : le texte est d'abord analysé pour identifier la nature grammaticale de chaque mot, puis la recherche de sentiment est restreinte aux entrées correspondant à cette catégorie grammaticale.

*2.VADER (Valence Aware Dictionary and sEntiment Reasoner)*

    VADER est un outil spécifiquement conçu pour l'analyse des sentiments exprimés sur les réseaux sociaux @hutto2014vader. Développé par C.J. Hutto et E.E. Gilbert, il combine un dictionnaire de polarité avec cinq règles heuristiques capturant les nuances sociales :
    
    - *Ponctuation* : un point d'exclamation amplifie l'intensité ("bien" → +, "bien !" → ++)
    - *Capitalisation* : les mots en MAJUSCULES indiquent une emphase
    - *Intensificateurs* : "très", "extrêmement" modulent le score
    - * Contraste* : "mais" signale un changement de polarité
    - *Négation* : "pas", "ne" inversent la polarité 
    
    #figure(
      table(
        columns: (1.8fr, 1fr, 1fr, 1fr),
        inset: 7pt,
        align: (left, center, center, center),
        fill: (x, y) => 
          if y == 0 {  }
          else if calc.rem(y, 2) == 1 { }
          else { white },
        stroke: 0.5pt + black,
        [#text(fill: black)[*Texte*]], [#text(fill: black)[*Pos*]], [#text(fill: black)[*Neu*]], [#text(fill: black)[*Neg*]],
        ["This is great!"], [0.567], [0.433], [0.0],
        ["This is GREAT!"], [0.658], [0.342], [0.0],
        ["This is great!!"], [0.700], [0.300], [0.0],
        ["I love it "], [0.784], [0.216], [0.0]
      ),
      caption: [Effet des heuristiques VADER sur les scores],
  kind: table
    )
    
    VADER produit un score *compound* normalisé entre -1 (négatif extrême) et +1 (positif extrême). Il est extrêmement rapide (traitement d'environ 10 000 textes par seconde) et ne nécessite pas de GPU, ce qui le rend adapté aux déploiements à grande échelle.

*3.ANEW (Affective Norms for English Words)*

    ANEW est une ressource psycholinguistique développée par Bradley et Lang @bradley1999anew, contenant des mots évalués selon trois dimensions affectives :
    
    - *Valence* : plaisir/déplaisir (de 1 = négatif à 9 = positif)
    - *Arousal* : excitation/calme
    - *Dominance* : contrôle/soumission
    
    La version originale contenait 1 034 mots ; Warriner et al. @warriner2013norms l'ont étendue à près de 14 000 lemmes anglais, avec des normes désagrégées par genre, âge et niveau d'éducation.
    
    Pour l'analyse de sentiments, les mots sont recherchés dans la base, et les valeurs de valence sont utilisées pour déterminer la polarité. Une heuristique de négation peut être appliquée : si un mot de négation ("not", "no") apparaît dans les trois mots précédents, la polarité est inversée par la formule $(5 - ("valence" - 5))$.

==== Basés sur l'Apprentissage Automatique

*1.Sentiment140*

    Sentiment140 est à la fois un dataset et une approche méthodologique développée par Go, Bhayani et Huang @go2009twitter. Le corpus contient *1,6 million de tweets* annotés automatiquement à l'aide d'émoticônes :
    - Les tweets contenant ":)" ou ":-)" sont étiquetés positifs
    - Ceux contenant ":(" ou ":-(" sont étiquetés négatifs
    
    Cette approche de *supervision distante* a permis de contourner le coût de l'annotation manuelle et de créer un corpus de taille suffisante pour entraîner des classifieurs supervisés. Les modèles entraînés sur Sentiment140 (Naïve Bayes, Maximum Entropy, SVM) ont démontré leur capacité à généraliser à d'autres tweets.
    
    #figure(
      table(
        columns: (1fr, 2fr, 1fr),
        inset: 7pt,
        align: (left, left, left),
        fill: (x, y) => 
          if y == 0 {  }
          else if calc.rem(y, 2) == 1 {  }
          else { white },
        stroke: 0.5pt + black,
        [#text(fill: black)[*Classe*]], [#text(fill: black)[*Critère d'annotation*]], [#text(fill: black)[*Volume*]],
        [Positif], [Présence de ":)", ":-,
  kind: table
)", ":D"], [~800 000],
        [Négatif], [Présence de ":(", ":-(", ":'("], [~800 000],
        [Neutre], [Absence d'émoticônes ou présence des deux], [Non inclus]
      ),
      caption: [Distribution du dataset Sentiment140]
    )

==== Basés sur le Deep Learning

*1.Hugging Face et l'écosystème Transformers*

    Hugging Face est devenue la plateforme de référence pour les modèles de deep learning en NLP. Sa bibliothèque `transformers` donne accès à des milliers de modèles pré-entraînés, dont beaucoup sont optimisés pour l'analyse de sentiments.
    
    Un exemple représentatif est le modèle *`customer-sentiment-analyzer`* d'IberaSoft, un DistilBERT fine-tuné sur 20 000 avis clients e-commerce et SaaS. Ses caractéristiques illustrent les standards actuels :
    
    #figure(
      table(
        columns: (1.2fr, 2.5fr),
        inset: 7pt,
        align: (left, left),
        fill: (x, y) => 
          if y == 0 {  }
          else if calc.rem(y, 2) == 1 { }
          else { white },
        stroke: 0.5pt + black,
        [#text(fill: black)[*Caractéristique*]], [#text(fill: black)[*Valeur*]],
        [Modèle de base], [DistilBERT (66M paramètres)],
        [Données d'entraînement], [20 000 avis Amazon, Yelp, G2, Capterra, TrustRadius],
        [Distribution des classes], [Positif 40%, Négatif 35%, Neutre 25%],
        [Précision], [90,2%],
        [Temps d'inférence (CPU)], [~35 ms par prédiction],
        [Taille du modèle], [268 Mo (67 Mo après quantification INT8)]
      ),
      caption: [Caractéristiques du modèle customer-sentiment-analyzer],
  kind: table
    )
    
    Les modèles Hugging Face peuvent être déployés en production via des API (FastAPI), conteneurisés avec Docker, et optimisés via quantification pour réduire leur empreinte mémoire.

=== Plateformes Commerciales de Social Listening

Les plateformes de *social listening* (écoute sociale) sont des solutions intégrées qui permettent aux entreprises de surveiller, analyser et répondre aux conversations en ligne. Une étude comparative de 13 outils majeurs révèle la diversité des fonctionnalités disponibles.

#figure(
  table(
    columns: (1fr, 1.7fr, 1.5fr, 1.5fr),
    inset: 7pt,
    align: (left, left, left, left),
    fill: (x, y) => 
      if y == 0 {  }
      else if calc.rem(y, 2) == 1 {  }
      else { white },
    stroke: 0.5pt + black,
    [#text(fill: black)[*Outil*]], [#text(fill: black)[*Analyse de sentiments*]], [#text(fill: black)[*Données historiques*]], [#text(fill: black)[*Prix*]],
    [Hootsuite], [ Améliorée], [7 jours], [À partir de 99\$/mois],
    [Talkwalker], [ IA multilingue], [Jusqu'à 2 ans], [Sur devis],
    [Brandwatch], [ NLP + analyse visuelle], [Depuis 2010], [Sur devis],
    [Sprout Social], [ Nuages de mots + IA], [Jusqu'à 7 jours (X)], [À partir de 199\$/utilisateur/mois],
    [Brand24], [ Temps réel + émotions], [~1 an], [À partir de 119\$/mois],
    [Meltwater], [ Reconnaissance d'émotions], [Archive 15 mois], [Sur devis],
    [Sprinklr], [ GenAI], [Archive étendue], [Sur devis]
  ),
  caption: [Comparaison des principales plateformes de social listening],
  kind: table  
)   

*Critères de sélection* : Le choix d'une plateforme dépend de plusieurs facteurs :
- *Taille de l'entreprise* : les solutions comme Hootsuite conviennent aux équipes en croissance, tandis que Brandwatch ou Sprinklr sont orientées grands comptes
- *Profondeur d'analyse* : besoin de données en temps réel (crise) ou d'analyse historique (recherche)
- *Couverture linguistique* : certaines plateformes offrent une analyse multilingue plus robuste
- *Budget* : des options gratuites existent (Google Alerts, Social Mention) mais avec des fonctionnalités limitées 

== Conclusion

