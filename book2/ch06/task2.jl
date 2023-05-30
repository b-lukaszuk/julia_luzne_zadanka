###############################################################################
#                               global variables                              #
###############################################################################
ints2words = Dict(
    0 => "zero",
    1 => "one",
    2 => "two",
    3 => "three",
    4 => "four",
    5 => "five",
    6 => "six",
    7 => "seven",
    8 => "eight",
    9 => "nine",
    10 => "ten",
    11 => "eleven",
    12 => "twelve",
    13 => "thirteen",
    14 => "fourteen",
    15 => "fifteen",
    16 => "sixteen",
    17 => "seventeen",
    18 => "eighteen",
    19 => "nineteen",
    20 => "twenty",
    30 => "thirty",
    40 => "forty",
    50 => "fifty",
    60 => "sixty",
    70 => "seventy",
    80 => "eighty",
    90 => "ninety",
    100 => "hundered",
)

###############################################################################
#                                  functions                                  #
###############################################################################
function translUnitsToStr(n::Int, dict::Dict{Int,String}=ints2words)::String
    @assert 0 <= n < 10 "n must to be between 0 and 9"
    return dict[n]
end

function translTeensToStr(n::Int, dict::Dict{Int,String}=ints2words)::String
    @assert 9 < n < 20 "n must to be between 10 and 19"
    return dict[n]
end

function translTensToStr(n::Int, dict::Dict{Int,String}=ints2words)::String
    @assert 19 < n < 100 "n must be between 20 and 99"
    t, u = divrem(n, 10)
    return dict[t*10] * (u == 0 ? "" : "-$(translUnitsToStr(u, dict))")
end

function translHundredsToStr(n::Int, dict::Dict{Int,String}=ints2words)::String
    @assert 99 < n < 1000 "n must to be between 100 and 999"
    h, t = divrem(n, 100)
    return dict[h] * " hundered" * (
               t == 0 ? "" :
               t < 10 ? " " * translUnitsToStr(t, dict) :
               t < 20 ? " " * translTeensToStr(t, dict) :
               " " * translTensToStr(t, dict)
           )
end

function translIntToStr(n::Int, dict::Dict{Int,String}=ints2words)::String
    return (
        n > 99 ? translHundredsToStr(n, dict) :
        19 < n < 100 ? translTensToStr(n, dict) :
        9 < n < 20 ? translTeensToStr(n, dict) :
        translUnitsToStr(n)
    )
end

###############################################################################
#                                   testing                                   #
###############################################################################
for i in 0:30
    println("$i => $(translIntToStr(i))")
end

for i in rand(1:999, 20)
    println("$i => $(translIntToStr(i))")
end
