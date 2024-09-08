struct Sphere
    radius::Float64
end

function getVolume(s::Sphere)::Float64
    return (4/3) * pi * s.radius^3
end

function getArea(s::Sphere)::Float64
    return 4 * pi * s.radius^2
end

function getSphere(volume::Float64)::Sphere
    radius::Float64 = cbrt(volume / pi / (4/3))
    return Sphere(radius)
end

# bile
bigS = Sphere(10)
bigV = getVolume(bigS)
bigA = getArea(bigS)

smallS = getSphere(bigV / 10)
smallV = getVolume(smallS)
smallA = getArea(smallS)
smallA * 10
