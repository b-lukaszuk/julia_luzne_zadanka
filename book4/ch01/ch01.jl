### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# ╔═╡ b71d296c-ad3f-11ed-288f-5fa9ad07e290
md"""# Chapter 1. Probability
[Link to chapter online](https://allendowney.github.io/ThinkBayes2/chap01.html)
"""

# ╔═╡ 21f45d1d-9db3-470a-afae-5d31ef1f4c3e
md"""## Warning

The content of this file may be incorrect, erroneous and/or harmful. Use it at Your own risk."""


# ╔═╡ 0018f4d8-e909-4f5b-a7ed-ca4550a101ac
md"""## Imports"""

# ╔═╡ 5811334a-bfea-4093-9b84-febb44d0df5b
begin
	import CSV as csv
	import DataFrames as pd # pandas in Python
	import PlutoUI
end

# ╔═╡ 8d5b4a4f-35aa-435a-a68a-6ff4cefceac0
PlutoUI.TableOfContents(depth=4)

# ╔═╡ ff5217ac-43b4-45f7-86f0-606482a3fcfa
md"""## Code from chapter"""

# ╔═╡ 1ba92f60-4366-4c75-a448-bb62623e3221
md"""### Data from gss_bayes.csv
[Link to the data file online](https://raw.githubusercontent.com/AllenDowney/BiteSizeBayes/master/gss_bayes.csv)"""

# ╔═╡ 28309c7a-1c24-4864-b5f7-6fc52db55ff5
begin
	# the file can be found at
	# https://raw.githubusercontent.com/AllenDowney/BiteSizeBayes/master/gss_bayes.csv
	gss = pd.DataFrame(csv.File("./gss_bayes.csv"))
	first(gss, 5)
end

# ╔═╡ 27620472-714e-4285-b785-01541fbab503
md"""### Fraction of Bankers"""

# ╔═╡ d5eca4b4-ce1e-4847-873b-96d9564dcb39
md"""the code (indus10 column) for "banking and related activities" is 6870"""

# ╔═╡ e6c8cafe-da15-41af-94e8-2b7a034dffe5
banker = Vector{Bool}((gss[!, :indus10] .== 6870));

# ╔═╡ 928aee16-3657-44af-9c3c-d710e72bd54a
"Number of bankers in the dataset: $(sum(banker))"

# ╔═╡ ce6f3827-0f7c-4463-9c8f-d417f23c55ba
"Fraction of bankers in the dataset: $(sum(banker) / length(banker))"

# ╔═╡ 52533666-0a44-46d8-987f-d618918a6ef5
md"""### The Probability Function"""

# ╔═╡ 2c69b6bb-5748-4479-a055-ee801fc476f1
begin
	# computing probability
	function get_prob(A::Vector{<:Number})::Float64
		return sum(A) / length(A)
	end

	function get_prob(A::Vector{Bool})::Float64
		return sum(A) / length(A)
	end
end

# ╔═╡ 8ec010c2-41c4-47bb-aced-6db24b714c59
"Experimental probability of being a banker: $(get_prob(banker))"

# ╔═╡ 946b0960-3e39-4697-9718-89c422a3ba4b
md"""Coding of sex: 1 - Male, 2 - Female"""

# ╔═╡ 0544df22-e00c-46e1-942c-e085d521eda8
begin
	female = Vector{Bool}((gss[!, :sex] .== 2))
	"Experimental probability of being a banker: $(get_prob(female))"
end

# ╔═╡ 11f3e137-9f39-46fc-9d0c-01cf29d2fa6a
md"""### Political Views and Parties
Coding of `polviews`:
- Extremely liberal 1
- Liberal 2
- Slightly liberal 3
- Moderate 4
- Slightly conservative 5
- Conservative 6
- Extremely conservative 7

Coding of `partyid`:
- Strong democrat 0
- Not strong democrat 1
- Independent, near democrat 2
- Independent 3
- Independent, near republican 4
- Not strong republican 5
- Strong republican 6
- Other party 7
"""

# ╔═╡ 364da58e-819c-45dd-9ede-baa5fa667f03
begin
	liberal = Vector{Bool}((gss[!, :polviews] .<= 3))
	"Experimental probability of liberal views: $(get_prob(liberal))"
end

# ╔═╡ 6105f242-d9c6-4f9a-abdd-d2d814327c1d
begin
	democrat = Vector{Bool}((gss[!, :partyid] .<= 1))
	"Experimental probability of partyid democrat: $(get_prob(democrat))"
end

# ╔═╡ 899a5de0-bb1e-46e2-93cf-d69a10914df3
md"""### Conjunction"""

