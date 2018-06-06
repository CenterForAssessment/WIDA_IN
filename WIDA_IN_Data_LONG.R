#################################################################################
###
### Data preparation script for WIDA IN data, 2017 & 2018
###
#################################################################################

### Load Packages

require(SGP)
require(data.table)


### Load Data

WIDA_IN_Data_LONG_2016_2017 <- fread("Data/Base_Files/WIDA_ACCESS_IN_2016_2017.txt")
WIDA_IN_Data_LONG_2017_2018 <- fread("Data/Base_Files/WIDA_ACCESS_IN_2017_2018.txt")
WIDA_IN_Data_LONG <- rbindlist(list(WIDA_IN_Data_LONG_2016_2017, WIDA_IN_Data_LONG_2017_2018))


### Clean Up Data

WIDA_IN_Data_LONG[,STN:=NULL]
setnames(WIDA_IN_Data_LONG, c("YEAR", "ID", "SCALE_SCORE", "PROF_LEVEL"))
levels(WIDA_IN_Data_LONG$GRADE) <- c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "0")
WIDA_IN_Data_LONG[,VALID_CASE := "VALID_CASE"]
WIDA_IN_Data_LONG[,CONTENT_AREA := "READING"]
WIDA_IN_Data_LONG[,YEAR := as.character(YEAR)]
WIDA_IN_Data_LONG[,ID := as.character(ID)]
WIDA_IN_Data_LONG[,GRADE := as.character(GRADE)]
WIDA_IN_Data_LONG[,SCALE_SCORE := as.numeric(SCALE_SCORE)]
WIDA_IN_Data_LONG[,ACHIEVEMENT_LEVEL := as.character(PROF_LEVEL)]
WIDA_IN_Data_LONG[PROF_LEVEL %in% c("", " NA", "A1", "A2", "A3", "P1", "P2"), ACHIEVEMENT_LEVEL := NA]
WIDA_IN_Data_LONG[,ACHIEVEMENT_LEVEL := strhead(ACHIEVEMENT_LEVEL, 1)]
WIDA_IN_Data_LONG[!is.na(ACHIEVEMENT_LEVEL),ACHIEVEMENT_LEVEL := paste("WIDA Level", ACHIEVEMENT_LEVEL)]


### Invalidate Cases with Scale Score out of Range (PROF_LEVEL in c("", " NA", "A1", "A2", "A3", "P1", "P2"))

WIDA_IN_Data_LONG[PROF_LEVEL %in% c("", " NA", "A1", "A2", "A3", "P1", "P2"), VALID_CASE := "INVALID_CASE"]


### Check for duplicates

setkey(WIDA_IN_Data_LONG, VALID_CASE, CONTENT_AREA, YEAR, ID, GRADE, SCALE_SCORE)
setkey(WIDA_IN_Data_LONG, VALID_CASE, CONTENT_AREA, YEAR, ID)
WIDA_IN_Data_LONG[which(duplicated(WIDA_IN_Data_LONG, by=key(WIDA_IN_Data_LONG)))-1, VALID_CASE := "INVALID_CASE"]
setkey(WIDA_IN_Data_LONG, VALID_CASE, CONTENT_AREA, YEAR, ID)


### Reorder

setcolorder(WIDA_IN_Data_LONG, c(8,9,1,2,3,4,5,6,10,7))


### Save data

save(WIDA_IN_Data_LONG, file="U:/DATA/SGP/ACCESS SGP/WIDA_IN_Data_LONG.Rdata")
#save(WIDA_IN_Data_LONG, file="Data/WIDA_IN_Data_LONG.Rdata")
