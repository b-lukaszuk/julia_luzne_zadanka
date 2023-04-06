module EmpiricalDistributions

include("./pmf.jl")
import .ProbabilityMassFunctions as pmf

include("./cdf.jl")
import .CumulativeProbabilityFunctions as cdf

function mkPmfFromCdf(cdfDist::cdf.Cdf{T})::pmf.Pmf{T} where T
    diffs::Vector{Float64} = diff(cdfDist.posteriors)
    prepend!(diffs, cdfDist.posteriors[1])
    return pmf.Pmf(cdfDist.names, diffs)
end

"""
    mkCdfFromPmf(pmfDist::pmf.Pmf{T}, usePriors::Bool=true)::cdf.Cdf{T}

    returns cdf build from pmf

    --
    args:
        pmfDist: Pmf struct
        usePriors: if true then pmf.priors are used to construct cdf
                otherwise pmf.posteriors are used to construct cdf
"""
function mkCdfFromPmf(pmfDist::pmf.Pmf{T}, usePriors::Bool=true)::cdf.Cdf{T} where T
    if usePriors
        return cdf.Cdf(pmfDist.names, cumsum(pmfDist.priors))
    else
        return cdf.Cdf(pmfDist.names, cumsum(pmfDist.posteriors))
    end
end

function getAvg(pmfDist::pmf.Pmf{T}, usePriors::Bool=true)::Float64 where T<:Union{Int, Float64}
    if usePriors
        return sum(pmfDist.names .* pmfDist.priors)
    else
        return sum(pmfDist.names .* pmfDist.posteriors)
    end
end

function getAvg(cdfDist::cdf.Cdf{T})::Float64 where T<:Union{Int, Float64}
    pmfDist::pmf.Pmf{T} = mkPmfFromCdf(cdfDist)
    return getAvg(pmfDist)
end

function getStd(pmfDist::pmf.Pmf{T}, usePriors::Bool=true)::Float64 where T<:Union{Int, Float64}
    avg::Float64 = getAvg(pmfDist, usePriors)
    devs::Vector{Float64} = pmfDist.names .- avg
    ps::Vector{Float64} = usePriors ? pmfDist.priors : pmfDist.posteriors
    var:: Float64 = sum((devs.^2) .* ps)
    return sqrt(var)
end

function getStd(cdfDist::cdf.Cdf{T}, usePriors::Bool=true)::Float64 where T<:Union{Int, Float64}
    pmfDist::pmf.Pmf{T} = mkPmfFromCdf(cdfDist)
    return getStd(pmfDist)
end

end