# ╔═╡ c3963f5d-da0b-4664-96d5-dbe40731dcbe
begin
	p_banker_and_democrat = get_prob(Vector{Bool}(banker .&& democrat))
	"Experimental probability of banker and democrat: $p_banker_and_democrat"
end

# ╔═╡ 18a1e2b5-8ab8-4b21-92d2-90350655409e
begin
	p_democrat_and_banker = get_prob(Vector{Bool}(democrat .&& banker))
	"Experimental probability of democrat and banker: $p_democrat_and_banker"
end

# ╔═╡ cff1ea7d-466e-4f5f-81ef-1fad38f6eef4
md"""### Conditional Probability"""

# ╔═╡ 667fa8a6-055e-43bc-ae4c-5d410fd48517
md"""What is the probability that a respondent is a democrat, given that they are liberal?"""

# ╔═╡ e459a955-3f98-449c-9d26-c0fc47324f19
function get_cond_prob(proposition::Vector{Bool}, given::Vector{Bool})::Float64
	return get_prob(proposition[given])
end

# ╔═╡ 201cc89b-366c-45ba-9e36-e0756ea2fce0
"Experimental P(democrat | liberal) = $(get_cond_prob(democrat, liberal))"

# ╔═╡ a54b8b96-63cb-443d-ba25-05beeec446a6
md"""What is the probability that a respondent is female, given that they are a banker?"""

# ╔═╡ 475de773-b242-47d5-b216-b52b58816e9f
"Experimental P(female | banker) = $(get_cond_prob(female, banker))"

# ╔═╡ 95c86f6b-d03e-4c39-becd-f7f6e2d87fe6
md"""What is the probability that a respondent is liberal, given that they are female?"""

# ╔═╡ d092f04f-1bbf-430a-a8b7-62456bd8cf13
"Experimental P(liberal | female) = $(get_cond_prob(liberal, female))"

# ╔═╡ 5236fb18-eb47-46b0-b452-588be0500c01
md"""### Conditional Probability Is Not Commutative"""

# ╔═╡ c1d111c3-8f6d-4492-bbe9-bfec47695af1
"Experimental P(female | banker) = $(get_cond_prob(female, banker))"

# ╔═╡ f03f6efe-2dcb-4334-beb1-bbac03beff66
"Experimental P(banker | female) = $(get_cond_prob(banker, female))"

# ╔═╡ 8e269d9f-1dff-4601-ad1e-9ccdd175a4e4
md"""### Condition and Conjunction"""

# ╔═╡ 8405c06b-cf28-4b5e-ae71-44999972d65d
begin
	liberal_and_democrat = Vector{Bool}(liberal .&& democrat)
	"Experimental P(female | (liberal & democrat)) = $(get_cond_prob(female, liberal_and_democrat))"
end

# ╔═╡ 4be70c9a-1172-4ec5-b84a-41d8e5aedb7d
begin
	liberal_and_female = Vector{Bool}(liberal .&& female)
	"Experimental P((liberal & female) | banker) = $(get_cond_prob(liberal_and_female, banker))"
end

# ╔═╡ dd39a65e-fecd-471c-b471-72f63bc8bb96
md"""### Laws of Probability"""

# ╔═╡ 16ddb8b5-9ee2-4798-97cc-90e008b7ac9d
md"""#### Theorem 1

$P(A|B) = \frac{P(A \ and \ B)}{P(B)}$"""

# ╔═╡ aa88711f-1f4d-4711-9bcf-48168843b3b1
get_cond_prob(female, banker)

# ╔═╡ 2556d2ec-0e42-4bd0-a4af-183885da8d51
get_prob(Vector{Bool}(female .&& banker)) / get_prob(banker)

# ╔═╡ 6bbe0418-2a8a-4161-ae51-3a8b953b27b7
md"""#### Theorem 2

$P(A \ and \ B) = P(B) \ P(A|B)$"""

# ╔═╡ 43a0ccb1-2d21-4afb-9866-956e3374a0cc
get_prob(Vector{Bool}(liberal .&& democrat))

# ╔═╡ f3b8818c-02fb-4c00-a925-1427385c9d25
get_prob(democrat) * get_cond_prob(liberal, democrat)

# ╔═╡ 627a3525-8ba8-4db9-a327-1c8ece94ea73
md"""#### Theorem 3

In math we got conjunction, i.e

$P(A \ and \ B) = P(B \ and \ A)$

If We apply Theorem 2 to both sides we have

$P(B) \ P(A|B) = P(A) \ P(B|A)$

and after solving for $P(A|B)$ we got Bayes's Theorem:

$P(A|B) = \frac{P(A)P(B|A)}{P(B)}$

"""

# ╔═╡ b1c85c96-35be-4510-8502-fdfcc7f8a65c
get_cond_prob(liberal, banker)

