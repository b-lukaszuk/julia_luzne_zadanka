### A Pluto.jl notebook ###
# v0.14.7

using Markdown
using InteractiveUtils

# ╔═╡ e163eaf0-f06f-4dad-bd2f-0771a9e349b2
using Printf

# ╔═╡ 7a948dee-73f8-11ed-21af-7b437918e3d2
md"# Task 3"

# ╔═╡ 7e880bc4-b604-4a44-b4a0-99b332a1e73e
md"""Written in Julia and Pluto.jl

**NO GUARANTEE THE PROGRAM WORKS CORRECTLY.** Use it at Your own risk."""

# ╔═╡ 6c87ae80-6bb0-4ad9-b479-5cf33efa00ff
md"""## Description
Write a program that begins by reading a number of cents from the user as an integer. Then your program should compute and display the denominations of the coins that should be used to give that amount of change to the shopper. The change should be given using as few coins as possible. Assume that the machine is loaded with pennies, nickels, dimes, quarters, loonies and toonies.
"""

# ╔═╡ c75d7ebd-12f2-43c0-8248-d7ea68e62772
md"""## My Notes

List of coins and their values:
+ penny - 1/100th of a dollar, a cent
+ nickel - five centes
+ dime - ten cents
+ quarter - 25 cents
+ loonie - 1 dollar coin in Canada (hint from the book)
+ toonie - 2 dollar coin in Canada (hint from the book)
"""

# ╔═╡ 37278acd-d2c3-49b1-9df1-c3ecc882f222
md"## Solution"

# ╔═╡ 2c819b49-3b67-4999-9ccd-fa14501d3afa
function my_math_floor(num::Float64)::Int64
	Int(parse(Float64, @sprintf("%0.f", num)))
end

# ╔═╡ 7da93653-583d-41ba-b863-2be754b2b803
available_coins::Array{Int} = [200, 100, 25, 10, 5, 1]

# ╔═╡ f4a1845e-0a96-4adc-a4e6-0cb606703474
function can_amount_be_subtracted_from_total(amount::Int, total::Int)::Bool
	return (total - amount) >= 0
end

# ╔═╡ c6abd44b-19fa-4a10-94be-0a956b0e903e
function get_change(sum_to_change::Int, available_coins::Array{Int}=available_coins)::Dict{Int, Int}
	change::Dict{Int, Int} = Dict()
	for coin in available_coins
		while can_amount_be_subtracted_from_total(coin, sum_to_change)
			sum_to_change = sum_to_change - coin
			if (haskey(change, coin))
				change[coin] = change[coin] + 1
			else
				change[coin] = 1
			end
		end
	end
	change
end

# ╔═╡ ddd48dca-6c38-48de-8bd5-eb8fff3cb90c
function get_change_money_info(dollars::Float64)::String
	result::String = "To change \$$dollars you should use:\n"
	coins_value_name::Dict{Int, String} = Dict(200 => "toonie", 100 => "loonie", 25 => "quarter", 10 => "dime", 5 => "nickel", 1 => "penny")
	change::Dict{Int, Int} = get_change(my_math_floor(dollars*100), available_coins)
	for k in keys(change)
		result = result * "$(change[k]) x $(coins_value_name[k])\n"
	end
	return result
end

# ╔═╡ 1f5fb186-6e42-409c-ac0d-5124901d433d
Text(get_change_money_info(1.13))

# ╔═╡ 31e0918b-44c4-4f5b-82eb-88a02b2a470b
Text(get_change_money_info(3.33))

# ╔═╡ 69ee0528-f0ff-43aa-b778-2e59de86963d
Text(get_change_money_info(4.77))

# ╔═╡ Cell order:
# ╟─7a948dee-73f8-11ed-21af-7b437918e3d2
# ╟─7e880bc4-b604-4a44-b4a0-99b332a1e73e
# ╟─6c87ae80-6bb0-4ad9-b479-5cf33efa00ff
# ╟─c75d7ebd-12f2-43c0-8248-d7ea68e62772
# ╟─37278acd-d2c3-49b1-9df1-c3ecc882f222
# ╠═e163eaf0-f06f-4dad-bd2f-0771a9e349b2
# ╠═2c819b49-3b67-4999-9ccd-fa14501d3afa
# ╠═7da93653-583d-41ba-b863-2be754b2b803
# ╠═f4a1845e-0a96-4adc-a4e6-0cb606703474
# ╠═c6abd44b-19fa-4a10-94be-0a956b0e903e
# ╠═ddd48dca-6c38-48de-8bd5-eb8fff3cb90c
# ╠═1f5fb186-6e42-409c-ac0d-5124901d433d
# ╠═31e0918b-44c4-4f5b-82eb-88a02b2a470b
# ╠═69ee0528-f0ff-43aa-b778-2e59de86963d
