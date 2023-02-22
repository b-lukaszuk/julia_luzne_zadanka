import DataFrames as pd
module ProbabilityMassFunction

mutable struct Pmf{T}
    names::Vector{T}
    priors::Vector{Float64}
    likelihoods::Vector{Float64}
    unnorms::Vector{Float64}
    norm::Float64
    posteriors::Vector{Float64}
    updated_before::Bool

    Pmf(ns::Vector{Int}, prs) = (length(ns) != length(prs)) ?
        error("length(names) must be equal length(priors)") :
        new{Int}(ns, prs, zeros(length(ns)), zeros(length(ns)), 0, zeros(length(ns)), false)

    Pmf(ns::Vector{String}, prs) = (length(ns) != length(prs)) ?
        error("length(names) must be equal length(priors)") :
        new{String}(ns, prs, zeros(length(ns)), zeros(length(ns)), 0, zeros(length(ns)), false)
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

function get_prior(pmf::Pmf, name::Union{Int, String})::Float64
    return get_field_vals_eq_name(pmf, name, "priors", 0.0)
end

function get_prior(pmf::Pmf{T}, names::Vector{T})::Vector{Float64} where T
    return [get_prior(pmf, n) for n in names]
end

function normalize!(pmf::Pmf)
    pmf.norm = sum(pmf.unnorms)
    if (pmf.norm == 0)
        pmf.posteriors = [0 for n in pmf.names]
    else
        pmf.posteriors = pmf.unnorms ./ pmf.norm
    end
end

function update!(pmf::Pmf)
    if !pmf.updated_before
        pmf.updated_before = true
    end
    pmf.unnorms = pmf.priors .* pmf.likelihoods
    normalize!(pmf)
end

function update!(pmf::Pmf, likelihoods::Vector{Float64})
    pmf.likelihoods = likelihoods
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

end
