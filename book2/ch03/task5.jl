### A Pluto.jl notebook ###
# v0.14.7

using Markdown
using InteractiveUtils

# ╔═╡ 6124691e-679b-4e29-bed5-7b703de99db6
using PlutoUI

# ╔═╡ 5a5ba42a-7a58-11ed-1142-0baca3b15b62
md"""# Task 5

## Title

Greatest Common Divisor

(Part 1, Exercise 75 from the book)

## Description

Write a program that reads two positive integers from the user and uses this algorithm to determine and report their greatest common divisor (the largest number, `d`, which divides evenly into both `n` and `m`).

Proposed algorithm:

$(html"<blockquote>
Initialize d to the smaller of m and n.</br>
While d does not evenly divide m or d does not evenly divide n do</br>
Decrease the value of d by 1</br>
Report d as the greatest common divisor of n and m
</blockquote>")
"""

# ╔═╡ 729ab6da-8659-483c-a933-f416f91dad6b
md"""## Solution
NO GUARANTEE IT WILL WORK OR WORK CORRECTLY! USE IT AT YOUR OWN RISK!
"""

# ╔═╡ 22d1ad58-1606-4a90-be96-68ffeef4bdcd
function get_greatest_common_divisor(m::Integer, n::Integer)::Integer
	d::Integer = min(m, n)
	while (m % d != 0) || (n % d != 0)
		d -= 1
	end
	return d
end

# ╔═╡ 8e9fb90f-5150-4fe9-b032-842f170d5ede
# testing
with_terminal() do
	for (m, n) in [Tuple(rand(10:50, 2)) for _ in 1:5]
		println("-" ^ 3)
		println("Searching for greatest common divisor for $m and $n")
		println("Result $(get_greatest_common_divisor(m, n))")
	end
end
# looks fine

# ╔═╡ Cell order:
# ╟─5a5ba42a-7a58-11ed-1142-0baca3b15b62
# ╟─729ab6da-8659-483c-a933-f416f91dad6b
# ╠═6124691e-679b-4e29-bed5-7b703de99db6
# ╠═22d1ad58-1606-4a90-be96-68ffeef4bdcd
# ╠═8e9fb90f-5150-4fe9-b032-842f170d5ede