# ╔═╡ 4c4bb214-cd21-4ba8-a573-d163003b4746
get_prob(liberal) * get_cond_prob(banker, liberal) / get_prob(banker)

# ╔═╡ 5b5677a0-3298-4d06-9880-0194a0a245f8
md"""#### The Law of Total Probability

$P(A) = P(B_{1} \ and \ A) + P(B_{2} \ and \ A)$

This law applies only if $B_{1}$ and $B_{2}$ are:
- Mutually exclusive, which means that only one of them can be true, and
- Collectively exhaustive, which means that one of them must be true
"""

# ╔═╡ ac370ad2-076e-4df4-a99d-9b27e68de39f
get_prob(banker)

# ╔═╡ 45692fea-5687-46f2-9c33-c315d7420cb1
begin
	male = gss[!, :sex] .== 1
	get_prob(Vector{Bool}(male .&& banker)) + get_prob(Vector{Bool}(female .&& banker))
end

# ╔═╡ 7adeb709-3216-41e9-887e-19bfc7abf9d8
md"""For many (N) Bs, we got:

$P(A) = \sum \limits_{i=1}^{N} P(B_{i}) P(A|B_{i})$
"""

# ╔═╡ f13aebbe-63fc-4a17-9e14-f4bfcdb98963
begin
	B = gss[!, :polviews]
	sum(
	[get_prob(Vector{Bool}(B .== i)) *
	get_cond_prob(banker, Vector{Bool}(B .== i))
		for i in 1:7]
	)
end

# ╔═╡ 4c865165-37cb-4b46-af82-f19b8ef0f840
md"""## Exercises"""

# ╔═╡ 3f38f11b-acad-44d2-bb6b-f133ae46028e
md"""#### Exercise 1

Let’s use the tools in this chapter to solve a variation of the Linda problem.

Linda is 31 years old, single, outspoken, and very bright.
She majored in philosophy.
As a student, she was deeply concerned with issues of discrimination and social justice, and also participated in anti-nuclear demonstrations.

Which is more probable?
1. Linda is a banker.
2. Linda is a banker and considers herself a liberal Democrat.

To answer this question, compute
- The probability that Linda is a female banker,
- The probability that Linda is a liberal female banker, and
- The probability that Linda is a liberal female banker and a Democrat.
"""

# ╔═╡ 13b094c6-3712-446e-9cb6-a3b835bdaacf
get_prob(Vector{Bool}(female .&& banker))

# ╔═╡ 030134bb-7e48-4c4e-bcef-401ee70e4ccc
get_prob(Vector{Bool}(liberal .&& female .&& banker))

