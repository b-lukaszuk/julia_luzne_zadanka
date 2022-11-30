function get_from_user(prompt_msg::String, input_type::DataType)
    while true
        try
            print(prompt_msg)
            user_input::String = readline()
            if input_type == String
                return user_input
            else
                return parse(input_type, user_input)
            end
        catch err
            if isa(err, ArgumentError)
                println("The input is not of type ", input_type, ". Try again.")
            end
        end
    end
end

function get_geogr_coordinate_from_user(prompt_msg::String,
    minIncl::Int64, maxIncl::Int64)::Int64
    coordinate::Int64 = -999
    while true
        coordinate = get_from_user(prompt_msg, Int64)
        if (minIncl <= coordinate <= maxIncl)
            break
        end
        println("The number is out of range. Try again.")
    end
    coordinate
end

function get_geogr_coordinates_from_user()::Tuple{Integer,Integer}
    (
        get_geogr_coordinate_from_user("\nEnter latitude (integer, -90 to 90) in degrees: ", -90, 90),
        get_geogr_coordinate_from_user("\nEnter longitude (integer, -180 to 180) in degrees: ", -180, 180)
    )
end

function get_geogr_coordinates_of_2_points()::Array{Tuple{Integer,Integer}}
    points::Array{Tuple{Integer,Integer}} = []
    for i in 1:2
        print("\n--Obtaining data for point ", i, "--\n")
        push!(points, get_geogr_coordinates_from_user())
    end
    points
end

function print_program_description()::Nothing
    println("\nHi.\n")
    println("This program reads the geographical coordinates of two points.")
    println("The points are located on the earth's surface.")
    println("Next it calculates the distance between the points.")
    println("The results of the operation will be printed to the terminal.")
    println("NO GUARANTEE THE PROGRAM WORKS CORRECTLY.")
    println("Still, I hope it'll work fine.")
    print("All clear. Then let's begin.\n")

end

function main()
    print_program_description()
    points::Array{Tuple{Integer,Integer}} = get_geogr_coordinates_of_2_points()
    println("You typed $points[1] and $points[2]")
    println("\nThat's all. Goodbye!\n")
end

main()