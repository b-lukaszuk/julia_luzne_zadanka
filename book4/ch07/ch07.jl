### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ e59f34b1-44ef-498d-bd44-7a83985674bb
begin
	include("pmf.jl")
	import .ProbabilityMassFunction as pmf
	include("simplestat.jl")
	import .SimpleStatistics as ss
end

# ╔═╡ 846f457a-b205-11ed-0734-f92538cec098
md"""# Chapter 7. Minimum, Maximum, and Mixture
[Link to chapter online](https://allendowney.github.io/ThinkBayes2/chap07.html)
"""

# ╔═╡ eccd52d8-0b23-48cd-a5f4-3a2f137457a9
md"""## Warning

The content of this file may be incorrect, erroneous and/or harmful. Use it at Your own risk."""

# ╔═╡ 1d47567d-2ca1-41f5-a4e9-9be714c3c00b
md"""## Imports"""

# ╔═╡ 4731f987-a9c3-4486-bda1-2af802a42a2c
begin
	import DataFrames as pd # pandas in Python
	import Distributions as dst
	import Plots as plts
	import PlutoUI
	import Random as rnd
end

# ╔═╡ 732ecfa0-b3a2-4892-81ef-334dee711a9c
PlutoUI.TableOfContents(depth=4)

# ╔═╡ 5da35a4b-bc8c-412c-89c8-16e46fd7f067
md"""## Code from chapter"""

# ╔═╡ 9e9cc1a8-dbc6-473a-b583-bf012d905ea4
md"### Cumulative Distribution Functions

A useful alternative to probability mass functions (pmf-s) are cumulative distribution functions (cdf-s).

