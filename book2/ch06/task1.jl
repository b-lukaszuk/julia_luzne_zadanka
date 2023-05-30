###############################################################################
#                                   imports                                   #
###############################################################################
import CairoMakie as cmk

###############################################################################
#                                  functions                                  #
###############################################################################
function throw2DiceTheor()::Vector{Int}
    result::Vector{Int} = []
    for i in 1:6, j in 1:6
        push!(result, i + j)
    end
    return result
end

function getCounts(v::Vector{T})::Dict{T,Int} where {T}
    result::Dict{T,Int} = Dict()
    for elt in v
        result[elt] = get(result, elt, 0) + 1
    end
    return result
end

function getProbs(counts::Dict{T,Int})::Dict{T,Float64} where {T}
    total::Int = sum(values(counts))
    return Dict(k => counts[k] / total for k in keys(counts))
end

function getKeysVals(counts::Dict{Int,T})::Tuple{Vector{Int},Vector{T}} where {T<:Union{Int,Float64}}
    ks::Vector{Int} = sort(collect(keys(counts)))
    vs::Vector{T} = [counts[k] for k in ks]
    return (ks, vs)
end

###############################################################################
#                                   testing                                   #
###############################################################################
# theoretical distribution
twoDiceTheor = getCounts(throw2DiceTheor())

# practical distribution
nThrows = 1_000
twoDicePract = sum(rand(1:6, nThrows, 2), dims=2) |> vec |> getCounts

# barplot of counts
begin
    f, ax, b = cmk.barplot(getKeysVals(twoDiceTheor)...)
    ax.title = "Two dice throw - theoretical distribution"
    ax.xlabel = "Sum of eyes thrown"
    ax.ylabel = "# times observed"
    ax.xticks = 0:14
    f
end

# barplot of proportions
begin
    tx, ty = getKeysVals(getProbs(twoDiceTheor))
    px, py = getKeysVals(getProbs(twoDicePract))
    f2, ax2, b2 = cmk.barplot(tx .- 0.25, ty; width=0.25, label="theor dist")
    b3 = cmk.barplot!(px .+ 0.25, py; width=0.25, label="pract dist ($nThrows throws)")
    ax2.title = "Two dice throw"
    ax2.xlabel = "Sum of eyes thrown"
    ax2.ylabel = "Proportion of times observed"
    ax2.xticks = 0:14
    cmk.axislegend()
    f2
end
