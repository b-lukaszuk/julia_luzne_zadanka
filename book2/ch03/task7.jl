### A Pluto.jl notebook ###
# v0.14.7

using Markdown
using InteractiveUtils

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

# ╔═╡ Cell order:
# ╟─e64325e6-7bd2-11ed-0ef1-43c0c830c626
