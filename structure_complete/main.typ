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
// PAGE DE GARDE
// ======================
#include "chapitres/page_garde.typ"


// ======================P
// PRÉLIMINAIRES — pas d'en-tête
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
  show outline.entry.where(level: 1): it => strong(it)
  show outline.entry.where(level: 1): entry => v(0.5cm) + entry
  it
}

#include "chapitres/remerciements.typ"
#include "chapitres/dedicaces.typ"
#include "chapitres/resume.typ"
#include "chapitres/abstract.typ"
#include "chapitres/resume_arabe.typ"

// -----------------------------------------------
// EN-TÊTE RÉUTILISABLE POUR LES LISTES
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

// -----------------------------------------------
// LISTE DES FIGURES
// --------------------------------------------
#set page(numbering: "i", header: header-liste, footer: context [#set align(right); #counter(page).display("i")])
#heading(level: 1, outlined: false)[Liste des figures]
#outline(target: figure.where(kind: image), title: none)

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
#set figure(numbering: (..n) => {
  let nums = n.pos()
  if nums.len() >= 2 {
    str(nums.at(0)) + "." + str(nums.at(1))
  } else {
    str(nums.at(0))
  }
})
// Compteur custom — step() appelé dans show heading AVANT affichage
// donc get() retourne 1 pour le premier chapitre
#let chap-num = counter("chap-num")

// --- Style visuel première page de chaque chapitre ---
#show heading.where(level: 1, outlined: true): it => {
  pagebreak(weak: true)
  v(1cm)

  if it.numbering != none {
    // step() d'abord → puis get() retourne la bonne valeur (1, 2, 3...)
    chap-num.step()
    context {
      let n = chap-num.get().at(0)
      align(left, stack(
        dir: ttb,
        text(size: 20pt, weight: "bold")[Chapitre #n],
        v(0.5cm),
        text(size: 20pt, weight: "bold")[#it.body],
      ))
    }
  } else {
    align(center, text(size: 16pt, weight: "bold")[#it.body])
  }

  v(1cm)
}

// --- En-tête dynamique corps ---
// SOLUTION : on cherche le heading actif, puis on compte combien de
// headings numérotés le précèdent (lui inclus) → c'est son numéro.
#set page(
  numbering: "1",
  header: context {
    let all-h = query(heading.where(level: 1, outlined: true))
    let past = all-h.filter(h => h.location().page() <= here().page())
    if past.len() == 0 { return [] }
    let cur = past.last()

    // Première page du chapitre → pas d'en-tête
    if cur.location().page() == here().page() { return [] }

    set align(left)
    set text(size: 9pt, style: "italic")

    if cur.numbering != none {
      // Compter combien de headings numérotés de niveau 1 existent
      // jusqu'à cur (inclus) → c'est le numéro du chapitre
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
// main.typ


// ======================
// CHAPITRES NUMÉROTÉS
// heading niveau 1 dans chaque fichier = titre seul sans "Chapitre N :"
// ======================
#set heading(numbering: "1.1", outlined: true)

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
#bibliography("references.bib", title: "Bibliographie", style: "ieee")

// ======================
// ANNEXES
// ======================
#include "chapitres/annexes.typ"

