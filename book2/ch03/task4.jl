### A Pluto.jl notebook ###
# v0.14.7

using Markdown
using InteractiveUtils

# ╔═╡ 54d499cd-c02c-4f3b-a358-a254932c7896
using PlutoUI # for with_terminal()

# ╔═╡ f6f920d4-794d-11ed-012c-f94db8c34b18
md"""# Task 4

## Title

Multiplication Table.

(Part 1, Exercise 74 from the book)

## Description

Write a program that displays multiplication table (from 1x1 till 10x10). The top row and the 1st left column are headers.
"""

# ╔═╡ 2098a35f-8c51-42ba-8853-cd0256a42e32
md"""## Solution
NO GUARANTEE IT WILL WORK OR WORK CORRECTLY! USE IT AT YOUR OWN RISK!
"""

# ╔═╡ e2fe74d2-5d3d-4e6e-8379-1e7386840dde
function get_multiplication_matrix(from_incl::Integer, to_incl::Integer)::Array{Integer, 2}
	[i*j for i in from_incl:to_incl, j in from_incl:to_incl]
end

# ╔═╡ 3145faf4-9346-4cd2-99b3-13718bf0297e
function mult_matrix_to_str_matrix(mult_matrix::Array{Integer, 2})::Array{String, 2}
	nrows, _ = size(mult_matrix) # nrows == ncols
	mult_mat = string.(mult_matrix)
	mult_mat = hcat(string.(collect(1:nrows), "|"), mult_mat)
	mult_mat = vcat("-", mult_mat)
	mult_mat = vcat(reshape(["x|"; string.(1:nrows)], (1, nrows+1)), mult_mat)
	mult_mat
end

# ╔═╡ d0243f84-0704-4d3b-8c92-bf1ae7a99909
function str_matrix_to_string(str_matrix::Array{String, 2})::String
	max_len::Integer = max([length(elt) for elt in str_matrix]...)
	nrows::Integer, ncols::Integer = size(str_matrix)
	result::String = ""
	for row in 1:nrows
		for col in 1:ncols
			result *= lpad(str_matrix[row, col], max_len + 2)
			(col == ncols) ? result *= "\n" : result *= ""
		end
	end
	result
end

# ╔═╡ 698f42bf-a6d5-45de-a6f4-6c95b6d492b1
function get_multiplication_table(from_incl::Integer, to_incl::Integer)::String
	mult_mat::Array{Integer, 2} = get_multiplication_matrix(from_incl, to_incl)
	mult_mat2::Array{String, 2} = mult_matrix_to_str_matrix(mult_mat)
	mult_mat3::String = str_matrix_to_string(mult_mat2)
	mult_mat3
end

# ╔═╡ b63f8db2-f39b-4850-9f68-224f63cbf3c0
# testing
with_terminal() do
	for i in 8:12
		println("---")
		println("printing multiplication table 1x1 to $(i)x$(i)")
		println(get_multiplication_table(1, i))
	end
end
# looks good

# ╔═╡ Cell order:
# ╟─f6f920d4-794d-11ed-012c-f94db8c34b18
# ╟─2098a35f-8c51-42ba-8853-cd0256a42e32
# ╠═54d499cd-c02c-4f3b-a358-a254932c7896
# ╠═e2fe74d2-5d3d-4e6e-8379-1e7386840dde
# ╠═3145faf4-9346-4cd2-99b3-13718bf0297e
# ╠═d0243f84-0704-4d3b-8c92-bf1ae7a99909
# ╠═698f42bf-a6d5-45de-a6f4-6c95b6d492b1
# ╠═b63f8db2-f39b-4850-9f68-224f63cbf3c0
