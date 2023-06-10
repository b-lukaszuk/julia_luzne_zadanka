function getFileContents(filePath::String, addLineNum::Bool = true)::String
    lines::Vector{String} = []
    open(filePath) do file
        for (i, line) in enumerate(eachline(file))
            push!(lines, addLineNum ? "$i: " * line : line)
        end
    end
    println("Reading from '$filePath' completed.")
    if addLineNum
        println("Adding line numbers completed.")
    end
    return join(lines, "\n")
end

function writeTextToFile(text::String, filePath::String)
    open(filePath, "w") do file
        write(file, text)
    end
    println("Writing to '$filePath' completed.")
end

function askUserShouldOverriteFile(filePath::String)::Bool
    userAnswer::String = ""
    if isfile(filePath)
        println("The file '$filePath' already exists.")
        print("Overwrite it? [Y/n (or anything else)] ")
        userAnswer = strip(readline())
        userAnswer = userAnswer == "" ? "y" : userAnswer
        return lowercase(userAnswer) == "y"
    end
    return true
end

function main()
    f2Read::String, f2Write::String = ARGS[1:2]
    f2ReadContents::String = ""
    if isfile(f2Read)
        f2ReadContents = getFileContents(f2Read)
        if askUserShouldOverriteFile(f2Write)
            writeTextToFile(f2ReadContents, f2Write)
        else
            println("Nothing to do. Quitting the program.")
        end
    else
        println("File '$f2Read' does not exist.")
        println("Nothing to do. Quitting the program.")
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
