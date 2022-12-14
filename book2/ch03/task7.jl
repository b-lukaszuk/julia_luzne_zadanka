### A Pluto.jl notebook ###
# v0.14.7

using Markdown
using InteractiveUtils

# ╔═╡ c515ec53-8794-489b-b787-c5c4d7533249
begin
    using PlutoUI: with_terminal
    using Statistics: mean
end

# ╔═╡ e64325e6-7bd2-11ed-0ef1-43c0c830c626
md"""# Task 7

## Title

Coin Flip Simulation

(Part 1, Exercise 80 from the book)

## Description

[...]

Create a program that uses Python’s random number generator to simulate flipping a coin several times. The simulated coin should be fair, meaning that the probability of heads is equal to the probability of tails. Your program should flip simulated coins until either 3 consecutive heads of 3 consecutive tails occur. Display an H each time the outcome is heads, and a T each time the outcome is tails, with all of the outcomes shown on the same line. Then display the number of flips needed to reach 3 consecutive flips with the same outcome. When your program is run it should perform the simulation 10 times and report the average number of flips needed. Sample output is shown below:

$(html"<blockquote>
H T T T (4 flips)</br>
H H T T H T H T T H H T H T T H T T T (19 flips)</br>
T T T (3 flips)</br>
T H H H (4 flips)</br>
H H H (3 flips)</br>
T H T T H T H H T T H H T H T H H H (18 flips)</br>
H T T H H H (6 flips)</br>
T H T T T (5 flips)</br>
T T H T T H T H T H H H (12 flips)</br>
T H T T T (5 flips)</br>
On average, 7.9 flips were needed.</br>
</blockquote>")
"""

# ╔═╡ 91f39242-493b-4f95-9b10-d87cf0ebd2c0
md"""## Solution
NO GUARANTEE IT WILL WORK OR WORK CORRECTLY! USE IT AT YOUR OWN RISK!
"""

# ╔═╡ 94b98f65-91e8-4d1d-ae6f-a24895119e83
# Head - 1, tail - 10, or vice-versa
function get_coin_toss()::Integer
    rand((1, 10))
end

# ╔═╡ cbfd9767-d9d0-40f3-a85b-d3212fcb85bb
function get_running_sum(coin_tosses::Vector{Integer}, lag::Integer=3)::Integer
    (length(coin_tosses) < lag) ? -99 : sum(coin_tosses[(end-(lag-1)):end])
end

# ╔═╡ f123baee-fdb3-483f-9c70-77e20ccde690
function get_tosses_until_x_repetitions_in_row(x_in_row::Integer=3)::Array{Integer,1}
    coin_tosses::Array{Integer,1} = []
    while !(get_running_sum(coin_tosses, x_in_row) in [x_in_row * 1, x_in_row * 10])
        push!(coin_tosses, get_coin_toss())
    end
    coin_tosses
end

# ╔═╡ 5493730a-74d6-4a17-b839-f1c7e8fb82ea
function print_info_about_coin_tosses(coin_tosses::Array{Integer,1})
    msg::String = join(map(digit -> digit == 1 ? "H" : "T", coin_tosses), " ")
    msg = msg * " ($(length(coin_tosses)) flips)"
    println(msg)
    nothing
end

# ╔═╡ 7690d6d3-8e34-41da-a924-0131cb617201
function run_n_simulations_print_result(n::Integer, x_repetitions_in_row::Integer)
    no_of_tosses_till_repetitions::Array{Integer,1} = zeros(n)
    trial_result::Array{Integer,1} = []
    for i in 1:n
        trial_result = get_tosses_until_x_repetitions_in_row(x_repetitions_in_row)
        print_info_about_coin_tosses(trial_result)
        no_of_tosses_till_repetitions[i] = length(trial_result)
    end
    println("On average, $(mean(no_of_tosses_till_repetitions)) flips were needed.")
    nothing
end

# ╔═╡ 81363a0d-fce3-44f0-831f-9cf70f16a5bf
with_terminal() do
    run_n_simulations_print_result(10, 3)
end

# ╔═╡ Cell order:
# ╟─e64325e6-7bd2-11ed-0ef1-43c0c830c626
# ╟─91f39242-493b-4f95-9b10-d87cf0ebd2c0
# ╠═c515ec53-8794-489b-b787-c5c4d7533249
# ╠═94b98f65-91e8-4d1d-ae6f-a24895119e83
# ╠═cbfd9767-d9d0-40f3-a85b-d3212fcb85bb
# ╠═f123baee-fdb3-483f-9c70-77e20ccde690
# ╠═5493730a-74d6-4a17-b839-f1c7e8fb82ea
# ╠═7690d6d3-8e34-41da-a924-0131cb617201
# ╠═81363a0d-fce3-44f0-831f-9cf70f16a5bf
