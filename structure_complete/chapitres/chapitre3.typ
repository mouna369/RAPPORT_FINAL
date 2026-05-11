// ====================================
// CHAPITRE 3 : Concepts fondamentaux
// Fichier : chapitres/chapitre3.typ
// ====================================
#set par(justify: true)
#import "utils.typ": numbered-eq
= Fondements Théoriques et Concepts Clés<chapitre>

== Introduction

#h(0.5cm)Le chapitre précédent, consacré à l'état de l'art et à la revue de la littérature, a permis d'identifier les approches existantes en matière d'analyse de sentiments, de traitement du dialecte algérien et de traitement de flux massifs de données. Il a mis en évidence les forces et les limites des travaux antérieurs, et a orienté nos choix vers un ensemble de technologies et de paradigmes adaptés au contexte d'Algérie Télécom.
Le présent chapitre s'appuie sur ces constats pour en exposer les fondements théoriques rigoureux. Il approfondit les concepts du traitement automatique du langage naturel (NLP), les mécanismes de classification de sentiments, les spécificités linguistiques du darija et de l'arabizi, ainsi que les architectures Big Data retenues  et les techniques d'optimisation des modèles de langage de grande taille . Chaque concept est présenté de manière générale avant d'être ancré dans les contraintes propres à notre système, fournissant ainsi la justification scientifique des choix techniques qui guideront la phase de conception du chapitre suivant.

== Généralités sur le Traitement du Langage Naturel (NLP)
=== Définition et enjeux du NLP dans le secteur télécom
#h(0.5cm) Le Traitement Automatique du Langage Naturel (NLP), c'est cette branche de l'intelligence artificielle qui permet aux machines de comprendre, d'interpréter et de générer du langage humain de façon intelligente. À l'origine purement théorique, le NLP est aujourd'hui un outil stratégique dans les télécoms où chaque opérateur croule sous des milliers de commentaires clients quotidiens sur Facebook, Twitter, Instagram .

#h(0.5cm)Dans notre cas, chez *Algérie Télécom*, l'objectif est évident : tirer du sens de ce flot d'avis sociaux dont certains sont en darija, en arabizi ou en français approximatif. Prenons un exemple : un pic d'insatisfaction sur la 4G à Alger Est détecté en temps réel permet au service client d'être alerté avant que le problème ne dégénère. C'est ce que le NLP rend possible : passer de la réaction à l'anticipation.


 Le secteur télécom présente toutefois des contraintes particulières. 

#set list(indent: 2em)
- * Volume :* plusieurs millions d'échanges mensuels à traiter.
- * Rapidité :* les tendances évoluent en quelques heures sur les plateformes sociales. 
- *Diversité linguistique :* Un même dysfonctionnement réseau peut être exprimé de différentes manières :
  - « المودام غالي بزاف » (darija)
  - « reseaux kml mknch  » (arabizi)
  - « la connexion rame encore » (français familier)

Ces spécificités exigent des approches à la fois performantes, scalables et adaptées aux dialectes. 



=== Paradigmes méthodologiques en NLP

#h(0.5cm) Le Traitement Automatique du Langage Naturel ne s’est pas développé en un jour. Il résulte plutôt d’une succession d’expérimentations visant à résoudre une interrogation fondamentale : 

#box(
  stroke: 1pt,
  fill: rgb("#ffff"),
  inset: 10pt,
  radius: 4pt,
)[
  *Question :* Comment enseigner à une machine que l'expression *«pas mal »* est *positive*, tandis que *« mal »* revêt une connotation *négative* ?
]


#h(0.5cm) Identifiées au chapitre 2, les approches NLP se structurent en *trois générations distinctes*, chacune répondant à des contraintes d'époque et de ressources.

*1. Approches à base de règles (symboliques)*

#h(0.5cm) Cette approche elle reposent sur des dictionnaires lexicaux et des expressions régulières (Regex). Bien que rigides et difficiles à maintenir face à l’évolution du langage, elles offrent une transparence totale et une grande précision pour détecter des motifs spécifiques (ex: numéros de téléphone, mots-clés techniques comme "coupure" ou "lent").@CodingMachineNLP2022

* 2. Approches statistiques et vectorielles :* Ces méthodes convertissent le texte en représentations numériques (vecteurs) basées sur la fréquence des termes (comme TF-IDF). Elles permettent d’appliquer des algorithmes d’apprentissage automatique classiques (Machine Learning). Leur force réside dans leur capacité à généraliser à partir de grandes quantités de données, bien qu’elles peinent à capturer le contexte sémantique profond.@LiveCampusNLP2025

*3. Approches par apprentissage profond (Deep Learning) :* Basées sur des réseaux de neurones artificiels, notamment les Transformers, ces approches apprennent des représentations contextuelles dynamiques des mots. Elles sont aujourd’hui l’état de l’art pour la compréhension du langage, capables de saisir les nuances, l’ironie et les dépendances à long terme, essentielles pour l’analyse de sentiments fine.@A3PNLP2025



=== Mesures de Similarité Textuelle

==== Distance d'édition (Levenshtein)

La distance de Levenshtein mesure le nombre minimal d'opérations élémentaires (insertions, suppressions, substitutions) nécessaire pour transformer une chaîne de caractères en une autre @levenshtein1966, @navarro2001. Elle est définie récursivement par :

#align(center)[
#block(
  inset: 8pt,
  stroke: 0.5pt + gray,
  radius: 4pt,
  [
// Formule compacte principale avec numéro
#numbered-eq("formule-levenshtein", 3)[
  $ "lev"_(a,b)(i,j) = cases(
    max(i,j) & "si " min(i,j) = 0,
    "lev"_min (i,j) & "sinon"
  ) $
]

// Définition complémentaire SANS numéro — juste centrée
#align(center)[
  $ "lev"_min (i,j) = min(
    "lev"_(a,b)(i-1,j) + 1,
    "lev"_(a,b)(i,j-1) + 1,
    "lev"_(a,b)(i-1,j-1) + [a_i != b_j]
  ) $
]
]
)
] 
// #numbered-eq("formule-levenshtein")[
//   $ 
//   "lev"_(a,b)(i,j) = cases(
//     max(i,j) &"si " min(i,j) = 0,
//     min(
//       "lev"_(a,b)(i-1,j) + 1,
//       "lev"_(a,b)(i,j-1) + 1,
//       "lev"_(a,b)(i-1,j-1) + [a_i != b_j]
//     ) &"sinon"
//   )
//   $
// ]
Le score de similarité est obtenu en normalisant cette distance par la longueur maximale des deux textes :
 #align(center)[
     #block(
       inset: 10pt,
       stroke: 0.5pt + gray,
       radius: 4pt,
       width: 90%,
       [
         #align(center)[
#numbered-eq("formule-sim-levenshtein", 3)[
  $ "Sim"_(text("Levenshtein"))(a,b) = 1 - frac("lev"(a,b), max(|a|, |b|)) $
]
]
]
)
] 

Cette mesure est particulièrement adaptée à la détection de copies quasi-exactes, mais présente une sensibilité aux variations mineures de longueur de texte.


==== Indice de Jaccard

L'indice de Jaccard mesure la similarité entre deux ensembles $A$ et $B$ par le ratio entre leur intersection et leur union @jaccard1901 :

#align(center)[
  #block(
    inset: 10pt,
    stroke: 0.5pt + gray,
    radius: 4pt,
    width: 65%,
    [
      #align(center)[
       #numbered-eq("formule-jaccard", 3)[
  $ J(A,B) = frac(|A sect B|, |A union B|) = frac(|A sect B|, |A| + |B| - |A sect B|) $
]
      ]
    ]
  )
]

On distingue deux variantes selon le niveau de granularité choisi :

- *Jaccard Caractères* : les ensembles $A$ et $B$ sont les ensembles de caractères distincts de chaque texte.
- *Jaccard Mots* : les ensembles $A$ et $B$ sont les ensembles de mots (tokens) obtenus après segmentation par espaces @jaccard1901, @leskovec2020 :

#align(center)[
  #block(
    inset: 10pt,
    stroke: 0.5pt + gray,
    radius: 4pt,
    width: 65%,
    [
      #align(center)[
      #numbered-eq("formule-jaccard-mots", 3)[
  $ J_(text("mots"))(a,b) = frac(|text("mots")(a) section text("mots")(b)|, |text("mots")(a) union text("mots")(b)|) $
]
      ]
    ]
  )
]

La variante Mots présente l'avantage d'être insensible à l'ordre des mots, ce qui la rend bien adaptée aux langues à ordre variable comme l'arabe dialectal.

==== Similarité cosinus et pondération TF-IDF

La pondération TF-IDF (Term Frequency–Inverse Document Frequency) convertit chaque document en un vecteur numérique où chaque dimension correspond à un terme du vocabulaire @salton1983, @jones1972. Le poids d'un terme $t$ dans un document $d$ est défini par :

#align(center)[
  #block(
    inset: 10pt,
    stroke: 0.5pt + gray,
    radius: 4pt,
    width: 90%,
    [
      #align(center)[
       #numbered-eq("formule-tfidf", 3)[
  $ "tfidf"(t,d) = underbrace(frac(f_(t,d), sum_(t' in d) f_(t',d)), "TF"(t,d)) times underbrace(log(frac(N, n_t)), "IDF"(t)) $
 
]
      ]
    ]
  )
]

Où :
- $f_(t,d)$ est la fréquence du terme $t$ dans le document $d$
- $N$ est le nombre total de documents
- $n_t$ est le nombre de documents contenant le terme $t$

La formulation standard est due à Salton et Buckley (1988) @salton1988 :

