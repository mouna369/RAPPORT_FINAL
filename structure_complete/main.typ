// ======================
// CONFIGURATION GLOBALE
// ======================
#set par(justify: true)
#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 2.5cm),
)
#set text(font: "Times New Roman", size: 11pt)
#show par: it => { block(spacing: 1.2em, it) }
#import "chapitres/utils.typ": equation-counter, numbered-eq

// ======================
// NUMÉROTATION HIÉRARCHIQUE DES FIGURES ET TABLEAUX
// ======================
// On relie le compteur de figures/tableaux au numéro de chapitre (niveau 1)
// pour obtenir une numérotation "1.1", "1.2", "2.1", etc.
// ======================
// NUMÉROTATION HIÉRARCHIQUE DES FIGURES ET TABLEAUX
// ======================
// Pour les figures (images)
#set figure(numbering: n => {
  let chapter = counter(heading.where(level: 1)).get().first()
  numbering("1.1", chapter, n)
})

// Numérotation séparée pour les tableaux (kind: table)
#show figure.where(kind: table): set figure(numbering: n => {
  let chapter = counter(heading.where(level: 1)).get().first()
  numbering("1.1", chapter, n)
})

// ======================
// PAGE DE GARDE
// ======================
#include "chapitres/page_garde.typ"

// ======================
// PRÉLIMINAIRES
// ======================
#set heading(numbering: none, outlined: false)

#set page(
  numbering: "i",
  header: none,
  footer: context [
    #set align(right)
    #counter(page).display("i")
  ],
)
#counter(page).update(1)

#show outline: it => {
  set text(12pt)
  // Supprimer les points de conduite pour tous les niveaux
  show outline.entry: it => {
    if it.level == 1 {
      v(0.5cm)
      set text(weight: "bold")
      it
    } else {
      it
    }
  }
  // Remplacer les points par rien (fill: none)
  set outline.entry(fill: none)
  it
}

#include "chapitres/remerciements.typ"
#include "chapitres/dedicaces.typ"
#include "chapitres/resume.typ"
#include "chapitres/abstract.typ"
#include "chapitres/resume_arabe.typ"

// -----------------------------------------------
// EN-TÊTE POUR LES LISTES
// -----------------------------------------------
#let header-liste = context {
  let all-h = query(heading.where(level: 1))
  let past = all-h.filter(h => h.location().page() <= here().page())
  if past.len() == 0 { return [] }
  let cur = past.last()
  if cur.location().page() == here().page() { return [] }
  set align(left)
  set text(size: 9pt, style: "italic")
  cur.body
  v(-0.5em)
  line(length: 100%)
}

#set page(numbering: "i", header: header-liste, footer: context [#set align(right); #counter(page).display("i")])
#heading(level: 1, outlined: false)[Liste des figures]
#outline(target: figure.where(kind: "figure"), title: none)

// -----------------------------------------------
// LISTE DES TABLEAUX
// -----------------------------------------------
#pagebreak()
#set page(numbering: "i", header: header-liste, footer: context [#set align(right); #counter(page).display("i")])
#heading(level: 1, outlined: false)[Liste des tableaux]
#outline(target: figure.where(kind: table), title: none)

// -----------------------------------------------
// TABLE DES MATIÈRES
// -----------------------------------------------
#pagebreak()
#set page(numbering: "i", header: header-liste, footer: context [#set align(right); #counter(page).display("i")])
#heading(level: 1, outlined: false)[Table des matières]
#outline(depth: 3, title: none, indent: 1em)

// -----------------------------------------------
// LISTE DES ABRÉVIATIONS
// -----------------------------------------------
#pagebreak()
#set page(numbering: "i", header: header-liste, footer: context [#set align(right); #counter(page).display("i")])
#heading(level: 1, outlined: false)[Liste des abréviations et acronymes]
#include "chapitres/abreviations.typ"

#pagebreak()

// ======================
// CORPS DU MÉMOIRE
// ======================

// --- Style des chapitres ---
#show heading.where(level: 1, outlined: true): it => {
  // Réinitialiser les compteurs de figures et de tableaux à chaque nouveau chapitre
  counter(figure).update(0)
  counter(figure.where(kind: table)).update(0)

  pagebreak(weak: true)
  v(1cm)

  if it.numbering != none {
    align(left, stack(
      dir: ttb,
      text(size: 20pt, weight: "bold")[Chapitre #counter(heading.where(level: 1)).display()],
      v(0.5cm),
      text(size: 20pt, weight: "bold")[#it.body],
    ))
  } else {
    align(center, text(size: 16pt, weight: "bold")[#it.body])
  }

  v(1cm)
}

// --- En-tête dynamique ---
#set page(
  numbering: "1",
  header: context {
    let all-h = query(heading.where(level: 1, outlined: true))
    let past = all-h.filter(h => h.location().page() <= here().page())
    if past.len() == 0 { return [] }
    let cur = past.last()

    if cur.location().page() == here().page() { return [] }

    set align(left)
    set text(size: 9pt, style: "italic")

    if cur.numbering != none {
      let numbered-before = all-h.filter(h => (
        h.numbering != none
          and h.location().page() <= cur.location().page()
          and h.location().position().y <= cur.location().position().y
      ))
      let n = numbered-before.len()
      [Chapitre ] + str(n) + [ : ] + cur.body
    } else {
      cur.body
    }

    v(-0.5em)
    line(length: 100%)
  },
  footer: context [
    #set align(right)
    #counter(page).display("1")
  ],
)

#counter(page).update(1)

// ======================
// INTRODUCTION GÉNÉRALE
// ======================
#set heading(numbering: none, outlined: true)
#include "chapitres/introduction_generale.typ"

// ======================
// CHAPITRES NUMÉROTÉS
// ======================
// IMPORTANT : numbering "1.1.1" pour numérotation hiérarchique correcte
// Niveau 1 → "1", niveau 2 → "1.1", niveau 3 → "1.1.1"
#set heading(numbering: "1.1.1", outlined: true)

#include "chapitres/chapitre1.typ"
#include "chapitres/chapitre2.typ"
#include "chapitres/chapitre3.typ"
#include "chapitres/chapitre4.typ"
#include "chapitres/chapitre5.typ"

// ======================
// CONCLUSION GÉNÉRALE
// ======================
#set heading(numbering: none, outlined: true)
#include "chapitres/conclusion_generale.typ"

// ======================
// BIBLIOGRAPHIE
// ======================
#set par(justify: true)
#bibliography("references.bib", title: "Bibliographie", style: "apa")

// ======================
// ANNEXES
// ======================
#include "chapitres/annexes.typ"