Here a pmf and cdf for [the Euro problem](https://allendowney.github.io/ThinkBayes2/chap04.html#the-euro-problem) discussed before.
"

# ╔═╡ fae6b24f-fe3e-4ad3-8919-3250c96fb438
coin1 = pmf.Pmf(collect(range(0, 1, 101)), repeat([1/101], 101));

# ╔═╡ 9fe98742-eb4a-4a9f-8e85-c9bcd3ddfa5a
coin1_data = Dict("n" => 250, "k" => 140);

# ╔═╡ 060ae814-3a4f-47c1-8fcb-28f08efaa4ab
pmf.update_binomial!(coin1, coin1_data);

# ╔═╡ 4aec3128-151a-4e7e-b800-01da1878256a
coin1_cum_prob = cumsum(coin1.posteriors);

# ╔═╡ 0563feda-7636-4a21-9747-6059f9668cf5
begin
	pmf.draw_posteriors(coin1, "Posterior distribution of the Euro problem",
		"Proportion of heads (x)", "Probability", "PMF")
	plts.plot!(coin1.names, coin1_cum_prob, label="CDF")
end

# ╔═╡ abe93224-077f-4498-ad96-2c55dcf4b1c0
coin1_cum_prob[findfirst(x -> x==0.61, coin1.names)]

# ╔═╡ 7dd74a7d-9872-413e-8a58-89c7945c28b9
coin1.names[findfirst(x -> x >= 0.96, coin1_cum_prob)]

# ╔═╡ 9d69d679-2266-4d09-b53f-0beca05f2179
md"#### CDF struct and its functionality"

# ╔═╡ 9f765925-29d9-4ec0-a960-8df4364469fd
mutable struct Cdf{T}
    names::Vector{T}
    posteriors::Vector{Float64}

    # posteriors are uniform, i.e. initially each prior is equally likely
    Cdf(ns::Vector{Int}, posts) = (length(ns) != length(posts)) ? error("length(names) must be equal length(posteriors)") : new{Int}(ns, posts)
    Cdf(ns::Vector{Float64}, posts) = (length(ns) != length(posts)) ? error("length(names) must be equal length(posteriors)") : new{Float64}(ns, posts)
    Cdf(ns::Vector{String}, posts) = (length(ns) != length(posts)) ? error("length(names) must be equal length(posteriors)") : new{String}(ns, posts)
end

# ╔═╡ 7be616ff-3178-4dee-9a85-fe4cf0558b02
function Base.show(io::IO, cdf::Cdf)
    result = "names: $(join(cdf.names, ", "))\n"
    result = result * "posteriors: $(join(map(x -> round(x, digits=3) |> string, cdf.posteriors), ", "))\n"
    print(io, result)
end

# ╔═╡ 838f95ff-6170-452b-a7d2-0892dccaa920
"""
	mk_cdf_from_pmf(pmf_dist::pmf.Pmf{T}, use_priors::Bool=true)::Cdf{T}

	returns cdf build from pmf

	--
	args:
		pmf_dist: Pmf struct
		use_priors: if true then pmf.priors are used to construct cdf
					otherwise pmf.posteriors are used to construct cdf
"""
function mk_cdf_from_pmf(pmf_dist::pmf.Pmf{T}, use_priors::Bool=true)::Cdf{T} where T
	if use_priors
		return Cdf(pmf_dist.names, cumsum(pmf_dist.priors))
	else
		return Cdf(pmf_dist.names, cumsum(pmf_dist.posteriors))
	end
end

# ╔═╡ 36e734ff-e684-4e9c-a93f-b7f59b8b63eb
function mk_pmf_from_cdf(cdf_dist::Cdf{T})::pmf.Pmf{T} where T
	diffs::Vector{Float64} = diff(cdf_dist.posteriors)
	prepend!(diffs, cdf_dist.posteriors[1])
	return pmf.Pmf(cdf_dist.names, diffs)
end

# ╔═╡ f99232a8-10c4-46f7-9fef-472e2d67f17b
"""
	get_name_for_posterior(cdf_dist::Cdf{T}, posterior::Float64)::T

	returns name from cdf.names that is >= posterior
"""
function get_name_for_posterior(cdf_dist::Cdf{T}, posterior::Float64)::T where T
	@assert 0 <= posterior <= 1
	return cdf_dist.names[findfirst(x -> x >= posterior, cdf_dist.posteriors)]
end

# ╔═╡ 80d8c54a-f6b6-46ba-af0c-dd3ec5ccc356
function get_posterior_for_name(cdf_dist::Cdf{T}, name::T)::Float64 where T
	return cdf_dist.posteriors[findfirst(x -> x == name, cdf_dist.names)]
end

# ╔═╡ 576cd7c4-549a-4ad5-9e52-7c8435191a98
function get_credible_interval(cdf_dist::Cdf{T}, prob::Float64)::Vector{T} where T
	@assert 0 <= prob <= 1
	probs::Vector{Float64} = [0.5 - prob / 2, 0.5 + prob / 2]
	return [get_name_for_posterior(cdf_dist, p) for p in probs]
end

# ╔═╡ 95f1806d-7fe6-4b8d-9901-bf05c33612a7
"""
	Computes and returns the distribution of a maximum of a cdf

	---
	args:
		n: Int, drawing n times from cdf_dist,
			returns cdf where cdf(x) prob. that all n of drawings are <= to x
"""
function get_max_cdf_dist(cdf_dist::Cdf{T}, n::Int)::Cdf{T} where T
	cdf_max_n::Vector{Float64} = cdf_dist.posteriors .^ n
	return Cdf(cdf_dist.names, cdf_max_n)
end

# ╔═╡ d0b1b8e7-2ce8-4f47-9ee0-251a64da1ca1
"""
	Computes and returns the distribution of a minimum of a cdf

	---
	args:
		n: Int, drawing n times from cdf_dist(x),
			returns cdf where cdf(x) prob. that all n of drawings are >= to x
"""
function get_min_cdf_dist(cdf_dist::Cdf{T}, n::Int)::Cdf{T} where T
	# prob that a val from dist is greater than x
	prob_gt = 1 .- cdf_dist.posteriors
	# prob that all n vals drawn from dist exceed x
	# (their min exceeds x)
	prob_gt_n = prob_gt .^ n
	prob_le_n = 1 .- prob_gt_n
	return Cdf(cdf_dist.names, prob_le_n)
end

# ╔═╡ 73ac6a7c-4f9f-46c2-a569-9391a724b53c
function get_avg(pmf_dist::pmf.Pmf{T},
	use_priors::Bool=true)::Float64 where T<:Union{Int, Float64}
	if use_priors
		return sum(pmf_dist.names .* pmf_dist.priors)
	else
		return sum(pmf_dist.names .* pmf_dist.posteriors)
	end
end

# ╔═╡ 5f27be89-656f-498e-a645-846c117ddab6
function get_avg(cdf_dist::Cdf{T})::Float64 where T<:Union{Int, Float64}
	pmf_dist::pmf.Pmf{T} = mk_pmf_from_cdf(cdf_dist)
	return get_avg(pmf_dist)
end

# ╔═╡ 42eefead-bd2c-4a01-82b2-63f057df55d6
function get_std(pmf_dist::pmf.Pmf{T},
	use_priors::Bool=true)::Float64 where T<:Union{Int, Float64}
	avg::Float64 = get_avg(pmf_dist, use_priors)
	devs::Vector{Float64} = pmf_dist.names .- avg
	ps::Vector{Float64} = use_priors ? pmf_dist.priors : pmf_dist.posteriors
	var:: Float64 = sum((devs.^2) .* ps)
	return sqrt(var)
end

# ╔═╡ afec0fff-df0b-47d9-98b1-09a34f8038b3
function get_std(cdf_dist::Cdf{T},
	use_priors::Bool=true)::Float64 where T<:Union{Int, Float64}
	pmf_dist::pmf.Pmf{T} = mk_pmf_from_cdf(cdf_dist)
	return get_std(pmf_dist)
end

# ╔═╡ 5dbad685-2b43-4cc0-a9db-098285cd334e
function is_roughly_equal(n1::Number, n2::Number, precision::Int=15)::Bool
	@assert 0 <= precision <= 16
	return round(n1, digits=precision) == round(n2, digits=precision)
end

# ╔═╡ 8e9c3291-9fa3-468a-ae6b-cabb4f5c5383
coin1_cdf = mk_cdf_from_pmf(coin1, false)

# ╔═╡ c6b6748d-3652-4c69-b058-b6b566ad5b97
coin1_recreated = mk_pmf_from_cdf(coin1_cdf);

# ╔═╡ ba3786c0-90dc-4068-a5f1-8fedaecfb176
all(is_roughly_equal.(coin1.posteriors, coin1_recreated.priors))

# ╔═╡ 6fa51b0a-ec5c-4bcd-a3b6-9ef6062c3393
get_credible_interval(coin1_cdf, 0.9)

# ╔═╡ f1aad45f-64eb-4f4d-84c4-24b1210865d7
get_name_for_posterior(coin1_cdf, 0.96)

# ╔═╡ eaf1c968-b9d4-4053-ac7c-4ea66851f24b
get_posterior_for_name(coin1_cdf, 0.61)

# ╔═╡ 97e0d994-cf77-41bd-909e-06806fefd321
md"### Best Three of Four

In Dungeons & Dragons, each character has six attributes:
- strength,
- intelligence,
- wisdom,
- dexterity,
- constitution,
- charisma.

To generate a new character, players roll four 6-sided dice for each attribute and add up the best three. For example, if I roll for strength and get 1, 2, 3, 4 on the dice, my character’s strength would be the sum of 2, 3, and 4, which is 9.
"

# ╔═╡ 6fd2afdb-f675-47d8-8338-d077a9959ae8
function mk_dice(sides::Int)::pmf.Pmf{Int}
	return pmf.mk_pmf_from_seq(collect(1:sides))
end

# ╔═╡ 0942fe2b-d3f1-4bcf-a103-828630d5f52b
begin
	dice6sides = mk_dice(6)
	three_dice_6_sides = repeat([dice6sides], 3)
end;

# ╔═╡ 9d5fa1c2-f8c0-41bf-8021-04cf6bd42507
pmf_3d6 = pmf.add_dist_seq(three_dice_6_sides)

# ╔═╡ c615644c-b8cf-4e08-89e4-ad6264ab0ea0
pmf.draw_priors(pmf_3d6, "Distribution of attributes",
	"Outcome", "PMF", "")

# ╔═╡ fdad0151-aba7-4621-872e-070874cf2445
md"If we roll four dice and add up the best three, computing the distribution of the sum is a bit more complicated. I’ll (Allen Downey) estimate the distribution by simulating 10,000 rolls."

# ╔═╡ f5ddf901-205e-497d-9aea-31bedf8ac866
begin
	n_rolls = 10_000
	rolls = rand(1:6, (n_rolls, 4))
	sort!(rolls, dims=2, rev=true)
	rolls_3_bests_sums = sum(rolls[:, 1:3], dims=2)
end;

# ╔═╡ 50d95345-d58f-4eab-bcaa-490dbf50c2bc
pmf_best3 = pmf.mk_pmf_from_seq(rolls_3_bests_sums[:, 1]);

# ╔═╡ 5afd384a-db69-4636-a939-1c36d876c184
begin
	pmf.draw_priors(pmf_3d6, "Distribution of attributes",
		"Outcome", "PMF", "sum of 3 dice")
	plts.plot!(pmf_best3.names, pmf_best3.priors, label="best 3 of 4", legend=:topleft)
end

# ╔═╡ 8fbca9d9-5db6-471d-b6bc-4412bc9ddee0
md"As you might expect, choosing the best three out of four tends to yield higher values.

Next we’ll find the distribution for the maximum of six attributes, each the sum of the best three of four dice."

# ╔═╡ ba4f448a-0929-425a-9e79-9f5663e21d8a
md"### Maximum

Recall that `Cdf(x)` is the sum of probabilities for quantities less than or equal to `x`. Equivalently, it is the probability that a random value chosen from the distribution is less than or equal to `x`.

Now suppose I draw 6 values from this distribution. The probability that all 6 of them are less than or equal to `x` is `Cdf(x)` raised to the 6th power."

# ╔═╡ de88b7f6-0a75-486a-902e-992f4816d560
begin
	cdf_best3 = mk_cdf_from_pmf(pmf_best3)
	cdf_max6 = Cdf(cdf_best3.names, cdf_best3.posteriors .^ 6)
end;

# ╔═╡ 22da94a4-e4b2-472b-84aa-a183f638d6c6
pmf_max6 = mk_pmf_from_cdf(cdf_max6);

# ╔═╡ b6008358-3e81-4470-8378-0c62168abbb0
begin
	pmf.draw_priors(pmf_max6, "Distribution of attributes",
		"Outcome", "PMF", "max of 6 attributes")
	plts.xticks!(3:18)
end

# ╔═╡ f2036c6b-ea7e-4fd3-8195-337249560f40
md"Most characters have at least one attribute greater than 12; almost 10% of them have an 18.

The following figure shows the CDFs for the three distributions we have computed."

# ╔═╡ bd67e94d-d08a-40b4-a3e0-a826d4620916
cdf_3d6 = mk_cdf_from_pmf(pmf_3d6);

# ╔═╡ 4002e8f8-a3ea-4243-b981-3b43cb47bf8e
begin
	plts.plot(cdf_3d6.names, cdf_3d6.posteriors, label="sum of 3 dice")
	plts.title!("Distribution of attributes")
	plts.xlabel!("Outcome")
	plts.ylabel!("PMF")

	plts.plot!(cdf_best3.names, cdf_best3.posteriors, label="best 3 of 4 dice")

	plts.plot!(cdf_max6.names, cdf_max6.posteriors, label="max of 6 attributes")
end

# ╔═╡ b0aea785-5700-48ee-b012-9070ac3458ae
md"### Minimum

To compute the distribution of the minimum, we'll use the **complementary CDF**, which we can compute like this:
"

# ╔═╡ 28c611da-6452-4a41-92ea-d987a464666e
prob_gt = 1 .- cdf_best3.posteriors;

# ╔═╡ 8512b66c-7746-4654-9cfe-b9c745faa109
md"As the variable name suggests, the complementary CDF is the probability that a value from the distribution is greater than `x`. If we draw 6 values from the distribution, the probability that all 6 exceed `x` is:"

# ╔═╡ df51529b-d1b0-4911-9583-b11ed7116be2
prob_gt6 = prob_gt .^ 6;

# ╔═╡ f5e79837-3011-420b-9f79-39986b09bced
md"If all 6 exceed `x`, that means their minimum exceeds `x`, so `prob_gt6` is the complementary CDF of the minimum. And that means we can compute the CDF of the minimum like this:"

# ╔═╡ fee8e66d-6e71-4fdd-8a80-1f93146fc1f0
prob_le6 = 1 .- prob_gt6;

# ╔═╡ 1918c9f6-c401-4298-af12-61c9ce9d9e40
md"We can put those values in a `Cdf` struct like this:"

# ╔═╡ cb29319d-309a-4f8b-9ca9-cac774d46c2b
cdf_min6 = Cdf(cdf_max6.names, prob_le6);

# ╔═╡ 19ec038d-3fdd-45f1-87f7-4f6a45bb5a07
begin
	plts.plot(cdf_max6.names, cdf_max6.posteriors, label="maximum of 6")
	plts.title!("Minimum and maximum of six attributes")
	plts.xlabel!("Outcome")
	plts.ylabel!("CDF")
	plts.xticks!(3:18)

	plts.plot!(cdf_min6.names, cdf_min6.posteriors, label="minimum of 6")
end

# ╔═╡ 9386ae07-6d2e-4ea2-a7b9-f681878101c5
md"### Mixture

Here’s another example inspired by Dungeons & Dragons:

- Suppose your character is armed with a dagger in one hand and a short sword in the other.
- During each round, you attack a monster with one of your two weapons, chosen at random.
- The dagger causes one 4-sided die of damage; the short sword causes one 6-sided die of damage.

What is the distribution of damage you inflict in each round?
"

# ╔═╡ 0e627f03-8a8c-4c83-94d6-69ad8022830c
begin
	d4s = mk_dice(4)
	d6s = mk_dice(6)
end;

# ╔═╡ 53f81cfa-b8cf-43e9-99e3-9f4f3eae5b8b
md"Now, let’s compute the probability you inflict 1 point of damage.

- If you attacked with the dagger, it’s 1/4.
- If you attacked with the short sword, it’s 1/6.

Because the probability of choosing either weapon is 1/2, the total probability is the average:"

# ╔═╡ 49818e55-b7b5-4ba2-a22d-06b208c5f0e1
sum(d4s.priors[1] + d6s.priors[1]) / 2

# ╔═╡ 88441cb6-d5fb-443a-9653-2a6200bb36a0
md"For the outcomes 2, 3, and 4, the probability is the same, but for 5 and 6 it’s different, because those outcomes are impossible with the 4-sided die.

In general we have:
"

# ╔═╡ 245ea5fd-baa5-46ff-889a-39c5cd123a14
# mix1 vals add up to 1
mix1 = ([get(d4s.priors, i, 0) for i in 1:6] .+ d6s.priors) ./ 2

# ╔═╡ d89e2928-a11b-4f74-9222-6ed62d8ff668
begin
	plts.bar(1:6, mix1, legend=false)
	plts.title!("Mixture of one 4-sided and one 6-sided die")
	plts.xlabel!("Outcome")
	plts.ylabel!("PMF")
end

# ╔═╡ 43967a1b-e1d0-4e24-9fdc-892a2d6f5e7f
md"Now suppose you are fighting three monsters:

- One has a club, which causes one 4-sided die of damage.
- One has a mace, which causes one 6-sided die.
- And one has a quarterstaff, which also causes one 6-sided die.

Because the melee is disorganized, you are attacked by one of these monsters each round, chosen at random.

Let's find the damage distribution in this case
"

# ╔═╡ d831a27e-8271-414c-a7d8-fdf5425e68c9
# mix2 vals add up to 1
mix2 = ([get(d4s.priors, i, 0) for i in 1:6] .+ d6s.priors .* 2) ./ 3

# ╔═╡ 3530dcdb-8513-47d5-bd6d-252d9701d1be
begin
	plts.bar(1:6, mix2, legend=false)
	plts.title!("Mixture of one 4-sided and two 6-sided die")
	plts.xlabel!("Outcome")
	plts.ylabel!("PMF")
end

# ╔═╡ 57cd4aa5-eb0a-48d4-837b-74ca0f6c651b
md"In this section we used the `+` operator, which adds the probabilities in the distributions, not to be confused with `Pmf.add_dist`, which computes the distribution of the sum of the distributions.

Let's see the difference, below the distribution of the total damage done per round."

# ╔═╡ f931a740-794b-4c7f-b153-36ea4f278933
tot_dmg_per_round = pmf.add_dist(
	pmf.Pmf(collect(1:6), mix1), pmf.Pmf(collect(1:6), mix2));

# ╔═╡ aecd8923-e40b-4661-9e5f-5ec73994fb15
begin
	plts.bar(tot_dmg_per_round.names, tot_dmg_per_round.priors, legend=false)
	plts.title!("Total damage inflicted by both parties")
	plts.xlabel!("Outcome")
	plts.ylabel!("PMF")
	plts.xticks!(2:12)
end

# ╔═╡ 48da7cb9-eef7-468a-88b8-42766fd55160
md"### General Mixtures
...we’ll continue the previous example for one more section.

Suppose three more monsters join the combat, each of them with a battle axe that causes one 8-sided die of damage. Still, only one monster attacks per round, chosen at random, so the damage they inflict is a mixture of:
- One 4-sided die,
- Two 6-sided dice, and
- Three 8-sided dice.
"

# ╔═╡ 77104898-c7fc-42e0-80f7-d6264c4da085
begin
	hypos = [4, 6, 8]
	counts = [1, 2, 3]
	pmf_dice = pmf.Pmf(counts, counts ./ sum(counts))
end

# ╔═╡ 54357568-f945-47a0-b7fa-4938de6ce81f
dice = [mk_dice(sides) for sides in hypos];

# ╔═╡ c5cfb8e2-f79e-4c6a-ba08-8dfa59c2ad79
md"To compute the distribution of the mixture, I’ll compute the weighted average of the dice, using the probabilities in `pmf_dice` as the weights."

# ╔═╡ f2296a8e-d403-4480-8f3f-028ff80a0652
function pad_vect(vect::Vector{Float64}, final_len::Int, fill::Float64=0.0)::Vector{Float64}
	return [get(vect, i, fill) for i in 1:final_len]
end

# ╔═╡ e6fc66ff-0640-4f61-b265-00bacc12cf16
begin
	no_of_sides = collect(1:max(hypos...))
	counts_and_priors = Dict{Int, Vector{Float64}}()
	for i in counts
		counts_and_priors[i] = pad_vect(dice[i].priors, max(hypos...))
	end
end

# ╔═╡ 41cbcd0b-2328-4dba-ae0c-6b27fc32310b
df1 = pd.DataFrame(Dict(string(k) => v for (k, v) in counts_and_priors))

# ╔═╡ 9dd62af8-dbd9-4611-82ca-1d8052eeceef
md"The next step is to multiply each row by the probabilities in `pmf_dice`"

# ╔═╡ a74ef7c7-bd72-498e-9e2e-dd8ea489d333
begin
	df2 = pd.select(df1,
		map(string, 1:3) .=> [x -> x .* y for y in pmf_dice.priors] .=> map(string, 1:3))
	df2
end

# ╔═╡ 8afd8d9b-a22c-42ab-bbe1-be69afbdc312
md"Now we add up the weighted distributions"

# ╔═╡ c0472bf4-751e-4161-8526-7bb80fb37c9b
mix3 = df2 |> Matrix |> x -> sum(x, dims=2)

# ╔═╡ 301b66ac-72cd-4671-98bb-c49aecad4ae9
begin
	plts.bar(1:8, mix3, label="mixture")
	plts.title!("Distribution of damage with three different weapons")
	plts.xlabel!("Outcome")
	plts.ylabel!("PMF")
	plts.xticks!(1:8)
end

# ╔═╡ 6eb30ed5-f897-4687-8029-911a7326744d
"""mk\\_mixture(pmf\\_dist::pmf.Pmf{Int}, pmf\\_seq::Vector{pmf.Pmf{Int}})::pmf.Pmf{Int}

	Make a mixture of distributions.

	---
	args:

		pmf_dist: probs of getting a dist in pmf_seq (names and priors)
		pmf_seq: pmf_dists and their probs (priors), names betw seqs should overlap
	"""
function mk_mixture(pmf_dist::pmf.Pmf{Int}, pmf_seq::Vector{pmf.Pmf{Int}})::pmf.Pmf{Int}
	max_len::Int = max([length(p.names) for p in pmf_seq]...)
	names::Vector{Int} = [p.names for p in pmf_seq if length(p.names) == max_len][1]
	pmfs_names_and_priors::Dict{Int, Vector{Float64}} = Dict(
		pmf_dist.names[i] => pad_vect(s.priors, max_len) for (i, s) in enumerate(pmf_seq))
	pmfs_names_and_posteriors::Dict{Int, Vector{Float64}} = Dict(
		k => v .* pmf.get_prior(pmf_dist, k) for (k, v) in pmfs_names_and_priors
	)
	df::pd.DataFrame = pd.DataFrame(
		Dict(string(k) => v for (k, v) in pmfs_names_and_posteriors))
	mix_probs::Vector{Float64} = (df |> Matrix |> x -> sum(x, dims=2))[:, 1]
	return pmf.Pmf(names, mix_probs)
end

# ╔═╡ 35568e58-a6bb-4a67-839e-e2152b3c19cf
mix = mk_mixture(pmf_dice, dice)

# ╔═╡ 6378e97f-7d68-4bed-a464-8bd216d1ef61
begin
	plts.bar(mix.names, mix.priors, label="mixture")
	plts.title!("Distribution of damage with three different weapons")
	plts.xlabel!("Outcome")
	plts.ylabel!("PMF")
	plts.xticks!(1:8)
end

# ╔═╡ 12300a6f-24be-4a91-b1de-c778b09954bf
md"### Summary

A `Pmf` and the corresponding `Cdf` are equivalent in the sense that they contain the same information, so you can convert from one to the other.
The primary difference between them is performance: some operations are faster and easier with a `Pmf`; others are faster with a `Cdf` (like presented in this chapter distribution of maximums and minimums).
"

# ╔═╡ c6e66856-425b-4b51-850c-5c7a1f423a95
md"## Exercises"

# ╔═╡ cf5d01a0-270d-4b4a-a26e-3e2d4a6a1791
md"### Exercise 1

When you generate a D&D character, instead of rolling dice, you can use the “standard array” of attributes, which is 15, 14, 13, 12, 10, and 8. Do you think you are better off using the standard array or (literally) rolling the dice?

Compare the distribution of the values in the standard array to the distribution we computed for the best three out of four:
- Which distribution has higher mean? Use the `mean` method.
- Which distribution has higher standard deviation? Use the `std` method.
- The lowest value in the standard array is 8. For each attribute, what is the probability of getting a value less than 8? If you roll the dice six times, what’s the probability that at least one of your attributes is less than 8?
- The highest value in the standard array is 15. For each attribute, what is the probability of getting a value greater than 15? If you roll the dice six times, what’s the probability that at least one of your attributes is greater than 15?

To get you started, here’s a `Cdf` that represents the distribution of attributes in the standard array:
"

# ╔═╡ 0b74df23-e86c-4033-a288-3890ae7efebc
begin
	ex1_standard = [15, 14, 13, 12, 10, 8]
	ex1_cdf_standard = mk_cdf_from_pmf(pmf.mk_pmf_from_seq(ex1_standard))
end

# ╔═╡ 12c5417d-9c8d-4f40-9837-84486683c264
begin
	plts.plot(ex1_cdf_standard.names, ex1_cdf_standard.posteriors, label="D&D standard", color=:navy)
	plts.scatter!(ex1_cdf_standard.names, ex1_cdf_standard.posteriors, label="",
		markershape=:circ, markercolor=:navy, markersize=6)
	plts.plot!(cdf_best3.names, cdf_best3.posteriors, label="D&D best 3 of 4",
		color=:red)
	plts.scatter!(cdf_best3.names, cdf_best3.posteriors, label="",
		markershape=:rect, markercolor=:red)
	plts.xticks!(1:20)
end

# ╔═╡ 0f2897a0-0bff-45be-a2af-80df284bb202
md"#### Ex1. Medians, means, stds

D&D standard:
- name of prob median = $(get_name_for_posterior(ex1_cdf_standard, 0.5))
- name of prob avg = $(round(get_avg(ex1_cdf_standard), digits=3))
- name of prob std = $(round(get_std(ex1_cdf_standard), digits=3))

D&D best 3 of 4:
- name of prob median = $(get_name_for_posterior(cdf_best3, 0.5))
- name of prob avg= $(round(get_avg(cdf_best3), digits=3))
- name of prob std = $(round(get_std(cdf_best3), digits=3))
"

# ╔═╡ f13ddf81-491e-412d-9e35-aa2e7824e6e3
md"#### Ex1. Attribute(s) less than 8

Best 3 of 4:
- prob of getting each attribute less than 8 = $(round(get_posterior_for_name(cdf_best3, 7), digits=3))
- prob of getting at least 1 of 6 attributes less than 8 = $(round(get_posterior_for_name(get_min_cdf_dist(cdf_best3, 6), 7), digits=3))
"

# ╔═╡ c199f262-11fb-40f7-a4da-b37d05cdc258
md"#### Ex1. Attribute(s) greater than 15

Best 3 of 4:
- prob of getting an attribute greater than 15 = $(round(1 - get_posterior_for_name(cdf_best3, 15), digits=3))
- prob of getting at least 1 of 6 attributes greater than 15 = $(round(1 - get_posterior_for_name(get_max_cdf_dist(cdf_best3, 6), 15), digits=3))
"

# ╔═╡ 80e41355-d158-4145-9c45-951d9aceedb7
md"### Exercise 2

Suppose you are fighting three monsters:
- One is armed with a short sword that causes one 6-sided die of damage,
- One is armed with a battle axe that causes one 8-sided die of damage, and
- One is armed with a bastard sword that causes one 10-sided die of damage.

One of the monsters, chosen at random, attacks you and does 1 point of damage.

Which monster do you think it was? Compute the posterior probability that each monster was the attacker.

If the same monster attacks you again, what is the probability that you suffer 6 points of damage?

**Hint**: Compute a posterior distribution as we have done before and pass it as one of the arguments to `make_mixture`.
"

# ╔═╡ 37a1b1cf-8ef7-47c5-8e71-0883a623bb6d
begin
	# P(D|H), or P(1..no_sides | n_sided_dice is choosen)
	# so, ex3_pmf_seq[1].priors contains rather likelihoods
	ex2_pmf_seq = [mk_dice(i) for i in [6, 8, 10]]
	ex2_posteriors = []
end;

# ╔═╡ 9bb3994d-4808-49a4-97e4-1f6c893bece7
for seq in ex2_pmf_seq
	# P(H), or P(choosing n_sided dice)
	# so we are updating priors
	pmf.update_likelihoods!(seq, repeat([1/3], length(seq.names)))
	# priors times likelihoods is the same as likelihoods times priors
	# the resultant posteriors are updated
	pmf.update_posteriors!(seq)
	push!(ex2_posteriors, pmf.get_prior(seq, 1))
end;

# ╔═╡ d61f135d-a6cf-4cce-9df7-f45f01f34f4f
# P(H|D), or P(dice | 1 dmg), or P(n_sided_dice | 1 side on top)
# probabilities of getting a given monster if we got 1 dmg
# for [6, 8, 10] sided dice respectively
ex2_post_norm = ex2_posteriors ./ sum(ex2_posteriors)

# ╔═╡ c2bc5bab-01cd-4338-9c17-dc7e4770b667
md"Not sure I understand the task description right.

'If the same monster attacks You again, what is the probability that you suffer 6 points of damage?'

Doesn't this mean that I need to calculate:
- P(6 dmg | 6 sided dice) = 1/6
- P(6 dmg | 8 sided dice) = 1/8
- P(6 dmg | 10 sided dice) = 1/10

But following the hint and using `make_mixture` will get me P(6 dmg) no matter the dice (monster), after I get 1 dmg in first throw (after considering probability of each monster in first attack). So, that's why I stop here."

# ╔═╡ 13f58198-6fce-4098-b64a-4fcdee753559
md"### Exercise 3

Henri Poincaré was a French mathematician who taught at the Sorbonne around 1900. The following anecdote about him is probably fiction, but it makes an interesting probability problem.

Supposedly Poincaré suspected that his local bakery was selling loaves of bread that were lighter than the advertised weight of 1 kg, so every day for a year he bought a loaf of bread, brought it home and weighed it. At the end of the year, he plotted the distribution of his measurements and showed that it fit a normal distribution with mean 950 g and standard deviation 50 g. He brought this evidence to the bread police, who gave the baker a warning.

For the next year, Poincaré continued to weigh his bread every day. At the end of the year, he found that the average weight was 1000 g, just as it should be, but again he complained to the bread police, and this time they fined the baker.

Why? Because the shape of the new distribution was asymmetric. Unlike the normal distribution, it was skewed to the right, which is consistent with the hypothesis that the baker was still making 950 g loaves, but deliberately giving Poincaré the heavier ones.

To see whether this anecdote is plausible, let’s suppose that when the baker sees Poincaré coming, he hefts n loaves of bread and gives Poincaré the heaviest one. How many loaves would the baker have to heft to make the average of the maximum 1000 g?

To get you started, I’ll generate a year’s worth of data from a normal distribution with the given parameters.
"

# ╔═╡ acbd2e1e-e803-41b0-8271-19afeb688c6e
begin
	ex3_mean = 950
	ex3_std = 50

	# unlikely that it will work like np.random.seed(17) in Python
	# but I will use it anyway
	rnd.seed!(17)
	ex3_sample = rand(dst.Normal(ex3_mean, ex3_std), 365)
end;

# ╔═╡ 342180b4-9861-4f63-9de2-ea18e83b0b28
begin
	plts.histogram(ex3_sample, legend=false)
	plts.title!("Bread loaves weight distribution")
	plts.xlabel!("Mass of a bread loaf [g]")
	plts.ylabel!("Number of bread loaves")
end

# ╔═╡ acf4f3df-a464-4f6d-9542-a295071bf616
md"#### Ex3. Solution

So, like in subchapter 'Maximum' from this chapter (ch07.jl) I will do Pmf and Cdf objects first"

# ╔═╡ 4a4b027f-368a-491b-865c-de11f230624f
begin
	# lets round the numbers just a bit
	ex3_pmf = pmf.mk_pmf_from_seq(round.(ex3_sample, digits=1))
	ex3_cdf = mk_cdf_from_pmf(ex3_pmf)
end;

# ╔═╡ 55f97f94-4624-4f9b-a22f-6f2eeed07dd3
begin
	plts.histogram(ex3_pmf.names, normalize=:probability, label="")
	plts.plot!(ex3_cdf.names, ex3_cdf.posteriors, label="CDF")
	plts.title!("Bread loaves weight distribution")
	plts.xlabel!("Mass of a bread loaf [g]")
	plts.ylabel!("Probability of a bread loaf having certain mass")
end

# ╔═╡ 7873d85c-33c1-44a4-b419-ba3d84632f86
md"Now, the baker compares a few bread loaves and chooses the most heavy one to give it to Poincaré. Lets say he compares between 2 (not possible to compare less than 2 bread loaves) and 10 bread loaves (otherwise it would take too much time to do that). So we need to use `get_max_cdf_dist` developed in this chapter (see section CDF struct and its functionality in this file)"

# ╔═╡ 5d3f2ab7-072d-43c4-9ff4-3f684eb59aa2
begin
	ex3_max_cdfs = Dict{Int, Cdf}()
	for i in 2:10
		ex3_max_cdfs[i] = get_max_cdf_dist(ex3_cdf, i)
	end;
end

# ╔═╡ a2a8baa8-b8db-42e2-b9a7-46ab524ee333
md"This `get_max_cdf_dist` will return `cdf` where `cdf(x)` is probability that all n of drawings are <= to `x`.

Now the question is 'How many loaves would the baker have to heft to make the average of the maximum 1000 g?' so, we need to calculate the averages (previously developed `get_avg` function) or a median (since in ideal normal distribution mean is equal to median).
"

# ╔═╡ 2e0e1c4e-d7cd-4a92-ac1a-a1933b026d70
begin
	ex3_max_avgs = Dict{Int, Float64}()
	for (k, v) in ex3_max_cdfs
		tmp = get_avg(v)
		if (990 <= tmp <= 1010)
			ex3_max_avgs[k] = tmp
		end
	end
end;

# ╔═╡ 26d219a8-6508-4959-86b3-89f4bdd8422e
# so the baker wouldhave to heft on avg 4 or 5 bread loaves
ex3_max_avgs

# ╔═╡ 81a95524-6c14-480c-be33-bafde878a610
# checkup of the above assumption with median
[get_name_for_posterior(ex3_max_cdfs[4], 0.5), get_name_for_posterior(ex3_max_cdfs[5], 0.5)]

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[compat]
DataFrames = "~1.5.0"
Distributions = "~0.25.86"
Plots = "~1.38.8"
PlutoUI = "~0.7.50"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.3"
manifest_format = "2.0"
project_hash = "957acda0eab9c483f905214da2b3b72fe8168977"

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

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "c6d890a52d2c4d55d326439580c3b8d0875a77d9"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.7"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "485193efd2176b88e6622a39a246f8c5b600e74e"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.6"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "9c209fb7536406834aa938fb149964b985de6c83"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.1"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random", "SnoopPrecompile"]
git-tree-sha1 = "aa3edc8f8dea6cbfa176ee12f7c2fc82f0608ed3"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.20.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "600cc5508d66b78aae350f7accdb58763ac18589"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.10"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "7a60c856b9fa189eb34f5f8a6f6b5529b7942957"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.6.1"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

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

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "da9e1a9058f8d3eec3a8c9fe4faacfb89180066b"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.86"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "7072f1e3e5a8be51d525d64f63d3ec1287ff2790"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.11"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "4423d87dc2d3201f3f1768a29e807ddc8cc867ef"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.71.8"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "3657eb348d44575cc5560c80d7e55b812ff6ffe1"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.71.8+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "d3b3624125c1474292d0d8ed0f65554ac37ddb23"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.74.0+2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "37e4657cd56b11abe3d10cd4a1ec5fbdb4180263"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.7.4"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "6de59b37a1d330bdd766610fe751fed605170dc4"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.13"

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

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "f377670cda23b6b7c1c0b3893e37451c5c1a2185"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.5"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6f2675ef130a300a112286de91973805fcc5ffbc"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.91+0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "2422f47b34d4b127720a18f86fa7b1aa2e141f29"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.18"

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

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c7cb1f5d892775ba13767a87c7ada0b980ea0a71"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+2"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "0a1b7c2863e44523180fdb3146534e265a91870b"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.23"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "cedb76b37bc5a6c702ade66be44f831fa23c681e"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

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

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "6503b77492fd7fcb9379bf73cd31035670e3c509"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.3.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9ff31d101d987eb9d66bd8b176ac7c277beccd09"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.20+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "d78db6df34313deaca15c5c0b9ff562c704fe1ab"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.5.0"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "67eae2738d63117a196f497d7db789821bce61d1"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.17"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "478ac6c952fddd4399e71d4779797c538d0ff2bf"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.8"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "1f03a2d339f42dca4a4da149c7e15e9b896ad899"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.1.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "c95373e73290cf50a8a22c3375e4625ded5c5280"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.4"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Preferences", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SnoopPrecompile", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "f49a45a239e13333b8b936120fe6d793fe58a972"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.38.8"

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
git-tree-sha1 = "548793c7859e28ef026dba514752275ee871169f"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "0c03844e2231e12fda4d0086fd7cbe4098ee8dc5"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+2"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "6ec7ac8412e83d57e313393220879ede1740f9ee"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.8.2"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
deps = ["SnoopPrecompile"]
git-tree-sha1 = "261dddd3b862bd2c940cf6ca4d1c8fe593e457c8"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.3"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase", "SnoopPrecompile"]
git-tree-sha1 = "e974477be88cb5e3040009f3767611bc6357846f"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.11"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "f65dcb5fa46aee0cf9ed6274ccbd597adc49aa7b"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.1"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6ed52fdd3382cf21947b15e8870ac0ddbff736da"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.4.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "30449ee12237627992a99d5e30ae63e4d78cd24a"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "77d3c4726515dca71f6d80fbb5e251088defe305"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.18"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

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

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "ef28127915f4229c971eb43f3fc075dd3fe91880"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.2.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "45a7769a04a3cf80da1c1c7c60caf932e6f4c9f7"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.6.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "f625d686d5a88bcd2b15cd81f18f98186fdc0c9a"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.3.0"