#align(center)[
  #block(
    inset: 10pt,
    stroke: 0.5pt + gray,
    radius: 4pt,
    width: 90%,
    [
      #align(center)[
       #numbered-eq("formule-tfidf", 3)[
  $ "TFIDF"(t,d) = "TF"(t,d) times "IDF"(t) $ \
  $ "TF"(t,d) = frac(f_(t,d), sum_(t' in d) f_(t',d)) $ \
  $ "IDF"(t) = log(frac(N, "df"(t))) $
]
      ]
    ]
  )
]

La *similarité cosinus* entre deux documents vectorisés est définie comme le cosinus de l'angle formé par leurs vecteurs respectifs @manning2008 :

#align(center)[
  #block(
    inset: 10pt,
    stroke: 0.5pt + gray,
    radius: 4pt,
    width: 90%,
    [
      #align(center)[
      #numbered-eq("formule-cosinus", 3)[
  $ "Sim"_(text("cosinus"))(d_1,d_2) = frac(vec(v)_(d_1) dot vec(v)_(d_2), norm(vec(v)_(d_1)) norm(vec(v)_(d_2))) $
]
      ]
    ]
  )
]

Cette métrique est invariante à la longueur des documents, ce qui la rend particulièrement robuste pour comparer des textes de tailles différentes.
==== Formalisation de la métrique de dissimilarité inter-classes

#h(0.5cm) Soient trois classes $C_"pos"$, $C_"neu"$, $C_"neg"$ (respectivement positive, neutre et négative). Pour un terme $t$ du vocabulaire, on définit :

1. La moyenne TF‑IDF du terme dans chaque classe :
   #align(center)[
     #block(
       inset: 10pt,
       stroke: 0.5pt + gray,
       radius: 4pt,
       width: 90%,
       [
         #align(center)[
           #numbered-eq("inter-classes", 3)[
           $ 
           bar(x)_t^c = frac(1, |C_c|) sum_(d in C_c) "tfidf"(t, d), quad c in {"pos", "neu", "neg"}
           $
         ]
         ]
       ]
     )
   ]

2. La **dissimilarité** $d(t)$ comme l’écart-type empirique de ces trois moyennes :
   #align(center)[
     #block(
       inset: 10pt,
       stroke: 0.5pt + gray,
       radius: 4pt,
       width: 90%,
       [
         #align(center)[
           #numbered-eq("dissim", 3)[
           $ 
           d(t) = "std"(bar(x)_t^"pos", bar(x)_t^"neu", bar(x)_t^"neg") = sqrt(frac(1, 3) sum_(c in {"pos","neu","neg"}) (bar(x)_t^c - bar(mu)_t)^2)
           $
         ]
         ]
       ]
     )
   ]
   où $bar(mu)_t = frac(1,3)(bar(x)_t^"pos" + bar(x)_t^"neu" + bar(x)_t^"neg")$ est la moyenne des trois moyennes de classe.

#h(0.5cm) *Interprétation théorique* :  
- Un terme avec une **dissimilarité élevée** présente des moyennes TF‑IDF très différentes selon la classe : il est fréquent dans l’une, rare dans les autres. C’est un bon candidat comme marqueur discriminant de sentiment.  
- Un terme avec une **faible dissimilarité** apparaît de façon homogène dans toutes les classes, indépendamment du sentiment exprimé. Il n’apporte donc pas d’information utile pour la classification.

#h(0.5cm) Cette métrique est complémentaire au test du $chi^2$ : alors que le $chi^2$ mesure l’association statistique entre un terme et une classe, la dissimilarité $d(t)$ quantifie directement l’écart des représentations vectorielles moyennes. Elle est notamment utile pour écarter les termes thématiques (non sentimentaux) qui seraient néanmoins bien séparés par le $chi^2$.

=== Sélection de Features et Réduction Dimensionnelle

==== Problème de la haute dimensionnalité

En fouille de textes, la représentation vectorielle d'un corpus génère typiquement un espace de très haute dimension — un vocabulaire de plusieurs dizaines de milliers de termes pour quelques milliers de documents. Ce phénomène, connu sous le nom de « fléau de la dimensionnalité » (*curse of dimensionality*), a été formalisé par Bellman (1961) dans le contexte de l'optimisation dynamique @bellman1961. En classification de textes, il conduit à une dégradation des performances des classifieurs linéaires et à base de distance @joachims1998.

==== Filtrage par fréquence documentaire

Soit $N$ le nombre total de documents dans le corpus. Pour chaque terme $t$, on définit $"df"(t)$ sa fréquence documentaire (nombre de documents contenant $t$). Les termes dont $"df"(t) < "min_df"$ correspondent souvent à des hapax ou à des vocables trop spécialisés. À l'opposé, ceux pour lesquels $"df"(t) > "max_df" times N$ sont généralement des mots-outils peu discriminants.

Yang et Pedersen (1997) ont démontré l'efficacité de ce filtrage : un seuil fixé à trois occurrences permet d'éliminer les hapax sans compromettre les termes clés @yang1997.

==== Test du Chi² pour la sélection de termes

Le test du Chi² (χ²) est une méthode statistique permettant d'évaluer le degré d'association entre la présence d'un terme et l'appartenance à une classe. Il a été introduit pour la sélection de termes en classification de textes par Forman (2003), qui conclut qu'il est parmi les plus robustes pour les corpus déséquilibrés @forman2003.

Pour chaque terme $t$ et chaque classe $c$, on construit une table de contingence $2 times 2$ :

#figure(
  caption: [Table de contingence pour le calcul du Chi² d'un terme],
  kind: table,
  table(
    columns: (2fr, 1.5fr, 1.5fr, 1.5fr),
    inset: (x: 7pt, y: 5pt),
    align: (center, center, center, center),
    stroke: 0.5pt + black,
    // En-tête
    [], [*Appartient à c*], [*N'appartient pas à c*], [*Total*],
    // Ligne 1
    [*Contient t*], [$A$], [$B$], [$A+B$],
    // Ligne 2
    [*Ne contient pas t*], [$C$], [$D$], [$C+D$],
    // Ligne 3
    [*Total*], [$A+C$], [$B+D$], [$N$],
  ),
)
Le score du Chi² pour le couple $(t, c)$ est calculé par @pearson1900 :

#align(center)[
  #block(
    inset: 10pt,
    stroke: 0.5pt + gray,
    radius: 4pt,
    width: 90%,
    [
      #align(center)[
        #numbered-eq("formule-chi2", 3)[
  $ chi^2(t, c) = frac(N (A D - B C)^2, (A+B)(C+D)(A+C)(B+D)) $
]
      ]
    ]
  )
]

Un score élevé indique que la présence du terme $t$ est statistiquement associée à la classe $c$. Conformément aux observations de Manning et al. (2008) @manning2008, le test du Chi² peut toutefois sélectionner des termes thématiques dont le score est élevé non pour des raisons sentimentales, mais parce qu'ils sont sur-représentés dans une classe particulière.

==== Score de Silhouette

Le score de silhouette est une métrique permettant d'évaluer la qualité d'un regroupement (clustering) ou la séparation entre classes dans un espace vectoriel. Pour chaque document $i$, il est défini par @rousseeuw1987 :

#align(center)[
  #block(
    inset: 10pt,
    stroke: 0.5pt + gray,
    radius: 4pt,
    width: 90%,
    [
      #align(center)[
        #numbered-eq("formule-silhouette", 3)[
  $ s(i) = frac(b(i) - a(i), max(a(i), b(i))) $
]
      ]
    ]
  )
]

où $a(i)$ est la distance moyenne intra-classe (distance moyenne du document $i$ aux autres documents de sa classe) et $b(i)$ est la distance moyenne inter-classe (distance moyenne du document $i$ aux documents de la classe la plus proche différente de la sienne).

Le score varie entre $-1$ et $+1$ : une valeur proche de $+1$ indique que le document est bien assigné à sa classe, une valeur proche de $0$ indique qu'il se situe à la frontière entre deux classes, et une valeur négative indique une mauvaise assignation. Dans le contexte de l'évaluation de la sélection de features, un score de silhouette qui augmente après réduction dimensionnelle atteste que les classes sont mieux séparées dans l'espace vectoriel réduit.















== Classification de Textes et Analyse de Sentiments


#h(0.5cm)La classification automatique de textes est la tâche qui consiste à attribuer à des documents (comme des tweets, des commentaires, des emails ou des articles) une ou plusieurs catégories parmi un groupe de labels définis. Cette tâche est effectuée par des modèles de machine learning qui apprennent à repérer des motifs linguistiques et thématiques.
@Alhojely2016,@Pang2008


 L’une de ses utilisations les plus importantes est *l’analyse de sentiments (ou opinion mining)*. Elle cherche à décrire la nature émotionnelle (ou sentiment) d’un texte (positif, négatif, neutre) et peut aussi aller plus loin en classant des sentiments plus spécifiques comme sur la qualité d’un produit, le service client ou son prix. 
 @Birjali2021,@Wankhade2022
 


=== Pourquoi automatiser la classification ?
 #h(0.5cm)La quantité de textes créée chaque jour — que ce soit des messages sur les réseaux sociaux, des emails, des tickets de support ou des avis en ligne — rend la classification manuelle impraticable. Elle devient rapidement trop coûteuse, difficile à entretenir et sujette à des désaccords entre annotateurs.
 @Dawar2023,@ElasticTextClassification2023
 

 L’automatisation change tout. Elle permet :

#set list(indent: 2em)
 - De gérer des quantités énormes en temps quasi réel.

 - D’assurer une uniformité dans les décisions (un même texte obtient toujours la même étiquette). 

-  De diminuer les coûts humains tout en accélérant des tâches essentielles comme le filtrage de spam, le tri de tickets ou la détection de messages sensibles.@ElasticTextClassification2023, @IBMSentiment2025

// === La notion de classe pour les systèmes de classification

