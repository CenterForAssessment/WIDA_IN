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

### Transform the baseline referenced targets
for (year.iter in 0:6) {
   variables.to.transform <- grep(paste0("YEAR_", year.iter), baseline.referenced.targets, value=TRUE)
   for (variable.iter in variables.to.transform) {
    new.variable.name <- paste0(variable.iter, "_NEW_SCALE")
    WIDA_IN_SGP_LONG_Data_2026_NEW_SCALE[, (new.variable.name) := SGPstateData[["WIDA"]][["SGP_Configuration"]][["ss_2026_scale_score_transformation_function"]](as.numeric(GRADE)+year.iter, get(variable.iter), direction = "OLD_to_NEW")]
   }
}

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