import Printf.@sprintf

function getFileContents(filePath::String, addLineNum::Bool = true)::String
    lines::Vector{String} = []
    open(filePath) do file
        for (i, line) in enumerate(eachline(file))
            push!(lines, addLineNum ? "$i: " * line : line)
        end
    end
    return join(lines, "\n")
end

function getCounts(v::Vector{T})::Dict{T,Int} where {T}
    result::Dict{T,Int} = Dict()
    for elt in v
        result[elt] = get(result, elt, 0) + 1
    end
    return result
end

function countCharsInStr(
    s::String,
    ignoreCase::Bool = true,
    chars2count::Vector{String} = map(string, collect('a':'z')),
)::Dict{String,Int}
    chars::Vector{String} = ignoreCase ? split(lowercase(s), "") : split(s, "")
    counts::Dict{String,Int} = getCounts(chars)
    return Dict(k => v for (k, v) in counts if k in chars2count)
end

function counts2Freqs(counts::Dict{T,Int})::Dict{T,Float64} where {T}
    total::Int = sum(values(counts))
    return Dict(k => v / total for (k, v) in counts)
end

function printFreqs(freqs::Dict{String,Float64})
    for (k, v) in freqs
        println(@sprintf("'%s' => %.3f", k, v))
    end
    return nothing
end

function main()
    f2Read::String = ARGS[1]
    fContents::String = ""
    if isfile(f2Read)
        fContents = getFileContents(f2Read)
        println("Reading contents of '$f2Read'. Done.")
        freqs::Dict{String,Float64} = countCharsInStr(fContents) |> counts2Freqs
        print("Counting frequencies of letters (case insensitive) in '$f2Read'. ")
        println("Done.\nResult:")
        printFreqs(freqs)
        println("That's all. Goodbye!")
    else
        println("File '$f2Read' does not exist.")
        println("Nothing to do. Quitting the program.")
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
