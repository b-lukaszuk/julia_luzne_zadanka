###############################################################################
#                                   imports                                   #
###############################################################################
import Printf: @sprintf
import Random as rnd
import StatsBase as sb

###############################################################################
#                                  functions                                  #
###############################################################################
function getRandBingoCard()::Dict{String, Vector{Int}}
    bingoCard::Dict{String, Vector{Int}} = Dict()
    for (k, i) in zip(["B", "I", "N", "G", "O"], [1, 16, 31, 46, 61])
        bingoCard[k] = sb.sample(i:i+14, 5, replace=false)
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

function getDiag(bingoCard::Dict{String, Vector{Int}}, slash::Bool)::Vector{Int}
    columns::Vector{String} = collect(keys(bingoCard))
    columns = columns[slash ? (1:5) : (5:-1:1)]
    diagonal::Vector{Int} = []
    for (row, col) in enumerate(columns)
        push!(diagonal, bingoCard[col][row])
    end
    return diagonal
end

function isBingoInCols(bingoCard::Dict{String, Vector{Int}})::Bool
    for c in collect(keys(bingoCard))
        if sum(bingoCard[c]) == 0
            return true
        end
    end
    return false
end

function isBingoInRows(bingoCard::Dict{String, Vector{Int}})::Bool
    for r in 1:5
        if sum(getRow(bingoCard, r)) == 0
            return true
        end
    end
    return false
end

function isBingoInDiagonals(bingoCard::Dict{String, Vector{Int}})::Bool
    for d in [true, false]
        if sum(getDiag(bingoCard, d)) == 0
            return true
        end
    end
    return false
end

function isBingoFound(bingoCard::Dict{String, Vector{Int}})::Bool
    return (isBingoInCols(bingoCard) ||
            isBingoInRows(bingoCard) ||
            isBingoInDiagonals(bingoCard))
end

# marks a number on a bingo card (if the number is there)
function markNumberOnBingo!(bingoCard::Dict{String, Vector{Int}}, num::Int)
    @assert 0 < num < 76 "number to mark needs to be between 1 and 75"
    for k in collect(keys(bingoCard))
        for i in 1:5
            if bingoCard[k][i] == num
                bingoCard[k][i] = 0
                break # "there can be only 1" such number on the card :)
            end
        end
    end
    return nothing
end

function getTimesToHitBingo()::Int
    bc::Dict{String, Vector{Int}} = getRandBingoCard()
    numsToMark::Vector{Int} = rnd.shuffle(1:75)
    for (i, n) in enumerate(numsToMark)
        markNumberOnBingo!(bc, n)
        if isBingoFound(bc)
            return i
        end
    end
    return -99999
end

function getTimesToHitBingos(nIter::Int = 10_000)::Vector{Int}
    times::Vector{Int} = zeros(nIter)
    for i in 1:nIter
        times[i] = getTimesToHitBingo()
    end
    return times
end

###############################################################################
#                                   testing                                   #
###############################################################################
times = getTimesToHitBingos(); # may take a 1-2 sec to execute
println("Hitting bingo statistics.")
println("\tMinimum: $(minimum(times))")
println("\tAverage: $(sum(times)/length(times))")
println("\tMaximum: $(maximum(times))")
