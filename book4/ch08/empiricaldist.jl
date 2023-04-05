module EmpiricalDistributions

include("./pmf.jl")
import .ProbabilityMassFunction as pmf

include("./cdf.jl")
import .CumulativeProbability as cdf

function mk_pmf_from_cdf(cdf_dist::cdf.Cdf{T})::pmf.Pmf{T} where T
    diffs::Vector{Float64} = diff(cdf_dist.posteriors)
    prepend!(diffs, cdf_dist.posteriors[1])
    return pmf.Pmf(cdf_dist.names, diffs)
end

"""
    mk_cdf_from_pmf(pmf_dist::pmf.Pmf{T}, use_priors::Bool=true)::cdf.Cdf{T}

    returns cdf build from pmf

    --
    args:
        pmf_dist: Pmf struct
        use_priors: if true then pmf.priors are used to construct cdf
                otherwise pmf.posteriors are used to construct cdf
"""
function mk_cdf_from_pmf(pmf_dist::pmf.Pmf{T}, use_priors::Bool=true)::cdf.Cdf{T} where T
    if use_priors
        return cdf.Cdf(pmf_dist.names, cumsum(pmf_dist.priors))
    else
        return cdf.Cdf(pmf_dist.names, cumsum(pmf_dist.posteriors))
    end
end

function get_avg(pmf_dist::pmf.Pmf{T}, use_priors::Bool=true)::Float64 where T<:Union{Int, Float64}
    if use_priors
        return sum(pmf_dist.names .* pmf_dist.priors)
    else
        return sum(pmf_dist.names .* pmf_dist.posteriors)
    end
end

function get_avg(cdf_dist::cdf.Cdf{T})::Float64 where T<:Union{Int, Float64}
    pmf_dist::pmf.Pmf{T} = mk_pmf_from_cdf(cdf_dist)
    return get_avg(pmf_dist)
end

function get_std(pmf_dist::pmf.Pmf{T}, use_priors::Bool=true)::Float64 where T<:Union{Int, Float64}
    avg::Float64 = get_avg(pmf_dist, use_priors)
    devs::Vector{Float64} = pmf_dist.names .- avg
    ps::Vector{Float64} = use_priors ? pmf_dist.priors : pmf_dist.posteriors
    var:: Float64 = sum((devs.^2) .* ps)
    return sqrt(var)
end

function get_std(cdf_dist::cdf.Cdf{T}, use_priors::Bool=true)::Float64 where T<:Union{Int, Float64}
    pmf_dist::pmf.Pmf{T} = mk_pmf_from_cdf(cdf_dist)
    return get_std(pmf_dist)
end

end