[[deps.StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

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
git-tree-sha1 = "1544b926975372da01227b382066ab70e574a3ec"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "94f38103c984f89cf77c402f2a68dbd870f8165f"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.11"

[[deps.Tricks]]
git-tree-sha1 = "aadb748be58b492045b4f56166b5188aa63ce549"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.7"

[[deps.URIs]]
git-tree-sha1 = "074f993b0ca030848b897beff716d93aca60f06a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "ed8d92d9774b077c53e1da50fd81a36af3744c1c"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "93c41695bc1c08c46c5899f4fe06d6ead504bb73"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.10.3+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c6edfe154ad7b313c01aceca188c05c835c67360"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.4+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "868e669ccb12ba16eaf50cb2957ee2ff61261c56"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.29.0+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9ebfc140cc56e8c2156a15ceac2f0302e327ac0a"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+0"
"""

# ╔═╡ Cell order:
# ╟─846f457a-b205-11ed-0734-f92538cec098
# ╟─eccd52d8-0b23-48cd-a5f4-3a2f137457a9
# ╟─1d47567d-2ca1-41f5-a4e9-9be714c3c00b
# ╠═4731f987-a9c3-4486-bda1-2af802a42a2c
# ╠═e59f34b1-44ef-498d-bd44-7a83985674bb
# ╠═732ecfa0-b3a2-4892-81ef-334dee711a9c
# ╟─5da35a4b-bc8c-412c-89c8-16e46fd7f067
# ╟─9e9cc1a8-dbc6-473a-b583-bf012d905ea4
# ╠═fae6b24f-fe3e-4ad3-8919-3250c96fb438
# ╠═9fe98742-eb4a-4a9f-8e85-c9bcd3ddfa5a
# ╠═060ae814-3a4f-47c1-8fcb-28f08efaa4ab
# ╠═4aec3128-151a-4e7e-b800-01da1878256a
# ╠═0563feda-7636-4a21-9747-6059f9668cf5
# ╠═abe93224-077f-4498-ad96-2c55dcf4b1c0
# ╠═7dd74a7d-9872-413e-8a58-89c7945c28b9
# ╟─9d69d679-2266-4d09-b53f-0beca05f2179
# ╠═9f765925-29d9-4ec0-a960-8df4364469fd
# ╠═7be616ff-3178-4dee-9a85-fe4cf0558b02
# ╠═838f95ff-6170-452b-a7d2-0892dccaa920
# ╠═36e734ff-e684-4e9c-a93f-b7f59b8b63eb
# ╠═f99232a8-10c4-46f7-9fef-472e2d67f17b
# ╠═80d8c54a-f6b6-46ba-af0c-dd3ec5ccc356
# ╠═576cd7c4-549a-4ad5-9e52-7c8435191a98
# ╠═95f1806d-7fe6-4b8d-9901-bf05c33612a7
# ╠═d0b1b8e7-2ce8-4f47-9ee0-251a64da1ca1
# ╠═73ac6a7c-4f9f-46c2-a569-9391a724b53c
# ╠═5f27be89-656f-498e-a645-846c117ddab6
# ╠═42eefead-bd2c-4a01-82b2-63f057df55d6
# ╠═afec0fff-df0b-47d9-98b1-09a34f8038b3
# ╠═5dbad685-2b43-4cc0-a9db-098285cd334e
# ╠═8e9c3291-9fa3-468a-ae6b-cabb4f5c5383
# ╠═c6b6748d-3652-4c69-b058-b6b566ad5b97
# ╠═ba3786c0-90dc-4068-a5f1-8fedaecfb176
# ╠═6fa51b0a-ec5c-4bcd-a3b6-9ef6062c3393
# ╠═f1aad45f-64eb-4f4d-84c4-24b1210865d7
# ╠═eaf1c968-b9d4-4053-ac7c-4ea66851f24b
# ╟─97e0d994-cf77-41bd-909e-06806fefd321
# ╠═6fd2afdb-f675-47d8-8338-d077a9959ae8
# ╠═0942fe2b-d3f1-4bcf-a103-828630d5f52b
# ╠═9d5fa1c2-f8c0-41bf-8021-04cf6bd42507
# ╠═c615644c-b8cf-4e08-89e4-ad6264ab0ea0
# ╟─fdad0151-aba7-4621-872e-070874cf2445
# ╠═f5ddf901-205e-497d-9aea-31bedf8ac866
# ╠═50d95345-d58f-4eab-bcaa-490dbf50c2bc
# ╠═5afd384a-db69-4636-a939-1c36d876c184
# ╟─8fbca9d9-5db6-471d-b6bc-4412bc9ddee0
# ╟─ba4f448a-0929-425a-9e79-9f5663e21d8a
# ╠═de88b7f6-0a75-486a-902e-992f4816d560
# ╠═22da94a4-e4b2-472b-84aa-a183f638d6c6
# ╠═b6008358-3e81-4470-8378-0c62168abbb0
# ╟─f2036c6b-ea7e-4fd3-8195-337249560f40
# ╠═bd67e94d-d08a-40b4-a3e0-a826d4620916
# ╠═4002e8f8-a3ea-4243-b981-3b43cb47bf8e
# ╟─b0aea785-5700-48ee-b012-9070ac3458ae
# ╠═28c611da-6452-4a41-92ea-d987a464666e
# ╟─8512b66c-7746-4654-9cfe-b9c745faa109
# ╠═df51529b-d1b0-4911-9583-b11ed7116be2
# ╟─f5e79837-3011-420b-9f79-39986b09bced
# ╠═fee8e66d-6e71-4fdd-8a80-1f93146fc1f0
# ╟─1918c9f6-c401-4298-af12-61c9ce9d9e40
# ╠═cb29319d-309a-4f8b-9ca9-cac774d46c2b
# ╠═19ec038d-3fdd-45f1-87f7-4f6a45bb5a07
# ╟─9386ae07-6d2e-4ea2-a7b9-f681878101c5
# ╠═0e627f03-8a8c-4c83-94d6-69ad8022830c
# ╟─53f81cfa-b8cf-43e9-99e3-9f4f3eae5b8b
# ╠═49818e55-b7b5-4ba2-a22d-06b208c5f0e1
# ╟─88441cb6-d5fb-443a-9653-2a6200bb36a0
# ╠═245ea5fd-baa5-46ff-889a-39c5cd123a14
# ╠═d89e2928-a11b-4f74-9222-6ed62d8ff668
# ╟─43967a1b-e1d0-4e24-9fdc-892a2d6f5e7f
# ╠═d831a27e-8271-414c-a7d8-fdf5425e68c9
# ╠═3530dcdb-8513-47d5-bd6d-252d9701d1be
# ╟─57cd4aa5-eb0a-48d4-837b-74ca0f6c651b
# ╠═f931a740-794b-4c7f-b153-36ea4f278933
# ╠═aecd8923-e40b-4661-9e5f-5ec73994fb15
# ╟─48da7cb9-eef7-468a-88b8-42766fd55160
# ╠═77104898-c7fc-42e0-80f7-d6264c4da085
# ╠═54357568-f945-47a0-b7fa-4938de6ce81f
# ╟─c5cfb8e2-f79e-4c6a-ba08-8dfa59c2ad79
# ╠═f2296a8e-d403-4480-8f3f-028ff80a0652
# ╠═e6fc66ff-0640-4f61-b265-00bacc12cf16
# ╠═41cbcd0b-2328-4dba-ae0c-6b27fc32310b
# ╟─9dd62af8-dbd9-4611-82ca-1d8052eeceef
# ╠═a74ef7c7-bd72-498e-9e2e-dd8ea489d333
# ╟─8afd8d9b-a22c-42ab-bbe1-be69afbdc312
# ╠═c0472bf4-751e-4161-8526-7bb80fb37c9b
# ╠═301b66ac-72cd-4671-98bb-c49aecad4ae9
# ╠═6eb30ed5-f897-4687-8029-911a7326744d
# ╠═35568e58-a6bb-4a67-839e-e2152b3c19cf
# ╠═6378e97f-7d68-4bed-a464-8bd216d1ef61
# ╟─12300a6f-24be-4a91-b1de-c778b09954bf
# ╟─c6e66856-425b-4b51-850c-5c7a1f423a95
# ╟─cf5d01a0-270d-4b4a-a26e-3e2d4a6a1791
# ╠═0b74df23-e86c-4033-a288-3890ae7efebc
# ╠═12c5417d-9c8d-4f40-9837-84486683c264
# ╟─0f2897a0-0bff-45be-a2af-80df284bb202
# ╟─f13ddf81-491e-412d-9e35-aa2e7824e6e3
# ╟─c199f262-11fb-40f7-a4da-b37d05cdc258
# ╟─80e41355-d158-4145-9c45-951d9aceedb7
# ╠═37a1b1cf-8ef7-47c5-8e71-0883a623bb6d
# ╠═9bb3994d-4808-49a4-97e4-1f6c893bece7
# ╠═d61f135d-a6cf-4cce-9df7-f45f01f34f4f
# ╟─c2bc5bab-01cd-4338-9c17-dc7e4770b667
# ╟─13f58198-6fce-4098-b64a-4fcdee753559
# ╠═acbd2e1e-e803-41b0-8271-19afeb688c6e
# ╠═342180b4-9861-4f63-9de2-ea18e83b0b28
# ╟─acf4f3df-a464-4f6d-9542-a295071bf616
# ╠═4a4b027f-368a-491b-865c-de11f230624f
# ╠═55f97f94-4624-4f9b-a22f-6f2eeed07dd3
# ╟─7873d85c-33c1-44a4-b419-ba3d84632f86
# ╠═5d3f2ab7-072d-43c4-9ff4-3f684eb59aa2
# ╟─a2a8baa8-b8db-42e2-b9a7-46ab524ee333
# ╠═2e0e1c4e-d7cd-4a92-ac1a-a1933b026d70
# ╠═26d219a8-6508-4959-86b3-89f4bdd8422e
# ╠═81a95524-6c14-480c-be33-bafde878a610
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
