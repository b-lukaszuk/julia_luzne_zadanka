# module ProbabilityMassFunction
# export Pmf, getPmfFromSeq, getFieldValsEqName, getPriorByName,
#     getPriorsByNames, setPosteriors!, setLikelihoods!,
#     normalizePosteriors!, updatePosteriors!, drawLinesPriors,
#     drawLinesPosteriors, getIndMaxPrior, getIndMaxPosterior,
#     getNameMaxPrior, getNameMaxPosterior, getTotalProbGEName,
#     convertPmf2df, getBinomialPmf, updateBinomial!, updateBinomPmf!,
#     getMean, getPosteriorsProbLEQ, updateCounts!, getQuantile,
#     getCredibleInterval, sumProbsByNames, addDist, subtractDist,
#     multDist

import CairoMakie as Cmk
import DataFrames as Dfs
import Distributions as Dsts

Num = Union{Int,Float64} # custom type

mutable struct Pmf{T}
    names::Vector{T} # names of hypotheses
    priors::Vector{Float64}
    likelihoods::Vector{Float64}
    posteriors::Vector{Float64}

    Pmf(ns::Vector{Int}, prs) =
        (length(ns) != length(prs)) ?
        error("length(names) must be equal length(priors)") :
        new{Int}(
            ns, (prs ./ sum(prs)), ones(length(ns)), ones(length(ns))
        )

    Pmf(ns::Vector{Float64}, prs) =
        (length(ns) != length(prs)) ?
        error("length(names) must be equal length(priors)") :
        new{Float64}(
            ns, (prs ./ sum(prs)), ones(length(ns)), ones(length(ns))
        )

    Pmf(ns::Vector{String}, prs) =
        (length(ns) != length(prs)) ?
        error("length(names) must be equal length(priors)") :
        new{String}(
            ns, (prs ./ sum(prs)), ones(length(ns)), ones(length(ns))
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

function getPriorByName(pmf::Pmf{T}, name::T, defVal::Float64=0.0)::Float64 where {T}
    return getFieldValsEqName(pmf, name, "priors", defVal)
end

function getPriorsByNames(pmf::Pmf{T}, names::Vector{T}, defVal::Float64=0.0)::Vector{Float64} where {T}
    return map(n -> getPriorByName(pmf, n, defVal), names)
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

function getMean(pmf::Pmf{T}, usePriors::Bool=false)::Float64 where {T<:Union{Int,Float64}}
    if usePriors
        return sum(pmf.priors .* pmf.names)
    else
        return sum(pmf.posteriors .* pmf.names)
    end
end

function getPosteriorsProbLEQ(pmf::Pmf{T}, x::T)::Float64 where {T<:Union{Int,Float64}}
    indOfX::Union{Int,Nothing} = findfirst(y -> y == x, pmf.names)
    return isnothing(indOfX) ? -99.0 : sum(pmf.posteriors[1:indOfX])
end


"""
    Update Pmf (names are hypothesized max counts)

    data - observed counts
"""
function updateCounts!(pmf::Pmf{Int}, data::Int)

    # the chance of seeing any number out of postulated N (max counts)
    # is 1/N (Ns are in pmf.names)
    likelihood::Vector{<:Float64} = 1 ./ pmf.names
    impossible::BitVector = data .> pmf.names
    likelihood[impossible] .= 0
    pmf.likelihoods .*= likelihood
    updatePosteriors!(pmf, true)

    return nothing
end


"""
    Update Pmf (names are hypothesized max counts)

    data - observed counts
"""
function updateCounts!(pmf::Pmf{Int}, data::Vector{<:Int})
    foreach(d -> updateCounts!(pmf, d), data)
    return nothing
end


"""
    Compute a quantile with the given prob.
"""
function getQuantile(pmf::Pmf{T}, prob::Float64,
    usePriors::Bool=false)::Float64 where {T<:Union{Int,Float64}}
    @assert (0 <= prob <= 1) "prob must be in range [0-1]"
    totalProb::Float64 = 0
    for (q, p) in zip(pmf.names,
        usePriors ? pmf.priors : pmf.posteriors)
        totalProb += p
        if totalProb >= prob
            return q
        end
    end
    return -99.0
end

function getCredibleInterval(
    pmf::Pmf{T}, ci::Float64, usePriors::Bool=false
)::Vector{T} where {T<:Union{Int,Float64}}
    @assert (0.5 <= ci <= 0.99) "ci must be in range [0.5 - 0.99]"
    halfCI::Float64 = ci / 2
    return [getQuantile(pmf, q, usePriors) for q in [0.5 - halfCI, 0.5 + halfCI]]
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
Inspired by a similar function found in empiricaldist by Allen Downey
    applies a fn to cartesianProduct(pmf1.names, pmf2.names)
    applies * to cartesianProduct(pmf1.prior, pmf2.priors), so P(A) and P(B)

args:
fn - function accepting two Int64s as input and returning Int64 as output
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

function subtractDist(pmf1::Pmf{Int}, x::Int)::Pmf{Int}
    return Pmf(pmf1.names .- x, pmf1.priors)
end

function subtractDist(pmf1::Pmf{Int}, pmf2::Pmf{Int})::Pmf{Int}
    return convolveDist(pmf1, pmf2, -)
end

function multDist(pmf1::Pmf{Int}, x::Int)::Pmf{Int}
    return Pmf(pmf1.names .* x, pmf1.priors)
end

function multDist(pmf1::Pmf{Int}, pmf2::Pmf{Int})::Pmf{Int}
    return convolveDist(pmf1, pmf2, *)
end


mutable struct Cdf{T}
    names::Vector{T}
    posteriors::Vector{Float64}

    # posteriors are uniform, i.e. initially each prior is equally likely
    Cdf(ns::Vector{Int}, posts) =
        (length(ns) != length(posts)) ?
        error("length(names) must be equal length(posteriors)") :
        new{Int}(ns, posts)
    Cdf(ns::Vector{Float64}, posts) =
        (length(ns) != length(posts)) ?
        error("length(names) must be equal length(posteriors)") :
        new{Float64}(ns, posts)
    Cdf(ns::Vector{String}, posts) =
        (length(ns) != length(posts)) ?
        error("length(names) must be equal length(posteriors)") :
        new{String}(ns, posts)
end

function Base.show(io::IO, cdf::Cdf)
    trim::Bool = length(cdf.names) > 10
    result::String = "names: $(join(trim ? cdf.names[1:10] : cdf.names, ", "))$(trim ? ", ..." : "")\n"
    result = result * "posteriors: $(join(map(x -> round(x, digits=3) |> string, trim ? cdf.posteriors[1:10] : cdf.posteriors),  ", "))$(trim ? ", ..." : "")\n"
    print(io, result)
end


"""
	convertPmf2Cdf(pmfDist::Pmf{T}, usePriors::Bool=true)::Cdf{T}

	returns cdf build from pmf

	--
	args:
		pmfDist: Pmf struct
		usePiors: if true then pmfDist.priors are used to construct cdf
				otherwise pmfDist.posteriors are used to construct cdf
"""
function convertPmf2Cdf(pmfDist::Pmf{T}, usePriors::Bool=true)::Cdf{T} where {T}
    if usePriors
        return Cdf(pmfDist.names, cumsum(pmfDist.priors))
    else
        return Cdf(pmfDist.names, cumsum(pmfDist.posteriors))
    end
end

function convertCdf2Pmf(cdfDist::Cdf{T})::Pmf{T} where {T}
    diffs::Vector{Float64} = diff(cdfDist.posteriors)
    prepend!(diffs, cdfDist.posteriors[1])
    return Pmf(cdfDist.names, diffs)
end


"""
	getNameGtEqPosterior(cdfDist::Cdf{T}, posterior::Float64)::T

	returns name from cdfDist.names that is >= posterior
"""
function getNameGtEqPosterior(cdfDist::Cdf{T}, posterior::Float64)::T where {T}
    @assert 0 <= posterior <= 1
    return cdfDist.names[findfirst(x -> x >= posterior, cdfDist.posteriors)]
end

function getPosteriorGtEqName(cdfDist::Cdf{T}, name::T)::Float64 where {T<:Union{Int,Float64}}
    return cdfDist.posteriors[findfirst(x -> x == name, cdfDist.names)]
end

function getCredibleInterval(cdfDist::Cdf{T}, prob::Float64)::Vector{T} where {T}
    @assert 0 <= prob <= 1
    probs::Vector{Float64} = [0.5 - prob / 2, 0.5 + prob / 2]
    return [getNameGtEqPosterior(cdfDist, p) for p in probs]
end


"""
	Computes and returns the distribution of a maximum of a cdf

	---
	args:
		n: Int, drawing n times from cdfDist,
			returns cdf where cdf(x) prob. that all n of drawings are <= to x
"""
function getMaxCdfDist(cdfDist::Cdf{T}, n::Int)::Cdf{T} where {T}
    cdfMaxN::Vector{Float64} = cdfDist.posteriors .^ n
    return Cdf(cdfDist.names, cdfMaxN)
end


"""
Computes and returns the distribution of a minimum of a cdf

---
args:
    n: Int, drawing n times from cdfDist(x),
            returns cdf where cdf(x) prob. that all n of drawings are >= x
"""
function getMinCdfDist(cdfDist::Cdf{T}, n::Int)::Cdf{T} where {T}
    # prob that a val from cdfDist is greater than x (a given cdfDist.name)
    probGt::Vector{<:Float64} = 1 .- cdfDist.posteriors
    # prob that all n vals drawn from dist exceed x
    # (their min exceeds x)
    probGtN::Vector{<:Float64} = probGt .^ n
    probLEqN::Vector{<:Float64} = 1 .- probGtN
    return Cdf(cdfDist.names |> copy, probLEqN)
end

"""getMixture(pmfDist::Pmf{Num},
        pmfSeq::Vector{Pmf{Num}},
        pmfSeqNames::Vector{String},
        outcomes::Vector{Int}
        usePriors::Bool)::Dfs.DataFrame

	Make a mixture of distributions.

	---
	args:
		pmfDist: probs of getting a dist in pmfSeq (names and priors)
		pmfSeq: pmfDists and their probs (priors), names betw seqs should overlap
        pmfSeqNames: names (strings) to be prepended to priors in Df colnames
        outcomes: what outcomes in each pmf from pmfSeq we are looking for
        usePriors: should use priors or posteriors from PmfDist
	"""
function getMixture(pmfDist::Pmf{A}, pmfSeq::Vector{Pmf{B}},
    pmfSeqNames::Vector{String},
    outcomes::Vector{C},
    usePriors::Bool=false)::Dfs.DataFrame where {A<:Num,B<:Num,C<:Num}
    df::Dfs.DataFrame = Dfs.DataFrame(outcome=outcomes)
    for (i, pmf) in enumerate(pmfSeq)
        df[:, string(pmfSeqNames[i], " priors")] = getPriorsByNames(pmf, df[:, :outcome])
    end
    for rowNum in 1:Dfs.nrow(df)
        df[rowNum, 2:end] = Vector(df[rowNum, 2:end]) .* (usePriors ? pmfDist.priors : pmfDist.posteriors)
    end
    df.posteriors = df[:, 2:end] |> Array |> a -> sum(a, dims=2) |> vec
    df.posteriors .= df.posteriors ./ sum(df.posteriors)
    return df
end

function getMean(cdf::Cdf)::Float64
    return cdf |> convertCdf2Pmf |> x -> getMean(x, true)
end

function getStd(
    pmfDist::Pmf{T},
    usePriors::Bool=true)::Float64 where {T<:Union{Int,Float64}}

    avg::Float64 = getMean(pmfDist, usePriors)
    diffs::Vector{Float64} = pmfDist.names .- avg
    ps::Vector{Float64} = usePriors ? pmfDist.priors : pmfDist.posteriors
    var::Float64 = sum((diffs .^ 2) .* ps)
    return sqrt(var)
end

function getStd(
    cdfDist::Cdf{T},
    usePriors::Bool=true)::Float64 where {T<:Union{Int,Float64}}

    pmfDist::Pmf{T} = convertCdf2Pmf(cdfDist)
    return getStd(pmfDist)
end

function getPosteriorEqName(cdfDist::Cdf{T}, name::T)::Float64 where {T<:Union{Int,Float64}}
    ind::Int = findfirst(isapprox(name), cdfDist.names)
    return cdfDist.posteriors[ind]
end

# end
