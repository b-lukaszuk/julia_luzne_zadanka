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

# marks random field (may mark previously marked field)
function markRandField!(bingoCard::Dict{String, Vector{Int}})
    letter::String = rand(collect(keys(bingoCard)))
    ind::Int = rand(1:5)
    bingoCard[letter][ind] = 0
    return nothing
end

function verboseSearchForBingoNTimes(n::Int)
    @assert 0 < n < 100
    bc::Dict{String, Vector{Int}} = getRandBingoCard()

    println("Initial bingo card:")
    println(getFormattedBingoCard(bc))

    for i in 1:n
        println("$i: marking random number on bingo card.")
        markRandField!(bc)
        if isBingoFound(bc)
            println("\nBingo found.")
            println(getFormattedBingoCard(bc))
            return nothing
        end
    end
    println("\nBingo not found.")
    println(getFormattedBingoCard(bc))

    return nothing
end

###############################################################################
#                                   testing                                   #
###############################################################################
verboseSearchForBingoNTimes(25)
