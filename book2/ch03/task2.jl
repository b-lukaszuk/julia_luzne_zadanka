### A Pluto.jl notebook ###
# v0.14.7

using Markdown
using InteractiveUtils

# ╔═╡ 6d657263-39df-49bd-8ece-da50016cb532
using PlutoUI # to print in Browser with println (see with_terminal() below)

# ╔═╡ 7400988e-7811-11ed-17e7-d3f4a0c34c65
md"""# Task 2

## Title

Square Root

(Part 1, Exercise 71 from the book)

## Description

Write a program that implements Newton’s method to compute and display the square root of a number entered by the user.

$(html"<blockquote>
Read x from the user</br>
Initialize guess to x/2</br>
While guess is not good enough do</br>
Update guess to be the average of guess and x/guess
</blockquote>")

[...] good enough when the absolute value of the difference between `guess` ∗ `guess` and `x` was less than or equal to 10^(-12).
"""

# ╔═╡ a521ad34-6c79-42e6-bf15-aaf19d50ec41
md"""## Solution
NO GUARANTEE IT WILL WORK OR WORK CORRECTLY! USE IT AT YOUR OWN RISK!
"""

# ╔═╡ ca8002f7-4899-4397-ad6d-0dae20ec405a
function is_guess_good_enough(guess::Number, x::Number)::Bool
	abs(guess * guess - x) < 10e-12
end

# ╔═╡ a30dd5e9-3ea8-4d6f-aa90-d52fa580a81b
function my_sqrt(x::Number)::Number
	guess::Number = x/2
	while !is_guess_good_enough(guess, x)
		guess = (guess + x/guess) / 2
	end
	guess
end

# ╔═╡ 5d9502ab-3510-47b7-babb-dfe786d554d7
# testing
with_terminal() do
	for tested_num in rand(2:81, 5)
		println(repeat("-", 5))
		println("number: $tested_num")
		println("my_sqrt: $(my_sqrt(tested_num))")
		println("build-in sqrt: $(sqrt(tested_num))")
	end
end

# ╔═╡ Cell order:
# ╟─7400988e-7811-11ed-17e7-d3f4a0c34c65
# ╟─a521ad34-6c79-42e6-bf15-aaf19d50ec41
# ╠═6d657263-39df-49bd-8ece-da50016cb532
# ╠═ca8002f7-4899-4397-ad6d-0dae20ec405a
# ╠═a30dd5e9-3ea8-4d6f-aa90-d52fa580a81b
# ╠═5d9502ab-3510-47b7-babb-dfe786d554d7
