### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ e59f34b1-44ef-498d-bd44-7a83985674bb
begin
	include("pmf.jl")
	import .ProbabilityMassFunction as pmf
end

# ╔═╡ 846f457a-b205-11ed-0734-f92538cec098
md"""# Chapter 5. Estimating Counts
[Link to chapter online](https://allendowney.github.io/ThinkBayes2/chap05.html)
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
end

# ╔═╡ 732ecfa0-b3a2-4892-81ef-334dee711a9c
PlutoUI.TableOfContents(depth=4)

# ╔═╡ 5da35a4b-bc8c-412c-89c8-16e46fd7f067
md"""## Code from chapter"""

# ╔═╡ 974927a3-d876-459e-b2a0-9db0def9e4f9
md"""### The Train Problem

...the train problem in Frederick Mosteller’s, [Fifty Challenging Problems in Probability with Solutions](https://store.doverpublications.com/0486653552.html):

'A railroad numbers its locomotives in order 1..N. One day you see a locomotive with the number 60. Estimate how many locomotives the railroad has.'

To apply Bayesian reasoning, we can break this problem into two steps:
- What did we know about N before we saw the data?
- For any given value of N, what is the likelihood of seeing the data (a locomotive with number 60)?

The answer to the first question is the prior. The answer to the second is the likelihood.
"""

# ╔═╡ ac9a468e-338c-4e7f-a62b-939eee7e4ff4
train = pmf.mk_pmf_from_seq(Vector{Int}(1:1000));

# ╔═╡ 897422c5-9e8c-420f-827b-dca40bca8f3d
function update_train!(train::pmf.Pmf{Int}, data::Int)
	hypos = train.names
	likelihood = 1 ./ hypos
	impossible = (data .> hypos)
	likelihood[impossible] .= 0
	train.likelihoods .*= likelihood
	pmf.calculate_posteriors!(train)
end

# ╔═╡ 897f4955-5c66-43be-acb1-bd4ac4f65d11
begin
	no_of_locomotive = 60
	update_train!(train, no_of_locomotive)
end;

# ╔═╡ 3417113f-e5ca-4303-a996-782e23e20d9c
pmf.draw_posteriors(train, "Posterior distribution no of locomotives",
	"Number of trains", "PMF", "Posterior after spotting train 60")

# ╔═╡ d7fc0874-bdcc-44b4-a5d6-84a1bcf7c5a7
pmf.get_name_max_posterior(train)

# ╔═╡ 520e0520-4b6a-4ada-b792-3fe30a4c932e
function get_mean_posterior(pmf_struct::pmf.Pmf{<:Union{Int, Float64}})::Float64
	return sum(pmf_struct.posteriors .* pmf_struct.names)
end

# ╔═╡ 69fedbfe-2a46-4bdf-af0f-4e1bc0f6f758
get_mean_posterior(train)

# ╔═╡ f8289553-3628-47db-9158-b07b5a4d04d7
md"""### Sensitivity to the Prior"""

# ╔═╡ 9c75478f-721f-4f7c-b793-d98abd7c46ac
begin
	upper_bounds1 = [500, 1000, 2000]
	mean_posteriors1 = []

	for high in upper_bounds1
		t1 = pmf.mk_pmf_from_seq(collect(1:high))
		update_train!(t1, 60)
		push!(mean_posteriors1, get_mean_posterior(t1))
	end

	pd.DataFrame((;upper_bounds1, mean_posteriors1))
end

# ╔═╡ ac0043ac-6ba0-4976-85c8-99bbd473e50e
md"When the posterior is sensitive to the prior, there are two ways to proceed:
- Get more data.
- Get more background information and choose a better prior.
"

# ╔═╡ 41384ccf-81b3-4c2a-ac4b-73b672271a53
begin
	dataset2 = [30, 60, 90]
	upper_bounds2 = [500, 1000, 2000]
	mean_posteriors2 = []

	for high in upper_bounds2
		t2 = pmf.mk_pmf_from_seq(collect(1:high))
		for d in dataset2
			update_train!(t2, d)
		end
		push!(mean_posteriors2, get_mean_posterior(t2))
	end

	pd.DataFrame((;upper_bounds2, mean_posteriors2))
end

