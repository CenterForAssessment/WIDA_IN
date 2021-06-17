#################################################################################
###
### Data preparation script for WIDA IN data 2021
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

WIDA_IN_Data_LONG_2021 <- fread("Data/Base_Files/WIDA_ACCESS_IN_2020_2021_PRELIMINARY.txt")


### Clean Up Data

WIDA_IN_Data_LONG_2021[,STN:=NULL]
WIDA_IN_Data_LONG_2021[,3:=NULL] ### Remove extraneous Grade variable
old.names <- c("District Number", "School Number", "STUDENT_ID", "Grade", "Composite (Overall) Scale Score", "Composite (Overall) Proficiency Level")
setnames(WIDA_IN_Data_LONG_2021, c("DISTRICT_NUMBER", "SCHOOL_NUMBER", "ID", "GRADE", "SCALE_SCORE", "ACHIEVEMENT_LEVEL_ORIGINAL"))
WIDA_IN_Data_LONG_2021[,YEAR := "2021"]
WIDA_IN_Data_LONG_2021[,ID := as.character(ID)]
WIDA_IN_Data_LONG_2021[GRADE=="KG", GRADE:="0"]
WIDA_IN_Data_LONG_2021[,GRADE:=as.character(as.numeric(GRADE))]
WIDA_IN_Data_LONG_2021[,SCALE_SCORE:=as.numeric(SCALE_SCORE)]
WIDA_IN_Data_LONG_2021[,ACHIEVEMENT_LEVEL := as.character(ACHIEVEMENT_LEVEL_ORIGINAL)]
WIDA_IN_Data_LONG_2021[,ACHIEVEMENT_LEVEL := strhead(ACHIEVEMENT_LEVEL, 1)]
WIDA_IN_Data_LONG_2021[ACHIEVEMENT_LEVEL_ORIGINAL %in% c("4.2", "4.3", "4.4"), ACHIEVEMENT_LEVEL:="4.2"]
WIDA_IN_Data_LONG_2021[ACHIEVEMENT_LEVEL_ORIGINAL %in% c("4.5", "4.6", "4.7", "4.8", "4.9"), ACHIEVEMENT_LEVEL:="4.5"]
WIDA_IN_Data_LONG_2021[!is.na(ACHIEVEMENT_LEVEL),ACHIEVEMENT_LEVEL := paste("WIDA Level", ACHIEVEMENT_LEVEL)]
WIDA_IN_Data_LONG_2021[,VALID_CASE := "VALID_CASE"]
WIDA_IN_Data_LONG_2021[,CONTENT_AREA := "READING"]


### Check for duplicates

setkey(WIDA_IN_Data_LONG_2021, VALID_CASE, CONTENT_AREA, YEAR, GRADE, ID, SCALE_SCORE)
setkey(WIDA_IN_Data_LONG_2021, VALID_CASE, CONTENT_AREA, YEAR, GRADE, ID)
WIDA_IN_Data_LONG_2021[which(duplicated(WIDA_IN_Data_LONG_2021, by=key(WIDA_IN_Data_LONG_2021)))-1, VALID_CASE := "INVALID_CASE"]
setkey(WIDA_IN_Data_LONG_2021, VALID_CASE, CONTENT_AREA, YEAR, GRADE, ID)


### Reorder

setcolorder(WIDA_IN_Data_LONG_2021, c(9, 10, 7, 4, 3, 5, 8, 6, 1, 2))


### Save data

save(WIDA_IN_Data_LONG_2021, file="Data/WIDA_IN_Data_LONG_2021.Rdata")
