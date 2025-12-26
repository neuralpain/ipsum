# Ipsum

Ipsum is a package which provides blind text generation through different modes such as natural writing and dialogue patterns, geometric structure and the fibonacci function, with the ability to generate text in multiple paragraphs rather than a single block.

## Usage

```typ
#import "@preview/ipsum:0.1.0": *

// Standard "human" patterns (default with 5 paragraphs)
#ipsum()

// A "Fade out" effect
#ipsum(mode: "fade", pars: 4, ratio: 0.66)

// Exact word count fitting
#ipsum(mode: "fit", total: 300, pars: 3)
```

## Ipsum Parameters

Enable `hint: true` view the effective parameters for each mode.

**Example:**

```typ
#ipsum(mode: "natural", pars: 2, hint: true)
```

### Global Parameters

These parameters apply to most or all modes.

| Parameter              |   Default   | Description                                          |
| ---------------------- | :---------: | ---------------------------------------------------- |
| `mode`                 | `"natural"` | The generation method.                               |
| `pars`                 |     `7`     | Number of paragraphs to generate.                    |
| `indent`               |   `0em `    | Paragraph first line indent.                         |
| `spacing`              |    `1em`    | Vertical spacing between paragraphs.                 |
| `stats`                |   `false`   | specific details about the generation at the bottom. |
| `paragraph-word-count` |   `false`   | Prefixes every paragraph with its word count.        |
| `hint`                 |   `false`   | Displays the valid parameters for the selected mode. |
| `ignore-limits`        |   `false`   | Allow values to go past safe limits.                 |
| `ignore-warnings`      |   `false`   | Hide warning text.                                   |

### Generation Modes

Text generation

- Human: `natural`, `dialogue`
- Geometric: `fade`, `fit`
- Logarithmic: `grow`
- Mathematic: `fibonacci`

#### Natural Flow (`mode: "natural"`)

The default mode. Simulates the flow of human writing. It randomly alternates between standard, long, and short paragraphs.

<!-- Best for: Articles, blog posts, essays. -->

| Parameter | Default | Description                                                       |
| --------- | :-----: | ----------------------------------------------------------------- |
| `average` |  `60`   | The baseline word count per paragraph.                            |
| `var`     |  `30`   | How much the length deviates from the average.                    |
| `seed`    |  `42`   | Change this integer to generate a completely different variation. |

**Example:**

```typ
#ipsum(mode: "natural", pars: 3, average: 40, var: 15)
```

#### Geometric Fade (`mode: "fade"`)

Generates paragraphs that decay in length geometrically.

<!-- Best for: Introductions, newsletter openers, marketing copy. -->

| Parameter | Default | Description                                 |
| --------- | :-----: | ------------------------------------------- |
| `start`   |  `100`  | The word count of the *first* paragraph.    |
| `ratio`   | `0.618` | Decay rate. `< 1.0` shrinks, `> 1.0` grows. |

**Example:**

```typ
#ipsum(mode: "fade", start: 80, pars: 4, ratio: 0.6)
```

#### Geometric Fit (`mode: "fit"`)

Distributes a specific total number of words across paragraphs, maintaining a specific decay ratio. Useful for areas with a hard word limit or limited space and want to see how text looks broken up.

<!-- Best for: Magazine layouts, fixed-height sidebars. -->

| Parameter | Default | Description                                                       |
| --------- | :-----: | ----------------------------------------------------------------- |
| `total`   |  `300`  | The sum of words across all generated paragraphs.                 |
| `ratio`   | `0.618` | The size relationship between the current paragraph and the next. |

**Example:**

```typ
#ipsum(mode: "fit", total: 250, pars: 5, ratio: 0.75, stats: true, paragraph-word-count: true)
```

#### Logarithmic Growth (`mode: "grow"`)

The opposite of a fade. Starts with small lines and slowly plateaus into longer, denser blocks of text.

<!-- Best for: Technical documentation, dramatic build-ups. -->

| Parameter | Default | Description                        |
| --------- | :-----: | ---------------------------------- |
| `base`    |  `20`   | Minimum base word count.           |
| `factor`  |  `30`   | The steepness of the growth curve. |

**Example:**

```typ
#ipsum(mode: "grow", pars: 4, base: 10, factor: 25, paragraph-word-count: true)
```

#### Dialogue Scene (`mode: "dialogue"`)

Simulates a novel. It generates a mix of narrative prose and spoken dialogue enclosed in quotation marks.
<!-- It handles indentation automatically (narrative uses standard indent, dialogue uses hanging indent). -->

<!-- Best for: Typesetting fiction, testing distinct paragraph styles. -->

| Parameter  | Default | Description                                       |
| ---------- | :-----: | ------------------------------------------------- |
| `events`   |  `10`   | Total number of lines (narrative or spoken).      |
| `ratio`    |  `0.6`  | Probability (0.0 to 1.0) that a line is dialogue. |
| `seed`     |  `42`   | Random seed for the conversation flow.            |
| `h-indent` |  `0em`  | Paragraph hanging indent.                         |

**Example:**

```typ
#ipsum(mode: "dialogue", events: 5, ratio: 0.7, indent: 2em)
```

#### Fibonacci Sequence (`mode: "fibonacci"`)

Generates paragraph lengths corresponding to the Fibonacci sequence (1, 1, 2, 3, 5, 8...).

| Parameter | Default | Description                                 |
| --------- | :-----: | ------------------------------------------- |
| `steps`   |   `8`   | How many steps of the sequence to generate. |
| `reverse` | `true`  | Reverse the sequence.                       |

**Example:**

```typ
#ipsum(mode: "fibonacci", steps: 7, reverse: true, spacing: 0.5em)
```
