###############################################################################
#                                   imports                                   #
###############################################################################
import StatsBase as sb
import Printf: @sprintf

###############################################################################
#                                  functions                                  #
###############################################################################
function getRandBingoCard()::Dict{String, Vector{Int}}
    bingoCard::Dict{String, Vector{Int}} = Dict()
    for (k, i) in zip(["B", "I", "N", "G", "O"], [1, 16, 31, 46, 61])
        bingoCard[k] = sb.sample(i:i+14, 5)
    end
    bingoCard["N"][3] = 0
    return bingoCard
end

function getRow(bingoCard::Dict{String, Vector{Int}}, rowInd::Int)::Vector{Int}
    @assert 0 < rowInd < 6
    result::Vector{Int} = []
    for k in keys(bingoCard)
        push!(result, bingoCard[k][rowInd])
    end
    return result
end

function getformattedRow(row::Vector{Int})::String
    result::Vector{String} = map(x -> @sprintf(" %2d ", x), row)
    return "|$(join(result, "|"))|"
end

function getFormattedBingoCard(bingoCard::Dict{String, Vector{Int}})::String
    rows::Vector{String} = []
    rowSep::String = ""
    for i in 1:5
        push!(rows, getRow(bingoCard, i) |> getformattedRow)
    end
    rowSep = "\n" * "-" ^ length(rows[1]) * "\n"
    return rowSep * join(rows, rowSep) * rowSep
end

###############################################################################
#                                   testing                                   #
###############################################################################
for _ in 1:3
    getRandBingoCard() |> getFormattedBingoCard |> println
end
