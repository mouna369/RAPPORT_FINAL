// // ======================
// // CONFIGURATION GLOBALE
// // ======================
// #set par(justify: true)
// #set page(
//   paper: "a4",
//   margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 2.5cm),
// )
// #set text(font: "Times New Roman", size: 11pt)
// #show par: it => { block(spacing: 1.2em, it) }
// #import "chapitres/utils.typ": equation-counter, numbered-eq

// // ======================
// // NUMÉROTATION HIÉRARCHIQUE DES FIGURES ET TABLEAUX
// // ======================
// // On relie le compteur de figures/tableaux au numéro de chapitre (niveau 1)
// // pour obtenir une numérotation "1.1", "1.2", "2.1", etc.
// // ======================
// // NUMÉROTATION HIÉRARCHIQUE DES FIGURES ET TABLEAUX
// // ======================
// // Pour les figures (images)
// #set figure(numbering: n => {
//   let chapter = counter(heading.where(level: 1)).get().first()
//   numbering("1.1", chapter, n)
// })

// // Numérotation séparée pour les tableaux (kind: table)
// #show figure.where(kind: table): set figure(numbering: n => {
//   let chapter = counter(heading.where(level: 1)).get().first()
//   numbering("1.1", chapter, n)
// })

// // ======================
// // PAGE DE GARDE
// // ======================
// #include "chapitres/page_garde.typ"

// // ======================
// // PRÉLIMINAIRES
// // ======================
// #set heading(numbering: none, outlined: false)

// #set page(
//   numbering: "i",
//   header: none,
//   footer: context [
//     #set align(right)
//     #counter(page).display("i")
//   ],
// )
// #counter(page).update(1)

// #show outline: it => {
//   set text(12pt)
//   show outline.entry: it => {
//     if it.level == 1 {
//       v(0.5cm)
//       set text(weight: "bold")
//       it
//     } else {
//       it
//     }
//   }
//   // NE PAS mettre set outline.entry(fill: none) ici !
//   it
// }

// #include "chapitres/remerciements.typ"
// #include "chapitres/dedicaces.typ"
// #include "chapitres/resume.typ"
// #include "chapitres/abstract.typ"
// #include "chapitres/resume_arabe.typ"

// // -----------------------------------------------
// // EN-TÊTE POUR LES LISTES
// // -----------------------------------------------
// #let header-liste = context {
//   let all-h = query(heading.where(level: 1))
//   let past = all-h.filter(h => h.location().page() <= here().page())
//   if past.len() == 0 { return [] }
//   let cur = past.last()
//   if cur.location().page() == here().page() { return [] }
//   set align(left)
//   set text(size: 9pt, style: "italic")
//   cur.body
//   v(-0.5em)
//   line(length: 100%)
// }

// #set page(numbering: "i", header: header-liste, footer: context [#set align(right); #counter(page).display("i")])
// #heading(level: 1, outlined: false)[Liste des figures]
// #v(2cm)
// #outline(target: figure.where(kind: image), title: none)

// // -----------------------------------------------
// // LISTE DES TABLEAUX
// // -----------------------------------------------
// #pagebreak()
// #set page(numbering: "i", header: header-liste, footer: context [#set align(right); #counter(page).display("i")])
// #heading(level: 1, outlined: false)[Liste des tableaux]
// #v(2cm)
// #outline(target: figure.where(kind: table), title: none)

// // -----------------------------------------------
// // TABLE DES MATIÈRES
// // -----------------------------------------------

// #pagebreak()
// #set page(numbering: "i", header: header-liste, footer: context [#set align(right); #counter(page).display("i")])
// #set text(size: 14pt)  // Augmente la taille du titre
// #heading(level: 1, outlined: false)[Table des matières]
// #v(1.5cm)
// #outline(depth: 3, title: none, indent: 1em)

// // -----------------------------------------------
// // LISTE DES ABRÉVIATIONS
// // -----------------------------------------------
// #pagebreak()
// #set page(numbering: "i", header: header-liste, footer: context [#set align(right); #counter(page).display("i")])
// // #heading(level: 1, outlined: false)[Liste des abréviations et acronymes]
// #include "chapitres/abreviations.typ"

// #pagebreak()

// // ======================
// // CORPS DU MÉMOIRE
// // ======================

// // --- Style des chapitres ---
// #show heading.where(level: 1, outlined: true): it => {
//   counter(figure.where(kind: image)).update(0)
//   counter(figure.where(kind: table)).update(0)

//   pagebreak(weak: true)
//   v(1cm)

//   if it.numbering != none {
//     align(left, stack(
//       dir: ttb,
//       text(size: 20pt, weight: "bold")[Chapitre #counter(heading.where(level: 1)).display()],
//       v(0.5cm),
//       text(size: 20pt, weight: "bold")[#it.body],
//     ))
//   } else {
//     align(center, text(size: 16pt, weight: "bold")[#it.body])
//   }

//   v(1cm)
// }

// // --- En-tête dynamique ---
// #set page(
//   numbering: "1",
//   header: context {
//     let all-h = query(heading.where(level: 1, outlined: true))
//     let past = all-h.filter(h => h.location().page() <= here().page())
//     if past.len() == 0 { return [] }
//     let cur = past.last()

//     if cur.location().page() == here().page() { return [] }

//     set align(left)
//     set text(size: 9pt, style: "italic")

//     if cur.numbering != none {
//       let numbered-before = all-h.filter(h => (
//         h.numbering != none
//           and h.location().page() <= cur.location().page()
//           and h.location().position().y <= cur.location().position().y
//       ))
//       let n = numbered-before.len()
//       [Chapitre ] + str(n) + [ : ] + cur.body
//     } else {
//       cur.body
//     }

