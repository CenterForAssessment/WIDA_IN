#############################################################################
###
### WIDA_IN output format for 2026 scale change
###
#############################################################################

### Load packages
require(data.table)
require(SGP) ### For  Scale Score Transformation Function

### Load data
load("Data/WIDA_IN_SGP_LONG_Data_2026.Rdata")

### Copy the original data to a new variable
WIDA_IN_SGP_LONG_Data_2026_NEW_SCALE <- copy(WIDA_IN_SGP_LONG_Data_2026)

### NULL out cohort referenced targets
all.scale.score.targets <- grep("SCALE_SCORE_SGP_TARGET", names(WIDA_IN_SGP_LONG_Data_2026), value=TRUE)
baseline.referenced.targets <- grep("SCALE_SCORE_SGP_TARGET_BASELINE", names(WIDA_IN_SGP_LONG_Data_2026), value=TRUE)
cohort.referenced.targets <- setdiff(all.scale.score.targets, baseline.referenced.targets)

WIDA_IN_SGP_LONG_Data_2026_NEW_SCALE[, (cohort.referenced.targets) := NULL]

### Transform the first year baseline referenced targets (1 to 5 year span) on OLD_SCALE to 1.0 to 6.0 performance level scale
WIDA_IN_SGP_LONG_Data_2026_NEW_SCALE[YEAR == "2026", PROFICIENCY_LEVEL_SGP_TARGET_BASELINE_5_YEAR_PROJ_YEAR_1_CURRENT_OLD_SCALE:=SGPstateData[['WIDA']][['SGP_Configuration']][['ss_to_pl_function']][['value']](as.character(as.numeric(GRADE)+1), ceiling(SCALE_SCORE_SGP_TARGET_BASELINE_5_YEAR_PROJ_YEAR_1_CURRENT))]
WIDA_IN_SGP_LONG_Data_2026_NEW_SCALE[YEAR == "2026", PROFICIENCY_LEVEL_SGP_TARGET_BASELINE_4_YEAR_PROJ_YEAR_1_CURRENT_OLD_SCALE:=SGPstateData[['WIDA']][['SGP_Configuration']][['ss_to_pl_function']][['value']](as.character(as.numeric(GRADE)+1), ceiling(SCALE_SCORE_SGP_TARGET_BASELINE_4_YEAR_PROJ_YEAR_1_CURRENT))]
WIDA_IN_SGP_LONG_Data_2026_NEW_SCALE[YEAR == "2026", PROFICIENCY_LEVEL_SGP_TARGET_BASELINE_3_YEAR_PROJ_YEAR_1_CURRENT_OLD_SCALE:=SGPstateData[['WIDA']][['SGP_Configuration']][['ss_to_pl_function']][['value']](as.character(as.numeric(GRADE)+1), ceiling(SCALE_SCORE_SGP_TARGET_BASELINE_3_YEAR_PROJ_YEAR_1_CURRENT))]
WIDA_IN_SGP_LONG_Data_2026_NEW_SCALE[YEAR == "2026", PROFICIENCY_LEVEL_SGP_TARGET_BASELINE_2_YEAR_PROJ_YEAR_1_CURRENT_OLD_SCALE:=SGPstateData[['WIDA']][['SGP_Configuration']][['ss_to_pl_function']][['value']](as.character(as.numeric(GRADE)+1), ceiling(SCALE_SCORE_SGP_TARGET_BASELINE_2_YEAR_PROJ_YEAR_1_CURRENT))]
WIDA_IN_SGP_LONG_Data_2026_NEW_SCALE[YEAR == "2026", PROFICIENCY_LEVEL_SGP_TARGET_BASELINE_1_YEAR_PROJ_YEAR_1_CURRENT_OLD_SCALE:=SGPstateData[['WIDA']][['SGP_Configuration']][['ss_to_pl_function']][['value']](as.character(as.numeric(GRADE)+1), ceiling(SCALE_SCORE_SGP_TARGET_BASELINE_1_YEAR_PROJ_YEAR_1_CURRENT))]

