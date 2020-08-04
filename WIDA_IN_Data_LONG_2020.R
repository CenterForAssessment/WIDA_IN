#################################################################################
###
### Data preparation script for WIDA IN data 2020
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

WIDA_IN_Data_LONG_2020 <- fread("Data/Base_Files/WIDA_ACCESS_IN_2019_2020.txt")


### Clean Up Data

WIDA_IN_Data_LONG_2020[,STN:=NULL]
setnames(WIDA_IN_Data_LONG_2020, c("YEAR", "ID", "GRADE", "SCALE_SCORE", "ACHIEVEMENT_LEVEL_ORIGINAL"))
WIDA_IN_Data_LONG_2020[,YEAR := as.character(YEAR)]
WIDA_IN_Data_LONG_2020[,ID := as.character(ID)]
WIDA_IN_Data_LONG_2020[GRADE=="KG", GRADE:="0"]
WIDA_IN_Data_LONG_2020[,GRADE:=as.character(as.numeric(GRADE))]
WIDA_IN_Data_LONG_2020[,SCALE_SCORE:=as.numeric(SCALE_SCORE)]
WIDA_IN_Data_LONG_2020[,ACHIEVEMENT_LEVEL := as.character(ACHIEVEMENT_LEVEL_ORIGINAL)]
WIDA_IN_Data_LONG_2020[,ACHIEVEMENT_LEVEL := strhead(ACHIEVEMENT_LEVEL, 1)]
WIDA_IN_Data_LONG_2020[ACHIEVEMENT_LEVEL_ORIGINAL %in% c("4.2", "4.3", "4.4"), ACHIEVEMENT_LEVEL:="4.2"]
WIDA_IN_Data_LONG_2020[ACHIEVEMENT_LEVEL_ORIGINAL %in% c("4.5", "4.6", "4.7", "4.8", "4.9"), ACHIEVEMENT_LEVEL:="4.5"]
WIDA_IN_Data_LONG_2020[!is.na(ACHIEVEMENT_LEVEL),ACHIEVEMENT_LEVEL := paste("WIDA Level", ACHIEVEMENT_LEVEL)]
WIDA_IN_Data_LONG_2020[,VALID_CASE := "VALID_CASE"]
WIDA_IN_Data_LONG_2020[,CONTENT_AREA := "READING"]


### Check for duplicates

setkey(WIDA_IN_Data_LONG_2020, VALID_CASE, CONTENT_AREA, YEAR, GRADE, ID, SCALE_SCORE)
setkey(WIDA_IN_Data_LONG_2020, VALID_CASE, CONTENT_AREA, YEAR, GRADE, ID)
WIDA_IN_Data_LONG_2020[which(duplicated(WIDA_IN_Data_LONG_2020, by=key(WIDA_IN_Data_LONG_2020)))-1, VALID_CASE := "INVALID_CASE"]
setkey(WIDA_IN_Data_LONG_2020, VALID_CASE, CONTENT_AREA, YEAR, GRADE, ID)


### Reorder

setcolorder(WIDA_IN_Data_LONG_2020, c(7,8,1,2,3,4,6,5))


### Save data

save(WIDA_IN_Data_LONG_2020, file="Data/WIDA_IN_Data_LONG_2020.Rdata")
