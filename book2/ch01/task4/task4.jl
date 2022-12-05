### A Pluto.jl notebook ###
# v0.14.7

using Markdown
using InteractiveUtils

# ╔═╡ 9c1a7af6-30b4-4d4d-b31d-bad5647ff6bc
using Plots

# ╔═╡ 1f6fa1ba-74cf-11ed-18c9-81ee9248f8e9
md"# Task 4"

# ╔═╡ 316ead2c-8cb3-4d2a-b947-196a545571dc
md"## Description"

# ╔═╡ 1178c3cd-99c5-4426-af75-1432cf92e848
md"""Create a program that determines how quickly an object is traveling when it hits the ground. The user will enter the height from which the object is dropped in meters [m]. Because the object is dropped its initial speed is 0 [$\frac{m}{s}$]. Assume that the acceleration due to gravity is 9.8 [$\frac{m}{s^2}$]. You can use the formula $vf = \sqrt{v_i^2 + 2ad}$ to compute the final speed, vf, when the initial speed, vi, acceleration, a, and distance, d, are known."""

# ╔═╡ 27234b68-a9f8-4987-bb0f-b3fe73b38c7c
md"## Solution"

# ╔═╡ a9efcb47-2a9d-4a0e-9121-753a0ef213fb
function get_vf(vi::Number, distance::Number, acceleration::Number = 9.8)::Float64
	sqrt(vi^2 + 2*acceleration*distance)
end

# ╔═╡ 469dd4fd-2686-421f-9507-d5751a034eb2
begin
initial_heights_meter::Array{Float64} = 0.6:0.2:2.5
end_speeds_meter_per_sec::Array{Float64} = get_vf.(0.0, initial_heights_meter)
end

# ╔═╡ 2c6c3065-0202-439c-bf85-3519b1484702
begin
	plot(initial_heights_meter, end_speeds_meter_per_sec)
	title!("Droping object,\ninitial height vs. speed when hitting the ground", legend=false)
	xlabel!("Initial height [m]")
	ylabel!("Speed when\nhitting the ground [m/s]")
end

# ╔═╡ Cell order:
# ╟─1f6fa1ba-74cf-11ed-18c9-81ee9248f8e9
# ╟─316ead2c-8cb3-4d2a-b947-196a545571dc
# ╟─1178c3cd-99c5-4426-af75-1432cf92e848
# ╟─27234b68-a9f8-4987-bb0f-b3fe73b38c7c
# ╠═9c1a7af6-30b4-4d4d-b31d-bad5647ff6bc
# ╠═a9efcb47-2a9d-4a0e-9121-753a0ef213fb
# ╠═469dd4fd-2686-421f-9507-d5751a034eb2
# ╠═2c6c3065-0202-439c-bf85-3519b1484702