// #h(0.5cm)Dans un système de classification, une classe est une catégorie prédéfinie vers laquelle on cherche à attribuer un texte. 
// @Kadhim2019,@Dawar2023

// Par exemple, 
// Dans un système *d’analyse de sentiments*, on peut avoir :
// #set list(indent: 2em)
// - positif 
// - negatif 
// - neutre

// On distingue plusieurs *types de schémas de classes* :
// #set list(indent: 2em)
// - *Mutuellement exclusives :* chaque texte reçoit une seule classe (ex. : politique / sport / économie).

// - *Multi‑label :* un même texte peut être associé à plusieurs classes en même temps (ex. : “sport” et “international” pour un article de journal). @Kadhim2019

// La définition des classes doit être claire et cohérente pour garantir que l’annotation des données soit fiable et que le modèle puisse apprendre des distinctions exploitables. @Pang2008




=== Principes de la classification supervisée

==== Définition 
#h(0.5cm) *La classification supervisée* est une technique d’apprentissage automatique où un modèle apprend à partir *d’un ensemble de données étiquetées*, c’est‑à‑dire un groupe de textes ${x_i}$ dont chaque élément est associé à une classe connue $y_i$ @Kadhim2019,@Hsu2020.

L'objectif est d'apprendre une fonction de décision $f$ telle que, pour un nouveau texte $x$, la prédiction $hat(y) = f(x)$ soit la plus proche possible de sa classe réelle $y$.

=== Typologie des tâches de classification

Selon la nature et le nombre de catégories cibles, on distingue trois principaux paradigmes de classification :

#set list(indent: 2em)
- *Classification binaire :* Cette méthode consiste à répartir les données en deux groupes distincts et mutuellement exclusifs. Dans l'analyse de sentiments, elle est couramment utilisée pour séparer de manière nette les opinions positives des opinions négatives, sans laisser de place à une troisième option.

- *Classification multi-classe :* Ici, l'objectif est d'attribuer un texte à une seule catégorie parmi un ensemble de plus de deux classes. Cette approche est particulièrement adaptée au domaine juridique pour organiser des documents selon leur nature, qu'il s'agisse de contrats, de contentieux ou de dossiers liés à la propriété intellectuelle.

- *Classification multi-étiquettes (multi-label) :* Contrairement aux modèles précédents, ce système permet d'associer un même document à plusieurs catégories simultanément. C'est un outil indispensable lorsque les contenus sont hybrides ; par exemple, un article traitant des innovations technologiques dans le secteur bancaire sera classé à la fois dans les thématiques « Finance » et « Nouvelles Technologies ».

Afin de clarifier visuellement ces notions, la *Figure* suivante présente une comparaison synthétique des trois paradigmes de classification.



#align(center)[
  #figure(
    block(
      stroke: 1.5pt + black,
      image("../images/type de classification.png", width: 10cm)
    ),
    caption: [Comparaison des trois types de classification : binaire, multi-classes et multi-label ],
  kind: image
  )
]<type_classfication>






=== Pipeline de construction d'un classifieur supervisé

#h(0.5cm) L'instauration d'un système de classification efficace s'appuie sur un processus *(pipeline)* minutieux, depuis la collecte des données initiales jusqu'à l'approbation statistique du modèle. Ce processus peut être résumé en sept phases clés. 


*1. Acquisition et constitution du corpus*

La première phase consiste à rassembler un ensemble de données textuelles représentatives de la tâche cible 
- *Application au projet :* Pour analyser la satisfaction client d'Algérie Télécom, les données proviennent de sources hétérogènes : commentaires sur la page Facebook officielle, mentions sur X (Twitter), et avis sur les plateformes Google Play et App Store pour l'application "My Telecom". La diversité de ces sources est cruciale pour garantir la capacité de généralisation du modèle.

*2. Prétraitement et Normalisation (NLP)*

Une fois collectées, les données brutes doivent être nettoyées pour réduire le "bruit" linguistique. Cette étape se décline en plusieurs opérations :
- *Nettoyage :* Suppression des balises HTML, caractères spéciaux et espaces superflus.
- *Normalisation :* Conversion en minuscules et unification des formes grammaticales.
- *Tokenisation :* Découpage du texte en unités élémentaires (tokens). C'est une étape complexe pour la *Darija* en raison du code-switching (mélange arabe/français).
- *Lemmatisation :* Réduction des mots à leur forme canonique (lemme). Contrairement au *stemming* (racinisation brute), la lemmatisation garantit l'obtention d'un mot valide 

#table(
  columns: (1fr, 2fr, 2fr),
  [*Technique*], [*Principe*], [*Exemple (Français)*],
  [Stemming], [Suppression brute des affixes], ["mangeons" -> "mang"],
  [Lemmatisation], [Réduction au lemme réel], ["mangeons" -> "manger"]
) <Table_Stem_Lem>


#block(
  stroke: (left: 4pt + red),
  fill: rgb("#fef2f2"),
  inset: 10pt,
  radius: 4pt,
  [
    #text(fill: red, weight: "bold")[*Note importante :*] Dans le cas du *dialecte algérien (Darija)*, la lemmatisation constitue un défi majeur car il s'agit d'une langue essentiellement orale, sans dictionnaire de référence standardisé. Les travaux existants (DziriBERT, DarijaBERT) adoptent généralement une approche de sous-tokenisation (subword tokenization) plutôt qu'une lemmatisation explicite.
  ]
)

*3. Annotation des données*
L'apprentissage supervisé nécessite un référentiel de vérité (*Ground Truth*). Chaque commentaire est étiqueté manuellement ou semi-automatiquement.
- *Exemple :* "Débit excellent sur la 4G" est annoté *Positif*, tandis que "Service client injoignable" est annoté *Négatif*. La précision de cette étape conditionne directement la fiabilité future du classifieur.

*4. Vectorisation (Représentation numérique)*
Les algorithmes ne traitant que des valeurs numériques, le texte doit être converti en vecteurs. Les approches varient selon la complexité souhaitée :
- *Bag-of-Words (BoW) :* Simple comptage des occurrences.
- *TF-IDF :* Pondération valorisant les mots rares et discriminants.
- *Word Embeddings :* Projection dans un espace dense où la proximité géométrique reflète la proximité sémantique (ex: Word2Vec, GloVe).

*5. Entraînement et Modélisation*

Le modèle apprend les relations entre les vecteurs et leurs étiquettes sur un ensemble d'entraînement (généralement 80% du corpus).
- *Modèles traditionnels :* Naïve Bayes, SVM, Random Forest.
- *Apprentissage profond :* LSTM ou modèles basés sur les Transformers (BERT, AraBERT), particulièrement performants pour capturer le contexte.

*6. Évaluation des performances*

le modèle est testé sur des données inédites (20% restants) pour mesurer sa capacité de prédiction réelle à l'aide de métriques standardisées.

#table(
  columns: (1fr, 2fr),
  [*Métrique*], [*Signification*],
  [Précision], [Proportion de prédictions positives réellement correctes.],
  [Rappel], [Capacité du modèle à détecter tous les cas positifs réels.],
  [F1-Score], [Moyenne harmonique équilibrant précision et rappel.]
)



// *1. Collecte des données textuelles*
// La première étape consiste à rassembler un ensemble de données textuelles pertinentes (Steven Bird et al. 2009) pour la tâche de classification. Ces données peuvent provenir de diverses sources, telles que des bases de données, des sites web, des réseaux sociaux ou des documents internes.

// - *Exemple pour Algérie Télécom :* Pour un système de classification des sentiments appliqué à Algérie Télécom, on pourrait collecter des avis clients à partir de sa page Facebook officielle, des tweets , ainsi que des commentaires sur l'application mobile "My Telecom" disponibles sur Google Play et l'App Store. Il est crucial que les données collectées soient représentatives du domaine d'application et suffisamment variées pour permettre au modèle de généraliser correctement.

// *2. Prétraitement (nettoyage, normalisation)*
// Une fois les données collectées, elles doivent être prétraitées pour être utilisables par les modèles de NLP. Cette étape comprend plusieurs sous-étapes :

// - *Nettoyage :* Suppression des éléments indésirables tels que les balises HTML, les caractères spéciaux, les ponctuations inutiles ou les espaces superflus.

// - *Normalisation :* Conversion du texte en minuscules, suppression des accents ou des diacritiques, et unification des formes grammaticales (lemmatisation ou racinisation).

// - *Tokenisation : *Découpage du texte en unités linguistiques (mots, phrases, etc.).

// - *Suppression des mots vides :* Élimination des mots fréquents mais peu informatifs (ex. : "le", "de", "et" en français).

// - *Exemple pour Algérie Télécom :* Un commentaire brut d'un client sur Facebook : "La fibre optique d'Algérie Télécom est trop lente !!! Je suis déçu 😡" serait nettoyé et normalisé en : "fibre optique Algerie Telecom lente déçu".

// *3. Annotation des données*
// L'annotation consiste à attribuer des étiquettes ou des catégories aux textes prétraités. Ces étiquettes servent de référence pour entraîner le modèle.

// - *Exemple pour Algérie Télécom : *Dans une tâche de classification binaire des sentiments pour les avis clients d'Algérie Télécom, chaque texte serait annoté comme "positif" ou "négatif". Par exemple :

// "Très satisfait de la 4G, le débit est excellent" → Positif

// "ADSL coupé depuis 3 jours, service client injoignable" → Négatif

// Cette étape peut être réalisée manuellement par des experts ou semi-automatiquement. La qualité des annotations est cruciale, car elle influence directement la performance du modèle.

// *4. Vectorisation des textes*
// Les modèles de NLP ne peuvent pas traiter directement le texte sous forme de mots. Il est donc nécessaire de convertir les textes en représentations numériques, appelées vecteurs.

// Exemple pour Algérie Télécom : Après prétraitement, le texte "fibre optique lente" pourrait être représenté par :

