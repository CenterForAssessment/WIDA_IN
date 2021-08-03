#################################################################
###
### Script to add variables to WIDA_IN_SGP for 2021 reporting
###
#################################################################

### Load packages

require(SGP)
require(data.table)


### Load Data

load("Data/WIDA_IN_SGP.Rdata")


### Add variables
tmp.copy <- copy(WIDA_IN_SGP@Data)
tmp.copy[YEAR=="2021" & SGP_BASELINE <= 30, SGP_LEVEL_COVID_IMPACT:="Increased Likelihood of Large to Severe COVID Related Academic Impact"]
tmp.copy[YEAR=="2021" & SGP_BASELINE > 30 & SGP_BASELINE < 50, SGP_LEVEL_COVID_IMPACT:="Increased Likelihood of Moderate COVID Related Academic Impact"]
tmp.copy[YEAR=="2021" & SGP_BASELINE >= 50, SGP_LEVEL_COVID_IMPACT:="Increased Likelihood of Modest to No COVID Related Academic Impact"]

tmp.copy[YEAR=="2021" & GRADE=="1"  & SGP_BASELINE < 50, SGP_TARGET_BASELINE_RECOVERY_4_YEAR:=50+(50-SGP_BASELINE)/4]
tmp.copy[YEAR=="2021" & GRADE=="2"  & SGP_BASELINE < 50, SGP_TARGET_BASELINE_RECOVERY_4_YEAR:=50+(50-SGP_BASELINE)/4]
tmp.copy[YEAR=="2021" & GRADE=="3"  & SGP_BASELINE < 50, SGP_TARGET_BASELINE_RECOVERY_4_YEAR:=50+(50-SGP_BASELINE)/4]
tmp.copy[YEAR=="2021" & GRADE=="4"  & SGP_BASELINE < 50, SGP_TARGET_BASELINE_RECOVERY_4_YEAR:=50+(50-SGP_BASELINE)/4]
tmp.copy[YEAR=="2021" & GRADE=="5"  & SGP_BASELINE < 50, SGP_TARGET_BASELINE_RECOVERY_4_YEAR:=50+(50-SGP_BASELINE)/4]
tmp.copy[YEAR=="2021" & GRADE=="6" & SGP_BASELINE < 50, SGP_TARGET_BASELINE_RECOVERY_4_YEAR:=50+(50-SGP_BASELINE)/4]
tmp.copy[YEAR=="2021" & GRADE=="7" & SGP_BASELINE < 50, SGP_TARGET_BASELINE_RECOVERY_4_YEAR:=100-SGP_BASELINE/4]
tmp.copy[YEAR=="2021" & GRADE=="8" & SGP_BASELINE < 50, SGP_TARGET_BASELINE_RECOVERY_4_YEAR:=100-SGP_BASELINE/4]
tmp.copy[YEAR=="2021" & GRADE=="9" & SGP_BASELINE < 50, SGP_TARGET_BASELINE_RECOVERY_4_YEAR:=100-SGP_BASELINE/3]
tmp.copy[YEAR=="2021" & GRADE=="10" & SGP_BASELINE < 50, SGP_TARGET_BASELINE_RECOVERY_4_YEAR:=100-SGP_BASELINE/2]
tmp.copy[YEAR=="2021" & GRADE=="11" & SGP_BASELINE < 50, SGP_TARGET_BASELINE_RECOVERY_4_YEAR:=100-SGP_BASELINE]


### Put data back
WIDA_IN_SGP@Data <- tmp.copy


### Save object
save(WIDA_IN_SGP, file="Data/WIDA_IN_SGP.Rdata")

### outputSGP
outputSGP(WIDA_IN_SGP)
