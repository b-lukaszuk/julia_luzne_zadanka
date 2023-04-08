module ProbabilityMassFunctions

import DataFrames as pd
import Distributions as dst
import Plots as plts

"""
Pmf - probability mass function object with functionality similar to Python's empiricaldist's (library) Pmf

Fields:

Pmf.names - Vector{<:Union{String, Int, Float64}} - names of hypothesis, e.g. choosing side 1-6 from a die

Pmf.priors - Vector{Float64} - prior probabilities (between 0-1), so P(H)

Pmf.likelihoods - Vector{Float64} - probabilities (likelihoods), so P(D|H)

Pmf.unnorms - Vector{Float64} - probabilities not scaled (e.g. their sum is different from 1)

Pmf.norm - Float64 - skalar for unnorms so they can sum up to 1, so I guess it is normalizing constant P(D)

Pmf.posteriors - Vector{Float64} - posterior probabilities, so P(H|D)
"""
mutable struct Pmf{T}
    names::Vector{T}
    priors::Vector{Float64}
    likelihoods::Vector{Float64}
    unnorms::Vector{Float64}
    norm::Float64
    posteriors::Vector{Float64}

    # posteriors are uniform, i.e. initially each prior is equally likely
    Pmf(ns::Vector{Int}, prs) = (length(ns) != length(prs)) ?
                                error("length(names) must be equal length(priors)") :
                                new{Int}(ns, prs, ones(length(ns)), ones(length(ns)), 0, ones(length(ns)))

    # posteriors are uniform, i.e. initially each prior is equally likely
    Pmf(ns::Vector{Float64}, prs) = (length(ns) != length(prs)) ?
                                    error("length(names) must be equal length(priors)") :
                                    new{Float64}(ns, prs, ones(length(ns)), ones(length(ns)), 0, ones(length(ns)))

    # posteriors are uniform, i.e. initially each prior is equally likely
    Pmf(ns::Vector{String}, prs) = (length(ns) != length(prs)) ?
                                   error("length(names) must be equal length(priors)") :
                                   new{String}(ns, prs, ones(length(ns)), ones(length(ns)), 0, ones(length(ns)))
end

function Base.show(io::IO, pmf::Pmf)
    result = "names: $(join(pmf.names, ", "))\n"
    result = result * "priors: $(join(map(x -> round(x, digits=3) |> string, pmf.priors), ", "))\n"
    result = result * "likelihoods: $(join(map(x -> round(x, digits=3) |> string, pmf.likelihoods), ", "))\n"
    result = result * "posteriors: $(join(map(x -> round(x, digits=3) |> string, pmf.posteriors), ", "))\n"
    print(io, result)
end

"""
gets counts of elements in a vector{T}, returns Dict{T, count}
"""
function getCounts(v::Vector{T})::Dict{T,Int} where {T}
    result::Dict{T,Int} = Dict()
    for elt in v
        result[elt] = get(result, elt, 0) + 1
    end
    return result
end

function mkPmfFromSeq(seq::Vector{T})::Pmf where {T}
    counts::Dict{T,Int} = getCounts(seq)
    total::Int = sum(values(counts))
    names::Vector{T} = sort(unique(seq))
    priors::Vector{Float64} = [counts[n] / total for n in names]
    return Pmf(names, priors)
end

function getFieldValsEqName(pmf::Pmf{T}, name::T, fieldName::String, default) where {T}
    ind = findfirst(x -> x == name, getproperty(pmf, Symbol("names")))
    return isnothing(ind) ? default : getproperty(pmf, Symbol(fieldName))[ind]
end

function getPrior(pmf::Pmf, name::Union{Int,String,Float64})::Float64
    return getFieldValsEqName(pmf, name, "priors", 0.0)
end

function getPrior(pmf::Pmf{T}, names::Vector{T})::Vector{Float64} where {T}
    return [getPrior(pmf, n) for n in names]
end

""""Normalizes Pmf.unnorms (unnormalized posteriors) and puts them into Pmf.posteriors
(normalized posteriors, they add up to 1)"""
function normalize!(pmf::Pmf)
    pmf.norm = sum(pmf.unnorms)
    if (pmf.norm == 0)
        pmf.posteriors = [0 for _ in pmf.names]
    else
        pmf.posteriors = pmf.unnorms ./ pmf.norm
    end
end

"""
Calculates posteriors from priors and likelihoods (priors * likelihoods)
if likelihoods were not set since struct creation then posteriors will be equal priors
"""
function calculatePosteriors!(pmf::Pmf)
    pmf.unnorms = pmf.priors .* pmf.likelihoods
    normalize!(pmf)
end

