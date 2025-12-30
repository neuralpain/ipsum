/*
  File: ipsum.typ
  Author: neuralpain
  Date Modified: 2025-12-30

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

#let _nerdstats(mode, words, pars, notes: ()) = {
  let avg = if pars > 0 { int(words / pars) } else { 0 }

  block(
    fill: rgb("#f6ffed"),
    stroke: 1pt + rgb("#b7eb8f"),
    inset: 1em,
    radius: 4pt,
    width: 100%,
    above: 1.5em,
  )[
    #set text(fill: rgb("#389e0d"), size: 0.9em)
    #stack(dir: ttb,
      spacing: 0.8em,
      [
        #box(inset: (right: 0.5em))[#emoji.chart]
        *`Stats for Nerds`* #h(1fr) #text(fill: gray, size: 0.8em, raw(mode))
      ],
      line(length: 100%, stroke: 0.5pt + rgb("#b7eb8f")),
      grid(
        columns: (1fr, 1fr, 1fr),
        align: center,
        stack(spacing: 0.5em, text(size: 0.8em, fill: gray)[`Total Words`], text(weight: "bold", size: 1.2em)[#raw(str(words))]),
        stack(spacing: 0.5em, text(size: 0.8em, fill: gray)[`Paragraphs`], text(weight: "bold", size: 1.2em)[#raw(str(pars))]),
        stack(spacing: 0.5em, text(size: 0.8em, fill: gray)[`Avg. Length`], text(weight: "bold", size: 1.2em)[#raw(str(avg))]),
      ),
      if notes.len() > 0 {
        line(length: 100%, stroke: 0.5pt + rgb("#b7eb8f"))
        set text(size: 0.85em)
        text(weight: "bold")[Notes:]
        list(marker: [•], ..notes)
      }
    )
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
  stats: false,
  ignore-limits: false,
  ignore-warnings: false,
) = {
  let average-minimum = 5
  let seed-threshold = 1000000000000 // one trillion
  let pars-threshold = 50
  let words-threshold = 100000
  let fib-threshold = 25
  let fib-high-volume = 20
  let fib-large-volume = 15
  // Stats
  let actual-words = 0
  let actual-pars = 0
  let recommendations = ()

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
    return _err("`mode` must be of type `string`.")
  }

  if mode.len() == 0 {
    _err("`mode` cannot be empty.")
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
    if start < 1 {
      return _err(title: "Invalid value", "Start count must be positive.")
    }
    if ratio < 0 {
      return _err(title: "Invalid value", "`ratio` cannot be negative.")
    }
  }

  if mode == "grow" {
    // Ln(1) is 0, so base must handle the minimum size
    if base < 1 {
      return _err(title: "Invalid value", "`base` size must be positive.")
    }
    if factor < 5 {
      _warn("`factor` size too small for any significant change.")
    }
  }

  if mode == "fit" {
    if total < pars {
      return _err("Total words (" + str(total) + ") is too low for " + str(pars) + " pars.")
    }
    // The formula uses division by (1 - ratio). If ratio is 1.0, this causes division by zero.
    if ratio == 1.0 {
      return _err("Division by zero. `ratio` cannot be exactly 1.0 in fit. Use 0.99 or 1.01.")
    }
    if ratio <= 0 {
      return _err("`ratio` must be positive.")
    }
  }

  if mode == "fibonacci" {
    if steps < 1 {
      return _err(title: "Invalid value", "`steps` must be >= 1.")
    }
    if steps > fib-threshold {
      if ignore-limits and not ignore-warnings {
        _warn("High `steps` value (>" + str(fib-threshold) + "). System may be slow to respond.")
      } else if not ignore-limits {
        return _err(title: "Limit Reached", "Larger `steps` value may result in poor performance or responsiveness.")
      }
    }
  }

  if mode == "natural" {
    if average < average-minimum {
      return _err("Average word count too low (min " + str(average-minimum) + ").")
    }
    // Ensure var doesn't create negative lengths
    if (average - var) < 0 {
      return _err("`var` (" + str(var) + ") is higher than `average` (" + str(average) + "). This may result in negative word counts.")
    }
  }

  if mode == "dialogue" {
    if events < 1 {
      return _err(title: "Invalid value", "`events` must be >= 1.")
    }
    if ratio < 0.0 or ratio > 1.0 {
      return _err(title: "Invalid value", "Talk ratio must be between 0.0 and 1.0.")
    }
  }

  if hint { _hint(mode, param-map.at(mode)) }

  if not ignore-warnings {
    if seed > seed-threshold { _warn("Set `seed` between 1 and one trillion for best results.") }
    if pars > pars-threshold {
      _warn(title: "High volume", "System may be slow to respond.")
    }
    if total > words-threshold or (mode == "fibonacci" and steps > fib-high-volume) {
      _warn(title: "High volume", "System may be slow to respond.")
    }
    if mode == "fibonacci" and steps >= fib-large-volume and reverse {
      _warn("Reverse Fibonacci `steps` > " + str(fib-large-volume) + " creates a very large leading paragraph.")
    } else if steps >= fib-large-volume {
      _warn("Fibonacci `steps` > " + str(fib-large-volume) + " creates very large paragraphs.")
    }
    if mode == "dialogue" and (ratio < 0.1 or ratio > 0.9) {
      _warn("Extreme `ratio` value may result in no dialogue or no narrative text.")
    }
    if mode == "fit" and ratio > 0.95 and ratio < 1.05 {
      _warn("`ratio` is very close to 1.0; paragraph lengths may appear identical due to integer rounding.")
    }
  }

  if mode == "fibonacci" or mode == "dialogue" { pars = 0 }

  if mode == "fade" {
    let results = range(0, pars).map(i => {
      let count = int(start * calc.pow(ratio, i))
      if count < 1 { count = 1 }
      let content = [
        #if paragraph-word-count { text(weight: "bold")[#count words:] }
        #h(indent)#lorem(count)
      ]
      (len: count, content: content)
    })

    if stats {
      actual-words = results.map(r => r.len).sum()
      actual-pars = results.len()
      if ratio > 0.9 { recommendations.push("Ratio is high (" + str(ratio) + "). Decrease to fade text faster.") }
    }

    stack(dir: ttb, spacing: spacing, ..results.map(r => r.content))
  }

  if mode == "grow" {
    let results = range(1, pars + 1).map(i => {
      let count = int(base + (factor * calc.ln(i)))
      let content = [
        #if paragraph-word-count { text(weight: "bold")[#count words:] }
        #h(indent)#lorem(count)
      ]
      (len: count, content: content)
    })

    if stats {
      actual-words = results.map(r => r.len).sum()
      actual-pars = results.len()
    }

    stack(dir: ttb, spacing: spacing, ..results.map(r => r.content))
  }

  if mode == "fit" {
    // a = S * (1 - r) / (1 - r^n)
    let first-len = total * (1 - ratio) / (1 - calc.pow(ratio, pars))

    let results = range(0, pars).map(i => {
      let len = int(first-len * calc.pow(ratio, i))
      if len < 1 { len = 1 }
      let content = [
        #if paragraph-word-count { text(weight: "bold")[#len words:] }
        #h(indent)#lorem(len)
      ]
      (len: len, content: content)
    })

    if stats {
      actual-words = results.map(r => r.len).sum()
      actual-pars = results.len()
      let diff = calc.abs(actual-words - total)
      if diff > (total * 0.05) {
        recommendations.push("Result deviates from target " + str(total) + " by " + str(diff) + " words due to integer rounding.")
        recommendations.push("Try slightly adjusting `ratio` or `pars` for better fit.")
      }
    }

    stack(dir: ttb, spacing: spacing, ..results.map(r => r.content))
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

    if stats {
      actual-words = reversed-fibs.sum()
      actual-pars = reversed-fibs.len()
    }

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
    let results = range(0, pars).map(i => {
      let noise = calc.sin((i + 1) * seed)
      let len = int(average + (noise * var))

      if noise > 0.8 {
        len = int(len * 1.5)
      } else if noise < -0.8 {
        len = int(len * 0.4)
      }

      if len < 5 { len = 5 }

      (len: len, content: [#h(indent)#lorem(len)])
    })

    if stats {
      actual-words = results.map(r => r.len).sum()
      actual-pars = results.len()
      if var > (average * 0.7) {
        recommendations.push("High variance detected. If paragraphs look too chaotic, reduce `var`.")
      }
    }

    stack(dir: ttb, spacing: spacing, ..results.map(r => r.content))
  }

  if mode == "dialogue" {
    let results = range(0, events).map(i => {
      let noise = calc.sin((i + 9) * seed)
      let length-noise = calc.cos((i + 3) * seed)
      let is-dialogue = noise < (ratio * 2 - 1)
      let len = 0
      let content = []

      if is-dialogue {
        len = int(3 + calc.abs(length-noise * 12))
        content = par(hanging-indent: h-indent)[
          #h(indent)“#lorem(len)#if len < 10 {"?"}”
        ]
      } else {
        len = int(25 + calc.abs(length-noise * 45))
        content = [#h(indent)#lorem(len)]
      }

      (len: len, content: content)
    })

    if stats {
      actual-words = results.map(r => r.len).sum()
      actual-pars = results.len()
    }

    stack(dir: ttb, spacing: spacing * 0.8, ..results.map(r => r.content))
  }

  if stats {
    _nerdstats(mode, actual-words, actual-pars, notes: recommendations)
  }
}
