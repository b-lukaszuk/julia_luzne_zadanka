### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# ╔═╡ b71d296c-ad3f-11ed-288f-5fa9ad07e290
md"""# Chapter 2. Bayes's Theorem
[Link to chapter online](https://allendowney.github.io/ThinkBayes2/chap02.html)
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

# ╔═╡ 2b5752ce-a4b3-4d74-ae8f-eb6ed1df501b
md"""### The Cookie Problem
We’ll start with a thinly disguised version of an [urn problem](https://en.wikipedia.org/wiki/Urn_problem):

Suppose there are two bowls of cookies.
- Bowl 1 contains 30 vanilla cookies and 10 chocolate cookies.
- Bowl 2 contains 20 vanilla cookies and 20 chocolate cookies.

Now suppose you choose one of the bowls at random and, without looking, choose a cookie at random. If the cookie is vanilla, what is the probability that it came from Bowl 1?
"""

# ╔═╡ 94210b00-f8cf-4085-a033-370fd39b8519
md"""Ok, for practice I will solve it on my own (no peeking).

$P(A) P(B|A) = P(B) P(A|B)$

I will make:
- V -  vanilla cookie
- B1 - Bowl 1
and replace with it A and B from the equation above

So now we have:

$P(V) P(B_{1}|V) = P(B_{1}) P(V|B_{1})$

no I divide both sides by P(V)

$P(B_{1}|V) = \frac{P(B_{1}) P(V|B_{1})}{P(V)}$

From the task I got:
- P(B1) = 1 of 2, so 1/2, or 0.5
- P(V|B1) = 30 of 40, so 30/40, or 3/4, or 0.75
- P(V) = (30 + 20) of (40 + 40), so 50/80, or 5/8, or 0.625

$P(B_{1}|V) = \frac{0.5*0.75}{0.625}$

$P(B_{1}|V) = 0.6$
"""

# ╔═╡ 98719a21-7fed-4df0-afc9-24edbffa7bba
md"""### Diachronic Bayes

Diachronic (related to change over time).

We gonna update the probability of a hypothesis, H, given some body of data, D.

Rewriting bayes's theorem with H (hypothesis) and D (data) yields:

$P(H|D) = \frac{P(H)P(D|H)}{P(D)}$
where:
- P(H) - the probability of the hypothesis before we see the data, called the prior probability, or just **prior**
- P(H|D) - the probability of the hypothesis after we see the dat, called the **posterior**
- P(D|H) - the probability of the data under the hypothesis, called the **likelihood**
- P(D) - the **total probability of the data**, under any hypothesis

Computing P(D) can be tricky. It is supposed to be the probability of seeing the data under any hypothesis at all, but it can be hard to nail down what that means.

Most often we simplify things by specifying a set of hypotheses that are:
- Mutually exclusive, which means that only one of them can be true, and
- Collectively exhaustive, which means one of them must be true

Here we use the Law of Total Probability from Chapter 1:

$P(D) = P(H_{1} \ and \ D) + P(H_{2} \ and \ D)$

Applying Theorem 2 from Chapter 1 we got:

$P(D) = P(H_{1})P(D|H_{1}) + P(H_{2})P(D|H_{2})$

For many (N) hypothesis, we got:

$P(D) = \sum \limits_{i=1}^{N} P(H_{i}) P(D|H_{i})$

The process in this section, using data [in P(D|H) and P(D)] and a prior probability [P(H)] to compute a posterior probability [P(H|D)], is called a **Bayesian update**.
"""

# ╔═╡ b0b5778c-fb95-405c-848b-84e958c6f359
md"""### Bayes Tables
A convenient tool for doing a Bayesian update is a Bayes table.
"""

# ╔═╡ 34494573-69f7-46cb-97d8-5616b1e88d52
md"""Here Bayes table for the cookie problem"""

# ╔═╡ c503bb91-d02d-4a6f-b364-aca1af367b36
table = pd.DataFrame(
	(; bowl=[1, 2],
	prior=[0.5, 0.5],
	likelihood=[0.75, 0.5])
)

# ╔═╡ 5d5db65c-0cc1-440e-aa35-89e14b2be49a
md"""You might notice that the likelihoods don't add up to 1.
That's OK; each of them is a probability condidioned on a different hypothesis.
There's no reason they should add up to 1 and no problem if they don't"""

# ╔═╡ d7de2e3c-1389-4d25-ab0a-c21eb06e2190
begin
	# unnorm - unnormalized posterior
	table[!, "unnorm"] = table[!, "prior"] .* table[!, "likelihood"]
	table
end

# ╔═╡ 3598aab2-8d1d-4977-9474-8f50167880c2
md"""In Diachronic Bayes (see above, or TOC) we said that:

$P(D) = \sum \limits_{i=1}^{N} P(H_{i}) P(D|H_{i})$
"""

# ╔═╡ 1dec6590-9004-463d-aaf7-d9a2d244e9a7
begin
	prob_data = sum(table[!, "unnorm"])
	"So, P(D) = $(prob_data)"
end

# ╔═╡ 878fd95f-5e2f-4688-b875-1b4f9d352aff
begin
	table[!, "posterior"] = table[!, "unnorm"] ./ prob_data
	table
end

# ╔═╡ 6c6d359f-0385-41b1-8e61-65458852786f
md"""The posterior probability for Bowl 1 is 0.6, and for Bowl 2 is 0.4.

When we add up the unnormalized posteriors and divide through, we force the posteriors to add up to 1. This process is called “normalization”, which is why the total probability of the data is also called the “normalizing constant”."""

# ╔═╡ 7d5bccec-876d-425b-a57f-261081b3d3b4
md"""### The Dice problem

Suppose I have a box with a 6-sided die, an 8-sided die, and a 12-sided die. I choose one of the dice at random, roll it, and report that the outcome is a 1. What is the probability that I chose the 6-sided die?"""

# ╔═╡ cc718d26-3833-4ece-a440-89acbc610430
md"""I will try to solve it using Bayes table from the previous example"""

# ╔═╡ 8c82ab57-b94e-4d5c-b3c6-3eaf15f15bf5
dice_problem = pd.DataFrame(
	(; no_of_sides=[6, 8, 12],
	prior=[1//3, 1//3, 1//3],
	likelihood=[1//6, 1//8, 1//12]
	)
)

# ╔═╡ 7a36515d-7ca6-480b-b62e-e6c9599752a8
begin
	dice_problem[!, "unnorm"] = dice_problem[!, "prior"] .* dice_problem[!, "likelihood"]
	dice_problem[!, "posterior"] = dice_problem[!, "unnorm"] ./ sum(dice_problem[!, "unnorm"])
	dice_problem
end

# ╔═╡ 4eafb4be-833b-42d0-b48d-343bbcee1418
md"""### The Monty Hall Problem

The Monty Hall problem is based on a game show called *Let’s Make a Deal*.
- there are three closed door
- behind one door there is a car, behind the others goats

The object of the game is to guess which door has the car. If you guess right, you get to keep the car.

To answer this question, we have to make some assumptions about the behavior of the host:
- the host always opens a door and offers you the option to switch
- he never opens the door you picked or the door with the car
- if you choose the door with the car, he chooses one of the other doors at random
"""

# ╔═╡ 8ed1590b-8216-48cd-8e3c-6b84c907c5e3
monty = pd.DataFrame(
	(; door_no=[1, 2, 3],
	prior=[1//3, 1//3, 1//3],
	)
)

# ╔═╡ e9bb20bf-fac0-493c-a72a-ab15534a7cf9
md"""The data is that Monty (the host) opened Door 3 and revealed a goat.
So let’s consider the probability of the data under each hypothesis:
- If the car is behind Door 1, Monty chooses Door 2 or 3 at random, so the probability he opens Door 3 is $\frac{1}{2}$.
- If the car is behind Door 2, Monty has to open Door 3, so the probability of the data under this hypothesis is 1.
- If the car is behind Door 3, Monty does not open it, so the probability of the data under this hypothesis is 0.
"""

# ╔═╡ 5d3cab7f-4758-4ad8-af97-a287c5c420a1
begin
	monty[!, "likelihood"] = [1//2, 1, 0]
	monty[!, "unnorm"] = monty[!, "prior"] .* monty[!, "likelihood"]
	monty[!, "posterior"] = monty[!, "unnorm"] ./ sum(monty[!, "unnorm"])
	monty
end

# ╔═╡ 536ed130-e53d-43d1-a724-174aa6f48dda
md"""As this example shows, our intuition for probability is not always reliable. Bayes’s Theorem can help by providing a divide-and-conquer strategy:
1. First, write down the hypotheses and the data.
2. Next, figure out the prior probabilities.
3. Finally, compute the likelihood of the data under each hypothesis.

The Bayes table does the rest."""

# ╔═╡ bd98b260-1b3a-4bc7-bd1f-ca0c10890c5a
md"""## Exercises"""

# ╔═╡ 4addcf84-1ea7-4a8f-b826-5f726ca46a98
function update!(table)
	table.unnorm = table.prior .* table.likelihood
	table.posterior = table.unnorm ./ sum(table.unnorm)
end

# ╔═╡ d1a98692-070f-4ab7-9786-a09801f01578
md"""### Exercise 1
Suppose you have two coins in a box. One is a normal coin with heads on one side and tails on the other, and one is a trick coin with heads on both sides. You choose a coin at random and see that one of the sides is heads. What is the probability that you chose the trick coin?
"""

# ╔═╡ 8ede20ab-5e2f-49fd-9e2e-2aadb1875bb0
ex1 = pd.DataFrame(
	(; coin_no=[1, 2],
	prior=[1//2, 1//2],
	likelihood=[1//2, 1]
	)
)

# ╔═╡ 9eddb47d-400d-42cc-9daa-f398fb771dfc
begin
	update!(ex1)
	ex1
end

# ╔═╡ 8e808732-01d8-4e1e-ad02-112178a0aaee
md"""### Exercise 2
Suppose you meet someone and learn that they have two children. You ask if either child is a girl and they say yes. What is the probability that both children are girls?

Hint: Start with four equally likely hypotheses.
"""

# ╔═╡ 103398e0-fc6c-41a9-ba85-a844cc2d5e35
ex2 = pd.DataFrame(
	(; hypothesis_no=collect(1:4),
	hypothesis_state=["bb", "bg", "gb", "gg"],
	prior=repeat([1//4], 4),
	likelihood=[0, 1, 1, 1]
	)
)

# ╔═╡ a5e5330b-fbdf-4987-a458-1637b6320e83
begin
	update!(ex2)
	ex2
end

# ╔═╡ 3b5c6d43-399d-4de9-bb8c-f6d5e9848238
md"""### Exercise 3

There are many variations of [the Monty Hall problem](https://en.wikipedia.org/wiki/Monty_Hall_problem).

For example, suppose Monty always chooses Door 2 if he can, and only chooses Door 3 if he has to (because the car is behind Door 2).
1. If you choose Door 1 and Monty opens Door 2, what is the probability the car is behind Door 3?
2. If you choose Door 1 and Monty opens Door 3, what is the probability the car is behind Door 2?
"""

# ╔═╡ 9d12e81a-b6b4-4f84-9a29-eef1cfd5e1e4
ex31 = pd.DataFrame(
	(; door_no=[1, 2, 3],
	prior=repeat([1//3], 3),
	likelihood=[1, 0, 1])
)

# ╔═╡ 49b548b0-ffd2-4bad-a57d-552d6d639a24
begin
	update!(ex31)
	ex31
end

# ╔═╡ 0af84d8d-4b77-4f33-81bd-20f53eafc5c5
ex32 = pd.DataFrame(
	(; door_no=[1, 2, 3],
	prior=repeat([1//3], 3),
	likelihood=[0, 1, 0])
)

# ╔═╡ 4cd525ba-24a9-4bd0-9780-a28bdbd7aeee
begin
	update!(ex32)
	ex32
end

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
# ╟─2b5752ce-a4b3-4d74-ae8f-eb6ed1df501b
# ╟─94210b00-f8cf-4085-a033-370fd39b8519
# ╟─98719a21-7fed-4df0-afc9-24edbffa7bba
# ╟─b0b5778c-fb95-405c-848b-84e958c6f359
# ╟─34494573-69f7-46cb-97d8-5616b1e88d52
# ╠═c503bb91-d02d-4a6f-b364-aca1af367b36
# ╟─5d5db65c-0cc1-440e-aa35-89e14b2be49a
# ╠═d7de2e3c-1389-4d25-ab0a-c21eb06e2190
# ╟─3598aab2-8d1d-4977-9474-8f50167880c2
# ╠═1dec6590-9004-463d-aaf7-d9a2d244e9a7
# ╠═878fd95f-5e2f-4688-b875-1b4f9d352aff
# ╟─6c6d359f-0385-41b1-8e61-65458852786f
# ╟─7d5bccec-876d-425b-a57f-261081b3d3b4
# ╟─cc718d26-3833-4ece-a440-89acbc610430
# ╠═8c82ab57-b94e-4d5c-b3c6-3eaf15f15bf5
# ╠═7a36515d-7ca6-480b-b62e-e6c9599752a8
# ╟─4eafb4be-833b-42d0-b48d-343bbcee1418
# ╠═8ed1590b-8216-48cd-8e3c-6b84c907c5e3
# ╟─e9bb20bf-fac0-493c-a72a-ab15534a7cf9
# ╠═5d3cab7f-4758-4ad8-af97-a287c5c420a1
# ╟─536ed130-e53d-43d1-a724-174aa6f48dda
# ╟─bd98b260-1b3a-4bc7-bd1f-ca0c10890c5a
# ╠═4addcf84-1ea7-4a8f-b826-5f726ca46a98
# ╟─d1a98692-070f-4ab7-9786-a09801f01578
# ╠═8ede20ab-5e2f-49fd-9e2e-2aadb1875bb0
# ╠═9eddb47d-400d-42cc-9daa-f398fb771dfc
# ╟─8e808732-01d8-4e1e-ad02-112178a0aaee
# ╠═103398e0-fc6c-41a9-ba85-a844cc2d5e35
# ╠═a5e5330b-fbdf-4987-a458-1637b6320e83
# ╟─3b5c6d43-399d-4de9-bb8c-f6d5e9848238
# ╠═9d12e81a-b6b4-4f84-9a29-eef1cfd5e1e4
# ╠═49b548b0-ffd2-4bad-a57d-552d6d639a24
# ╠═0af84d8d-4b77-4f33-81bd-20f53eafc5c5
# ╠═4cd525ba-24a9-4bd0-9780-a28bdbd7aeee
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
