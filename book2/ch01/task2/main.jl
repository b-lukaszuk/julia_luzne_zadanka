using Printf

function get_from_user(prompt_msg::String, input_type::Type{T})::T where T
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

function get_geogr_coordinates_from_user()::Dict{String,Integer}
    coordinates::Dict{String,Integer} = Dict()
    coordinates["latitude"] = get_geogr_coordinate_from_user(
        "\nEnter latitude (integer, -90 to 90) in degrees: ", -90, 90)
    coordinates["longitude"] = get_geogr_coordinate_from_user(
        "\nEnter longitude (integer, -180 to 180) in degrees: ", -180, 180)
    coordinates
end

function get_geogr_coordinates_of_2_points()::Array{Dict{String,Integer}}
    points::Array{Dict{String,Integer}} = []
    for i in 1:2
        print("\n--Obtaining data for point ", i, "--\n")
        push!(points, get_geogr_coordinates_from_user())
    end
    points
end

# distance = 6371.01 × arccos(sin(lat1) × sin(lat2) + cos(lat1) × cos(lat2) × cos(long1 − long2))
function get_distance(p1::Dict{String,Integer},
    p2::Dict{String,Integer})::Float64
    6371.01 * acos(
        sin(deg2rad(p1["latitude"])) * sin(deg2rad(p2["latitude"]))
        +
        cos(deg2rad(p1["latitude"])) * cos(deg2rad(p2["latitude"])) *
        cos(deg2rad(p1["longitude"]) - deg2rad(p2["longitude"])))
end

function pause_until_keypress()
    print("Press any key to begin: ")
    readline()
    println()
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
    pause_until_keypress()
    points::Array{Dict{String,Integer}} = get_geogr_coordinates_of_2_points()
    println("\nGeographical coordinates of two points obtained.")
    println("\nCalculating distance between (lat, long):")
    print("($(points[1]["latitude"]), $(points[1]["longitude"])) and ")
    println("($(points[2]["latitude"]), $(points[2]["longitude"]))")
    @printf("Result: %.2f [km]", get_distance(points...))
    println("\n\nThat's all. Goodbye!\n")
end

main()
