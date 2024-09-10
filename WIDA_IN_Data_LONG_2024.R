#################################################################################
###
### Data preparation script for WIDA IN data 2024
###
#################################################################################

### Load Packages

require(SGP)
require(data.table)


### Utility function

strtail <- function (s, n = 1) {
    if (n < 0)
        substring(s, 1 - n)
    else substring(s, nchar(s) - n + 1)
}

strhead <- function (s, n) {
    if (n < 0)
        substr(s, 1, nchar(s) + n)
    else substr(s, 1, n)
}


### Load Data
#WIDA_IN_Data_LONG_2024 <- fread("Data/Base_Files/WIDA_ACCESS_IN_2023_2024.csv")
WIDA_IN_Data_LONG_2024 <- fread("Data/Base_Files/WIDA_ACCESS_IN_2023_2024_UPDATE.csv")


### Clean Up Data
WIDA_IN_Data_LONG_2024[,STN:=NULL]
WIDA_IN_Data_LONG_2024[,SCHOOL_YEAR_ID:=NULL]
old.names <- c("IDOE_CORPORATION_ID", "IDOE_SCHOOL_ID", "STUDENT_ID", "GRADE", "Composite_Overall_Scale Score", "Composite_Overall_Proficiency Level")
setnames(WIDA_IN_Data_LONG_2024, c("DISTRICT_NUMBER", "SCHOOL_NUMBER", "ID", "GRADE", "SCALE_SCORE", "ACHIEVEMENT_LEVEL_ORIGINAL"))
WIDA_IN_Data_LONG_2024[,YEAR := "2024"]
WIDA_IN_Data_LONG_2024[,ID := as.character(ID)]
WIDA_IN_Data_LONG_2024[GRADE=="KG", GRADE:="00"]
WIDA_IN_Data_LONG_2024[,GRADE:=as.character(as.numeric(GRADE))]
WIDA_IN_Data_LONG_2024[,SCALE_SCORE:=as.numeric(SCALE_SCORE)]
WIDA_IN_Data_LONG_2024[,ACHIEVEMENT_LEVEL := as.character(ACHIEVEMENT_LEVEL_ORIGINAL)]
WIDA_IN_Data_LONG_2024[,ACHIEVEMENT_LEVEL := strhead(ACHIEVEMENT_LEVEL, 1)]
WIDA_IN_Data_LONG_2024[ACHIEVEMENT_LEVEL_ORIGINAL %in% c("4.2", "4.3", "4.4"), ACHIEVEMENT_LEVEL:="4.2"]
WIDA_IN_Data_LONG_2024[ACHIEVEMENT_LEVEL_ORIGINAL %in% c("4.5", "4.6", "4.7", "4.8", "4.9"), ACHIEVEMENT_LEVEL:="4.5"]
WIDA_IN_Data_LONG_2024[!is.na(ACHIEVEMENT_LEVEL),ACHIEVEMENT_LEVEL := paste("WIDA Level", ACHIEVEMENT_LEVEL)]
WIDA_IN_Data_LONG_2024[,VALID_CASE := "VALID_CASE"]
WIDA_IN_Data_LONG_2024[,CONTENT_AREA := "READING"]


### Check for duplicates

setkey(WIDA_IN_Data_LONG_2024, VALID_CASE, CONTENT_AREA, YEAR, GRADE, ID, SCALE_SCORE)
setkey(WIDA_IN_Data_LONG_2024, VALID_CASE, CONTENT_AREA, YEAR, GRADE, ID)
WIDA_IN_Data_LONG_2024[which(duplicated(WIDA_IN_Data_LONG_2024, by=key(WIDA_IN_Data_LONG_2024)))-1, VALID_CASE := "INVALID_CASE"]
setkey(WIDA_IN_Data_LONG_2024, VALID_CASE, CONTENT_AREA, YEAR, GRADE, ID)

### Invalidate data with missing scale scores

WIDA_IN_Data_LONG_2024[is.na(SCALE_SCORE), VALID_CASE:="INVALID_CASE"]

### Reorder

setcolorder(WIDA_IN_Data_LONG_2024, c(9, 10, 7, 4, 3, 5, 8, 6, 1, 2))


### INVALIDATE cases

WIDA_IN_Data_LONG_2024[is.na(GRADE), VALID_CASE:="INVALID_CASE"]

### Save data

save(WIDA_IN_Data_LONG_2024, file="Data/WIDA_IN_Data_LONG_2024.Rdata")