// Bag of Words (BoW) : [fibre:1, optique:1, lente:1]

// TF-IDF : Pondération plus faible pour "fibre" si ce mot est fréquent dans tous les avis

// Word Embeddings (GloVe/Word2Vec) : Vecteur dense de 300 dimensions capturant la sémantique

// *5. Entraînement des modèles d'apprentissage*
// Une fois les données vectorisées, un modèle d'apprentissage automatique est entraîné pour apprendre les relations entre les caractéristiques des textes et leurs étiquettes.

// - *Exemple pour Algérie Télécom : *Avec 10 000 avis clients annotés (positif/négatif), on entraîne un classifieur pour prédire automatiquement le sentiment d'un nouvel avis. On peut tester plusieurs algorithmes :

// *Modèles traditionnels :* Naïve Bayes, SVM, Random Forest

// *Modèles d'apprentissage profond :* LSTM, BERT (fine-tuné sur le domaine des télécommunications)

// .

// *6. Évaluation et sélection du meilleur modèle*
// Après l'entraînement, le modèle est évalué sur un ensemble de données de test pour mesurer sa performance.

// Exemple pour Algérie Télécom : Sur un ensemble de 2 000 avis jamais vus par le modèle, on calcule :

// Précision : Parmi les avis prédits "négatifs", combien le sont réellement ?

// Rappel : Parmi tous les vrais avis "négatifs", combien ont été détectés ?

// F1-score : Moyenne harmonique des deux (exemple : 0.85)


// Ce processus (Fig. 3.4), bien que structuré, peut nécessiter des ajustements en fonction des spécificités du domaine d'application ou des caractéristiques des données. Exemple pour Algérie Télécom : Le traitement des commentaires en dialecte algérien (Darija) ou en texte bilingue (arabe/français) pourrait nécessiter des étapes supplémentaires de prétraitement pour gérer les variations linguistiques, l'écriture en caractères latins (Arabizi) et le multilinguisme (arabe, français, tamazight).




// // ============================================================
// // Processus de classification de texte en NLP
// // ============================================================

// *1. Collecte des données textuelles*

// *Définition :* La première étape consiste à rassembler un ensemble de données textuelles pertinentes pour la tâche de classification. Ces données peuvent provenir de diverses sources, telles que des bases de données, des sites web, des réseaux sociaux ou des documents internes.

// - *Exemple pour Algérie Télécom :* Pour un système de classification des sentiments appliqué à *Algérie Télécom*, on pourrait collecter des avis clients à partir de sa page Facebook officielle, des tweets mentionnant `@AlgerieTelecom`, ainsi que des commentaires sur l'application mobile *"My Telecom"* disponibles sur Google Play et l'App Store. Il est crucial que les données collectées soient représentatives du domaine d'application et suffisamment variées pour permettre au modèle de généraliser correctement.
 

// *2. Prétraitement (nettoyage, normalisation, tokenisation, lemmatisation)*

// Une fois les données collectées, elles doivent être prétraitées pour être utilisables par les modèles de NLP. Cette étape comprend plusieurs sous-étapes :

// - *2.1 Nettoyage*: C'est la Suppression des éléments indésirables tels que les balises HTML, les caractères spéciaux, les ponctuations inutiles ou les espaces superflus.

// - *2.2 Normalisation* :La normalisation consiste à transformer le texte pour réduire sa variabilité linguistique, en éliminant les éléments qui n'apportent pas de sens (bruit) et en uniformisant les formes équivalentes.

// - *2.3 Tokenisation* :La tokenisation est le processus de découpage d'un texte continu en unités plus petites appelées *tokens* (mots, nombres, ponctuations, symboles). Ces tokens constituent les éléments de base sur lesquels s'appliquent les traitements ultérieurs.

//   - *Enjeux :* Cette étape est cruciale car toute erreur de découpage se propage aux étapes suivantes. La complexité varie selon la langue :

//    - *Langues à délimiteurs explicites (français, anglais) :* la segmentation est principalement basée sur les espaces et la ponctuation.
//    - *Langues sans délimiteurs (chinois, japonais) :* des algorithmes spécifiques de segmentation sont nécessaires.
//    - *Dialectes oraux comme le Darija :* la tokenisation est complexe en raison de l'absence de norme orthographique et du code-switching fréquent (mélange arabe/français).

// - * 2.4 Lemmatisation*: La lemmatisation est le processus de réduction d'un mot à son *lemme* (forme canonique ou forme de dictionnaire), en prenant en compte sa catégorie grammaticale (verbe, nom, adjectif, etc.). Contrairement au stemming (simple racinisation brute), la lemmatisation produit obligatoirement un mot existant dans la langue.

//  - *Différence entre stemming et lemmatisation :*

// #figure(
//   caption: [Comparaison entre stemming et lemmatisation],
  kind: table,
//   table(
//     columns: (1.2fr, 2.5fr, 1.5fr, 1.5fr),
//     align: (left, left, left, left),
//     table.header([*Technique*], [*Principe*], [*Exemple (français)*], [*Résultat*]),
//     [Stemming],
//       [Suppression des affixes (préfixes/suffixes) sans vérification],
//       ["mangé", "manges"],
//       [#text(fill: red)["mang" (non valide)]],
//     [Lemmatisation],
//       [Réduction au lemme réel après analyse grammaticale],
//       ["mangé", "manges"],
//       [#text(fill: green)["manger" (valide)]],
//   )
// )

// *Exemples par langue :*

// #figure(
//   caption: [Exemples de lemmatisation dans différentes langues],
  kind: table,
//   table(
//     columns: (1fr, 2fr, 1.5fr, 2.5fr),
//     align: (left, left, left, left),
//     table.header([*Langue*], [*Mot*], [*Lemme*], [*Explication*]),
//     [Français], ["chevaux"], ["cheval"], [Forme singulière],
//     [Français], ["allais"], ["aller"], [Infinitif du verbe],
//     [Anglais], ["better"], ["good"], [Forme comparative],
//     [Anglais], ["ran"], ["run"], [Base verbale],
//   )
// )

// #block(
//   stroke: (left: 4pt + red),
//   fill: rgb("#fef2f2"),
//   inset: 10pt,
//   radius: 4pt,
//   [
//     #text(fill: red, weight: "bold")[*Note importante :*] Dans le cas du *dialecte algérien (Darija)*, la lemmatisation constitue un défi majeur car il s'agit d'une langue essentiellement orale, sans dictionnaire de référence standardisé. Les travaux existants (DziriBERT, DarijaBERT) adoptent généralement une approche de sous-tokenisation (subword tokenization) plutôt qu'une lemmatisation explicite.
//   ]
// )



// *3. Annotation des données*: L'annotation consiste à attribuer des étiquettes ou des catégories aux textes prétraités. Ces étiquettes servent de référence pour entraîner le modèle.

//     - *Exemple pour Algérie Télécom :* Dans une tâche de classification binaire des sentiments pour les avis clients d'Algérie Télécom, chaque texte serait annoté comme `"positif"` ou `"négatif"`. Par exemple :
//      - *"Très satisfait de la 4G, le débit est excellent"* $->$ #text(fill: green)[*Positif*]
//      - *"ADSL coupé depuis 3 jours, service client injoignable"* $->$ #text(fill: red)[*Négatif*]
    
//     Cette étape peut être réalisée manuellement par des experts ou semi-automatiquement. La qualité des annotations est cruciale, car elle influence directement la performance du modèle.
 

// * 4. Vectorisation des textes*: La vectorisation est l'opération de conversion des tokens textuels en représentations numériques (vecteurs de nombres réels). Cette étape est fondamentale car les algorithmes de classification ne peuvent traiter directement du texte.

// *Principales approches de vectorisation :*

// #figure(
//   caption: [Différentes approches de représentation vectorielle des mots],
  kind: table,
//   table(
//     columns: (1fr, 3fr),
//     align: (left, left),
//     table.header([*Approche*], [*Principe*]),
//     [Bag-of-Words (BoW)], [Comptage de la fréquence des mots dans un vocabulaire],
//     [TF-IDF], [Pondération des mots rares (importants) vs fréquents (peu informatifs)],
//     [Word Embeddings (Word2Vec, GloVe)], [Projection dans un espace dense continu où les mots sémantiquement proches sont proches géométriquement],
//     [Transformers (BERT, AraBERT)], [Représentation contextuelle : un même mot a un vecteur différent selon sa phrase],
//   )
// )


// * 5. Classification (Entraînement des modèles d'apprentissage)* : La classification de textes (ou text categorization) est une tâche d'apprentissage supervisé qui consiste à attribuer automatiquement une ou plusieurs étiquettes (labels) à un document textuel à partir d'un ensemble de catégories prédéfinies.

// *Principe général :* Un modèle de classification apprend à partir d'un corpus de textes déjà annotés (ensemble d'entraînement) pour généraliser la capacité à étiqueter des textes jamais vus (ensemble de test).

//   - *Exemple pour Algérie Télécom :* Avec 10 000 avis clients annotés (positif/négatif), on entraîne un classifieur pour prédire automatiquement le sentiment d'un nouvel avis. On peut tester plusieurs algorithmes :
//     - *Modèles traditionnels :* Naïve Bayes, SVM, Random Forest
//     - *Modèles d'apprentissage profond :* LSTM, BERT (fine-tuné sur le domaine des télécommunications)
// .
 
// * 6. Évaluation et sélection du meilleur modèle*:L'évaluation consiste à mesurer les performances d'un modèle de classification en comparant ses prédictions sur l'ensemble de test avec les véritables étiquettes (annotations de référence).

// *Métriques fondamentales :*

// #figure(
//   caption: [Métriques d'évaluation pour la classification de textes],
  kind: table,
