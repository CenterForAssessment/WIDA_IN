#################################################################################
###
### Data preparation script for WIDA IN data 2023
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

WIDA_IN_Data_LONG_2023 <- fread("Data/Base_Files/WIDA_ACCESS_IN_2022_2023.txt")


### Clean Up Data

WIDA_IN_Data_LONG_2023[,STN:=NULL]
WIDA_IN_Data_LONG_2023[,school_year_id:=NULL]
old.names <- c("IDOE_CORPORATION_ID", "IDOE_SCHOOL_ID", "STUDENT_ID", "GRADE", "Composite_Overall_Scale Score", "Composite_Overall_Proficiency Level")
setnames(WIDA_IN_Data_LONG_2023, c("DISTRICT_NUMBER", "SCHOOL_NUMBER", "ID", "GRADE", "SCALE_SCORE", "ACHIEVEMENT_LEVEL_ORIGINAL"))
WIDA_IN_Data_LONG_2023[,YEAR := "2023"]
WIDA_IN_Data_LONG_2023[,ID := as.character(ID)]
WIDA_IN_Data_LONG_2023[,GRADE:=as.character(as.numeric(GRADE))]
WIDA_IN_Data_LONG_2023[,SCALE_SCORE:=as.numeric(SCALE_SCORE)]
WIDA_IN_Data_LONG_2023[,ACHIEVEMENT_LEVEL := as.character(ACHIEVEMENT_LEVEL_ORIGINAL)]
WIDA_IN_Data_LONG_2023[,ACHIEVEMENT_LEVEL := strhead(ACHIEVEMENT_LEVEL, 1)]
WIDA_IN_Data_LONG_2023[ACHIEVEMENT_LEVEL_ORIGINAL %in% c("4.2", "4.3", "4.4"), ACHIEVEMENT_LEVEL:="4.2"]
WIDA_IN_Data_LONG_2023[ACHIEVEMENT_LEVEL_ORIGINAL %in% c("4.5", "4.6", "4.7", "4.8", "4.9"), ACHIEVEMENT_LEVEL:="4.5"]
WIDA_IN_Data_LONG_2023[!is.na(ACHIEVEMENT_LEVEL),ACHIEVEMENT_LEVEL := paste("WIDA Level", ACHIEVEMENT_LEVEL)]
WIDA_IN_Data_LONG_2023[,VALID_CASE := "VALID_CASE"]
WIDA_IN_Data_LONG_2023[,CONTENT_AREA := "READING"]


### Check for duplicates

setkey(WIDA_IN_Data_LONG_2023, VALID_CASE, CONTENT_AREA, YEAR, GRADE, ID, SCALE_SCORE)
setkey(WIDA_IN_Data_LONG_2023, VALID_CASE, CONTENT_AREA, YEAR, GRADE, ID)
WIDA_IN_Data_LONG_2023[which(duplicated(WIDA_IN_Data_LONG_2023, by=key(WIDA_IN_Data_LONG_2023)))-1, VALID_CASE := "INVALID_CASE"]
setkey(WIDA_IN_Data_LONG_2023, VALID_CASE, CONTENT_AREA, YEAR, GRADE, ID)


### Reorder

setcolorder(WIDA_IN_Data_LONG_2023, c(9, 10, 7, 4, 3, 5, 8, 6, 1, 2))


### INVALIDATE cases

WIDA_IN_Data_LONG_2023[is.na(GRADE), VALID_CASE:="INVALID_CASE"]

### Save data

save(WIDA_IN_Data_LONG_2023, file="Data/WIDA_IN_Data_LONG_2023.Rdata")
