import DataFrames as pd # pandas in python
import Distributions as dst
import HypothesisTests as ht
import MultipleTesting as mt
import Statistics as stat


#########
# Warning
#########
#########################################################################################
# NO GUARANTEE THAT THE SOLUTIONS WILL WORK OR WORK CORRECTLY! USE THEM AT YOUR OWN RISK!
# THE ANSWERS PROVIDED BELOW MAY BE WRONG. USE THEM AT YOUR OWN RISK!
#########################################################################################

##################################
# Ch 9.4 ONE GROUP OF OBSERVATIONS
##################################
tab91 = pd.DataFrame(
    (; dailyIntakeKJ=[5260, 5470, 5640, 6180, 6390, 6515, 6805, 7515, 7515, 8230, 8770])
)
stat.std(tab91[!, "dailyIntakeKJ"])
stat.mean(tab91[!, "dailyIntakeKJ"])

ht.OneSampleTTest(tab91[!, "dailyIntakeKJ"], 7725)
ht.SignTest(tab91[!, "dailyIntakeKJ"], 7725) # test with continuity correction
ht.SignedRankTest(tab91[!, "dailyIntakeKJ"] .- 7725)
# to get p-value itself from a test:
# x = ht.SignedRankTest(tab91[!, "daily_intake_kJ"] .- 7725)
# ht.pvalue(x)


##########################################
# Ch 9.5 TWO GROUPS OF PAIRED OBSERVATIONS
##########################################
tab93 = pd.DataFrame(
    (; intakeKJPremenopause=[5260, 5470, 5640, 6180, 6390, 6515, 6805, 7515, 7515, 8230, 8770],
    intakeKJPostmenopause=[3910, 4220, 3885, 5160, 5645, 4680, 5265, 5975, 6790, 6900, 7335]
))

ht.OneSampleTTest(tab93[!, :intakeKJPremenopause], tab93[!, :intakeKJPostmenopause])
ht.SignTest(tab93[!, :intakeKJPremenopause] .- tab93[!, :intakeKJPostmenopause])
ht.SignedRankTest(tab93[!, :intakeKJPremenopause] .- tab93[!, :intakeKJPostmenopause])


###############################################
# Ch 9.6 TWO INDEPENDENT GROUPS OF OBSERVATIONS
###############################################
# table 9.4. 24 hour total energy expenditure (MJ/day)
# in groups of lean and obese women (Prentice et al., 1986)
tab94Lean = [6.13, 7.05, 7.48, 7.48, 7.53, 7.58, 7.9, 8.08, 8.09, 8.11, 8.40, 10.15, 10.88]
tab94Obese = [8.79, 9.19, 9.21, 9.68, 9.69, 9.97, 11.51, 11.85, 12.79]

ht.LeveneTest(tab94Lean, tab94Obese)
ht.EqualVarianceTTest(tab94Lean, tab94Obese)
ht.MannWhitneyUTest(tab94Lean, tab94Obese)

# table 9.6  Serum thyroxine level (nmol/l) in 16 hypothyroid infants by
# severity of symptoms (Hulse et al., 1979)
tab96SligthOrNone = [34, 45, 49, 55, 58, 59, 60, 62, 86]
tab96Marked = [5, 8, 18, 24, 60, 84, 96]

ht.LeveneTest(tab96SligthOrNone, tab96Marked)
# it seems that the HypothesisTests library has no Shapiro-Wilk test implemented
ht.ExactOneSampleKSTest(tab96Marked,
    dst.Normal(stat.mean(tab96Marked), stat.std(tab96Marked)))
ht.ExactOneSampleKSTest(tab96SligthOrNone,
    dst.Normal(stat.mean(tab96SligthOrNone), stat.std(tab96SligthOrNone)))
ht.UnequalVarianceTTest(tab96SligthOrNone, tab96Marked)


#########################################################
# CH 9.8 THREE OR MORE INDEPENDENT GROUPS OF OBSERVATIONS
#########################################################
# table 9.10 Red cell folate levels (ug/l) in three groups of cardiac
# bypass patients given different levels of nitrous oxide ventilation (Ames et al., 1978)
tab910 = pd.DataFrame(
    (; follate=[243, 251, 275, 291, 347, 354, 380, 392, 206, 210, 226, 249, 255, 273, 285, 295, 309, 241, 258, 270, 293, 328],
    gr=vcat(fill.(["gr1", "gr2", "gr3"], [8, 9, 5])...)
))

function splitByGroup(values::Vector{<:Number}, groups::Vector{String})::Dict{String,Vector{<:Number}}
    grNames::Vector{String} = unique(groups)
    result::Dict{String,Vector{<:Number}} = Dict()
    for gr in grNames
        result[gr] = values[findall(x -> x == gr, groups)]
    end
    return result
end

function dict2namedTuple(d::Dict{String,Vector{<:Number}})
    return NamedTuple(Symbol(k) => v for (k, v) in d)
end

splitByGroup(tab910[!, "follate"], tab910[!, "gr"]) |> dict2namedTuple |>
x -> ht.OneWayANOVATest(x...)

function pairwiseTTest(vals::Vector{<:Number}, grs::Vector{<:String},
    adjust::Bool=true, adjustmentMt=mt.BenjaminiHochberg
)::Dict{String,Float64}
    grouped::Dict{String,Vector{<:Number}} = splitByGroup(vals, grs)
    groups::Vector{String} = collect(keys(grouped))
    comparisons::Vector{String} = []
    pValues::Vector{Float64} = []
    for i in eachindex(groups)
        for j in (i+1):length(groups)
            gi, gj = groups[i], groups[j]
            eqvars = ht.pvalue(ht.LeveneTest(grouped[gi], grouped[gj])) >= 0.05
            push!(comparisons, "$(gi) vs. $(gj)")
            (eqvars ? ht.EqualVarianceTTest(grouped[gi], grouped[gj]) : ht.UnequalVarianceTTest(grouped[gi], grouped[gj])) |>
            ht.pvalue |> x -> push!(pValues, x)
        end
    end
    if adjust
        pValues = mt.adjust(pValues, adjustmentMt())
    end
    return Dict(k => v for (k, v) in zip(comparisons, pValues))
end

pairwiseTTest(tab910[!, "follate"], tab910[!, "gr"], true, mt.Bonferroni)

# table91.5. Reduction i weekly headache activity for three treatement groups,
# expressed as a percentage of baseline data (fentress et al., 1986)
tab915 = pd.DataFrame(
    (; relaxFeedback=[62, 74, 86, 74, 91, 37],
    relax=[69, 43, 100, 94, 100, 98],
    untreated=[50, -120, 100, -288, 4, -76])
)

ht.KruskalWallisTest(tab915[!, :relaxFeedback], tab915[!, :relax],
    tab915[!, :untreated])