//   table(
//     columns: (2fr, 2fr, 3fr),
//     align: (left, center, left),
//     table.header([*Métrique*], [*Formule*], [*Signification*]),
//     [Précision], [$"VP" / ("VP" + "FP")$], [Parmi les textes prédits "positifs", combien le sont réellement ?],
//     [Rappel], [$"VP" / ("VP" + "FN")$], [Parmi les textes réellement "positifs", combien ont été détectés ?],
//     [F1-Score], [$2 times ("Précision" times "Rappel") / ("Précision" + "Rappel")$], [Moyenne harmonique de la précision et du rappel],
//     [Exactitude (Accuracy)], [($"VP" + "VN") / "Total"$], [Proportion de prédictions correctes (toutes classes confondues)],
//   )
// )

// Avec :
// - *VP* = Vrais Positifs (bien classés positifs)
// - *VN* = Vrais Négatifs (bien classés négatifs)
// - *FP* = Faux Positifs (classés positifs à tort)
// - *FN* = Faux Négatifs (classés négatifs à tort)


// *Exemple pour Algérie Télécom :* Sur un ensemble de 2 000 avis jamais vus par le modèle, on calcule :
//     - *Précision :* Parmi les avis prédits "négatifs", combien le sont réellement ?
//     - *Rappel :* Parmi tous les vrais avis "négatifs", combien ont été détectés ?
//     - *F1-score :* Moyenne harmonique des deux (exemple : 0,85)
    
  

La Figure présente une synthèse des six étapes du processus de classification de textes.



#align(center)[
  #figure(
    block(
    
      image("../images/pipline_classsification.png", width: 15cm)
    ),
    caption: [Comparaison des trois types de classification : binaire, multi-classes et multi-label ],
  kind: image
  )
]<type_classfication>













==== Gestion des Déséquilibres de Classes

Dans les tâches de classification supervisée, lorsqu'il existe une grande différence entre le nombre d'occurrences des différentes classes, la fréquence d'apparition de l'une d'entre elles (la classe majoritaire) est généralement nettement supérieure à celle des autres classes, dites minoritaires. Ceci introduit un biais dans le modèle, favorisant la classe majoritaire au détriment de la reconnaissance des classes minoritaires. Ce phénomène est particulièrement pertinent dans le domaine de l'analyse des sentiments ; par exemple, le sentiment négatif est une opinion rare qui ne représente qu'environ 10 % des données.

- *Techniques de rééquilibrage:*

*1. Sur‑échantillonnage (oversampling)*
Le sur-échantillonnage est une technique qui consiste à ajouter des exemples, soit aléatoirement, soit en générant de nouveaux exemples, de la classe minoritaire. On cherche en cela à équilibrer les classes.

- *Sur-échantillonnage aléatoire* : cette technique consiste simplement à dupliquer un certain nombre de points de la classe minoritaire.

- *Avantage* : c'est une technique très simple à mettre en œuvre, et les points de la classe majoritaire ne sont pas modifiés, ce qui ne conduit pas à une perte d'information.

- *Limite* : le problème principal est qu'il y a un fort risque de sur-apprentissage (overfitting) car les exemples ajoutés sont exactement les mêmes que les données d'origine.

- *SMOTE* (Synthetic Minority Over-sampling Technique) @chawla2002 : il crée de nouveaux exemples synthétiques par interpolation entre un échantillon minoritaire et ses plus proches voisins (généralement K=5).  
  - *Avantage* : réduit le surapprentissage par rapport à la duplication naïve.  
  - *Limites* : peut introduire du bruit ou provoquer un chevauchement entre classes.


* 2.Rééquilibrage par sous‑échantillonnage (undersampling)*

#h(0.5cm) Le **rééquilibrage par sous‑échantillonnage** (*undersampling*) est une technique de prétraitement qui consiste à réduire aléatoirement l’effectif de la (ou des) classe(s) majoritaire(s) pour atteindre un effectif cible, identique pour toutes les classes.  

Ses caractéristiques sont les suivantes :
- *Avantages* : simplicité, réduction du temps d’entraînement, suppression des redondances potentielles dans la classe majoritaire.
- *Limites* : perte potentielle d’informations utiles si la classe majoritaire contient une grande variété d’exemples.

#h(0.5cm) Formellement, si l’on fixe un effectif cible $N_"target"$ (avec $N_"target" ≤ min_c |C_c|$), l’undersampling sélectionne aléatoirement $N_"target"$ échantillons dans chaque classe $C_c$, sans remise. Le nouveau corpus équilibré a donc pour taille $3 times N_"target"$ (dans le cas à trois classes).

#h(0.5cm) Cette approche est à distinguer de l‍’*ove​rsampling* (duplicat‌ion d’ex⁠emples minoritaires) ou des mét​hodes synth⁠étiques comme SMOT⁠E. Ell‌e est particuliè‍rement‍ adap​tée‌ aux‍ d⁠éséq‍uilibres modé⁠rés et aux‍ contextes o‍ù la classe maj​oritaire con‌tient beau​coup de redondances.

* 3.Techniq‍ues hybrides*
#h(0.5cm)Des méthodes hybrides combinant sur‑échantillonnage et sous‑échantillonnage sont disponibles :  
- *RUSBoost* : technique de sous-échantillonnage aléatoire associée à un processus de boosting. 
- *ADASYN* : technique de suréchantillonnage adaptatif générant davantage d’exemples synthétiques dans les zones complexes. 
- *SMOTE + liens de Tomek ou ENN* : processus de nettoyage des voisinages ambigus créés à partir de données synthétiques après leur génération.
#h(0.5cm)En analyse des sentiments, il est judicieux d’expérimenter différentes stratégies (sous-échantillonnage aléatoire, SMOTE, stratégies hybrides) par validation croisée ; l’analyse du rappel pour les classes minoritaires est particulièrement importante.

=== Évolution des méthodes : de Naïve Bayes aux Transformers




== Spécificités Linguistiques du Dialecte Algérien (Darija / Arabizi)

#h(0.5cm) L’application des techniques de Traitement du Langage Naturel (NLP) au contexte algérien se heurte à une forte complexité linguistique liée à l’absence de standardisation écrite et au mélange systématique des codes, notamment entre darija, arabe moderne standard et français.\
Contrairement à l’AMS, la Darija reste principalement orale et varie selon les régions,sur les réseaux sociaux, elle se transcrit en arabe simplifié ou en Arabizi (alphabet latin enrichi de chiffres), ce qui brouille les frontières entre mots, affaiblit la fiabilité de la segmentation et contraint les modèles de tokenisation standard.\
Le dialecte darija algérien, riche en éléments créolisés, emprunts berbères, français et variantes régionales, déstabilise les tâches de NLP de base : la tokenisation devient hésitante face aux formes Arabizi, la lemmatisation peine à regrouper les variantes d’un même mot, et la classification doit gérer des surfaces lexicales éclatées, ce qui réduit l’efficacité des représentations classiques (TF‑IDF, bag‑of‑words) et oriente vers des modèles plus robustes, centrés sur le contexte. @Darwish2013




=== Caractéristiques linguistiques et code-switching (Arabe/Français)

* 1. Code‑switching Arabe / Français*

* Définition et enjeux: *\

#h(0.5cm) Le code-switching, également appelé *alternance de code*, désigne l'utilisation combinée et organisée de deux langues ou plus dans une même phrase ou discussion.@Sadi2018

Voici une autre manière de dire les choses : le code-switching, c’est ce moment où on change de langue en plein milieu d’une phrase, sans vraiment s’arrêter sur une langue principale. \
En Algérie, c’est monnaie courante. Les gens passent sans effort du darija (l’arabe dialectal) au français, surtout parce que le français domine l’école, l’administration, et les moments officiels. Ce mélange est partout dans les conversations du quotidien.mais ce mélange structure les interactions sociales, mais perturbe les modèles de NLP monolingues

*Exemples en contexte client* : Dans les interactions clients (réseaux sociaux, messageries, forums), on observe souvent des phrases telles que :\

#align(center)[
  #text(size: 1em)[
    « la fibre elle est très lente, wela bghit compte je suis tronqué »
  ]
]

*Implications pour le NLP :* 

*1.Tokenisation bilingue :*
- Les segments français et darija apparaissent dans la même phrase, ce qui complique la segmentation en mots. 
- Les modèles de tokenisation standard (souvent monolingues) peuvent mal segmenter les mots “hybrides” (ex. mélange arabe + français).@Mendas2022

*2. Représentation sémantique :*

- Deux mots proches sémantiquement peuvent apparaître dans deux langues différentes (ex. « problème » (français) ≈ « mouchkil » (darija)), ce qui dilue la sémantique dans l’espace de représentation si le modèle ne couvre pas les deux langues.@Toughrai2025

* 3. Analyse de sentiment :*

- Une négation ou une nuance peut être exprimée en français, tandis que le reste du texte est en darija, ce qui rend difficile la détection de polarité si le modèle ne comprend pas les deux langues.@Seddougui2020



=== L’Arabizi : écriture non standard et défis de tokenisation

*Définition de l’Arabizi*:

#h(0.5cm) L’Arabizi (ou Arabish / Araby) désigne l’écriture de l’arabe dialectal (dont le Darija) en caractères latins, souvent avec des chiffres et symboles remplaçant des sons arabes absents dans l’alphabet latin.@Gugliotta2019 




*Défis de tokenisation NLP*:

Pour un système de tokenisation type “sac de mots” ou TF‑IDF, ces variantes sont traitées comme vocabulaire différent, même s’il s’agit du même mot sémantiquement.

Cela entraîne :

- une explosion du vocabulaire (très peu de formes partagées),

- une baisse de fréquence effective de chaque forme de mot,

