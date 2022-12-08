### A Pluto.jl notebook ###
# v0.14.7

using Markdown
using InteractiveUtils

# ╔═╡ fef0259f-3851-45c2-b530-ffe8837e1c78
using PlutoUI

# ╔═╡ 605d94a6-7723-11ed-1b6a-b19f8db19c16
md"""# Task 4

## Title

Roulette Payouts

(Part 1, Exercise 60 from the book)

## Description

A roulette wheel has 38 spaces on it. Of these spaces, 18 are black, 18 are red, and two are green. The green spaces are numbered 0 and 00. The red spaces are numbered 1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34 and 36. The remaining integers between 1 and 36 are used to number the black spaces.

[...] consider the following subset of them in this exercise:
   + Single number (1 to 36, 0, or 00)
   + Red versus Black
   + Odd versus Even (Note that 0 and 00 do not pay out for even)
   + 1 to 18 versus 19 to 36

Write a program that simulates a spin of a roulette wheel by using Python’s random number generator. Display the number that was selected and all of the bets that must be payed, e.g.

<pre>
The spin resulted in 13...
Pay 13
Pay Black
Pay Odd
Pay 1 to 18
</pre>

or

<pre>
The spin resulted in 0...
Pay 0
</pre>

or

<pre>
The spin resulted in 00...
Pay 00
</pre>
"""

# ╔═╡ 04067ce1-3200-4bc8-b7c8-716e71be6f4c
md"""## Solution
NO GUARANTEE IT WILL WORK OR WORK CORRECTLY! USE IT AT YOUR OWN RISK!
"""

# ╔═╡ addad8c5-ab7b-4968-9a52-403d81e3c113
# result: -1:36, where -1 is 00
function spin_roulette()::Int64
	rand(-1:36)
end

# ╔═╡ 0d79fad1-6367-4f38-a9d7-7675fcec2f1e
function spin2string(spin::Int64)::String
	(spin < 0) ? "00" : string(spin)
end

# ╔═╡ 914ea9cb-6dd4-4e81-be4f-80d7fb808e59
function is_red(spin::Int64)::Bool
	spin in [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36]
end

# ╔═╡ c5aac29e-5606-46f2-b8f5-373c78860cc9
function get_spin_and_pays_msgs(spin::Int64)::String
	spin_str::String = spin2string(spin)
	msg::String = "The pay resulted in $spin_str...\n"
	msg *= "Pay $spin_str\n"
	if (spin <= 0)
		return msg
	end
	is_red(spin) ? msg *= "Pay Red\n" : msg *= "Pay Black\n"
	(spin % 2 == 0) ? msg *= "Pay Even\n" : msg *= "Pay Odd\n"
	(spin <= 18) ? msg *= "Pay 1-18\n" : msg *= "Pay 19-36\n"
	return msg
end

# ╔═╡ a5482c3a-bf65-4baa-a458-7c7def6a9d27
with_terminal() do
	println(get_spin_and_pays_msgs(spin_roulette()))
end

# ╔═╡ Cell order:
# ╟─605d94a6-7723-11ed-1b6a-b19f8db19c16
# ╟─04067ce1-3200-4bc8-b7c8-716e71be6f4c
# ╠═fef0259f-3851-45c2-b530-ffe8837e1c78
# ╠═addad8c5-ab7b-4968-9a52-403d81e3c113
# ╠═0d79fad1-6367-4f38-a9d7-7675fcec2f1e
# ╠═914ea9cb-6dd4-4e81-be4f-80d7fb808e59
# ╠═c5aac29e-5606-46f2-b8f5-373c78860cc9
# ╠═a5482c3a-bf65-4baa-a458-7c7def6a9d27
