# ###########################
# CONFIG: parameters affecting processing
# ###########################

## These control whether the external data is downloaded and processed.
process_anon <- TRUE
download_anon <- TRUE

## The year the report is for(

report.year <- 2025


## These define the start (and end) dates for processing of data
firstday <- paste0(as.character(report.year -1),"-12-01")
lastday  <- paste0(as.character(report.year),"-11-30")

# ###########################
# CONFIG: define paths and filenames for later reference
# ###########################

# Change the basepath depending on your system

basepath <- here::here()
setwd(basepath)



# for Jira stuff

jira.anon.partial <- file.path("data","jira","anon")
jiraconf <- file.path(basepath,"data","confidential","jira")
jiraanon <- file.path(basepath,jira.anon.partial)
manual   <- file.path(basepath,"data","manual")
jira.raw <- file.path("data","jira","raw")


# for other stuff
icpsrconf       <- file.path(basepath,"data","confidential","icpsr")
icpsrbase       <- file.path(basepath,"data","icpsr")
icpsr.utilization.date <- "2025-12-08" 
icpsr.utilization.file <- paste0("utilizationReport-",icpsr.utilization.date,".csv")
icpsr.custom.xlsx <- "AEA_Report_20251205_edited.csv"

zenodobase       <- file.path(basepath,"data","zenodo")

# file names
# These need to be updated to reflect latest
jira.anon.name <- file.path(jiraanon,"jira.anon.RDS")
jira.anon.commit <- "91a673fe3d07fe6970588dfd62e3c85aff8774ec" # this is the hash from the Git repo
jira.anon.sha256 <- "c4e35e6b62581d6652109bb0c1134861e7715d721b22e254dc7fa69d8191779f"
jira.anon.urlbase <- paste0("https://raw.githubusercontent.com/AEADataEditor/processing-jira-process-data/",jira.anon.commit)

jira.anon.url     <- file.path(jira.anon.urlbase,"data","anon","jira.anon.RDS")
jira.members.url  <- file.path(jira.anon.urlbase,"data","replicationlab_members.txt")
jira.members.name <- file.path(jiraanon,"replicationlab_members.txt")


# This file is received from the AEA Editorial Office. It may need some minor formatting changes.
scholarone      <- file.path(basepath,"data","scholarone")
scholarone.file <- "dataEditorReport_20241111-20251110.xlsx"

scholarone.name <- file.path(scholarone,scholarone.file)

scholarone.prev <- "dataEditorReport_20231111-20241110.xlsx"


# The file should have one tab per journal. 07_table4.R will rename journal names accordingly.
# Look for the part that says
# 27: Total Number of Rounds Manuscripts Underwent			
# 28: 
# 29: Total Rounds	Manuscripts	Percentage	
# 30:            1	58	0.79	
# 31:            2	15	0.21	
scholarone.skip  <- 31  # <---- This number should correspond to the lines above "Total Rounds"
scholarone.skip2 <- 42  # <---- This number should correspond to the lines with "Current Round"

scholarone.pskip <- 33 # <---- This is the number in the previous year's file

# local
images   <- file.path(basepath, "images" )
tables   <- file.path(basepath, "tables" )
programs <- file.path(basepath,"programs")
temp     <- file.path(basepath,"data","temp")


# parameters
latexnums.Rda <- file.path(tables,"latexnums.Rda")
latexnums.tex <- file.path(tables,"latexnums.tex")

for ( dir in list(images,tables,programs,temp)){
  if (file.exists(dir)){
  } else {
    dir.create(file.path(dir))
  }
}

set.seed(20201201)


####################################
# global libraries used everywhere #
####################################



## Initialize a file that will be used at the end to write out LaTeX parameters for in-text 
## reference

pkgTest("tibble")
if (file.exists(latexnums.Rda)) {
  print(paste0("File for export to LaTeX found: ",latexnums.Rda))
} else {
  latexnums <- tibble(field="version",value=as.character(date()),updated=date())
  saveRDS(latexnums,latexnums.Rda)
}

update_latexnums <- function(field,value) {
  # should test if latexnums is in memory
  latexnums <- readRDS(latexnums.Rda)
  
  # find out if a field exists
  if ( any(latexnums$field == field) ) {
    message(paste0("Updating existing field ",field))
    latexnums[which(latexnums$field == field), ]$value <- as.character(value)
    latexnums[which(latexnums$field == field), ]$updated <- date()
    #return(latexnums)
  } else {
    message(paste0("Adding new row for field ",field))
    latexnums <- latexnums %>% add_row(field=field,value=as.character(value),updated=date())
    #return(latexnums)
  }
  saveRDS(latexnums,latexnums.Rda)
}

.Last <- function() {
  sessionInfo()
}