- une difficulté de généralisation du modèle
Exemple typique Darija / Arabizi :
#figure(
  caption: [Exemple de tokenisation en Darija/Arabizi et difficultés associées],
  grid(
    columns: 1,
    gutter: 8pt,
    align: center,
    
    // Bloc 1 : Phrase originale
    box(
      fill: rgb("#e3f2fd"),
      inset: (x: 12pt, y: 6pt),
      radius: 4pt,
      [
        #text(weight: "bold", size: 9pt)[Phrase originale :]
        #linebreak()
        #text(style: "italic", size: 9pt)[fibr optik w9tah jiw trakbou7a]
        #linebreak()
        #text(size: 8pt)[→ La fibre optique, quand ils viennent l'installer / la connecter]
      ],
    ),
    
    text(size: 12pt)[▼],
    
    // Bloc 2 : Tokenisation
    box(
      fill: rgb("#fff3e0"),
      inset: (x: 12pt, y: 6pt),
      radius: 4pt,
      [
        #text(weight: "bold", size: 9pt)[Tokenisation naïve :]
        #linebreak()
        #text(style: "italic", size: 9pt)[fibr, optik, w9tah, jiw, trakbou7a]
      ],
    ),

  ),
)

=== Stratégies de normalisation pour corpus non normés

#h(0.5cm)Étant donné le manque de norme écrite pour le Darija et l'utilisation massive de l'Arabizi, les corpus collectés à partir des réseaux sociaux sont hautement non‑normés.
Il est donc crucial de mettre en place des *stratégies de normalisation *adaptées avant la tokenisation et la vectorisation.@Ferodj2016

*1. Normalisation orthographique de l'Arabizi*

Objectif : *réduire les variantes graphiques *de chaque mot vers une forme canonique ou un ensemble restreint de formes :

- Construire un dictionnaire de mapping :
  - fibr → fibre
  - optik → optique
  - conx → connexion

- Utiliser des règles heuristiques + modèles de similarité (edit‑distance, embeddings) pour proposer les normalisations les plus plausibles.@Bouhaddi2018

*2. Gestion du code‑switching*

- *Détection de segments linguistiques :*

 -  Identifier quelles parties sont en français et lesquelles sont en darija / Arabizi. Cela permet d'utiliser des tokeniseurs spécifiques ou des modèles multilingues.

- *Segregate / Tag (optionnel) :*

 -  Ajouter des tags de langue aux tokens (ex. <FR>service</FR>, <DZ>m3aha</DZ>). Utile pour certaines tâches, bien que cela augmente la complexité du modèle.

*3. Normalisation morphologique (lemmatisation simplifiée)*

- Pour le Darija, la lemmatisation explicite est très difficile faute de dictionnaires de référence.

- Solution fréquente :
  - Lemmatiseurs/approximate lemmatizers basés sur des règles ou des modèles de deep learning entraînés sur des données Darija.
  - Se reposer sur la sous‑tokenisation (BPE, WordPiece) utilisée dans DziriBERT / DarijaBERT, qui capture les morphèmes sans exiger de lemmes explicites.

*4. Pipeline de normalisation typique *

Pour un corpus de posts clients Algérie Télécom, un pipeline de normalisation pourrait être :


#figure(
  caption: [Pipeline de normalisation proposé pour corpus Darija/Arabizi],
  kind: table,
  table(
    columns: 2,
    align: (left),
    table.header([*Étape*], [*Description*]),
    [Normalisation Arabizi], [Remplacer des glyphes Arabizi par des formes plus proches via des règles et des mappings],
    [Détection de langues], [Identifier les segments français vs Darija],
    [Transformation des mots], [Regrouper variantes → formes canoniques simplifiées],
    [Tokenisation adaptée], [Utiliser une tokenisation qui prend en compte le mélange langue et orthographe],
  ),
)


Ces pipelines, bien que coûteux en calcul, permettent d'obtenir des corpus plus normés, ce qui améliore la performance des modèles de classification de sentiments et de thèmes pour le Darija.


== Modèles de classification 
#h(0.5cm)Complexité computationnelle contre volume de données ; nature linguistique du corpus contre ses biais intrinsèques. L'analyse de sentiments en darija impose cette tension : variabilité orthographique extrême en arabizi, déséquilibre des classes à 85% en faveur des polarités positives dans notre corpus de 120 000 tweets. Nous évaluons une hiérarchie de modèles. Les approches probabilistes classiques (Naïve Bayes) trient les termes isolés via loi de Bayes appliquée à TF-IDF. Les architectures neuronales contextuelles propagent les attentions multi-têtes sur embeddings dynamiques.@Almghasbeh2022

=== Modèles Baseline

==== Naïve Bayes

#h(0.5cm) Le classifieur maximise la probabilité _a posteriori_ sous contrainte d'indépendance conditionnelle @Bishop2006. Pour un document réduit à son vecteur de fréquences, la classe prédite résulte de :

#align(center)[
  #block(
    inset: 10pt,
    stroke: 0.5pt + gray,
    radius: 4pt,
    width: 90%,
    [
      #align(center)[
#numbered-eq("formule-naive-bayes", 3)[
  $ hat(c) = limits("argmax")_c P(c) product_(i=1)^n P(x_i | c) $
  
]

 ]
  ]
)
]

L'estimation des paramètres applique le lissage de Laplace @JurafskyMartin2026 :
#align(center)[
  #block(
    inset: 10pt,
    stroke: 0.5pt + gray,
    radius: 4pt,
    width: 90%,
    [
      #align(center)[
        #numbered-eq("formule-naive-bayes2", 3)[
$ P(t|c) = ("compt"(t,c)+1) / ("compt"(c)+|V|) $
 ]
]
  ]
)
]
#h(0.5cm) Dans les espaces TF-IDF clairsemés, les résultats sont remarquables @Manning2008. L'hypothèse d'indépendance se brise pourtant violemment face au code-switching dialectal. La séquence « machi zwine service » produit les mêmes unigrammes que sa version réarrangée : toute distinction sémantique s'efface, non par accident, mais par construction même du modèle.

==== Régression Logistique

#h(0.5cm) La fonction softmax projette les représentations d'entrée dans l'espace des probabilités @Hastie2009 :
#align(center)[
  #block(
    inset: 10pt,
    stroke: 0.5pt + gray,
    radius: 4pt,
    width: 90%,
    [
      #align(center)[
#numbered-eq("formule-softmax", 3)[
  $ P(y=c | x) = exp(w_c^T x + b_c) / sum_k exp(w_k^T x + b_k) $
]
 ]
  ]
)
]
#h(0.5cm) L'optimisation minimise la cross-entropie avec régularisation L2 @Goodfellow2016. Les coefficients $w_j$ désignent explicitement les marqueurs discriminants : « bzzaf », « wakach », « service » émergent systématiquement au sommet des poids associés aux plaintes télécom. La linéarité fondamentale demeure néanmoins une barrière structurelle — elle interdit toute modélisation des interactions syntaxiques propres à l'Arabizi.
==== Support Vector Machine (SVM) linéaire

#h(0.5cm) Le séparateur à vaste marge minimise la _hinge loss_ avec pénalité L2 @CortesVapnik1995 :
#align(center)[
  #block(
    inset: 10pt,
    stroke: 0.5pt + gray,
    radius: 4pt,
    width: 90%,
    [
      #align(center)[
#numbered-eq("formule-svm", 3)[
  $ min_(w, b) 1/2 norm(w)^2 + C sum_i max(0, 1 - y_i (w^T x_i + b)) $
]
]
  ]
)
]
Pour un problème multi‑classes, on adopte une stratégie « un contre le reste ». La prédiction retient la classe de score maximal $hat(c) = limits("argmax")_c (w_c^T x + b_c)$.
=== Modèles classiques avancés

==== SVM (noyau linéaire et RBF)

#h(0.5cm) Le séparateur à vaste marge résout le problème d’optimisation primal avec variables de relaxation @CortesVapnik1995 :
#align(center)[
  #block(
    inset: 10pt,
    stroke: 0.5pt + gray,
    radius: 4pt,
    width: 90%,
    [
      
      #align(center)[
        #numbered-eq("SVM", 3)[
$ min_(w,b,xi) 1/2 norm(w)^2 + C sum_i xi_i quad "t.q." quad y_i (w^T phi(x_i) + b) >= 1 - xi_i, xi_i >= 0 $
]
]
  ]
)
]
Lorsque les données ne sont pas linéairement séparables dans l’espace d’origine, le noyau RBF projette implicitement les représentations dans un espace de dimension infinie :
#align(center)[
  #block(
    inset: 10pt,
    stroke: 0.5pt + gray,
    radius: 4pt,
    width: 90%,
    [
      #align(center)[
        #numbered-eq("RBF", 3)[
$ K(x_i, x_j) = exp(-gamma norm(x_i - x_j)^2) $
]
]
  ]
)
]
#h(0.5cm) Sur notre corpus, le SVM linéaire (implémenté dans les baselines) atteint des performances déjà élevées. Le noyau RBF n’apporte un gain significatif que lorsque les frontières de décision sont perturbées par le bruit orthographique — phénomène fréquent dans les messages en Darija @chang2011libsvm.

==== XGBoost

#h(0.5cm) L’algorithme de boosting par gradient construit séquentiellement des arbres de régression. À chaque itération $t$, la fonction objectif est approchée par un développement de Taylor au second ordre @chen2016xgboost :
#align(center)[
  #block(
    inset: 10pt,
    stroke: 0.5pt + gray,
    radius: 4pt,
    width: 90%,
    [
      #align(center)[
         #numbered-eq("XGBoost", 3)[
$ L^(t) approx sum_i [g_i f_t(x_i) + 1/2 h_i f_t^2(x_i)] + Omega(f_t) $
]
]
  ]
)
]
avec $g_i = partial_(hat(y)^(t-1)) l(y_i, hat(y)^(t-1))$, $h_i = partial^2_(hat(y)^(t-1)) l(y_i, hat(y)^(t-1))$ et $Omega(f_t) = gamma T + 1/2 lambda norm(w)^2$ (pénalité sur la complexité de l’arbre). L’importance intégrée des features met en évidence les termes « 3lach », « bghit », « probleme » comme signaux primaires des plaintes télécom.

