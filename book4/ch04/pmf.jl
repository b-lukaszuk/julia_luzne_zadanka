module ProbabilityMassFunction

import CairoMakie as Cmk
import DataFrames as Dfs

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
    result = "names: $(join(pmf.names, ", "))\n"
    result = result * "priors: $(join(map(x -> round(x, digits=3) |> string, pmf.priors), ", "))\n"
    result = result * "likelihoods: $(join(map(x -> round(x, digits=3) |> string, pmf.likelihoods), ", "))\n"
    result = result * "posteriors: $(join(map(x -> round(x, digits=3) |> string, pmf.posteriors), ", "))\n"
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

# normalizes pmf.posteriors so they add up to 1
function normalizePosteriors!(pmf::Pmf{T}) where {T}
    pmf.posteriors = pmf.posteriors ./ sum(pmf.posteriors)
end

# updates posteriors (priors .* likeliehoods)
# if normalize = true, then posteriors are normalized
function updatePosteriors!(pmf::Pmf{T}, normalize::Bool=true) where {T}
    setPosteriors!(pmf, pmf.priors .* pmf.likelihoods)
    if normalize
        normalizePosteriors!(pmf)
    end
end

function drawLinesPosteriors(pmf::Pmf{T},
    title::String,
    xlabel::String,
    ylabel::String)::Cmk.Figure where {T}
    fig = Cmk.Figure(resolution=(600, 400))
    ax1, l1 = Cmk.lines(fig[1, 1],
        pmf.names, pmf.posteriors, color="navy",
        axis=(;
            title=title,
            xlabel=xlabel,
            ylabel=ylabel,
        ))
    Cmk.axislegend(ax1,
        [l1],
        ["posterior"],
        position=:lt
    )
    return fig
end

function getIdMaxPosterior(pmf::Pmf)::Int
    maxProb::Float64 = max(pmf.posteriors...)
    return findfirst(x -> x == maxProb, pmf.posteriors)
end

function getNameMaxPosterior(pmf::Pmf{T})::T where {T}
    return pmf.names[getIdMaxPosterior(pmf)]
end

function pmf2df(pmf::Pmf{T})::Dfs.DataFrame where {T}
    return Dfs.DataFrame(
        (;
        names=pmf.names,
        priors=pmf.priors,
        likelihoods=pmf.likelihoods,
        posteriors=pmf.posteriors
    )
    )
end

end