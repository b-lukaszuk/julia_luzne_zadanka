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

end
