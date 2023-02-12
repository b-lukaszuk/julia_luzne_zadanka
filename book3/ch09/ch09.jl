import DataFrames as pd # pandas in python
import Distributions as dst
import Statistics as stat
import HypothesisTests as ht


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
    (; daily_intake_kJ=[5260, 5470, 5640, 6180, 6390, 6515, 6805, 7515, 7515, 8230, 8770])
)
stat.std(tab91[!, "daily_intake_kJ"])
stat.mean(tab91[!, "daily_intake_kJ"])

ht.OneSampleTTest(tab91[!, "daily_intake_kJ"], 7725)
ht.SignTest(tab91[!, "daily_intake_kJ"], 7725) # test with continuity correction
ht.SignedRankTest(tab91[!, "daily_intake_kJ"] .- 7725)
# to get p-value itself from a test:
# x = ht.SignedRankTest(tab91[!, "daily_intake_kJ"] .- 7725)
# ht.pvalue(x)


##########################################
# Ch 9.5 TWO GROUPS OF PAIRED OBSERVATIONS
##########################################
tab93 = pd.DataFrame(
    (; intake_kJ_premenopause=[5260, 5470, 5640, 6180, 6390, 6515, 6805, 7515, 7515, 8230, 8770],
    intake_kJ_postmenopause=[3910, 4220, 3885, 5160, 5645, 4680, 5265, 5975, 6790, 6900, 7335]
))

ht.OneSampleTTest(tab93[!, :intake_kJ_premenopause], tab93[!, :intake_kJ_postmenopause])
ht.SignTest(tab93[!, :intake_kJ_premenopause] .- tab93[!, :intake_kJ_postmenopause])
ht.SignedRankTest(tab93[!, :intake_kJ_premenopause] .- tab93[!, :intake_kJ_postmenopause])


###############################################
# Ch 9.6 TWO INDEPENDENT GROUPS OF OBSERVATIONS
###############################################
# table 9.4. 24 hour total energy expenditure (MJ/day)
# in groups of lean and obese women (Prentice et al., 1986)
tab94_lean = [6.13, 7.05, 7.48, 7.48, 7.53, 7.58, 7.9, 8.08, 8.09, 8.11, 8.40, 10.15, 10.88]
tab94_obese = [8.79, 9.19, 9.21, 9.68, 9.69, 9.97, 11.51, 11.85, 12.79]

ht.LeveneTest(tab94_lean, tab94_obese)
ht.EqualVarianceTTest(tab94_lean, tab94_obese)
ht.MannWhitneyUTest(tab94_lean, tab94_obese)

# table 9.6  Serum thyroxine level (nmol/l) in 16 hypothyroid infants by
# severity of symptoms (Hulse et al., 1979)
tab96_sligth_or_none = [34, 45, 49, 55, 58, 59, 60, 62, 86]
tab96_marked = [5, 8, 18, 24, 60, 84, 96]

ht.LeveneTest(tab96_sligth_or_none, tab96_marked)
# it seems that the HypothesisTests library has no Shapiro-Wilk test implemented
ht.ExactOneSampleKSTest(tab96_marked,
    dst.Normal(stat.mean(tab96_marked), stat.std(tab96_marked)))
ht.ExactOneSampleKSTest(tab96_sligth_or_none,
    dst.Normal(stat.mean(tab96_sligth_or_none), stat.std(tab96_sligth_or_none)))
ht.UnequalVarianceTTest(tab96_sligth_or_none, tab96_marked)