//     v(-0.5em)
//     line(length: 100%)
//   },
//   footer: context [
//     #set align(right)
//     #counter(page).display("1")
//   ],
// )

// #counter(page).update(1)

// // ======================
// // INTRODUCTION GÉNÉRALE
// // ======================
// #set heading(numbering: none, outlined: true)
// #include "chapitres/introduction_generale.typ"

// // ======================
// // CHAPITRES NUMÉROTÉS
// // ======================
// // IMPORTANT : numbering "1.1.1" pour numérotation hiérarchique correcte
// // Niveau 1 → "1", niveau 2 → "1.1", niveau 3 → "1.1.1"
// #set heading(numbering: "1.1.1", outlined: true)

// #include "chapitres/chapitre1.typ"
// #include "chapitres/chapitre2.typ"
// #include "chapitres/chapitre3.typ"
// #include "chapitres/chapitre4.typ"
// #include "chapitres/chapitre5.typ"

// // ======================
// // CONCLUSION GÉNÉRALE
// // ======================
// #set heading(numbering: none, outlined: true)
// #include "chapitres/conclusion_generale.typ"

// // ======================
// // BIBLIOGRAPHIE
// // ======================
// #set par(justify: true)
// #bibliography("references.bib", title: "Bibliographie", style: "ieee")

// // ======================
// // ANNEXES
// // ======================
// #counter(figure).update(0)
// #counter(figure.where(kind: table)).update(0)

// #show figure.where(kind: image): set figure(numbering: n => {
//   "A." + str(n)
// })
// #show figure.where(kind: table): set figure(numbering: n => {
//   "A." + str(n)
// })

// #include "chapitres/annexes.typ"
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
// Pour les figures (images)
#set figure(numbering: n => {
  let chapter = counter(heading.where(level: 1, outlined: true)).get().first()
  numbering("1.1", chapter, n)
})

// Numérotation séparée pour les tableaux (kind: table)
#show figure.where(kind: table): set figure(numbering: n => {
  let chapter = counter(heading.where(level: 1, outlined: true)).get().first()
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

// ======================
// REMERCIEMENTS, DÉDICACES, RÉSUMÉS (SANS NUMÉRO DE PAGE)
// ======================
#set page(numbering: none)
#set page(header: none, footer: none)

#include "chapitres/remerciements.typ"
#include "chapitres/dedicaces.typ"
#include "chapitres/resume.typ"
#include "chapitres/abstract.typ"
#include "chapitres/resume_arabe.typ"

// ======================
// LISTES (NUMÉROTATION ROMAINE i, ii, iii...)
// ======================
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
  show outline.entry: it => {
    if it.level == 1 {
      v(0.5cm)
      set text(weight: "bold")
      it
    } else {
      it
    }
  }
  it
}

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

#set page(header: header-liste, footer: context [#set align(right); #counter(page).display("i")])

// ======================
// TABLE DES MATIÈRES (page i)
// ======================
#heading(level: 1, outlined: true)[Table des matières]
#v(1.5cm)
#set text(size: 11pt)
#outline(depth: 3, title: none, indent: 1em)

// ======================
// FORCER LA PAGE 5 POUR LA LISTE DES FIGURES
// ======================
#pagebreak()
#counter(page).update(5)

// ======================
// LISTE DES FIGURES (page v)
// ======================
#heading(level: 1, outlined: true)[Liste des figures]
#v(2cm)
#outline(target: figure.where(kind: image), title: none)

// ======================
// FORCER LA PAGE 8 POUR LA LISTE DES TABLEAUX
// ======================
#pagebreak()
#counter(page).update(8)

// ======================
// LISTE DES TABLEAUX (page viii)
// ======================
#heading(level: 1, outlined: true)[Liste des tableaux]
#v(2cm)
#outline(target: figure.where(kind: table), title: none)

// ======================
// FORCER LA PAGE 10 POUR LA LISTE DES ABRÉVIATIONS
// ======================
#pagebreak()
#counter(page).update(10)

// ======================
// LISTE DES ABRÉVIATIONS (page x)
// ======================

#include "chapitres/abreviations.typ"

#pagebreak()

// ======================
// CORPS DU MÉMOIRE (NUMÉROTATION ARABE 1, 2, 3...)
// ======================

// --- Style des chapitres ---
#show heading.where(level: 1, outlined: true): it => {
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)

  pagebreak(weak: true)
  v(1cm)

  if it.numbering != none {
    align(left, stack(
      dir: ttb,
      text(size: 20pt, weight: "bold")[Chapitre #counter(heading.where(level: 1, outlined: true)).display()],
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
// INTRODUCTION GÉNÉRALE (page 1)
// ======================
#set heading(numbering: none, outlined: true)
// #include "chapitres/table_matieres.typ"
// #include "chapitres/liste_figures.typ"
// #include "chapitres/listes_tableaux.typ"
// #include "chapitres/abreviations.typ"
#include "chapitres/introduction_generale.typ"

// ======================
// CHAPITRES NUMÉROTÉS
// ======================
// IMPORTANT : numbering "1.1.1" pour numérotation hiérarchique correcte
#set heading(numbering: "1.1.1", outlined: true)

#include "chapitres/chapitre1.typ"
#include "chapitres/chapitre2.typ"
#include "chapitres/chapitre3.typ"
#include "chapitres/chapitre4.typ"
#include "chapitres/chapitre5.typ"

// ======================
// CONCLUSION GÉNÉRALE (NON NUMÉROTÉE)
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
#counter(figure).update(0)
#counter(figure.where(kind: table)).update(0)

#show figure.where(kind: image): set figure(numbering: n => {
  "A." + str(n)
})
#show figure.where(kind: table): set figure(numbering: n => {
  "A." + str(n)
})

#include "chapitres/annexes.typ"