# ╔═╡ 3b4e907b-b971-4760-927c-eb34d1b76921
md"""### Power Law Prior

This law suggests that if there are 1000 companies with fewer than 10 locomotives, there might be 100 companies with 100 locomotives, 10 companies with 1000, and possibly one company with 10,000 locomotives.

Mathematically, a power law means that the number of companies with a given size, `N`, is proportional to $(1/N)^{\alpha}$, where $\alpha$ is a parameter that is often near 1.
"""

# ╔═╡ f644bb99-04c9-4f34-ae62-5a9436695873
function get_no_of_companies_by_power_law(hypos::Vector{Int}; alpha::Float64=1.0)::Vector{Float64}
	return 1 ./ hypos .^(alpha)
end

# ╔═╡ 911b3f25-572c-4e59-b027-0bdd825426d7
begin
	priors2 = get_no_of_companies_by_power_law(collect(1:1000))
	priors2 = priors2 ./ sum(priors2)
	train2 = pmf.Pmf(collect(1:1000), priors2)
end;

# ╔═╡ 8f3868aa-beb6-4a3c-ad74-a78a42aadcbd
begin
	pmf.draw_priors(train, "Prior distributions", "Number of trains", "PMF", "uniform dist")
	plts.plot!(train2.names, train2.priors, label="power law")
end

# ╔═╡ c3da9f04-192c-4b3b-ac96-fda61e13c071
update_train!(train2, no_of_locomotive);

# ╔═╡ 155c2bcc-344a-4f30-82b0-accf62f8d381
begin
	pmf.draw_posteriors(train, "Posterior distributions\nafter seeing locomotive no. 60", "Number of trains", "PMF", "uniform priors")
	plts.plot!(train2.names, train2.posteriors, label="power law priors")
end

# ╔═╡ 8da26b37-47b9-42df-9bee-716bfe4528f1
begin
	dataset3 = [30, 60, 90]
	upper_bounds3 = [500, 1000, 2000]
	mean_posteriors3 = []
	t3 = pmf.Pmf(collect(1:100), 1:100)

	for high in upper_bounds3
		posteriors3 = get_no_of_companies_by_power_law(collect(1:high))
		t3 = pmf.Pmf(collect(1:high), posteriors3 ./ sum(posteriors3))
		for d in dataset3
			update_train!(t3, d)
		end
		push!(mean_posteriors3, get_mean_posterior(t3))
	end

	pd.DataFrame((;upper_bounds3, mean_posteriors3))
end

# ╔═╡ fae71039-91c3-43c1-b705-55b7579f3639
md"""### Credible Intervals"""

# ╔═╡ d06e3ee1-ac43-4405-b141-d1aee99483ac
function get_name_for_quantile(pmf_struct::pmf.Pmf{<:Union{Int, Float64}}, cum_posterior_prob::Float64)::Union{Int, Float64}
	@assert (0 <= cum_posterior_prob <= 1)
	total::Float64 = 0
	for i in eachindex(pmf_struct.names)
		total += pmf_struct.posteriors[i]
		if total >= cum_posterior_prob
			return pmf_struct.names[i]
		end
	end
	return nothing
end

# ╔═╡ 8ec8c7c1-b2b5-4072-9bd7-b8a5c372e521
function get_name_for_quantile(pmf_struct::pmf.Pmf{<:Union{Int, Float64}}, cum_posterior_probs::Vector{Float64})::Vector{<:Union{Int, Float64}}
	return [get_name_for_quantile(pmf_struct, p) for p in cum_posterior_probs]
end

# ╔═╡ af56f241-4077-43c8-902e-6cab28bff929
get_name_for_quantile(t3, 0.5)

# ╔═╡ c2c4f8ab-ada0-4b7c-9c8a-8befb22f23fe
get_name_for_quantile(t3, [0.05, 0.95])

# ╔═╡ 1e3b42aa-5d26-4daf-af62-ba561eb7db03
function get_credible_interval(pmf_struct::pmf.Pmf{<:Union{Int, Float64}}, prob::Float64)::Vector{<:Union{Int, Float64}}
	@assert (0 <= prob <= 1)
	half_prob::Float64 = prob / 2
	return get_name_for_quantile(pmf_struct, [0.5 - half_prob, 0.5 + half_prob])
end

