### A Pluto.jl notebook ###
# v0.14.7

using Markdown
using InteractiveUtils

# ╔═╡ d94466ab-880e-4e48-bf9e-408006e758af
using PlutoUI # to print in Browser with println (see with_terminal() below)

# ╔═╡ ce98cb4a-764a-11ed-0991-8341f8e1fb66
md"""# Task 3

## Title

Chinese Zodiac

(Part 1, Exercise 48 from the book)

## Description

The Chinese zodiac assigns animals to years in a 12 year cycle, e.g.

Year: Animal
* 2000: Dragon
* 2001: Snake
* 2002: Horse
* 2003: Sheep
* 2004: Monkey
* 2005: Rooster
* 2006: Dog
* 2007: Pig
* 2008: Rat
* 2009: Ox
* 2010: Tiger
* 2011: Hare

Write a program that reads a year from the user and displays the animal associated with that year. Your program should work correctly for any year greater than or equal to zero, not just the ones listed in the table.

## My notes

A year 0 does not exist [see: wikipedia](https://en.wikipedia.org/wiki/Year_zero) so instead the lower limit will be year 1.
"""

# ╔═╡ e558dbd8-5634-448b-9b4e-b9e7921cbeaa
md"""## Solution
NO GUARANTEE IT WILL WORK OR WORK CORRECTLY! USE IT AT YOUR OWN RISK!
"""

# ╔═╡ 9f094006-55c1-445b-99d5-ddaa942a1fbc
function get_chinese_zodiac_sign(year::Integer)::String
	if year < 1
		throw(ArgumentError("Year must be >= 1"))
	end
	signs_2000_2011::Array{String} = ["Dragon", "Snake", "Horse", "Sheep",
		"Monkey", "Rooster", "Dog", "Pig", "Rat", "Ox", "Tiger", "Hare"]
	# 2000 % 12 = 8, so 12 - 8 = 5
	signs_ordered::Array{String} = signs_2000_2011[[5:end; 1:4]]
	signs_ordered[(year % 12) + 1] # indexed from 1:end, incl-incl
end

# ╔═╡ 4dc089ef-4866-4afd-95e4-36b0d9bb97b4
with_terminal() do
	for i in 1997:2023
		println("year $i, sign: $(get_chinese_zodiac_sign(i))")
	end
end

# ╔═╡ 3cd8cfe5-65bb-4d99-9720-623a0f6a56d7
with_terminal() do
	for i in 1:20
		println("year $i, sign: $(get_chinese_zodiac_sign(i))")
	end
end

# ╔═╡ Cell order:
# ╟─ce98cb4a-764a-11ed-0991-8341f8e1fb66
# ╟─e558dbd8-5634-448b-9b4e-b9e7921cbeaa
# ╠═d94466ab-880e-4e48-bf9e-408006e758af
# ╠═9f094006-55c1-445b-99d5-ddaa942a1fbc
# ╠═4dc089ef-4866-4afd-95e4-36b0d9bb97b4
# ╠═3cd8cfe5-65bb-4d99-9720-623a0f6a56d7
