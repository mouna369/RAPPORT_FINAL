// ====================================
// PAGE DE GARDE
// Fichier : chapitres/page_garde.typ
// ====================================
#set page(numbering: none)

#align(center)[

  // ── Texte arabe en haut ──
 #text(font: ("Times New Roman", "Amiri"), size: 13pt, weight: "bold", dir: rtl)[
  الجمهورية الجزائرية الديمقراطية الشعبية \
  وزارة التعليم العالي والبحث العلمي
]
  #v(0.3cm)

  // ── Texte français institution ──
  #text(size: 11pt)[
    République Algérienne Démocratique et Populaire \
    Ministère de l'Enseignement Supérieur et de la Recherche Scientifique \
    *Université d'Alger 01 Benyoucef BENKHEDDA*
  ]

  #v(0.4cm)

  // ── Logo centré ──
  #image("../images/logo_fac.jpg", width: 3cm)

  #v(0.4cm)

  // ── Faculté / Département ──
  #text(size: 12pt)[
    Faculté des Sciences \
    Département d'Informatique \
    Mémoire de fin d'études pour l'obtention du diplôme de \
    *Master en Informatique* \
    Spécialité : *Analyse et Sciences de Données*
  ]

  #v(0.6cm)

  // ── Thème avec lignes séparatrices (comme dans l'image) ──
  #text(size: 16pt, weight: "bold")[Thème]

  #v(0.2cm)
  #line(length: 100%, stroke: 1.5pt)
  #v(0.4cm)

  #text(size: 15pt, weight: "bold")[
    Concevoir un système d'analyse et de suivi des interactions clients 
    sur les réseaux sociaux à l'aide des techniques de NLP \
    et du Big Data dans le service télécom.
  ]

  #v(0.1cm)
  #line(length: 100%, stroke: 1.5pt)

  #v(0.8cm)

  // ── Réalisé par / Encadré par ──
  #grid(
    columns: (1fr, 1fr),
    align(left)[
      *Réalisé par :* \
      #v(0.2cm)
      Mme Hadj Abderrahmane Yousra \
      Mme Rehamnia Mouna
    ],
    align(right)[
      *Encadré par :* \
      #v(0.2cm)
      Mme GHOUL Rafia \
      Mme OUNNAR Lamia
    ]
  )

  #v(0.7cm)

  // ── Jury / Soutenance ──
  #grid(
    columns: (1fr, 1fr),
    align(left)[
      *Devant le jury composé de :* \
      #v(0.2cm)
      Pr. [Nom] #h(1fr) Président \
      Pr. [Nom] #h(1fr) Examinateur \
      Dr. [Nom] #h(1fr) Examinateur
    ],
    align(right)[
      *Soutenu le :* \
      #v(0.2cm)
      [Date de soutenance]
    ]
  )

  #v(1.19cm)

  // ── Promotion ──
  Promotion : *2025 – 2026*
]