function updateLikelihoods!(pmf::Pmf, newLikelihoods::Vector{Float64})
    pmf.likelihoods .*= newLikelihoods
end

"""
Updates posteriors (posteriors * likelihoods) and normalizes them
if posteriors were not updated before then the distribution of posteriors is uniform
"""
function updatePosteriors!(pmf::Pmf)
    pmf.unnorms = pmf.likelihoods .* pmf.posteriors
    normalize!(pmf)
end

function pmf2df(pmf::Pmf)::pd.DataFrame
    df = pd.DataFrame((; pmf.names, pmf.priors, pmf.likelihoods, pmf.posteriors))
    return df
end

function getPosterior(pmf::Pmf{T}, name::T)::Float64 where {T}
    return getFieldValsEqName(pmf, name, "posteriors", 0.0)
end

function getPosterior(pmf::Pmf{T}, names::Vector{T})::Vector{Float64} where {T}
    return [getPosterior(pmf, n) for n in names]
end

function getIdMaxPosterior(pmf::Pmf)::Int
    maxProb::Float64 = max(pmf.posteriors...)
    return findfirst(x -> x == maxProb, pmf.posteriors)
end

function getNameMaxPosterior(pmf::Pmf{T})::T where {T}
    return pmf.names[getIdMaxPosterior(pmf)]
end

"""
Creates a Pmf struct for a binomial with names
0:n and their coresponding probabilities as priors
"""
function mkBinomialPmf(n::Int, p::Float64)::Pmf{Int}
    ks::Vector{Int} = collect(0:n)
    ps::Vector{Float64} = dst.pdf.(dst.Binomial(n, p), ks)
    return Pmf(ks, ps)
end

"""
Reads data from dataset, updates likelihood based on probMapping,
then calculates and updates posteriors (old posteriors are discarded)
"""
function calculatePosteriors!(pmf::Pmf{T}, dataset::String,
    probMapping::Dict{Char,Vector{Float64}}) where {T<:Union{Int,String,Float64}}
    for datum in dataset
        pmf.likelihoods = pmf.likelihoods .* probMapping[datum]
    end
    calculatePosteriors!(pmf)
end

"""
Calculates likelihoods for binomial with n trials, k successes, p - prob. of success (taken from priors)
then it updates posteriors (old posteriors * new likelihoods) and normalizes them
"""
function updateBinomial!(binomPmf::Pmf{T}, data::Dict{String,Int}) where {T<:Union{Int,String,Float64}}
    ns::Vector{Float64} = binomPmf.names
    likelihood::Vector{Float64} = dst.pdf.(dst.Binomial.(data["n"], ns), data["k"])
    updateLikelihoods!(binomPmf, likelihood)
    updatePosteriors!(binomPmf)
end

"""
Draws posteriors (Y-axis) and names (X-axis) if they are numeric, uses Plots
"""
function drawPosteriors(pmf::Pmf{T}, title::String, xlab::String, ylab::String, label::String) where {T<:Union{Int,Float64}}
    plts.plot(pmf.names, pmf.posteriors, label=label)
    plts.title!(title)
    plts.xlabel!(xlab)
    plts.ylabel!(ylab)
end

"""
Draws priors (Y-axis) and names (X-axis) if they are numeric, uses Plots
"""
function drawPriors(pmf::Pmf{T}, title::String, xlab::String, ylab::String, label::String) where {T<:Union{Int,Float64}}
    plts.plot(pmf.names, pmf.priors, label=label)
    plts.title!(title)
    plts.xlabel!(xlab)
    plts.ylabel!(ylab)
end

function getMean(pmf::Pmf{<:Union{Int,Float64}}, usePriors::Bool=false)::Float64
    return usePriors ? sum(pmf.priors .* pmf.names) : sum(pmf.posteriors .* pmf.names)
end

function getNameForQuantile(pmf::Pmf{<:Union{Int,Float64}},
    cumPosteriorProb::Float64)::Union{Int,Float64}
    @assert (0 <= cumPosteriorProb <= 1)
    total::Float64 = 0
    for i in eachindex(pmf.names)
        total += pmf.posteriors[i]
        if total >= cumPosteriorProb
            return pmf.names[i]
        end
    end
    return nothing
end

function getNameForQuantile(pmf::Pmf{<:Union{Int,Float64}},
    cumPosteriorProbs::Vector{Float64})::Vector{<:Union{Int,Float64}}
    return [getNameForQuantile(pmf, p) for p in cumPosteriorProbs]
end

