### A Pluto.jl notebook ###
# v0.14.7

using Markdown
using InteractiveUtils

# ╔═╡ b4bfd3b4-2944-4c4c-bc09-ecc1c61e0efb
using Plots

# ╔═╡ c44cc7be-74d7-11ed-329d-c3c45c60988c
md"# Task 5"

# ╔═╡ e2ba3373-7010-474f-9bb8-b0c524f0a8c2
md"## Description"

# ╔═╡ 074444ac-e310-4d00-9c86-c3a4e9fdc99c
md"""A polygon is regular if its sides are all the same length and the angles between all of the adjacent sides are equal. The area of a regular polygon can be computed using the following formula, where `s` is the length of a side and `n` is the number of sides:
area = $\frac{n*s^2}{4*tan(\frac{\pi}{n})}$
"""

# ╔═╡ 17a8a7e6-de3d-4314-be63-b39a46d5ec17
md"## Solution"

# ╔═╡ 451b494f-7bf7-4f1a-afec-af18ce96d630
function get_reg_polygon_area(no_of_sides::Integer, side_length::Number)::Float64
	(no_of_sides*side_length^2) / (4*tan(pi/no_of_sides))
end

# ╔═╡ 45ef0fcd-080b-4672-8bb7-8728c68ce504
begin
no_of_sides::Array{Int64} = 3:1:8
reg_polyg_area::Array{Float64} = get_reg_polygon_area.(no_of_sides, 2)
end

# ╔═╡ f59ce5c6-7712-4fbf-9809-ef3ad02b5b52
function my_round(num::Float64)::Float64
	round(num, digits=2, base=10)
end

# ╔═╡ 2c5a9f9a-bab1-4152-8179-14fbe14f7d48
begin
	plot(no_of_sides, reg_polyg_area, seriestype=:scatter,
		markersize=reg_polyg_area)
	annotate!(no_of_sides .* 1.25, reg_polyg_area,
		text.(string.(my_round.(reg_polyg_area), " [\$cm^2\$]"), pointsize=8))
	ylims!((0, 25))
	xlims!((0, 12))
	title!("Number of sides (2 [cm])\nvs.\nRegular polygon area [\$cm^2\$]",
		legend=false)
	xlabel!("Number of sides, each 2 [cm]")
	ylabel!("Regular polygon area [\$cm^2\$]")
end

# ╔═╡ Cell order:
# ╟─c44cc7be-74d7-11ed-329d-c3c45c60988c
# ╟─e2ba3373-7010-474f-9bb8-b0c524f0a8c2
# ╟─074444ac-e310-4d00-9c86-c3a4e9fdc99c
# ╟─17a8a7e6-de3d-4314-be63-b39a46d5ec17
# ╠═b4bfd3b4-2944-4c4c-bc09-ecc1c61e0efb
# ╠═451b494f-7bf7-4f1a-afec-af18ce96d630
# ╠═45ef0fcd-080b-4672-8bb7-8728c68ce504
# ╠═f59ce5c6-7712-4fbf-9809-ef3ad02b5b52
# ╠═2c5a9f9a-bab1-4152-8179-14fbe14f7d48
