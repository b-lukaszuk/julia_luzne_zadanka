module CumulativeProbability

mutable struct Cdf{T}
    names::Vector{T}
    posteriors::Vector{Float64}

    Cdf(ns::Vector{Int}, posts) = (length(ns) != length(posts)) ? error("length(names) must be equal length(posteriors)") : new{Int}(ns, posts)
    Cdf(ns::Vector{Float64}, posts) = (length(ns) != length(posts)) ? error("length(names) must be equal length(posteriors)") : new{Float64}(ns, posts)
    Cdf(ns::Vector{String}, posts) = (length(ns) != length(posts)) ? error("length(names) must be equal length(posteriors)") : new{String}(ns, posts)
end

function Base.show(io::IO, cdf::Cdf)
    result = "names: $(join(cdf.names, ", "))\n"
    result = result * "posteriors: $(join(map(x -> round(x, digits=3) |> string, cdf.posteriors), ", "))\n"
    print(io, result)
end

"""
    getNameForPosterior(cdfDist::Cdf{T}, posterior::Float64)::T

    returns name from cdf.names that is >= posterior
"""
function getNameForPosterior(cdfDist::Cdf{T}, posterior::Float64)::T where T
    @assert 0 <= posterior <= 1
    return cdfDist.names[findfirst(x -> x >= posterior, cdfDist.posteriors)]
end

function getPosteriorForName(cdfDist::Cdf{T}, name::T)::Float64 where T
    return cdfDist.posteriors[findfirst(x -> x == name, cdfDist.names)]
end

function getCredibleInterval(cdfDist::Cdf{T}, prob::Float64)::Vector{T} where T
    @assert 0 <= prob <= 1
    probs::Vector{Float64} = [0.5 - prob / 2, 0.5 + prob / 2]
    return [getNameForPosterior(cdfDist, p) for p in probs]
end

"""
    Computes and returns the distribution of a maximum of a cdf

    ---
    args:
        n: Int, drawing n times from cdfDist,
            returns cdf where cdf(x) prob. that all n of drawings are <= to x
"""
function getMaxCdfDist(cdfDist::Cdf{T}, n::Int)::Cdf{T} where T
    cdfMaxN::Vector{Float64} = cdfDist.posteriors .^ n
    return Cdf(cdfDist.names, cdfMaxN)
end

"""
    Computes and returns the distribution of a minimum of a cdf

    ---
    args:
        n: Int, drawing n times from cdfDist(x),
            returns cdf where cdf(x) prob. that all n of drawings are >= to x
"""
function getMinCdfDist(cdfDist::Cdf{T}, n::Int)::Cdf{T} where T
    # prob that a val from dist is greater than x
    probGt::Vector{Float64} = 1 .- cdfDist.posteriors
    # prob that all n vals drawn from dist exceed x
    # (their min exceeds x)
    probGtN::Vector{Float64} = probGt .^ n
    probLeN::Vector{Float64} = 1 .- probGtN
    return Cdf(cdfDist.names, probLeN)
end

end
