### A Pluto.jl notebook ###
# v0.14.7

using Markdown
using InteractiveUtils

# ╔═╡ cffb85d9-1179-4762-98a2-94b4b2a6defd
using PlutoUI

# ╔═╡ 158e4ad0-7b04-11ed-3918-2faea89ddff7
md"""# Task 6

## Title

Binary to Decimal

(Part 1, Exercise 77 from the book)

## Description

Write a program that converts a binary (base 2) number to decimal (base 10).
"""

# ╔═╡ 8716c9a2-a897-4b76-9c6a-2dc01def804d
md"""## Solution
NO GUARANTEE IT WILL WORK OR WORK CORRECTLY! USE IT AT YOUR OWN RISK!
"""

# ╔═╡ 5935469b-cb15-4de7-a3dc-2b3892ce6b3b
function contains_only_1_or_0(maybe_binary::String)::Bool
	length(filter(x -> !(x == '0' || x == '1'), maybe_binary)) == 0
end

# ╔═╡ 9b0fdde8-243e-4681-80e6-367ab966d3ba
function binary_2_decimal(binary::String)::Integer
	if !contains_only_1_or_0(binary)
		throw(ArgumentError("binary can conatin only 1s and 0s"))
	end
    decimal::Integer = 0
    rev_binary::String = binary[end:-1:1]
    for i in eachindex(rev_binary)
        decimal += (rev_binary[i] == '1') ? 2^(i-1) : 0
    end
    decimal
end

# ╔═╡ 3279f9fc-1677-46fd-af43-718c0d740a87
function get_random_binary(binary_length::Integer = 6)
	join(rand(("0", "1"), binary_length), "")
end

# ╔═╡ 6b617524-8395-444b-8cd1-4a2f3a301df5
binaries_examples::Array{String} = [get_random_binary() for _ in 1:5]

# ╔═╡ f1fc75cb-c740-4466-abb4-d82a83c7d174
with_terminal() do
	for tested_binary in binaries_examples
		println("-" ^ 3)
		println("Converting binary to decimal my function.")
		println("$tested_binary => $(binary_2_decimal(tested_binary))")
		println("Converting binary to decimal build-in function.")
		println("$tested_binary => $(parse(Int, tested_binary; base=2))")
	end
end

# ╔═╡ Cell order:
# ╟─158e4ad0-7b04-11ed-3918-2faea89ddff7
# ╟─8716c9a2-a897-4b76-9c6a-2dc01def804d
# ╠═cffb85d9-1179-4762-98a2-94b4b2a6defd
# ╠═5935469b-cb15-4de7-a3dc-2b3892ce6b3b
# ╠═9b0fdde8-243e-4681-80e6-367ab966d3ba
# ╠═3279f9fc-1677-46fd-af43-718c0d740a87
# ╠═6b617524-8395-444b-8cd1-4a2f3a301df5
# ╠═f1fc75cb-c740-4466-abb4-d82a83c7d174
