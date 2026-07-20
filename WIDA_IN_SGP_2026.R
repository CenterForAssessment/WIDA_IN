##########################################################################################
###
### Script for calculating SGPs for 2025-2026 WIDA/ACCESS Indiana
###
##########################################################################################

### Load SGP package
require(SGP)
require(data.table)


### Load Data
load("Data/WIDA_IN_SGP.Rdata")
load("Data/WIDA_IN_Data_LONG_2026.Rdata")

###   Add single-cohort baseline matrices to SGPstateData
SGPstateData <- SGPmatrices::addBaselineMatrices("WIDA_IN", "2026")

### Fix ACHIEVEMENT_LEVEL
WIDA_IN_SGP@Data[ACHIEVEMENT_LEVEL_ORIGINAL %in% c("4.0", "4.1", "4.2"), ACHIEVEMENT_LEVEL:="WIDA Level 4"]
WIDA_IN_SGP@Data[ACHIEVEMENT_LEVEL_ORIGINAL %in% c("4.3", "4.4", "4.5", "4.6", "4.7", "4.8", "4.9"), ACHIEVEMENT_LEVEL:="WIDA Level 4.3"]

### Parameters
parallel.config <- list(BACKEND="MIRAI", WORKERS=list(PERCENTILES=4, BASELINE_PERCENTILES=4, PROJECTIONS=4, LAGGED_PROJECTIONS=4, SGP_SCALE_SCORE_TARGETS=4, GA_PLOTS=1, SG_PLOTS=1))

### Run analyses
WIDA_IN_SGP <- updateSGP(
		WIDA_IN_SGP,
		WIDA_IN_Data_LONG_2026,
		steps=c("prepareSGP", "analyzeSGP", "combineSGP"),
		sgp.percentiles=TRUE,
		sgp.projections=FALSE,
		sgp.projections.lagged=FALSE,
		sgp.percentiles.baseline=FALSE,
		sgp.projections.baseline=FALSE,
		sgp.projections.lagged.baseline=FALSE,
		get.cohort.data.info=TRUE,
		sgp.target.scale.scores=FALSE,
		plot.types=c("growthAchievementPlot", "studentGrowthPlot"),
		sgPlot.demo.report=TRUE,
		save.intermediate.results=FALSE,
		parallel.config=parallel.config)

### Run abcSGP for baseline referenced SGPs
WIDA_IN_SGP@Data[YEAR<"2026", SCALE_SCORE_OLD_SCALE:=SCALE_SCORE]
setnames(WIDA_IN_SGP@Data, c("SCALE_SCORE_OLD_SCALE", "SCALE_SCORE"), c("SCALE_SCORE", "SCALE_SCORE_OLD_SCALE"))
WIDA_IN_SGP <- abcSGP(
		WIDA_IN_SGP,
		steps=c("prepareSGP", "analyzeSGP", "combineSGP"),
		years="2026",
		sgp.percentiles=FALSE,
		sgp.projections=FALSE,
		sgp.projections.lagged=FALSE,
		sgp.percentiles.baseline=TRUE,
		sgp.projections.baseline=TRUE,
		sgp.projections.lagged.baseline=TRUE,
		save.intermediate.results=FALSE,
		sgp.target.scale.scores=TRUE,
		parallel.config=parallel.config)
setnames(WIDA_IN_SGP@Data, c("SCALE_SCORE_OLD_SCALE", "SCALE_SCORE"), c("SCALE_SCORE", "SCALE_SCORE_OLD_SCALE"))

### outputSGP
outputSGP(WIDA_IN_SGP)


### Save results
save(WIDA_IN_SGP, file="Data/WIDA_IN_SGP.Rdata")
