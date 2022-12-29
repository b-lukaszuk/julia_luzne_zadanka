### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# ╔═╡ decb129a-87b4-11ed-1706-6f555929a470
md"""# Task 1

## Original exercise number

Exercise 7-3

## Description

The mathematician Srinivasa Ramanujan found an infinite series that can be used
to generate a numerical approximation of $1 \over \pi$:

${1 \over \pi} = {2 \sqrt 2 \over 9801} \sum^{\infty}_{k=0}{(4k)! (1103 + 26390k) \over (k!)^{4}396^{4k}}$

Write a function called `estimatepi` that uses this formula to compute and
return an estimate of $\pi$. It should use a while loop to compute terms of the
summation until the last term is smaller than `1e-15` (which is Julia notation
for $10^{−15}$). You can check the result by comparing it to $\pi$.
"""

# ╔═╡ Cell order:
# ╟─decb129a-87b4-11ed-1706-6f555929a470
