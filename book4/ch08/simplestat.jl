module SimpleStatistics

function prob2odds(prob::T)::T where T<:Union{Float64, Rational}
    @assert (0 <= prob <= 1)
    return prob / (1-prob)
end

function prob2odds(prob::T)::T where T<:Union{Float64, Rational}
    @assert (0 <= prob <= 1)
    return prob / (1-prob)
end

function prob2odds(prob::T)::T where T<:Union{Float64, Rational}
    @assert (0 <= prob <= 1)
    return prob / (1-prob)
end

function odds2prob(yes::T, no::T)::T where T<:Union{Float64, Rational}
    @assert yes >= 0
    @assert no > 0
    return yes / (yes+no)
end

function odds2prob(yes::T, no::T)::T where T<:Union{Float64, Rational}
    @assert yes >= 0
    @assert no > 0
    return yes / (yes+no)
end

function isRoughlyEqual(n1::Number, n2::Number, precision::Int=15)::Bool
    @assert 0 <= precision <= 16
    return round(n1, digits=precision) == round(n2, digits=precision)
end

function getAvg(xs::Vector{Number})::Float64
    return sum(xs) / length(xs)
end

end