# ╔═╡ 30acee30-58a1-4ff8-9de7-e02aa353f8cb
get_credible_interval(t3, 0.9)

# ╔═╡ 74116b5b-9eb6-4c65-bf0c-4b2cee05b257
get_credible_interval(t3, 0.95)

# ╔═╡ c9c4f5c2-d41d-447e-9cf8-2f3ea3b918af
md"""### The German Tank Problem

During World War II The Wester Allies used statistics like in the train problem to determine the production of german tanks.

See: [the Wikipedia page](https://en.wikipedia.org/wiki/German_tank_problem)
"""

# ╔═╡ 49f25152-5581-4b3b-9daa-0c3664c60734
md"""### Informative Priors

Among Bayesians, there are two approaches to choosing prior distributions:
- informative priors
- uninformative priors

Informative priors might seem arbitrary. Uninformative priors give illusion of objectivity.

If you have a lot of data, the choice of the prior doesn’t matter; informative and uninformative priors yield almost the same results. If you don’t have much data, using relevant background information (like the power law distribution) makes a big difference.

And if, as in the German tank problem, you have to make life and death decisions based on your results, you should probably use all of the information at your disposal, rather than maintaining the illusion of objectivity by pretending to know less than you do.
"""

# ╔═╡ 31246ebf-ddb1-4576-9f97-db6f88393a94
md"""## Exercises"""

# ╔═╡ b906b25b-24c8-4bf5-9e0f-0c8c663c8042
md"""### Exercise 1

Suppose you are giving a talk in a large lecture hall and the fire marshal interrupts because they think the audience exceeds 1200 people, which is the safe capacity of the room.

You think there are fewer then 1200 people, and you offer to prove it. It would take too long to count, so you try an experiment:
- You ask how many people were born on May 11 and two people raise their hands.
- You ask how many were born on May 23 and 1 person raises their hand.
- Finally, you ask how many were born on August 1, and no one raises their hand.

How many people are in the audience? What is the probability that there are more than 1200 people.

**Hint**: Remember the binomial distribution.
"""

# ╔═╡ 12d746e7-2764-484e-b136-d0c4084cd755
md"""#### Ex1. Reasoning

Let's say (assume) that a year have always 365 days (no leap years) and that we can have in the lecture hall from 365 people (we would not confuse less than that with 1200 or more) to roughly 2*1200 people (otherwise it is clearly more than 1200).

So my assumptions are:
- there are from 365 people, up to 2400 people
- each of those numbers is equally likely.

If so, then the priors look like:
"""

# ╔═╡ 3256d1e4-ac91-4842-8164-aa701e94d24d
ex1 = pmf.mk_pmf_from_seq(collect(365:2400));

# ╔═╡ a78e3c88-cd83-43a0-8192-ef08f36a2a6f
md"Now according to the hint I should use some binomial functions.

