/*
  File: ipsum.typ
  Author: neuralpain
  Date Modified: 2025-12-27

  Description: Lorem's Ipsum.
*/

#let __golden = 0.61803398875

#let _hint(mode, params) = {
  block(
    fill: rgb("#e6f7ff"),
    stroke: 1pt + blue.lighten(30%),
    inset: 0.8em,
    radius: 4pt,
    width: 100%,
    below: 1em,
  )[
    #set text(fill: blue.darken(30%), size: 0.9em)
    #box(inset: (right: 0.5em))[#emoji.info]
    *Available parameters for mode '#raw(mode)':*
    #h(0.5em)
    #params.map(p => raw(p)).join(", ")
  ]
}

#let ipsum(
  mode: "natural",
  pars: 7,
  indent: 0em,
  start: 100,
  spacing: 1em,
  justify: false,
  ratio: __golden,
  // Geometric
  total: 300,
  // Logarithmic
  base: 20,
  mult: 30,
  stats: false,
  paragraph-word-count: false,
  // Fibonacci
  steps: 8,
  reverse: true,
  // Human Flow
  average: 60,
  var: 30,
  seed: 42,
  // Dialogue
  events: 10,
  // System
  hint: false,
) = {
  let param-map = (
    "natural":    ("pars", "average", "var", "seed", "indent"),
    "grow":       ("pars", "base", "mult", "indent"),
    "fade":       ("pars", "start", "ratio", "indent"),
    "fit":        ("pars", "total", "ratio", "indent"),
    "dialogue":   ("events", "ratio", "seed", "indent"),
    "fibonacci":  ("steps", "reverse"),
  )

  if hint { _hint(mode, param-map.at(mode)) }

  if mode == "fade" {
    stack(dir: ttb, spacing: spacing,
      ..range(0, pars).map(i => {
        let count = int(start * calc.pow(ratio, i))
        if count < 1 { count = 1 }
        [
          #if paragraph-word-count { text(weight: "bold")[#count words:] }
          #h(indent)#lorem(count)
        ]
      }),
    )
  }

  if mode == "grow" {
    stack(dir: ttb, spacing: spacing,
      ..range(1, pars + 1).map(i => {
        let count = int(base + (mult * calc.ln(i)))
        [
          #if paragraph-word-count { text(weight: "bold")[#count words:] }
          #h(indent)#lorem(count)
        ]
      }),
    )
  }

  if mode == "fit" {
    // a = S * (1 - r) / (1 - r^n)
    let first-len = total * (1 - ratio) / (1 - calc.pow(ratio, pars))

    stack(dir: ttb, spacing: spacing,
      ..range(0, pars).map(i => {
        let len = int(first-len * calc.pow(ratio, i))
        if len < 1 { len = 1 }
        [
          #if paragraph-word-count { text(weight: "bold")[#len words:] }
          #h(indent)#lorem(len)
        ]
      }),
    )

    let actual-sum = range(0, pars).map(i => int(first-len * calc.pow(ratio, i))).sum()

    if stats {
      v(0.5em)
      text(style: "italic", size: 0.8em)[
        Target: #total | Actual Sum: #actual-sum words
      ]
      v(1em)
    }
  }

  if mode == "fibonacci" {
    set par(justify: true, first-line-indent: 1.5em)

    let get-fibs(steps) = {
      let nums = (1, 1)
      while nums.len() < steps {
        let len = nums.len()
        let next = nums.at(len - 1) + nums.at(len - 2)
        nums.push(next)
      }
      return nums
    }

    let fibs = get-fibs(steps)
    let reversed-fibs = if reverse { fibs.rev() } else { fibs }

    stack(dir: ttb, spacing: spacing, ..reversed-fibs.map(count => {
      grid(
        columns: (3em, 1fr),
        gutter: 1em,
        align(right + top)[
          #text(weight: "bold", fill: gray)[#count]
        ],
        [#lorem(count)],
      )
    }))
  }

  if mode == "natural" {
    stack(dir: ttb, spacing: spacing,
      ..range(0, pars).map(i => {
        let noise = calc.sin((i + 1) * seed)
        let len = int(average + (noise * var))

        if noise > 0.8 {
          len = int(len * 1.5)
        } else if noise < -0.8 {
          len = int(len * 0.4)
        }

        if len < 5 { len = 5 } // sanitize negative values

        [#h(indent)#lorem(len)]
      }),
    )
  }

  if mode == "dialogue" {
    stack(dir: ttb, spacing: spacing * 0.8,
      ..range(0, events).map(i => {
        let noise = calc.sin((i + 9) * seed)
        let length-noise = calc.cos((i + 3) * seed)
        let is-dialogue = noise < (ratio * 2 - 1)

        if is-dialogue {
          let len = int(3 + calc.abs(length-noise * 12))
          [#h(indent)“#lorem(len)#if len < 10 {"?"}”]
        } else {
          let len = int(25 + calc.abs(length-noise * 45))
          [#h(indent)#lorem(len)]
        }
      }),
    )
  }

  if stats and mode != "fit" {
    v(0.5em)
    text(fill: gray, size: 0.8em)[*Stats:* Mode: #mode | Params verified.]
  }
}
