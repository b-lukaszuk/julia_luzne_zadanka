module ProbabilityMassFunction

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

function get_counts(v::Vector{T})::Dict{T, Int} where T
    result::Dict{T, Int} = Dict()
    for elt in v
        result[elt] = get(result, elt, 0) + 1
    end
    return result
end

function mk_pmf_from_seq(seq::Vector{T})::Pmf where T
    counts::Dict{T, Int} = get_counts(seq)
    total::Int = sum(values(counts))
    names::Vector{T} = unique(seq)
    priors::Vector{Float64} = [counts[n]/total for n in names]
    return Pmf(names, priors)
end

function get_field_vals_eq_name(pmf::Pmf{T}, name::T, field_name::String, default) where T
    ind = findfirst(x -> x == name, getproperty(pmf, Symbol("names")))
    return isnothing(ind) ? default : getproperty(pmf, Symbol(field_name))[ind]
end

function get_prior(pmf::Pmf, name::Union{Int, String, Float64})::Float64
    return get_field_vals_eq_name(pmf, name, "priors", 0.0)
end

function get_prior(pmf::Pmf{T}, names::Vector{T})::Vector{Float64} where T
    return [get_prior(pmf, n) for n in names]
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
function calculate_posteriors!(pmf::Pmf)
    pmf.unnorms = pmf.priors .* pmf.likelihoods
    normalize!(pmf)
end

"""
Updates posteriors (old posteriors * new likelihoods) and normalizes them
if posteriors were not updated before then the distribution of posteriors is uniform
"""
function update_posteriors!(pmf::Pmf, new_likelihoods::Vector{Float64})
    pmf.likelihoods = new_likelihoods
    pmf.unnorms = pmf.posteriors .* pmf.likelihoods
    normalize!(pmf)
end

function pmf2df(pmf::Pmf)::pd.DataFrame
    df = pd.DataFrame((;pmf.names, pmf.priors, pmf.likelihoods, pmf.posteriors))
    return df
end

function get_posterior(pmf::Pmf{T}, name::T)::Float64 where T
    return get_field_vals_eq_name(pmf, name, "posteriors", 0.0)
end

function get_posterior(pmf::Pmf{T}, names::Vector{T})::Vector{Float64} where T
    return [get_posterior(pmf, n) for n in names]
end

function get_id_max_posterior(pmf::Pmf)::Int
    max_prob::Float64 = max(pmf.posteriors...)
    return findfirst(x->x==max_prob, pmf.posteriors)
end

function get_name_max_posterior(pmf::Pmf{T})::T where T
    return pmf.names[get_id_max_posterior(pmf)]
end

"""
Creates a Pmf struct for a binomial with names
0:n and their coresponding probabilities as priors
"""
function mk_binomial_pmf(n::Int, p::Float64)::Pmf{Int}
    ks::Vector{Int} = collect(0:n)
    ps::Vector{Float64} = dst.pdf.(dst.Binomial(n, p), ks)
    return Pmf(ks, ps)
end

"""
Reads data from dataset, updates likelihood based on prob_mapping,
then calculates and updates posteriors (old posteriors are discarded)
"""
function calculate_posteriors!(pmf::Pmf{T}, dataset::String, prob_mapping::Dict{Char, Vector{Float64}}) where T<:Union{Int, String, Float64}
    for datum in dataset
        pmf.likelihoods = pmf.likelihoods .* prob_mapping[datum]
    end
    calculate_posteriors!(pmf)
end

"""
Calculates likelihoods for binomial with n trials, k successes, p - prob. of success (taken from priors)
then it updates posteriors (old posteriors * new likelihoods) and normalizes them
"""
function update_binomial!(binom_pmf::Pmf{T}, data::Dict{String, Int}) where T<:Union{Int, String, Float64}
    ps::Vector{Float64} = binom_pmf.priors
    likelihood::Vector{Float64} = dst.pdf.(dst.Binomial.(data["n"], ps), data["k"])
    update_posteriors!(binom_pmf, likelihood)
end

"""
Draws posteriors (Y-axis) and names (X-axis) if they are numeric, uses Plots
"""
function draw_posteriors(pmf::Pmf{T}, title::String, xlab::String, ylab::String, label::String) where T<:Union{Int, Float64}
    plts.plot(pmf.names, pmf.posteriors, label=label)
    plts.title!(title)
    plts.xlabel!(xlab)
    plts.ylabel!(ylab)
end

end