function getCredibleInterval(pmf::Pmf{<:Union{Int,Float64}},
    prob::Float64)::Vector{<:Union{Int,Float64}}
    @assert (0 <= prob <= 1)
    halfProb::Float64 = prob / 2
    return getNameForQuantile(pmf, [0.5 - halfProb, 0.5 + halfProb])
end

function updateWithData!(pmf::Pmf{Int}, data::Int)
    hypos = pmf.names
    likelihood = 1 ./ hypos
    impossible = (data .> hypos)
    likelihood[impossible] .= 0
    pmf.likelihoods .*= likelihood
    pmf.calculatePosteriors!(pmf)
end

function sumProbsByNames(names::Vector{Int}, probs::Vector{Float64})::Dict{Int,Float64}
    @assert length(names) == length(probs)
    res::Dict{Int,Float64} = Dict()
    for i in eachindex(names)
        res[names[i]] = get(res, names[i], 0) + probs[i]
    end
    return res
end

"""
Inspired by similar function in empiricaldist by Allen Downey

args:
fn - function accepting 2 Int64 as input and returning Int64 as output
"""
function convolveDist(pmf1::Pmf{Int}, pmf2::Pmf{Int}, fn::Function)::Pmf{Int}
    # Iterators.product(vec1, vec2) gives cartesian product of two vects [(v1.0, v2.0), (v1.0, v2.1), etc.]
    newNames::Vector{Int} = [[fn(a, b) for (a, b) in Iterators.product(pmf1.names, pmf2.names)]...]
    newPriors::Vector{Float64} = [[a * b for (a, b) in Iterators.product(pmf1.priors, pmf2.priors)]...]
    probs::Dict{Int,Float64} = sumProbsByNames(newNames, newPriors)
    orderedKeys::Vector{Int64} = sort(collect(keys(probs)))
    orderedVals::Vector{Float64} = [probs[k] for k in orderedKeys]
    return Pmf(orderedKeys, orderedVals ./ sum(orderedVals))
end

function addDist(pmf1::Pmf{Int}, x::Int)::Pmf{Int}
    return Pmf(pmf1.names .+ x, pmf1.priors)
end

function addDist(pmf1::Pmf{Int}, pmf2::Pmf{Int})::Pmf{Int}
    return convolveDist(pmf1, pmf2, +)
end

function addDistSeq(seq::Vector{<:Pmf{Int}})::Pmf{Int}
    res::Pmf{Int} = seq[1]
    for i in 2:length(seq)
        res = addDist(res, seq[i])
    end
    return res
end

function subDist(dist::Pmf{Int}, x::Int)::Pmf{Int}
    return Pmf(dist.names .- x, dist.priors)
end

function subDist(pmf1::Pmf{Int}, pmf2::Pmf{Int})::Pmf{Int}
    return convolveDist(pmf1, pmf2, -)
end

function multDist(dist::Pmf{Int}, x::Int)::Pmf{Int}
    return Pmf(dist.names .* x, dist.priors)
end

function multDist(pmf1::Pmf{Int}, pmf2::Pmf{Int})::Pmf{Int}
    return convolveDist(pmf1, pmf2, *)
end

function padVect(vect::Vector{T}, final_len::Int, fill::Number=0)::Vector{T} where {T<:Union{Int,Float64}}
    return [get(vect, i, fill) for i in 1:final_len]
end

"""mkMixture(pmfDist::Pmf{Int}, pmfSeq::Vector{Pmf{Int}})::Pmf{Int}

    Make a mixture of distributions.

    ---
    args:

        pmfDist: probs of getting a dist in pmfSeq (names and priors)
        pmfSeq: pmfDists and their probs (priors), names betw seqs should overlap
    """
function mkMixture(pmfDist::Pmf{A}, pmfSeq::Vector{Pmf{B}})::Pmf{B} where {A<:Union{Int,Float64},B<:Union{Int,Float64}}
    maxLen::Int = max([length(p.names) for p in pmfSeq]...)
    names::Vector{B} = [p.names for p in pmfSeq if length(p.names) == maxLen][1]
    pmfsNamesAndPriors::Dict{A,Vector{Float64}} = Dict(
        pmfDist.names[i] => padVect(s.priors, maxLen) for (i, s) in enumerate(pmfSeq))
    pmfsNamesAndPosteriors::Dict{A,Vector{Float64}} = Dict(
        k => v .* getPrior(pmfDist, k) for (k, v) in pmfsNamesAndPriors)
    df::pd.DataFrame = pd.DataFrame(
        Dict(string(k) => v for (k, v) in pmfsNamesAndPosteriors))
    mixProbs::Vector{Float64} = (df|>Matrix|>x->sum(x, dims=2))[:, 1]
    return Pmf(names, mixProbs)
end

end
