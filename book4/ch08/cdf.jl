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
    get_name_for_posterior(cdf_dist::Cdf{T}, posterior::Float64)::T

    returns name from cdf.names that is >= posterior
"""
function get_name_for_posterior(cdf_dist::Cdf{T}, posterior::Float64)::T where T
    @assert 0 <= posterior <= 1
    return cdf_dist.names[findfirst(x -> x >= posterior, cdf_dist.posteriors)]
end

function get_posterior_for_name(cdf_dist::Cdf{T}, name::T)::Float64 where T
    return cdf_dist.posteriors[findfirst(x -> x == name, cdf_dist.names)]
end

function get_credible_interval(cdf_dist::Cdf{T}, prob::Float64)::Vector{T} where T
    @assert 0 <= prob <= 1
    probs::Vector{Float64} = [0.5 - prob / 2, 0.5 + prob / 2]
    return [get_name_for_posterior(cdf_dist, p) for p in probs]
end

"""
    Computes and returns the distribution of a maximum of a cdf

    ---
    args:
        n: Int, drawing n times from cdf_dist,
            returns cdf where cdf(x) prob. that all n of drawings are <= to x
"""
function get_max_cdf_dist(cdf_dist::Cdf{T}, n::Int)::Cdf{T} where T
    cdf_max_n::Vector{Float64} = cdf_dist.posteriors .^ n
    return Cdf(cdf_dist.names, cdf_max_n)
end

"""
    Computes and returns the distribution of a minimum of a cdf

    ---
    args:
        n: Int, drawing n times from cdf_dist(x),
            returns cdf where cdf(x) prob. that all n of drawings are >= to x
"""
function get_min_cdf_dist(cdf_dist::Cdf{T}, n::Int)::Cdf{T} where T
    # prob that a val from dist is greater than x
    prob_gt::Vector{Float64} = 1 .- cdf_dist.posteriors
    # prob that all n vals drawn from dist exceed x
    # (their min exceeds x)
    prob_gt_n::Vector{Float64} = prob_gt .^ n
    prob_le_n::Vector{Float64} = 1 .- prob_gt_n
    return Cdf(cdf_dist.names, prob_le_n)
end

end
