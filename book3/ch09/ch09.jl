import DataFrames as pd # pandas in python
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
