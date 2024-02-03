module ProbabilityMassFunction

import CairoMakie as Cmk
import DataFrames as Dfs
import Distributions as Dsts

mutable struct Pmf{T}
    names::Vector{T} # names of hypotheses
    priors::Vector{Float64}
    likelihoods::Vector{Float64}
    posteriors::Vector{Float64}

    Pmf(ns::Vector{Int}, prs) =
        (length(ns) != length(prs)) ?
        error("length(names) must be equal length(priors)") :
        new{Int}(
            ns, (prs ./ sum(prs)), zeros(length(ns)), zeros(length(ns))
        )

    Pmf(ns::Vector{Float64}, prs) =
        (length(ns) != length(prs)) ?
        error("length(names) must be equal length(priors)") :
        new{Float64}(
            ns, (prs ./ sum(prs)), zeros(length(ns)), zeros(length(ns))
        )

    Pmf(ns::Vector{String}, prs) =
        (length(ns) != length(prs)) ?
        error("length(names) must be equal length(priors)") :
        new{String}(
            ns, (prs ./ sum(prs)), zeros(length(ns)), zeros(length(ns))
        )
end

function Base.show(io::IO, pmf::Pmf)
    trim::Bool = length(pmf.names) > 10
    result::String = "names: $(join(trim ? pmf.names[1:10] : pmf.names, ", "))$(trim ? ", ..." : "")\n"
    result = result * "priors: $(join(map(x -> round(x, digits=3) |> string, trim ? pmf.priors[1:10] : pmf.priors), ", "))$(trim ? ", ..." : "")\n"
    result = result * "likelihoods: $(join(map(x -> round(x, digits=3) |> string, trim ? pmf.likelihoods[1:10] : pmf.likelihoods), ", "))$(trim ? ", ..." : "")\n"
    result = result * "posteriors: $(join(map(x -> round(x, digits=3) |> string, trim ? pmf.posteriors[1:10] : pmf.posteriors),  ", "))$(trim ? ", ..." : "")\n"
    print(io, result)
end

function getCounts(v::Vector{T})::Dict{T,Int} where {T}
    result::Dict{T,Int} = Dict()
    for elt in v
        result[elt] = get(result, elt, 0) + 1
    end
    return result
end

function getPmfFromSeq(seq::Vector{T})::Pmf{T} where {T}
    counts::Dict{T,Int} = getCounts(seq)
    sortedKeys::Vector{T} = keys(counts) |> collect |> sort
    sortedVals::Vector{Int} = [counts[k] for k in sortedKeys]
    return Pmf(sortedKeys, sortedVals)
end

function getFieldValsEqName(pmf::Pmf{T}, name::T, fieldName::String, default) where {T}
    ind = findfirst(x -> x == name, getproperty(pmf, Symbol("names")))
    return isnothing(ind) ? default : getproperty(pmf, Symbol(fieldName))[ind]
end

function getPriorByName(pmf::Pmf{T}, name::T)::Float64 where {T}
    return getFieldValsEqName(pmf, name, "priors", 0.0)
end

function getPriorsByNames(pmf::Pmf{T}, names::Vector{T})::Vector{Float64} where {T}
    return map(n -> getPriorByName(pmf, n), names)
end

function setPosteriors!(pmf::Pmf{T}, newPosteriors::Vector{Float64}) where {T}
    pmf.posteriors = newPosteriors
end

function setLikelihoods!(pmf::Pmf{T}, newLikelihoods::Vector{Float64}) where {T}
    pmf.likelihoods = newLikelihoods
end


"""
        normalizes pmf.posteriors so they add up to 1
"""
function normalizePosteriors!(pmf::Pmf{T}) where {T}
    pmf.posteriors = pmf.posteriors ./ sum(pmf.posteriors)
end


"""
        updates posteriors (priors .* likeliehoods)
        if normalize = true, then posteriors are normalized
"""
function updatePosteriors!(pmf::Pmf{T}, normalize::Bool=true) where {T}
    setPosteriors!(pmf, pmf.priors .* pmf.likelihoods)
    if normalize
        normalizePosteriors!(pmf)
    end
end