### Transform the first year baseline referenced targets (1 to 5 year span) from OLD_SCALE to NEW_SCALE
WIDA_IN_SGP_LONG_Data_2026_NEW_SCALE[YEAR == "2026", SCALE_SCORE_SGP_TARGET_BASELINE_5_YEAR_PROJ_YEAR_1_CURRENT_NEW_SCALE:=SGPstateData[['WIDA']][['SGP_Configuration']][['ss_2026_scale_score_transformation_function']] (as.numeric(GRADE)+1, ceiling(SCALE_SCORE_SGP_TARGET_BASELINE_5_YEAR_PROJ_YEAR_1_CURRENT), direction = "OLD_to_NEW")]
WIDA_IN_SGP_LONG_Data_2026_NEW_SCALE[YEAR == "2026", SCALE_SCORE_SGP_TARGET_BASELINE_4_YEAR_PROJ_YEAR_1_CURRENT_NEW_SCALE:=SGPstateData[['WIDA']][['SGP_Configuration']][['ss_2026_scale_score_transformation_function']] (as.numeric(GRADE)+1, ceiling(SCALE_SCORE_SGP_TARGET_BASELINE_4_YEAR_PROJ_YEAR_1_CURRENT), direction = "OLD_to_NEW")]
WIDA_IN_SGP_LONG_Data_2026_NEW_SCALE[YEAR == "2026", SCALE_SCORE_SGP_TARGET_BASELINE_3_YEAR_PROJ_YEAR_1_CURRENT_NEW_SCALE:=SGPstateData[['WIDA']][['SGP_Configuration']][['ss_2026_scale_score_transformation_function']] (as.numeric(GRADE)+1, ceiling(SCALE_SCORE_SGP_TARGET_BASELINE_3_YEAR_PROJ_YEAR_1_CURRENT), direction = "OLD_to_NEW")]
WIDA_IN_SGP_LONG_Data_2026_NEW_SCALE[YEAR == "2026", SCALE_SCORE_SGP_TARGET_BASELINE_2_YEAR_PROJ_YEAR_1_CURRENT_NEW_SCALE:=SGPstateData[['WIDA']][['SGP_Configuration']][['ss_2026_scale_score_transformation_function']] (as.numeric(GRADE)+1, ceiling(SCALE_SCORE_SGP_TARGET_BASELINE_2_YEAR_PROJ_YEAR_1_CURRENT), direction = "OLD_to_NEW")]
WIDA_IN_SGP_LONG_Data_2026_NEW_SCALE[YEAR == "2026", SCALE_SCORE_SGP_TARGET_BASELINE_1_YEAR_PROJ_YEAR_1_CURRENT_NEW_SCALE:=SGPstateData[['WIDA']][['SGP_Configuration']][['ss_2026_scale_score_transformation_function']] (as.numeric(GRADE)+1, ceiling(SCALE_SCORE_SGP_TARGET_BASELINE_1_YEAR_PROJ_YEAR_1_CURRENT), direction = "OLD_to_NEW")]

### Save transformed data
save(WIDA_IN_SGP_LONG_Data_2026_NEW_SCALE, file="Data/WIDA_IN_SGP_LONG_Data_2026_NEW_SCALE.Rdata")
fwrite(WIDA_IN_SGP_LONG_Data_2026_NEW_SCALE, file="Data/WIDA_IN_SGP_LONG_Data_2026_NEW_SCALE.txt", na = "", quote = FALSE, sep = "|", row.names = FALSE, col.names = TRUE)
tmp.working.directory <- getwd()
setwd("Data")
if ("WIDA_IN_SGP_LONG_Data_2026_NEW_SCALE.txt.zip" %in% list.files()) file.remove("WIDA_IN_SGP_LONG_Data_2026_NEW_SCALE.txt.zip")
suppressMessages(
	zip("WIDA_IN_SGP_LONG_Data_2026_NEW_SCALE.txt.zip", "WIDA_IN_SGP_LONG_Data_2026_NEW_SCALE.txt", flags="-rmq1")
)
setwd(tmp.working.directory)