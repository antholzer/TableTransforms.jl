using TableTransforms
using Distributions
using Tables
using TypedTables
using CategoricalArrays
using ScientificTypes: Count, Multiclass
using LinearAlgebra
using Statistics
using Test, Random, Plots
using ReferenceTests, ImageIO

# set default configurations for plots
gr(ms=2, mc=:black, aspectratio=:equal,
   label=false, size=(600,400))

# workaround GR warnings
ENV["GKSwstype"] = "100"

# environment settings
isCI = "CI" ∈ keys(ENV)
islinux = Sys.islinux()
visualtests = !isCI || (isCI && islinux)
datadir = joinpath(@__DIR__,"data")

# for functor tests in Functional testset
struct Polynomial{T<:Real}
  coeffs::Vector{T}
end
Polynomial(args::T...) where {T<:Real} = Polynomial(collect(args))
(p::Polynomial)(x) = sum(a * x^(i-1) for (i, a) in enumerate(p.coeffs))

function isequalmissing(a, b)
  length(a) == length(b) || return false
  for (x, y) in zip(a, b)
    x === y || return false
  end
  return true
end

# list of tests
testfiles = [
  "distributions.jl",
  "colspec.jl",
  "transforms.jl"
]

@testset "TableTransforms.jl" begin
  for testfile in testfiles
    include(testfile)
  end
end