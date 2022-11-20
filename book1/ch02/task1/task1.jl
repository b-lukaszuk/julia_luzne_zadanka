function get_sphere_volume(radius::Number)::Float64
    return 4/3 * pi * radius^3
end

println("Volume of a sphere with radius 5 = " * string(get_sphere_volume(5)))
println("That's all. Goodbye.")
