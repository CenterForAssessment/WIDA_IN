#################################################################
###
### Script to add variables to WIDA Indiana for 2022 reporting
###
#################################################################

### Load packages
require(SGP)
require(data.table)


### Load Data
load("Data/WIDA_IN_SGP.Rdata")
load("Data/WIDA_IN_SGP_WIDE_Data.Rdata")

### Create variables
impact.levels <- c("Increased Likelihood of Large to Severe COVID Related Academic Impact", "Increased Likelihood of Moderate COVID Related Academic Impact", "Increased Likelihood of Modest to No COVID Related Academic Impact")
recovery.levels.list <- list()
large.impact.recovery.levels <- c("Large 2019 to 2021 impact followed by low rates of learning in 2022", "Large impact followed by typical rates of learning in 2022", "Large impact followed by high rates of learning in 2022")
moderate.impact.recovery.levels <- c("Moderate 2019 to 2021 impact followed by low rates of learning in 2022", "Moderate impact followed by typical rates of learning in 2022", "Moderate impact followed by high rates of learning in 2022")
no.impact.recovery.levels <- c("Modest to no 2019 to 2021 impact followed by low rates of learning in 2022", "Modest to no impact followed by typical rates of learning in 2022", "Modest to no impact followed by high rates of learning in 2022")
recovery.levels.list[[1]] <- large.impact.recovery.levels
recovery.levels.list[[2]] <- moderate.impact.recovery.levels
recovery.levels.list[[3]] <- no.impact.recovery.levels

### Add variables
for (impact.levels.iter in seq_along(impact.levels)) {
    WIDA_IN_SGP_WIDE_Data[SGP_LEVEL_COVID_IMPACT.2021.READING==impact.levels[impact.levels.iter] & SGP_BASELINE.2022.READING < 30, SGP_LEVEL_COVID_IMPACT.2022.READING:=recovery.levels.list[[impact.levels.iter]][1]]
    WIDA_IN_SGP_WIDE_Data[SGP_LEVEL_COVID_IMPACT.2021.READING==impact.levels[impact.levels.iter] & SGP_BASELINE.2022.READING >= 30 & SGP_BASELINE.2022.READING <= 70, SGP_LEVEL_COVID_IMPACT.2022.READING:=recovery.levels.list[[impact.levels.iter]][2]]
    WIDA_IN_SGP_WIDE_Data[SGP_LEVEL_COVID_IMPACT.2021.READING==impact.levels[impact.levels.iter] & SGP_BASELINE.2022.READING > 70, SGP_LEVEL_COVID_IMPACT.2022.READING:=recovery.levels.list[[impact.levels.iter]][3]]
}

WIDA_IN_SGP_WIDE_Data[, SGP_TARGET_BASELINE_RECOVERY_4_YEAR.2022.READING:=SGP_TARGET_BASELINE_RECOVERY_4_YEAR.2021.READING+(SGP_TARGET_BASELINE_RECOVERY_4_YEAR.2021.READING-SGP_BASELINE.2022.READING)/2]


### Create a LONG data file to merge into @Data 

tmp.read <- WIDA_IN_SGP_WIDE_Data[,c("ID", "SGP_LEVEL_COVID_IMPACT.2022.READING", "SGP_TARGET_BASELINE_RECOVERY_4_YEAR.2022.READING")][,CONTENT_AREA:="READING"][,VALID_CASE:="VALID_CASE"][,YEAR:="2022"][!is.na(SGP_LEVEL_COVID_IMPACT.2022.READING) | !is.na(SGP_TARGET_BASELINE_RECOVERY_4_YEAR.2022.READING)]
setnames(tmp.read, 2:3, c("SGP_LEVEL_COVID_IMPACT", "SGP_TARGET_BASELINE_RECOVERY_4_YEAR"))
setkey(tmp.read, VALID_CASE, CONTENT_AREA, YEAR, ID)

### Merge in additional variables
tmp.copy <- copy(WIDA_IN_SGP@Data)
setkey(tmp.copy, VALID_CASE, CONTENT_AREA, YEAR, ID)

variables.to.merge <- c("SGP_LEVEL_COVID_IMPACT", "SGP_TARGET_BASELINE_RECOVERY_4_YEAR")
tmp.index <- tmp.copy[tmp.read[,c("VALID_CASE", "CONTENT_AREA", "YEAR", "ID"), with=FALSE], which=TRUE, on=key(tmp.read)]
tmp.copy[tmp.index, (variables.to.merge):=tmp.read[, variables.to.merge, with=FALSE]]

WIDA_IN_SGP@Data <- tmp.copy 

### Save object
save(WIDA_IN_SGP, file="Data/WIDA_IN_SGP.Rdata")

### outputSGP
outputSGP(WIDA_IN_SGP)
