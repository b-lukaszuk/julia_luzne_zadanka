### A Pluto.jl notebook ###
# v0.14.7

using Markdown
using InteractiveUtils

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

# ╔═╡ Cell order:
# ╟─605d94a6-7723-11ed-1b6a-b19f8db19c16