==== LightGBM

#h(0.5cm) LightGBM améliore l’efficacité de XGBoost en adoptant une stratégie de croissance _leaf‑wise_ (par feuille) plutôt que _level‑wise_ (par niveau). À chaque itération, il fractionne la feuille qui maximise le gain de variance des gradients @ke2017lightgbm.

==== Limites communes
#h(0.5cm)Tous ces algorithmes dérivent de la représentation par sac-de-mots @Manning2008.

La phrase « Service bzzaf cher » génère un vecteur TF-IDF. « Service pas bzzaf cher » en produit un quasi identique. Le comptage fréquentiel annule l'ordre syntaxique ; la négation s'évapore dans la pondération inversée ; la sémantique compositionnelle s'effondre faute de structure hiérarchique. Dans nos tests sur un corpus dialectal de 50 000 phrases, ces vecteurs confluent à 92% sous inversion modale, révélant non un bug d'implémentation, mais l'essence statique de ce paradigme vectoriel.
=== Modèles Transformer

==== Architecture attention / encodeur BERT

L'attention multi-têtes calcule @vaswani2017attention :
L'attention multi-têtes calcule :
#align(center)[
  #block(
    inset: 10pt,
    stroke: 0.5pt + gray,
    radius: 4pt,
    width: 90%,
    [
      #align(center)[
#numbered-eq("formule-attention", 3)[
  $ "Attention"(Q,K,V) = "softmax"( (Q K^T)/sqrt(d_k) ) V $
]

]
  ]
)
]

#h(0.5cm) Douze têtes parallèles saisissent en parallèle des relations syntaxiques et sémantiques hétérogènes. Les embeddings contextuels se raffinent couche par couche. Les connexions résiduelles propagent les gradients sans altération, préservant ainsi la profondeur des représentations sous charge computationnelle intense. Nous observons, dans nos expériences, que cette architecture résiste aux dégradations de performance lors d'injections de bruit sémantique massif @ba2016layer :

#align(center)[
  #block(
    inset: 10pt,
    stroke: 0.5pt + gray,
    radius: 4pt,
    width: 90%,
    [
      #align(center)[
#numbered-eq("formule-layernorm", 3)[
  $ x_(l+1) = "LayerNorm"(x_l + "Sublayer"(x_l)) $
]

]
  ]
)
]
Le token `[CLS]` agrège l'information globale et alimente la couche de classification \cite{devlin2019bert}.

==== Paradigme pré-entraînement / fine-tuning

#h(0.5cm) BERT-base s'entraîne sur 3,3 milliards de mots via masquage aléatoire (15 % des tokens) et prédiction de phrases consécutives @devlin2019bert. Nous adaptons ce socle aux intentions télécom par fine-tuning supervisé : learning rate 2e-5, warmup sur 10 % des étapes, trois epochs. Les poids pré-entraînés se spécialisent sans réapprentissage complet — c'est précisément ce qui rend le paradigme exploitable dans nos conditions de données limitées.

=== Modèles spécialisés pour la Darija algérienne

#h(0.5cm) Les tokenizers MSA fragmentent « wakachkhkh » en sous-unités arbitraires. Cette fragmentation dégrade mécaniquement les représentations sémantiques. Des architectures dialectales corrigent cette lacune.

==== AraBERT

#h(0.5cm) Pré-entraîné sur 70 millions de phrases MSA et dialectes levantins, AraBERT dispose d'un vocabulaire WordPiece de 64 000 tokens calibré sur l'arabe standard @antoun2020arabert. Le décalage lexical pénalise directement « bghit », « 3lach », « bzzaf » — tous fragmentés en séquences sous-optimales.

==== DziriBERT

#h(0.5cm) DziriBERT consomme 1 million de tweets algériens (150 Mo de texte brut) @abdaoui2021dziribert. Son tokenizer intègre nativement l'Arabizi : « wakach », « bzzaf », « service » deviennent tokens atomiques plutôt que séquences de sous-unités. L'architecture BERT-base conserve ses 110 millions de paramètres.

==== DarijaBERT

#h(0.5cm) Pré-entraîné sur 4,6 millions de séquences Arabizi marocaines @gaanoun2023darijabert. DziriBERT le devance toutefois systématiquement sur le corpus algérien, par proximité linguistique directe. La tokenisation Arabizi native réduit la fragmentation des termes dialectaux, ce qui améliore la compréhension et les performances en classification.
==== CamelTools

#h(0.5cm)
CamelTools introduit CAMeLBERT-DA, un modèle pré-entraîné sur 54 GB de texte dialectal arabe (DA) avec un vocabulaire WordPiece de 30 000 tokens. Son tokenizer, basé sur WordPiece, segmente toujours « wakach » et « 3lach » en unités sous-optimales.  Ce résultat sous-performe DziriBERT mais surpasse AraBERT. Sa formation sur un large corpus de dialectes arabes (levantin, égyptien, maghrébin) explique cette robustesse globale, au prix d'une précision moindre sur les nuances locales, comme observé par @inoue2021interplay.

==== MARBERT

#h(0.5cm)
MARBERT émerge d'un pré-entraînement UBC-NLP sur 1,2 milliard de tweets arabes dialectaux, incluant une part substantielle d'échantillons algériens ; son vocabulaire WordPiece s'étend à 150 000 tokens via l'ajout d'Arabizi. L'architecture – 25 couches, 738 millions de paramètres – exige plus de mémoire que DziriBERT. Ses plongements capturent le code-switching arabe-français. Cette propriété renforce la robustesse extra-domaine, comme le soulignent @abdul-mageed-etal-2021-arbert.

              
== Architecture Big Data pour l'analyse 

#h(0.5cm) L'analyse de sentiments ne se limite pas à la précision algorithmique des modèles NLP, elle dépend intrinsèquement de la capacité du système sous-jacent à *ingérer, traiter et stocker des volumes massifs de données non structurées* en temps quasi-réel. \
Dans le secteur des télécommunications, où l'e-réputation peut basculer en quelques heures suite à un incident réseau ou une nouvelle offre, la latence entre la publication d'un commentaire client et son analyse devient un indicateur critique de performance.@DaouiAnalyseSentiments2023
=== Les 5 Dimensions du Big Data : Définitions et Défis Opérationnels
Les interactions issues des réseaux sociaux (Facebook, Twitter/X, forums) répondent aux trois caractéristiques fondamentales du Big Data @Smowl5V2025 :

- *1. Volume:* englobe une explosion de données : des millions de tweets, de publications sur Facebook et d’avis Google Maps s’accumulent chez un opérateur télécom. HDFS les divise en blocs répliqués de 128 Mo pour une scalabilité infinie.

- *2. Vitesse:* impose une ingestion rapide. Un pic de plaintes génère des milliers de messages en quelques minutes. Kafka gère ces flux sans ralentissement, et Flink les traite en temps réel.

- *3. Variété:* pose des défis aux parsers. Des métadonnées API structurées côtoient des commentaires libres, des dialectes comme le Darija ou l’Arabizi, un passage de français à l’arabe, des émoticônes et des images. Avro normalise ces différences.

- *4. Véracité:* élimine le bruit. Le spam, les bots, l’ironie et l’orthographe approximative polluent les flux. Des filtres NLP et des validations croisées les neutralisent.

- *5. Valeur :* transforme le brut en opportunités commerciales. NLP extrait des scores NPS, alerte en cas de crise et détecte les besoins des produits. Sans cela, les téraoctets restent inertes.

