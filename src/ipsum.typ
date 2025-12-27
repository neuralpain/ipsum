/*
  File: ipsum.typ
  Author: neuralpain
  Date Modified: 2025-12-27

  Description: Lorem's Ipsum.
*/

#let __golden = 0.61803398875

#let _err(msg, title: "Error") = {
  block(
    fill: rgb("#ffcccc"),
    stroke: 1pt + red,
    inset: 1em,
    radius: 4pt,
    width: 100%,
  )[
    #set text(fill: red.darken(30%))
    #box(inset: (right: 0.5em))[#emoji.warning]
    #h(0.3em)*#raw(title + ": ")*#raw(msg)
  ]
}

#let _warn(msg, title: "Warning") = {
  block(
    fill: rgb("#fff4cc"),
    stroke: 1pt + orange.darken(10%),
    inset: 1em,
    radius: 4pt,
    width: 100%,
  )[
    #set text(fill: orange.darken(40%))
    #box(inset: (right: 0.5em))[#emoji.warning]
    #h(0.3em)*#raw(title + ": ")*#raw(msg)
  ]
}

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
  factor: 30,
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
  h-indent: 0em,
  // System
  hint: false,
  ignore-limits: false,
  ignore-warnings: false,
) = {
  let seed-threshold = 1000000000000 // one trillion

  let valid-modes = (
    "natural",    // Natural human flow
    "grow",       // Logarithmic
    "fade",       // Geometric
    "fit",        // Geometric
    "dialogue",   // Natural speech patterns
    "fibonacci",  // Mathematic
  )

  let param-map = (
    "natural":    ("pars", "average", "var", "seed", "indent"),
    "grow":       ("pars", "base", "factor", "indent"),
    "fade":       ("pars", "start", "ratio", "indent"),
    "fit":        ("pars", "total", "ratio", "indent"),
    "dialogue":   ("events", "ratio", "seed", "indent"),
    "fibonacci":  ("steps", "reverse"),
  )

  if type(mode) != str {
    return _err("Mode must be of type `string`.")
  }

  if mode.len() == 0 {
    _err("Mode cannot be empty.")
    _err(title: "Valid modes", valid-modes.join(", "))
    return
  }

  if mode not in valid-modes {
    _err("Unknown mode '" + mode + "'.")
    _err(title: "Valid modes", valid-modes.join(", "))
    return
  }

  for (key, value) in param-map {
    if mode == key and "pars" in value and pars < 1 {
      return _err(title: "Invalid value", "`pars` must be >= 1.")
    }
  }

  if mode == "fade" {
    if start < 1 { return _err(title: "Invalid value", "Start count must be positive.") }
    if ratio < 0 { return _err(title: "Invalid value", "`ratio` cannot be negative.") }
  }

  if mode == "grow" {
    // Ln(1) is 0, so base must handle the minimum size
    if base < 1 { return _err("`base` size must be positive.") }
    if factor < 5 { _warn("`factor` size too small for any significant change.") }
  }

  if mode == "fit" {
    if total < pars {
      return _err("Total words (" + str(total) + ") is too low for " + str(pars) + " pars.")
    }
    // The formula uses division by (1 - ratio). If ratio is 1.0, this causes division by zero.
    if ratio == 1.0 { return _err("Division by zero. `ratio` cannot be exactly 1.0 in fit. Use 0.99 or 1.01.") }
    if ratio <= 0 { return _err("`ratio` must be positive.") }
  }

  if mode == "fibonacci" {
    if steps < 1 { return _err("`steps` must be >= 1.") }
    if steps > 30 {
      if ignore-limits and not ignore-warnings { _warn("`steps` too high (>30). System may be slow to respond.") }
      else if not ignore-limits { _err("`steps` too high (>30).") }
      return
    }
  }

  if mode == "natural" {
    if average < 5 { return _err("Average word count too low (min 5).") }
    // Ensure var doesn't create negative lengths
    if (average - var) < 0 {
      return _err("`var` (" + str(var) + ") is higher than `average` (" + str(average) + "); this may result in negative word counts.")
    }
  }

  if mode == "dialogue" {
    if events < 1 { return _err("`events` must be >= 1.") }
    if ratio < 0.0 or ratio > 1.0 { return _err("Talk ratio must be between 0.0 and 1.0.") }
  }

  if hint { _hint(mode, param-map.at(mode)) }

  if not ignore-warnings {
    if seed > seed-threshold { _warn("Set `seed` between 1 and one trillion for best results.") }
    if pars > 50 or total > 2000 or steps > 20 { _warn("High volume requested. System may be slow to respond.") }
    if steps > 12 and reverse { _warn("Fibonacci steps > 12 with reverse: true creates a very large leading paragraph.") }
    if mode == "dialogue" and (ratio < 0.1 or ratio > 0.9) {
      _warn("Extreme `ratio` may result in no dialogue or no narrative text.")
    }
    if mode == "fit" and ratio > 0.95 and ratio < 1.05 {
      _warn("Ratio is very close to 1.0; paragraph lengths may appear identical due to integer rounding.")
    }
  }

  if mode == "fibonacci" or mode == "dialogue" { pars = 0 }

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
        let count = int(base + (factor * calc.ln(i)))
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
          par(hanging-indent: h-indent)[
            #h(indent)“#lorem(len)#if len < 10 {"?"}”
          ]
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
