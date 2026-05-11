// chapitres/utils.typ

#let equation-counter = counter("equation")

#let numbered-eq(label-name, chap-number, body) = {
  equation-counter.step()

  block(
    width: 100%,
    above: 1.2em,
    below: 1.2em,
  )[
    #context {
      let eq-num = equation-counter.display()
      table(
        columns: (1fr, auto),
        align: (center + horizon, right + horizon),
        stroke: none,
        inset: 0pt,
        column-gutter: 8pt,
        // ✅ Taille réduite appliquée ici globalement
        text(size: 9pt)[#body],
        text(size: 10pt)[(#chap-number.#eq-num)]
      )
    }
    #label(label-name)
  ]
}