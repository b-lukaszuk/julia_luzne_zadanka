function main()
    customFunctions = [
        Dict("description" => "adds a and b",
            "fn" => (a, b) -> a + b),
        Dict("description" => "subtracts b from a",
            "fn" => (a, b) -> a - b),
        Dict("description" => "multiplies a times b",
            "fn" => (a, b) -> a * b),
        Dict("description" => "divides a by b",
            "fn" => (a, b) -> a / b),
        Dict("description" => "returns log10 of a",
            "fn" => (a, b) -> log10(a)),
        Dict("description" => "raises a to the power of b",
            "fn" => (a, b) -> a^b),
    ]

    println("-"^30)
    println("Task1.")
    println("Custom function examples.")
    for customFn in customFunctions
        println("\nDescription: $(customFn["description"])")
        println("fn(20, 3) = $(customFn["fn"](20, 3))}")
    end
    println("\nThat's all. Goodbye!")
    println("-"^30)
end

main()