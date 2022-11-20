function rightjustify(s::String)::String
    return " " ^ (70 - length(s)) * s
end

println("Right Justifying string 'monty' so that 'y' is in column 70.")
println(rightjustify("monty"))
println("That's all. Goodbye.")