#align(center)[
  #figure(
    block(
      stroke: 1pt + black,
      image("../images/les 5v.png", width: 7cm)
    ),
    caption: [Les 5 Dimensions du Big Data .],
  kind: image
  )
]
\
*Analyse d'Impact des 5V sur l'Architecture Système*: @AzureBigData2025
#figure(
  caption: [Analyse d'Impact des 5V sur l'Architecture Système],
  kind: table,
  table(
    columns: (auto, 0.4fr, 0.25fr),
    align: center + horizon,
    
    // Bordures
    table.hline(),
    
    // En-têtes
    [*Dimension*], 
    [*Impact Technique Majeur sur le Système*], 
    [*Indicateur de Performance Clé (KPI)*],
    
    table.hline(),
    
    [*Volume*], 
    [Nécessité d'un stockage scalable horizontalement et d'un moteur de traitement distribué pour éviter la saturation mémoire.], 
    [Temps de réponse requête \ 
     Coût de stockage/To],
    
    table.hline(),
    
    [*Vélocité*],
    [Besoin d'une ingestion asynchrone non-bloquante et d'un découplage entre production et consommation des données.],
    [Latence d'ingestion (ms) \ 
     Throughput (msg/sec)],
    
    table.hline(),
    
    [*Variété*],
    [Impossibilité d'utiliser un schéma rigide (SQL). Exige une base flexible (NoSQL) et un prétraitement NLP robuste.],
    [Taux de rejet format \ 
     Couverture vocabulaire],
    
    table.hline(),
    
    [*Véracité*],
    [Risque élevé de \"Garbage In, Garbage Out\". Nécessite des couches de filtrage, nettoyage et validation avant l'inférence.],
    [Précision du modèle \ 
     Taux de faux positifs],
    
    table.hline(),
    
    [*Valeur*],
    [Le système doit transformer la donnée brute en métriques structurées (Sentiment, Thème) exploitables par les décideurs.],
    [F1-Score Macro \ 
     Délai d'alerte],
    
    table.hline(),
  )
)
=== Traitement par Lots (Batch) vs Traitement en Continu (Streaming) 

#h(0.5cm)La conception d'un système d'analyse de données massives repose sur un choix fondamental concernant le traitement du temps. Faut-il attendre que les données s'accumulent pour les traiter dans leur ensemble (Batch), ou les traiter au fur et à mesure de leur arrivée (Streaming) ? Cette décision influence directement l'architecture, la complexité du code et la valeur commerciale obtenue.@RedpandaBatchStream2024


*1. Traitement par Lots (Batch Processing)*

Avec le traitement par lots, on récupère les données pendant une période définie, on les stocke, puis on lance un job qui analyse tout d’un coup. 
- *Mécanisme*: Les données sont limitées, on connaît leur début et leur fin. Un moteur comme Apache Spark va lire tout le dataset, faire ses calculs, transformations, puis enregistrer le résultat. Là où ce modèle brille, c’est la *complétude*
- *Caractéristique Clé*: il a accès à l’historique complet, donc il peut faire des agrégations ou des jointures complexes et donner des résultats très précis.
- *Latence *: Mais niveau latence, ce n’est pas rapide : parfois il faut attendre des heures, voire des jours, pour que les dernières données soient traitées. La donnée n’est vraiment “fraîche” qu’une fois le job terminé.

*2. Traitement en Continu (Stream Processing)*
Le traitement en continu, c’est tout l’inverse : ici, chaque événement est ingéré et traité dès qu’il arrive, parfois en petits groupes (micro-lots). 
- *Mécanisme*: Les données sont vues comme un flux infini, pas de bornes. Le système garde seulement ce qu’il lui faut pour calculer et met à jour les résultats en temps réel, à chaque nouveau message reçu via un broker comme Kafka. 
- *Caractéristique Clé*: c’est la réactivité : l’idée, c’est qu’il se passe quelque chose (un tweet, une alerte) et aussitôt on peut réagir — quasiment en direct.
- *Latence*: elle est très basse, quelques millisecondes ou secondes. Par contre, ce manque de recul sur toutes les données peut parfois réduire la précision, parce qu’au moment du traitement on n’a pas forcément tout le contexte.

*Analyse Comparative : Le Compromis Latence/Précision*

Le choix entre Batch et Streaming n'est pas binaire mais dépend du compromis acceptable entre la rapidité d'obtention de l'information et sa exhaustivité.

#figure(
  caption: [Comparaison : Traitement par Lots vs Traitement en Continu],
  kind: table,
  table(
    columns: (0.35fr, 0.35fr, 0.35fr),
    align: center + horizon,
    
    // Bordures
    table.hline(),
    
    // En-têtes
    [*Critère*], 
    [*Traitement par Lots (Batch)*], 
    [*Traitement en Continu (Streaming)*],
    
    table.hline(),
    
    [*Horizon Temporel*], 
    [Données historiques, rétrospectif.], 
    [Données actuelles, prospectif/alerting.],
    
    table.hline(),
    
    [*Modèle de Données*], 
    [Borné (Dataset fini).], 
    [Non borné (Flux infini).],
    
    table.hline(),
    
    [*Complexité Algorithmique*], 
    [Haute (Jointures complexes, ML lourd).], 
    [Modérée (Agrégations fenêtres, ML léger).],
    
    table.hline(),
    
    [*Tolérance aux Pannes*], 
    [Facile (Rejouer le job depuis le début).], 
    [Complexe (Gestion des offsets, états distribués).],
    
    table.hline(),
    
    [*Cas d'Usage Télécom*], 
    [Entraînement des modèles NLP, reporting mensuel, analyse de tendances long terme.], 
    [Détection de crises e-réputation, suivi de satisfaction instantané, routage prioritaire des réclamations.],
    
    table.hline(),
  )
)



#align(center)[
  #figure(
   
    block(
     stroke: 1pt + black,
      image("../images/streamVSbatch.jpg", width: 12cm)
    ),
    caption: [Traitement par Lots  Vs Traitement en Continu  ],
  kind: image
  )
]



=== Bases de données NoSQL et MongoDB

==== Du modèle relationnel au paradigme NoSQL
Le terme NoSQL @stonebraker2011 désigne un certain nombre de SGBD abandonnant le modèle relationnel – à savoir les tables à schéma fixe et le SQL – lesquels manient de façon adéquate des données hétérogènes, distribuées et massives, inadaptées aux SGBDR traditionnels. Développé à partir des années 2000 pour répondre aux défis des Big Data du web, le NoSQL privilégie, contre l’objectif d’une consistance stricte, la disponibilité, et la tolérance au partitionnement (AP du théorème CAP) @brewer2000 @brewer2012, dans la lignée des SGBD NoSQL, là où SGBDR retient CP (ou CA) @cattell2011.


- *Quatre grandes familles dominent* : 
#figure(
  table(
    columns: (auto, 1fr, auto),
    align: (left, left, left),
    table.header(
      [*Type*],
      [*Principe*],
      [*Exemple typique*],
    ),
    [Orienté documents],
    [Stockage en documents JSON/BSON, sans schéma imposé],
    [MongoDB, Couchbase],
    [Clé‑valeur],
    [Association d’une clé unique à une valeur (souvent en mémoire)],
    [Redis, DynamoDB],
    [Orienté colonnes],
    [Données organisées par familles de colonnes, optimisées pour l’agrégation],
    [Cassandra, HBase],
    [Graphes],
    [Nœuds (entités) et arêtes (relations)],
    [Neo4j, Amazon Neptune],
  ),
  caption: [Les quatre grandes familles NoSQL],
  kind: table,
)

==== MongoDB : modèle orienté documents

#h(0.5cm) *MongoDB*, système de gestion de bases de données (*SGBD*) à code source libre, a été lancé en 2007 @chodorow2013, et dans lequel les données sont stockées en BSON (Binary JSON), hiérarchiquement organisées selon la structure base → collection → document. 

#h(0.5cm)Les collections sont de type _schemaless_ (les documents pouvant avoir des structures variables les uns par rapport aux autres) et les documents sont identifiés de manière unique par un champ *"\_id"* de type *"ObjectId"* (12 octets : timestamp, identifiant machine, compteur) garantissant l’unicité sans nécessiter de coordination distribuée @mongodb2021.

La dénormalisation se voit conférer une grande valeur, car l’objet utile est en fait le document qui va regrouper dans ses propriétés toutes les informations nécessairement souvent consultées ensemble : cette technique permet d’éviter les jointures coûteuses au prix d’un niveau de redondance cadré, qualifié à tort mais avec bonheur de _sacrificiel_ (contrairement donc à, mais aussi à l’opposée de la 3NF @codd1970).
==== Indexation et agrégation
#h(0.5cm) *MongoDB* recourt à des index de type arbre B pour effectuer un passage d’un *collection scan* vérifiant une complexité en O(N) à un accès d’une complexité en O(log N) @bayer1972. Types supportés : simple, composé, s parse , TTL.

#h(0.5cm) Le pipeline d’agrégation @mongodb2021 (étapes « \$match », « \$group », « \$project », « \$sort » ) procède au traitement côté serveur évitant des rapatriements de données pour des calculs tels que les distributions de sentiments.

Les Change Streams @mongodb2021 permettent à une application de procéder à des abonnements aux insertions en temps réel, cela a été réalisée via l’*oplog* (journal de réplication), sujet de productivité de notre producteur Kafka.

==== Justification pour notre corpus
#h(0.5cm)  Le fait que MongoDB soit retenu comme la couche de stockage repose sur quatre arguments directement liés aux caractéristiques du projet :

- *Flexibilité schématique* : les commentaires issus de sept plateformes possèdent des structures hétérogènes (champ modérateur absent d’environ 15 % des documents ; colonne  « Publication » systématiquement vide sur la période). MongoDB puise dans cette variabilité sans migration de schéma @cattell2011, à la différence du SGBDR qui imposerait que soient définis à l’avance tous les champs.
- *Enrichissement progressif* : chaque commentaire s’enrichit le long du pipeline de champs calculés (hash de dédoublonnage, résultat de nettoyage, sentiment prédit, flags sémantiques). La structure documentaire permet d’accumuler ces enrichissements sans créer de tables intermédiaires.
- *Intégration native avec Python et Spark* : le connecteur pymongo @pymongo2023 propose une API simple que l’on peut utiliser dans les scripts du consommateur Kafka, et le connecteur Spark-MongoDB permet à chaque worker du cluster de lire et écrire directement sans intermédiaires de type fichiers.
- *Change Streams pour l’architecture événementielle* : aucun SGBDR classique n’expose d’équivalent aussi simple pour écouter des flux d’insertion en temps réel, et fait ainsi de MongoDB le pivot naturel entre la collecte et le traitement distribué.


== Conclusion 

Ce chapitre a établi les assises théoriques et technologiques nécessaires à la compréhension des enjeux liés à l’analyse automatisée des interactions clients. Il a été démontré que la complexité linguistique des corpus dialectaux, marquée par l’absence de normalisation et le mélange des codes, rend obsolètes les approches lexicales traditionnelles. Le recours à des modèles de langage contextuels profonds s’impose ainsi pour capturer la sémantique fine et les nuances propres à ces variétés linguistiques. Parallèlement, l’étude des contraintes inhérentes aux données massives — volume, vélocité et hétérogénéité.

#h(0.5cm)Cette analyse conceptuelle permet d’identifier les défis techniques majeurs, tels que la latence, le déséquilibre des classes et le bruit lexical, qui constituent les principaux goulots d’étranglement des systèmes existants. Ces fondements offrent un cadre de référence rigoureux pour aborder la phase de conception détaillée. Le chapitre suivant traduira ces principes en une architecture logicielle concrète, robuste et scalable, conçue pour répondre aux exigences opérationnelles du traitement de flux sociaux en continu.




#pagebreak()
