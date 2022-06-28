#################################################################################
###
### Data preparation script for WIDA IN data 2022
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

WIDA_IN_Data_LONG_2022 <- fread("Data/Base_Files/WIDA_ACCESS_IN_2021_2022.csv")


### Clean Up Data

WIDA_IN_Data_LONG_2022[,STN:=NULL]
WIDA_IN_Data_LONG_2022[,school_year_id:=NULL]
old.names <- c("STUDENT_ID", "Grade", "Composite_Overall_Scale Score", "Composite_Overall_Proficiency Level")
setnames(WIDA_IN_Data_LONG_2022, c("ID", "GRADE", "SCALE_SCORE", "ACHIEVEMENT_LEVEL_ORIGINAL"))
WIDA_IN_Data_LONG_2022[,YEAR := "2022"]
WIDA_IN_Data_LONG_2022[,ID := as.character(ID)]
WIDA_IN_Data_LONG_2022[,GRADE:=as.character(as.numeric(GRADE))]
WIDA_IN_Data_LONG_2022[,SCALE_SCORE:=as.numeric(SCALE_SCORE)]
WIDA_IN_Data_LONG_2022[,ACHIEVEMENT_LEVEL := as.character(ACHIEVEMENT_LEVEL_ORIGINAL)]
WIDA_IN_Data_LONG_2022[,ACHIEVEMENT_LEVEL := strhead(ACHIEVEMENT_LEVEL, 1)]
WIDA_IN_Data_LONG_2022[ACHIEVEMENT_LEVEL_ORIGINAL %in% c("4.2", "4.3", "4.4"), ACHIEVEMENT_LEVEL:="4.2"]
WIDA_IN_Data_LONG_2022[ACHIEVEMENT_LEVEL_ORIGINAL %in% c("4.5", "4.6", "4.7", "4.8", "4.9"), ACHIEVEMENT_LEVEL:="4.5"]
WIDA_IN_Data_LONG_2022[!is.na(ACHIEVEMENT_LEVEL),ACHIEVEMENT_LEVEL := paste("WIDA Level", ACHIEVEMENT_LEVEL)]
WIDA_IN_Data_LONG_2022[,VALID_CASE := "VALID_CASE"]
WIDA_IN_Data_LONG_2022[,CONTENT_AREA := "READING"]


### Check for duplicates

setkey(WIDA_IN_Data_LONG_2022, VALID_CASE, CONTENT_AREA, YEAR, GRADE, ID, SCALE_SCORE)
setkey(WIDA_IN_Data_LONG_2022, VALID_CASE, CONTENT_AREA, YEAR, GRADE, ID)
WIDA_IN_Data_LONG_2022[which(duplicated(WIDA_IN_Data_LONG_2022, by=key(WIDA_IN_Data_LONG_2022)))-1, VALID_CASE := "INVALID_CASE"]
setkey(WIDA_IN_Data_LONG_2022, VALID_CASE, CONTENT_AREA, YEAR, GRADE, ID)


### Reorder

setcolorder(WIDA_IN_Data_LONG_2022, c(7, 8, 5, 2, 1, 3, 6, 4))


### INVALIDATE cases

WIDA_IN_Data_LONG_2022[is.na(GRADE), VALID_CASE:="INVALID_CASE"]

### Save data

save(WIDA_IN_Data_LONG_2022, file="Data/WIDA_IN_Data_LONG_2022.Rdata")
