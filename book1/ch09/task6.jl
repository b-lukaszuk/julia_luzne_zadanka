### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# ╔═╡ 01906f90-8d1f-11ed-3a90-c99790f1daed
md"""# Task 6

## Original exercise number

Exercise 9-9

## Description

Here’s another Car Talk Puzzler you can solve with a search
(https://www.cartalk.com/puzzler/browse):

Recently I had a visit with my mom and we realized that the two digits that make
up my age when reversed resulted in her age. For example, if she’s 73, I’m 37.
We wondered how often this has happened over the years but we got sidetracked
with other topics and we never came up with an answer.

When I got home I figured out that the digits of our ages have been reversible
six times so far. I also figured out that if we’re lucky it would happen again
in a few years, and if we’re really lucky it would happen one more time after
that. In other words, it would have happened 8 times over all. So the question
is, how old am I now?

Write a Julia program that searches for solutions to this Puzzler.

### Tip

You might find the function `lpad` useful.
"""

# ╔═╡ 24230db1-da11-41cf-ae71-d66d4ef30db8
md"""## Solution"""

# ╔═╡ aec327c7-4bc5-4045-bb63-61129b53baec
md"""NO GUARANTEE THAT THE SOLUTION WILL WORK OR WORKS CORRECTLY! USE IT AT
YOUR OWN RISK!"""

# ╔═╡ 3c2c736d-f5bb-407c-bb8e-d5310ac46a4c
md"""### Imports"""

# ╔═╡ a18a78ae-61d6-4825-a506-adac41688bb4
import PlutoUI: with_terminal

# ╔═╡ 4db8a87e-28e5-4bb2-9438-82e7a57861fb
md"""### Assumptions
- mothers give birth when they are between:
	+ 5 years old (Lina Medina, see wiki), and
	+ 67 years old (Maria del Carmen Bousada de Lara, see wiki)
- human being lives up to 123 years (Jeanne Calment, see wiki)
- starting age of son is 0 years
- we compare mother's age and son's age once every year
"""

# ╔═╡ 9b5a13b3-11fe-4d33-998b-e1f1a65f3316
md"""### Functions"""

# ╔═╡ 6b50a54e-22b2-4a1a-925a-c7b354a84616
function rev_int(num::Int)::Int
	return parse(Int, string(num)[end:-1:1])
end

# ╔═╡ e5c5a5a8-184c-4cef-b5d6-f43b1d7a4756
function is_int1_eql_rev_int2(int1::Int, int2::Int)::Bool
	return int1 == rev_int(int2)
end

# ╔═╡ 1d9f0abc-a81d-4fed-9f12-ab643e49b6e3
function get_son_ages_eql_to_rev_mother_age(
	mother_age_at_birth::Int = 5)::Vector{Int}
	mother_ages::Vector{Int} = collect(mother_age_at_birth:123)
	son_ages::Vector{Int} = collect(0:123)
	son_ages_eql_rev_age_mother::Vector{Int} = []
	for i in eachindex(mother_ages)
		if is_int1_eql_rev_int2(mother_ages[i], son_ages[i])
			push!(son_ages_eql_rev_age_mother, son_ages[i])
		end
	end
	return son_ages_eql_rev_age_mother
end

# ╔═╡ 2dde8c3c-5a21-427c-9549-d55b99c2b3ff
# key - mother's age, when she gave birth, values son ages (rev mother age)
function get_mother_ages_overlap_son_ages(
	mother_age_birth_start::Int=5,
	mother_age_birth_stop::Int=67,
starting_son_age_0::Bool = true)::Dict{Int, Vector{Int}}
	overlaps::Dict{Int, Vector{Int}} = Dict()
	for i in mother_age_birth_start:mother_age_birth_stop
		tmp = get_son_ages_eql_to_rev_mother_age(i)
		if length(tmp) > 0
			overlaps[i] = tmp
		end
	end
	return overlaps
end

# ╔═╡ 768a5518-061f-4bd6-8771-2dadfa8cda40
md"""## Possible solution"""

# ╔═╡ f83d64dc-b92e-4e24-be90-a7c6e14a0690
with_terminal() do
	mother_ages::Dict{Int, Vector{Int}} = get_mother_ages_overlap_son_ages(5, 67)
	println("Given the assumptions declared above.")
	for (k, v) in mother_ages
		if length(v) > 6
			println("-" ^ 3)
			println("For a mother giving birth when she is: $k years old")
			println("Her age will be equal to the reverse age of her son")
			println("$(length(v)) times, i.e. $v")
		end
	end
end

# ╔═╡ 35aed4d9-a191-4474-87d1-5f4c9b863683
md"""Most likely (for decency reasons) the guy's mother gave birth to him when
she was 18 years old, and he is now 68 years old (and she is 86 years old).

Naturally, probably my assumptions did not hold, that is why I got the result.
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoUI = "~0.7.49"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.3"
manifest_format = "2.0"
project_hash = "08cc58b1fbde73292d848136b97991797e6c5429"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "6466e524967496866901a78fca3f2e9ea445a559"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eadad7b14cf046de6eb41f13c9275e5aa2711ab6"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.49"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "ac00576f90d8a259f2c9d823e91d1de3fd44d348"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─01906f90-8d1f-11ed-3a90-c99790f1daed
# ╟─24230db1-da11-41cf-ae71-d66d4ef30db8
# ╟─aec327c7-4bc5-4045-bb63-61129b53baec
# ╟─3c2c736d-f5bb-407c-bb8e-d5310ac46a4c
# ╠═a18a78ae-61d6-4825-a506-adac41688bb4
# ╟─4db8a87e-28e5-4bb2-9438-82e7a57861fb
# ╟─9b5a13b3-11fe-4d33-998b-e1f1a65f3316
# ╠═6b50a54e-22b2-4a1a-925a-c7b354a84616
# ╠═e5c5a5a8-184c-4cef-b5d6-f43b1d7a4756
# ╠═1d9f0abc-a81d-4fed-9f12-ab643e49b6e3
# ╠═2dde8c3c-5a21-427c-9549-d55b99c2b3ff
# ╟─768a5518-061f-4bd6-8771-2dadfa8cda40
# ╠═f83d64dc-b92e-4e24-be90-a7c6e14a0690
# ╟─35aed4d9-a191-4474-87d1-5f4c9b863683
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