function drawLinesPmf(pmf::Pmf{T},
    pmfFieldForYs::String,
    title::String,
    xlabel::String,
    ylabel::String)::Cmk.Figure where {T}
    fig = Cmk.Figure(size=(600, 400))
    ax1, l1 = Cmk.lines(fig[1, 1],
        pmf.names, getproperty(pmf, Symbol(pmfFieldForYs)), color="navy",
        axis=(;
            title=title,
            xlabel=xlabel,
            ylabel=ylabel,
        ))
    return fig

end

function drawLinesPosteriors(pmf::Pmf{T},
    title::String,
    xlabel::String,
    ylabel::String)::Cmk.Figure where {T}
    return drawLinesPmf(pmf, "posteriors", title, xlabel, ylabel)
end

function drawLinesPriors(pmf::Pmf{T},
    title::String,
    xlabel::String,
    ylabel::String)::Cmk.Figure where {T}
    return drawLinesPmf(pmf, "priors", title, xlabel, ylabel)
end

function getIndMaxField(pmf::Pmf, field::String)::Int
    maxProb::Float64 = max(getproperty(pmf, Symbol(field))...)
    return findfirst(x -> x == maxProb, getproperty(pmf, Symbol(field)))
end

function getIndMaxPosterior(pmf::Pmf)::Int
    return getIndMaxField(pmf, "posteriors")
end

function getIndMaxPrior(pmf::Pmf)::Int
    return getIndMaxField(pmf, "priors")
end

function getNameMaxPrior(pmf::Pmf{T})::T where {T}
    return pmf.names[getIndMaxPrior(pmf)]
end

function getNameMaxPosterior(pmf::Pmf{T})::T where {T}
    return pmf.names[getIndMaxPosterior(pmf)]
end

function getTotalProbGEName(pmf::Pmf{T}, field::String, name::T)::Float64 where {T}
    ge::BitVector = pmf.names .>= name
    total::Float64 = getproperty(pmf, Symbol(field))[ge] |> sum
    return total
end

function convertPmf2df(pmf::Pmf{T})::Dfs.DataFrame where {T}
    return Dfs.DataFrame(
        (;
        names=pmf.names,
        priors=pmf.priors,
        likelihoods=pmf.likelihoods,
        posteriors=pmf.posteriors
    )
    )
end


"""
        Make a binomial Pmf.
        n - number of trials
        p - probability of success in single trial
"""
function getBinomialPmf(n::Int, p::Float64)::Pmf{Int}
    ks::Vector{Int} = 0:1:n |> collect
    ps::Vector{Float64} = Dsts.pdf.(Dsts.Binomial(n, p), ks)
    ps = map(x -> round(x, digits=6), ps)
    return Pmf(ks, ps)
end


"""
    Update binormial pmf with a given sequence of:
           succeses ('s' or other letter) and failures ('f' or other letter)

    binomPmf.names - e.g. probs of success (e.g. different coins to get heads)
    dataset - result of an experiment (string of form "ffsfss")
    probMapping - keys: 'f', 's',
                  vals: probability vector of getting 'f' or 's' for each
                  hypothesis (binomPmf.names)
                  
"""
function updateBinomPmf!(
    binomPmf::Pmf{Float64},
    dataset::String,
    probMapping::Dict{Char,Vector{Float64}})

    binomPmf.likelihoods .= 1
    for data in dataset
        binomPmf.likelihoods .*= probMapping[data]
    end
    updatePosteriors!(binomPmf, true)

    return nothing

end


"""
    Update binormial binomPmf based on the result of an experiment

    binomPmf.names - e.g. probs of success (e.g. different coins to get heads)
    (n, k) - results of an experiment, where:
        n - number of trials
        k - number of success
"""
function updateBinomial!(binomPmf::Pmf{Float64}, k::Int, n::Int)

    @assert (k <= n) "k must be <= n"

    likelihoods::Vector{Float64} = Dsts.pdf.(
        Dsts.Binomial.(n, binomPmf.names), k)
    setLikelihoods!(binomPmf, likelihoods)
    updatePosteriors!(binomPmf, true)

    return nothing
end

function getMeanPosterior(pmf::Pmf{T})::Float64 where {T<:Union{Int,Float64}}
    return sum(pmf.posteriors .* pmf.names)
end

end
