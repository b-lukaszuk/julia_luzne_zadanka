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