# ╔═╡ 3cd2cd2a-68a2-43c4-bcb6-766ecb8f5fcc
get_prob(Vector{Bool}(liberal .&& female .&& banker .&& democrat))

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
CSV = "~0.10.9"
DataFrames = "~1.5.0"
PlutoUI = "~0.7.50"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.3"
manifest_format = "2.0"
project_hash = "b9ecb36555f622903138d30d6fbb20c7ca52f1cd"

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

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "SnoopPrecompile", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "c700cce799b51c9045473de751e9319bdd1c6e94"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.9"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "9c209fb7536406834aa938fb149964b985de6c83"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.1"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "61fdd77467a5c3ad071ef8277ac6bd6af7dd4c04"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.6.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "e8119c1a33d267e16108be441a287a6981ba1630"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.14.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SnoopPrecompile", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "aa51303df86f8626a962fccb878430cdb0a97eee"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.5.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "e27c4ebe80e8699540f2d6c805cc12203b614f12"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.20"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

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

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "82aec7a3dd64f4d9584659dc0b62ef7db2ef3e19"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.2.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

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

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

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

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "6f4fbcd1ad45905a5dee3f4256fabb49aa2110c6"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.7"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "5bb5129fdd62a2bbbe17c2756932259acf467386"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.50"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "LaTeXStrings", "Markdown", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "96f6db03ab535bdb901300f88335257b0018689d"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.2"

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

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "c02bd3c9c3fc8463d3591a62a378f90d2d8ab0f3"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.17"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "a4ada03f999bd01b3a25dcaa30b2d929fe537e00"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.0"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "c79322d36826aa2f4fd8ecfa96ddb47b174ac78d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "94f38103c984f89cf77c402f2a68dbd870f8165f"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.11"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "074f993b0ca030848b897beff716d93aca60f06a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.WorkerUtilities]]
git-tree-sha1 = "cd1659ba0d57b71a464a29e64dbc67cfe83d54e7"
uuid = "76eceee3-57b5-4d4a-8e66-0e911cebbf60"
version = "1.6.1"

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
# ╟─b71d296c-ad3f-11ed-288f-5fa9ad07e290
# ╟─21f45d1d-9db3-470a-afae-5d31ef1f4c3e
# ╟─0018f4d8-e909-4f5b-a7ed-ca4550a101ac
# ╠═5811334a-bfea-4093-9b84-febb44d0df5b
# ╠═8d5b4a4f-35aa-435a-a68a-6ff4cefceac0
# ╟─ff5217ac-43b4-45f7-86f0-606482a3fcfa
# ╟─1ba92f60-4366-4c75-a448-bb62623e3221
# ╠═28309c7a-1c24-4864-b5f7-6fc52db55ff5
# ╟─27620472-714e-4285-b785-01541fbab503
# ╟─d5eca4b4-ce1e-4847-873b-96d9564dcb39
# ╠═e6c8cafe-da15-41af-94e8-2b7a034dffe5
# ╠═928aee16-3657-44af-9c3c-d710e72bd54a
# ╠═ce6f3827-0f7c-4463-9c8f-d417f23c55ba
# ╟─52533666-0a44-46d8-987f-d618918a6ef5
# ╠═2c69b6bb-5748-4479-a055-ee801fc476f1
# ╠═8ec010c2-41c4-47bb-aced-6db24b714c59
# ╟─946b0960-3e39-4697-9718-89c422a3ba4b
# ╠═0544df22-e00c-46e1-942c-e085d521eda8
# ╟─11f3e137-9f39-46fc-9d0c-01cf29d2fa6a
# ╠═364da58e-819c-45dd-9ede-baa5fa667f03
# ╠═6105f242-d9c6-4f9a-abdd-d2d814327c1d
# ╟─899a5de0-bb1e-46e2-93cf-d69a10914df3
# ╠═c3963f5d-da0b-4664-96d5-dbe40731dcbe
# ╠═18a1e2b5-8ab8-4b21-92d2-90350655409e
# ╟─cff1ea7d-466e-4f5f-81ef-1fad38f6eef4
# ╟─667fa8a6-055e-43bc-ae4c-5d410fd48517
# ╠═e459a955-3f98-449c-9d26-c0fc47324f19
# ╠═201cc89b-366c-45ba-9e36-e0756ea2fce0
# ╟─a54b8b96-63cb-443d-ba25-05beeec446a6
# ╠═475de773-b242-47d5-b216-b52b58816e9f
# ╟─95c86f6b-d03e-4c39-becd-f7f6e2d87fe6
# ╠═d092f04f-1bbf-430a-a8b7-62456bd8cf13
# ╟─5236fb18-eb47-46b0-b452-588be0500c01
# ╠═c1d111c3-8f6d-4492-bbe9-bfec47695af1
# ╠═f03f6efe-2dcb-4334-beb1-bbac03beff66
# ╟─8e269d9f-1dff-4601-ad1e-9ccdd175a4e4
# ╠═8405c06b-cf28-4b5e-ae71-44999972d65d
# ╠═4be70c9a-1172-4ec5-b84a-41d8e5aedb7d
# ╟─dd39a65e-fecd-471c-b471-72f63bc8bb96
# ╟─16ddb8b5-9ee2-4798-97cc-90e008b7ac9d
# ╠═aa88711f-1f4d-4711-9bcf-48168843b3b1
# ╠═2556d2ec-0e42-4bd0-a4af-183885da8d51
# ╟─6bbe0418-2a8a-4161-ae51-3a8b953b27b7
# ╠═43a0ccb1-2d21-4afb-9866-956e3374a0cc
# ╠═f3b8818c-02fb-4c00-a925-1427385c9d25
# ╟─627a3525-8ba8-4db9-a327-1c8ece94ea73
# ╠═b1c85c96-35be-4510-8502-fdfcc7f8a65c
# ╠═4c4bb214-cd21-4ba8-a573-d163003b4746
# ╟─5b5677a0-3298-4d06-9880-0194a0a245f8
# ╠═ac370ad2-076e-4df4-a99d-9b27e68de39f
# ╠═45692fea-5687-46f2-9c33-c315d7420cb1
# ╟─7adeb709-3216-41e9-887e-19bfc7abf9d8
# ╠═f13aebbe-63fc-4a17-9e14-f4bfcdb98963
# ╟─4c865165-37cb-4b46-af82-f19b8ef0f840
# ╟─3f38f11b-acad-44d2-bb6b-f133ae46028e
# ╠═13b094c6-3712-446e-9cb6-a3b835bdaacf
# ╠═030134bb-7e48-4c4e-bcef-401ee70e4ccc
# ╠═3cd2cd2a-68a2-43c4-bcb6-766ecb8f5fcc
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