From [Distributions package](https://juliastats.org/Distributions.jl/stable/) we got:
- `Distributions.Binomial(n, p)`
- `Distributions.pdf(d::UnivariateDistribution, x::Real)`

`p` is probability of choosing a person born at any day of the year (so 1/365)

`n` is the number of people in the lecture hall (365:2400)

`x` is the number of people born at a given day that were chosen at random (k in binomial distribution)

Since I got 2 times May 11, 1 time May 23, and 0 times August 1, then I will multiply the probabilities
"

# ╔═╡ 680f3a55-f716-40d7-8e86-b14f8b0b98da
md"""#### Ex1. Solution"""

# ╔═╡ 70c1c088-22ac-4875-be40-9a01bdf7283f
begin
	for x in [0, 1, 2]
		ex1.likelihoods .*= dst.pdf.(dst.Binomial.(ex1.names, 1/365), x)
	end
	pmf.calculate_posteriors!(ex1)
end;

# ╔═╡ 68b34a97-f178-4845-acc5-fe4e09900fb8
pmf.draw_posteriors(ex1, "Posterior distribution of\nnum. of people in the lecture hall", "Num. of people in the lecture hall", "PMF", "posteriors")

# ╔═╡ 10b608ee-179e-40bf-b42e-4cdd64eb583a
pmf.get_name_max_posterior(ex1)

# ╔═╡ 89cc98c1-63b6-4de2-a1ac-d795fe1e7d84
get_mean_posterior(ex1)

# ╔═╡ 7fc87f8c-6a09-4f7a-981c-eadbc343a94c
get_credible_interval(ex1, 0.95)

# ╔═╡ 592a45a1-1fd6-4f2f-891d-f0ecfa7aefa6
md"""Probability of more than 1200 people in the lecture hall is:"""

# ╔═╡ b95a2c7f-9f12-4824-bc87-37a8cd7f9e27
sum(ex1.posteriors[findfirst(x -> x == 1201, ex1.names):end])

# ╔═╡ a187248f-e3f3-43d4-b563-6db158723316
md"""### Exercise 2

I often see rabbits in the garden behind my house, but it’s not easy to tell them apart, so I don’t really know how many there are.

Suppose I deploy a motion-sensing camera trap that takes a picture of the first rabbit it sees each day. After three days, I compare the pictures and conclude that two of them are the same rabbit and the other is different.

How many rabbits visit my garden?

To answer this question, we have to think about the prior distribution and the likelihood of the data:
- I have sometimes seen four rabbits at the same time, so I know there are at least that many. I would be surprised if there were more than 10. So, at least as a starting place, I think a uniform prior from 4 to 10 is reasonable.
- To keep things simple, let’s assume that all rabbits who visit my garden are equally likely to be caught by the camera trap in a given day. Let’s also assume it is guaranteed that the camera trap gets a picture every day.
"""

# ╔═╡ bbf7a43f-8b8b-4465-8626-6ed13d23296d
ex2 = pmf.mk_pmf_from_seq(collect(4:10));

# ╔═╡ d4e29859-ddf4-40fb-967e-1f53c730ca9c
md"#### Ex2. Resoning

What are the likelihoods, so P(D|H)?

<<<Let’s also assume it is guaranteed that the camera trap gets a picture every day.>>
So every day either I got a rabbit or I don't, but I got a picture (So, 0 or 1 rabbits).

Let's say that there are 4 rabbits so what is a probability that I get:
- 2x rabbit A, 1x rabbit B from three days observation (1 rabbit at a day)

So, I can have it on 3 ways:
- (rA and rA and rB) OR
- (rA and rB and rA) OR
- (rB and rA and rA)

All three probabilities are equal to each other.

<<<[...] let’s assume that all rabbits who visit my garden are equally likely to be caught by the camera trap in a given day>>> So, probability of getting any rabbit is 1/4 (if there are 4 rabbits in my garden)

So, the probability of getting: rA and rA and rB is:
1/4 (P getting any rabbit, e.g. rabbit A on day 1) * 1/4 (P getting on day 2 the rabbit from day 1) * 3/4 (P getting some other rabit, e.g. rabbit B on day 3)

So the P(D|H) is $3 * (\frac{1}{4} * \frac{1}{4} * \frac{3}{4})$, or for N rabbits and 3 days:

$3 * [\frac{1}{N} * \frac{1}{N} * (1 - \frac{1}{N})]$
"

# ╔═╡ 20551428-3e31-4d83-ac06-44b92b3d3391
md"#### Ex2. Solution"

# ╔═╡ 58991c12-02e3-40d7-afe4-5fc3f524b993
function get_ex2_likelihood(n::Int)::Float64
	return Float64(3 * (1//n * 1//n * (1 - 1//n)))
end

# ╔═╡ 1d0c2366-1a06-4db4-8b18-48a925d8839f
begin
	ex2.likelihoods = get_ex2_likelihood.(ex2.names)
	pmf.calculate_posteriors!(ex2)
end;

# ╔═╡ 8ba6ecea-14f7-4dc5-a310-627926543b0e
begin
	pmf.draw_posteriors(ex2, "Posterior probability\nspotted: 2*rabbitA, 1*rabbitB", "Number of rabbits in garden", "PMF", "")
	plts.scatter!(ex2.names, ex2.posteriors, label="Posterior for number of rabbits in garden")
end

# ╔═╡ 79a5ea4a-16cc-4b0b-94d8-f6e939c70b56
md"### Exercise 3

Suppose that in the criminal justice system, all prison sentences are either 1, 2, or 3 years, with an equal number of each. One day, you visit a prison and choose a prisoner at random. What is the probability that they are serving a 3-year sentence? What is the average remaining sentence of the prisoners you observe?
"

# ╔═╡ d6c75e08-3c10-44d9-bed2-3984b4513d26
md"#### Ex3. Simulation

First, let's try to solve it with some compter simulation."

# ╔═╡ f53b72a8-1218-4ce3-a587-20c943e41e2b
struct Prisoner
	full_sentence::Int
	remained::Int

	Prisoner(s::Int) = new(s, s)
	Prisoner(s::Int, r::Int) = new(s, r)
end

# ╔═╡ 1015595b-73b5-4647-8634-5ea871309eaa
function reduce_remained(p::Prisoner)::Prisoner
	return Prisoner(p.full_sentence, p.remained-1)
end

# ╔═╡ 9f1b43fd-82c7-47ca-b956-9d4c712cb142
function ex3_run_cycle(prevPris::Vector{Prisoner})::Vector{Prisoner}
	newPris = filter(p->p.remained > 0, [reduce_remained(p) for p in prevPris])
	for s in 1:3
		push!(newPris, Prisoner(s))
	end
	return newPris
end

# ╔═╡ b849ddc4-7c30-44b2-9f36-9b9b530aef3b
function ex3_run_n_cycles(n::Int)::Vector{Prisoner}
	prisoners::Vector{Prisoner} = [Prisoner(s) for s in 1:3]
	for _ in 1:n
		prisoners = ex3_run_cycle(prisoners)
	end
	return prisoners
end

# ╔═╡ bf5342f8-a450-4366-b910-573613d0f1d0
function count_properties(prisoners::Vector{Prisoner}, prop::String)::Dict{Int, Int}
	counts::Dict{Int, Int} = Dict()
	for p in prisoners
		field = getproperty(p, Symbol(prop))
		counts[field] = get(counts, field, 0) + 1
	end
	return counts
end

# ╔═╡ 2abd014c-0b6d-4bff-97d4-c7f757596dbf
# due to the construction of ex3_run_n_cycles with n=3, gives the same result as n=100
ex3_tmp1 = count_properties(ex3_run_n_cycles(3), "full_sentence")

# ╔═╡ 6cd042e1-acd7-48c4-92c6-2fa9ef585b31
# probability of finding a prisoner with given sentence (full_sentence, probability)
[(k, v/sum(values(ex3_tmp1))) for (k, v) in ex3_tmp1]

# ╔═╡ 6c68d24f-8355-40d5-abc3-cacd3d3efd5a
# due to the construction of ex3_run_n_cycles with n=3, gives the same result as n=100
ex3_tmp2 = count_properties(ex3_run_n_cycles(3), "remained")

# ╔═╡ 4958a1a6-7620-4479-a3c7-fa2456d56f58
# average sentence
sum([k*v for (k, v) in ex3_tmp2]) / sum(values(ex3_tmp2))

# ╔═╡ 339b1196-ded0-457c-9068-677aaddafae0
md"#### Ex3. Reasoning

So, probability (based on simulation) it seems that the greater the sentence, the greater the probability of finding a prisoner with that sentence (directly proportional), like:
- P(1) => 1,
- P(2) => 2 * P(1),
- P(3) => 3 * P(1).

The remaining years:
- sentence: 1yr => [1yr]
- sentence: 2yrs => [1yr, 2yrs]
- sentence: 3yrs => [1yr, 2yrs, 3yrs]

So, probability of remaining is 3x1year, 2x2years, 1x3years each divided by 6
"

# ╔═╡ 0f83771f-c088-408f-b32f-63a5090b2757
md"#### Ex3. Solution with PMF"

# ╔═╡ 683670dc-4283-48d8-8cf4-e52ac7411a0a
ex3 = pmf.Pmf(collect(1:3), collect(1:3) ./ sum(1:3))

# ╔═╡ 40737bfd-2c53-44bb-b2a3-8245558298d8
begin
	plts.bar(ex3.names, ex3.priors, label="Priors")
	plts.title!("Probability of finding a prisoner\nwith a given sentence")
	plts.xlabel!("Total sentence [years]")
	plts.ylabel!("PMF")
	plts.xticks!(1:3)
end

# ╔═╡ 1c5b5e86-61bb-481f-913c-776570ace001
ex3_remaining = collect(3:-1:1.0) ./ sum(collect(3:-1:1.0))

# ╔═╡ e63f4a17-b424-473a-883c-b75e24b3473f
begin
	plts.bar(ex3.names, ex3_remaining, label="Posteriors")
	plts.title!("Probability of finding a prisoner\nwith a remaining sentence")
	plts.xlabel!("Remaining sentence [years]")
	plts.ylabel!("PMF")
	plts.xticks!(1:3)
end

# ╔═╡ b8b17db3-987a-4146-aa70-37d53f7255a8
sum([i*v for (i, v) in enumerate(ex3_remaining)])

# ╔═╡ 1a4dd964-d1a6-4562-b264-10b888f065e0
md"### Exercise 4

If I chose a random adult in the U.S., what is the probability that they have a sibling? To be precise, what is the probability that their mother has had at least one other child.

[This article from the Pew Research Center](https://www.pewresearch.org/social-trends/2015/05/07/family-size-among-mothers/) provides some relevant data.

From it, I extracted the following distribution of family size for mothers in the U.S. who were 40-44 years old in 2014:
"

# ╔═╡ b7c7bca4-dea7-4ce8-8822-e1cec53066a7
ex4 = pmf.Pmf(collect(1:4), [22, 41, 24, 14])

# ╔═╡ 72417b17-4601-4adf-884b-b9ca69a6958d
begin
	plts.bar(ex4.names, ex4.priors, legend=false)
	plts.title!("Distribution of family size")
	plts.xlabel!("Number of children")
	plts.ylabel!("PMF")
	plts.xticks!(1:4, ["1", "2", "3", "4+"])
end

# ╔═╡ b122bba5-1042-4b15-bd73-775552665d9a
md"For simplicity, let’s assume that all families in the 4+ category have exactly 4 children."

# ╔═╡ efdcc141-6dd7-4aef-8b71-9b7a545718fb
md"#### Ex4. Reasoning

Hmm, there is one small problem with the data, namely: sum(ex4.priors) = $(sum(ex4.priors)) so, it is more than 100%.

Let's correct that right away, making it add up to 100% or 1.
"

# ╔═╡ 196ba57f-c4e5-4abf-a5c5-7c9929392657
ex4.priors = ex4.priors ./ sum(ex4.priors)

# ╔═╡ 7a4b5968-f558-4cf6-bf58-94c47681790d
sum(ex4.priors)

# ╔═╡ caaf3a48-2674-4310-9ed7-db97ea61f3b2
md"much better."

# ╔═╡ 2d598078-1a33-4724-889e-bb2500451b0d
md"#### Ex4. Solution

OK, so now, let's go for probability.
In the case of prisoners You were more likely to choose a prisoner with a longer sentence, so here You are more likely to choose a person with siblings."

# ╔═╡ 3bda1d60-904c-45b6-ba1c-d1f3335c611b
begin
	ex4.likelihoods = collect(1:4) ./ sum(1:4)
	pmf.calculate_posteriors!(ex4)
end

# ╔═╡ 20fab33b-d6ad-4b05-956d-81e79936fdf3
ex4.posteriors

# ╔═╡ 01c7e0c6-96df-477a-95ab-edcd263848b2
sum(ex4.posteriors[2:end])

# ╔═╡ 3eaf0b6a-9d95-4eda-b04f-37991cdf6ff1
md"""### Exercise 5

The [Doomsday argument](https://en.wikipedia.org/wiki/Doomsday_argument) is “a probabilistic argument that claims to predict the number of future members of the human species given an estimate of the total number of humans born so far.”

Suppose there are only two kinds of intelligent civilizations that can happen in the universe. The “short-lived” kind go exinct after only 200 billion individuals are born. The “long-lived” kind survive until 2,000 billion individuals are born. And suppose that the two kinds of civilization are equally likely. Which kind of civilization do you think we live in?

The Doomsday argument says we can use the total number of humans born so far as data. According to the [Population Reference Bureau](https://www.prb.org/articles/how-many-people-have-ever-lived-on-earth/), the total number of people who have ever lived is about 108 billion.

Since you were born quite recently, let’s assume that you are, in fact, human being number 108 billion. If `N` is the total number who will ever live and we consider you to be a randomly-chosen person, it is equally likely that you could have been person 1, or `N`, or any number in between. So what is the probability that you would be number 108 billion?

Given this data and dubious prior, what is the probability that our civilization will be short-lived?
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
DataFrames = "~1.5.0"
Distributions = "~0.25.81"
Plots = "~1.38.5"
PlutoUI = "~0.7.50"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.3"
manifest_format = "2.0"
project_hash = "88ccaab2c9e087d9fcb28b6a79a4a5d940366c13"

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
git-tree-sha1 = "61fdd77467a5c3ad071ef8277ac6bd6af7dd4c04"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.6.0"

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
git-tree-sha1 = "9258430c176319dc882efa4088e2ff882a0cb1f1"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.81"

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
git-tree-sha1 = "d3ba08ab64bdfd27234d3f61956c966266757fe6"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.7"

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
git-tree-sha1 = "660b2ea2ec2b010bb02823c6d0ff6afd9bdc5c16"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.71.7"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "d5e1fd17ac7f3aa4c5287a61ee28d4f8b8e98873"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.71.7+0"

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
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions", "Test"]
git-tree-sha1 = "709d864e3ed6e3545230601f94e11ebc65994641"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.11"

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
git-tree-sha1 = "82aec7a3dd64f4d9584659dc0b62ef7db2ef3e19"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.2.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

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
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "cf494dca75a69712a72b80bc48f59dcf3dea63ec"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.16"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "6f4fbcd1ad45905a5dee3f4256fabb49aa2110c6"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.7"

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
git-tree-sha1 = "8ac949bd0ebc46a44afb1fdca1094554a84b086e"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.38.5"

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

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "0c03844e2231e12fda4d0086fd7cbe4098ee8dc5"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+2"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "786efa36b7eff813723c4849c90456609cf06661"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.8.1"

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
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

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
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "ab6083f09b3e617e34a956b43e9d51b824206932"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.1.1"

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
git-tree-sha1 = "c79322d36826aa2f4fd8ecfa96ddb47b174ac78d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.0"

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
# ╟─974927a3-d876-459e-b2a0-9db0def9e4f9
# ╠═ac9a468e-338c-4e7f-a62b-939eee7e4ff4
# ╠═897422c5-9e8c-420f-827b-dca40bca8f3d
# ╠═897f4955-5c66-43be-acb1-bd4ac4f65d11
# ╠═3417113f-e5ca-4303-a996-782e23e20d9c
# ╠═d7fc0874-bdcc-44b4-a5d6-84a1bcf7c5a7
# ╠═520e0520-4b6a-4ada-b792-3fe30a4c932e
# ╠═69fedbfe-2a46-4bdf-af0f-4e1bc0f6f758
# ╟─f8289553-3628-47db-9158-b07b5a4d04d7
# ╠═9c75478f-721f-4f7c-b793-d98abd7c46ac
# ╟─ac0043ac-6ba0-4976-85c8-99bbd473e50e
# ╠═41384ccf-81b3-4c2a-ac4b-73b672271a53
# ╟─3b4e907b-b971-4760-927c-eb34d1b76921
# ╠═f644bb99-04c9-4f34-ae62-5a9436695873
# ╠═911b3f25-572c-4e59-b027-0bdd825426d7
# ╠═8f3868aa-beb6-4a3c-ad74-a78a42aadcbd
# ╠═c3da9f04-192c-4b3b-ac96-fda61e13c071
# ╠═155c2bcc-344a-4f30-82b0-accf62f8d381
# ╠═8da26b37-47b9-42df-9bee-716bfe4528f1
# ╟─fae71039-91c3-43c1-b705-55b7579f3639
# ╠═d06e3ee1-ac43-4405-b141-d1aee99483ac
# ╠═8ec8c7c1-b2b5-4072-9bd7-b8a5c372e521
# ╠═af56f241-4077-43c8-902e-6cab28bff929
# ╠═c2c4f8ab-ada0-4b7c-9c8a-8befb22f23fe
# ╠═1e3b42aa-5d26-4daf-af62-ba561eb7db03
# ╠═30acee30-58a1-4ff8-9de7-e02aa353f8cb
# ╠═74116b5b-9eb6-4c65-bf0c-4b2cee05b257
# ╟─c9c4f5c2-d41d-447e-9cf8-2f3ea3b918af
# ╟─49f25152-5581-4b3b-9daa-0c3664c60734
# ╟─31246ebf-ddb1-4576-9f97-db6f88393a94
# ╟─b906b25b-24c8-4bf5-9e0f-0c8c663c8042
# ╟─12d746e7-2764-484e-b136-d0c4084cd755
# ╠═3256d1e4-ac91-4842-8164-aa701e94d24d
# ╟─a78e3c88-cd83-43a0-8192-ef08f36a2a6f
# ╟─680f3a55-f716-40d7-8e86-b14f8b0b98da
# ╠═70c1c088-22ac-4875-be40-9a01bdf7283f
# ╠═68b34a97-f178-4845-acc5-fe4e09900fb8
# ╠═10b608ee-179e-40bf-b42e-4cdd64eb583a
# ╠═89cc98c1-63b6-4de2-a1ac-d795fe1e7d84
# ╠═7fc87f8c-6a09-4f7a-981c-eadbc343a94c
# ╟─592a45a1-1fd6-4f2f-891d-f0ecfa7aefa6
# ╠═b95a2c7f-9f12-4824-bc87-37a8cd7f9e27
# ╟─a187248f-e3f3-43d4-b563-6db158723316
# ╠═bbf7a43f-8b8b-4465-8626-6ed13d23296d
# ╟─d4e29859-ddf4-40fb-967e-1f53c730ca9c
# ╟─20551428-3e31-4d83-ac06-44b92b3d3391
# ╠═58991c12-02e3-40d7-afe4-5fc3f524b993
# ╠═1d0c2366-1a06-4db4-8b18-48a925d8839f
# ╠═8ba6ecea-14f7-4dc5-a310-627926543b0e
# ╟─79a5ea4a-16cc-4b0b-94d8-f6e939c70b56
# ╟─d6c75e08-3c10-44d9-bed2-3984b4513d26
# ╠═f53b72a8-1218-4ce3-a587-20c943e41e2b
# ╠═1015595b-73b5-4647-8634-5ea871309eaa
# ╠═9f1b43fd-82c7-47ca-b956-9d4c712cb142
# ╠═b849ddc4-7c30-44b2-9f36-9b9b530aef3b
# ╠═bf5342f8-a450-4366-b910-573613d0f1d0
# ╠═2abd014c-0b6d-4bff-97d4-c7f757596dbf
# ╠═6cd042e1-acd7-48c4-92c6-2fa9ef585b31
# ╠═6c68d24f-8355-40d5-abc3-cacd3d3efd5a
# ╠═4958a1a6-7620-4479-a3c7-fa2456d56f58
# ╟─339b1196-ded0-457c-9068-677aaddafae0
# ╟─0f83771f-c088-408f-b32f-63a5090b2757
# ╠═683670dc-4283-48d8-8cf4-e52ac7411a0a
# ╠═40737bfd-2c53-44bb-b2a3-8245558298d8
# ╠═1c5b5e86-61bb-481f-913c-776570ace001
# ╠═e63f4a17-b424-473a-883c-b75e24b3473f
# ╠═b8b17db3-987a-4146-aa70-37d53f7255a8
# ╟─1a4dd964-d1a6-4562-b264-10b888f065e0
# ╠═b7c7bca4-dea7-4ce8-8822-e1cec53066a7
# ╠═72417b17-4601-4adf-884b-b9ca69a6958d
# ╟─b122bba5-1042-4b15-bd73-775552665d9a
# ╟─efdcc141-6dd7-4aef-8b71-9b7a545718fb
# ╠═196ba57f-c4e5-4abf-a5c5-7c9929392657
# ╠═7a4b5968-f558-4cf6-bf58-94c47681790d
# ╟─caaf3a48-2674-4310-9ed7-db97ea61f3b2
# ╟─2d598078-1a33-4724-889e-bb2500451b0d
# ╠═3bda1d60-904c-45b6-ba1c-d1f3335c611b
# ╠═20fab33b-d6ad-4b05-956d-81e79936fdf3
# ╠═01c7e0c6-96df-477a-95ab-edcd263848b2
# ╟─3eaf0b6a-9d95-4eda-b04f-37991cdf6ff1
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
