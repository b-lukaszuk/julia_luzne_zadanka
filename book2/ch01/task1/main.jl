function get_integer_from_user(number_designation::String="a")::Integer
    int_from_user::Integer = 0
    while true
        print("\nEnter number " * number_designation * " (integer): ")
        try
            int_from_user = parse(Int64, readline())
            break
        catch err
            if isa(err, ArgumentError)
                println("That was not an integer. Try again.")
            end
        end
    end
    int_from_user
end

function print_program_description()::Nothing
    println("\nHi.\n")
    println("This is a program that reads two integers, a and b, from the user.")
    println("Next it will perform a number of mathematical operations on them.")
    println("The results of the operations will be printed to the screen.")
    println("NO GUARANTEE OF THE PROGRAM ACCURACY. Still, I hope it'll work fine.")
    println("All clear. Then let's begin.\n")
end

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

    print_program_description()
    int_a::Integer = get_integer_from_user()
    int_b::Integer = get_integer_from_user("b")
    for customFn in customFunctions
        println("\nDescription: $(customFn["description"])")
        println("fn($(int_a), $(int_b)) = $(customFn["fn"](int_a, int_b))")
    end
    println("\nThat's all. Goodbye!\n")
end

main()