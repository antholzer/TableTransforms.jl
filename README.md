# TableTransforms.jl

[![Build Status](https://github.com/juliohm/TableTransforms.jl/workflows/CI/badge.svg)](https://github.com/juliohm/TableTransforms.jl/actions)
[![Coverage](https://codecov.io/gh/juliohm/TableTransforms.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/juliohm/TableTransforms.jl)

This package provides transforms that are commonly used
in statistics and machine learning. It was developed to
address specific needs in feature engineering and works
with general [Tables.jl](https://github.com/JuliaData/Tables.jl)
tables.

Past attempts to model transforms in Julia such as
[FeatureTransforms.jl](https://github.com/invenia/FeatureTransforms.jl)
served as inspiration for this package. We are happy to absorb any
missing transform, and contributions are very welcome.

Here are some unique features:

- Transforms are **revertible** meaning that one can apply a transform
  and undo the transformation without having to do all the manual work
  keeping constants around.

- Pipelines can be easily constructed with clean syntax
  `(f1 → f2 → f3) ∥ (f4 → f5)`, and they are automatically
  revertible when the individual transforms are revertible.

- Branches of a pipeline are run in parallel using multiple threads
  with [Transducers.jl](https://github.com/JuliaFolds/Transducers.jl).

## Rationale

A common task in statistics and machine learning consists of transforming
the variables of a problem to achieve better convergence or to apply methods
that rely on multivariate Gaussian distributions. This process can be quite
tedious to implement by hand and very error-prone. We provide a consistent
and clean API to combine statistical transforms into pipelines.

## Installation

Get the latest stable release with Julia's package manager:

```julia
] add TableTransforms
```

## Usage

Below is a quick example of a pipeline with two parallel branches.
The tables produced by these two branches are concatenated horizontally
in the final table. Even though the pipeline is complex, we can still
revert it:

```julia
using TableTransforms

# create a random table
table = (a = rand(100), b = rand(100))

# create a transform pipeline
f1 = ZScore()
f2 = Scale()
f3 = Quantile()
f4 = Functional(log)
f5 = Interquartile()
pipeline = (f1 → f2 → f3) ∥ (f4 → f5)

# feed data into the pipeline
newtable = pipeline(table)

# alternatively save cache and revert later
newtable, cache = apply(pipeline, table)

# learn a model with newtable
# ...

# revert pipeline when done learning
original = revert(pipeline, newtable, cache)
```

## Available transforms

Please check the docstrings for additional information.

### Builtin

| Transform | Description |
|-----------|-------------|
| `Identity` | Identity transform |
| `Center` | Mean removal |
| `Scale` | Interval scaling |
| `MinMax` | Shortcut for `Scale(low=0.0, high=1.0)` |
| `Interquartile` | Shortcut for `Scale(low=0.25, high=0.75)` |
| `ZScore` | Z-score (a.k.a. normal score) |
| `Quantile` | Quantile-quantile transform |
| `EigenAnalysis` | Eigenanalysis of covariance |
| `PCA` | Shortcut for `ZScore() → EigenAnalysis(:V)` |
| `DRS` | Shortcut for `ZScore() → EigenAnalysis(:VD)` |
| `SDS` | Shortcut for `ZScore() → EigenAnalysis(:VDV)` |
| `Sequential` | Transform created with `→` (\to in LaTeX) |
| `Parallel` | Transform created with `∥` (\parallel in LaTeX) |

### External

| Transform | Description |
|-----------|-------------|
| `LogRatio` | Log-ratio transforms (see [CoDa.jl](https://github.com/JuliaEarth/CoDa.jl)) |

## Custom transforms

It is easy to integrate custom transforms into existing
pipelines. The new transform should be a subtype of
`Transform`, and should implement `apply`. If the new
transform `isrevertible`, then it should also implement
`revert`.

## Contributing

Contributions are very welcome. Please [open an issue](https://github.com/JuliaML/TableTransforms.jl/issues) if you have questions.

## Related packages

- [FeatureTransforms.jl](https://github.com/invenia/FeatureTransforms.jl)
  has transforms, but they are not fully revertible. Some transforms such
  as `MeanStdScaling` are constructed for a specific table and cannot be
  inserted in the middle of a pipeline.
- [AutoMLPipeline.jl](https://github.com/IBM/AutoMLPipeline.jl) relies on
  the Python stack via [PyCall.jl](https://github.com/JuliaPy/PyCall.jl).
  They provide pipelines with Julia's pipe `|>` operator and follow a
  more "Pythonic" interface. They do not support general
  [Tables.jl](https://github.com/JuliaData/Tables.jl).
- [Chain.jl](https://github.com/jkrumbiegel/Chain.jl) is a general package
  to execute functions in sequence given a
  [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl) as input.
  This package is suitable for more low-level manipulation of tables, it
  is not intended for statistical transforms such as `PCA`, `ZScore`, etc.
  Additionally, the syntax of the package promotes greedy transforms instead
  of lazily building a pipeline and then applying to multiple tables.
