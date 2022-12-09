### A Pluto.jl notebook ###
# v0.14.7

using Markdown
using InteractiveUtils

# ╔═╡ 1b21c462-5038-41a3-a9dc-9e9ca438a730
using PlutoUI # to print in Browser with println (see with_terminal() below)

# ╔═╡ 5f282336-780d-11ed-2732-39f113931d9a
md"""# Task 1

## Title

Parity Bits

(Part 1, Exercise 68 from the book)

## Description

Write a program that computes the [parity bit](https://en.wikipedia.org/wiki/Parity_bit) for groups of 8 bits [...] using even parity. Blank line ends input entry phase.

So a parity bit is calculated for every 7 bits.
"""

# ╔═╡ d3cdbbbd-f531-4e2e-84ef-3fd0aa923db8
md"""## Solution
NO GUARANTEE IT WILL WORK OR WORK CORRECTLY! USE IT AT YOUR OWN RISK!
"""

# ╔═╡ 5cf5b829-f861-48ad-b217-f6e99e8ea720
function get_counts(seven_bits::String)::Dict{Char, Int64}
	counts::Dict{Char, Int64} = Dict('0' => 0, '1' => 0)
	for one_bit in seven_bits
		if haskey(counts, one_bit)
			counts[one_bit] += 1
		end
	end
	counts
end

# ╔═╡ 39f9f07f-7ebb-439e-a851-17f0464eb34e
function get_parity_bit(seven_bits::String)::Char
	result::Dict{Char, Int64} = get_counts(seven_bits)
	if (result['0'] + result['1'] != 7)
		throw(ArgumentError("seven_bits must contain 7 chars 0s or 1s"))
	end
	(result['1'] % 2 == 1) ? '1' : '0'
end

# ╔═╡ a1fa790f-9080-42fe-a1bb-b70572e62625
function get_rand_7_bits()::String
	string(rand("01", 7)...)
end

# ╔═╡ 745ac91c-15ef-47c7-a3e8-9e813d8d266f
# testing
with_terminal() do
	for seven_bits in [get_rand_7_bits() for _ in 1:5]
		println(repeat("-", 5))
		println("seven bits: $seven_bits")
		println("parity bit: $(get_parity_bit(seven_bits))")
	end
end

# ╔═╡ Cell order:
# ╟─5f282336-780d-11ed-2732-39f113931d9a
# ╟─d3cdbbbd-f531-4e2e-84ef-3fd0aa923db8
# ╠═1b21c462-5038-41a3-a9dc-9e9ca438a730
# ╠═5cf5b829-f861-48ad-b217-f6e99e8ea720
# ╠═39f9f07f-7ebb-439e-a851-17f0464eb34e
# ╠═a1fa790f-9080-42fe-a1bb-b70572e62625
# ╠═745ac91c-15ef-47c7-a3e8-9e813d8d266f
