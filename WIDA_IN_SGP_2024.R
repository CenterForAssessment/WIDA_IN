##########################################################################################
###
### Script for calculating SGPs for 2023-2024 WIDA/ACCESS Indiana
###
##########################################################################################

### Load SGP package
require(SGP)


### Load Data
load("Data/WIDA_IN_SGP.Rdata")
load("Data/WIDA_IN_Data_LONG_2024.Rdata")

###   Add single-cohort baseline matrices to SGPstateData
SGPstateData <- SGPmatrices::addBaselineMatrices("WIDA_IN", "2024")

### Run analyses
WIDA_IN_SGP <- updateSGP(
		WIDA_IN_SGP,
		WIDA_IN_Data_LONG_2024,
		steps=c("prepareSGP", "analyzeSGP", "combineSGP", "visualizeSGP", "outputSGP"),
		sgp.percentiles=TRUE,
		sgp.projections=TRUE,
		sgp.projections.lagged=TRUE,
		sgp.percentiles.baseline=TRUE,
		sgp.projections.baseline=TRUE,
		sgp.projections.lagged.baseline=TRUE,
		get.cohort.data.info=TRUE,
		sgp.target.scale.scores=TRUE,
		plot.types=c("growthAchievementPlot", "studentGrowthPlot"),
		sgPlot.demo.report=TRUE,
		parallel.config=list(BACKEND="PARALLEL", WORKERS=list(PERCENTILES=4, BASELINE_PERCENTILES=4, PROJECTIONS=4, LAGGED_PROJECTIONS=4, SGP_SCALE_SCORE_TARGETS=4, GA_PLOTS=1, SG_PLOTS=1)))


### Save results
#save(WIDA_IN_SGP, file="Data/WIDA_IN_SGP.Rdata")
