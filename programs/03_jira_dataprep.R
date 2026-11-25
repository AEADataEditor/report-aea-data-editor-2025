# Tabulate statistics and make graphs for the AEA data editor report
# Originally written by Harry Son
# Updated by Lars Vilhuber
# 2021-12-30
# Updated by Takshil Sachdev
# 2025-01-26

# Inputs
# - file.path(jiraanon,"jira.anon.RDS") 
# Outputs
# - file.path(temp,"jira.pyear.RDS"))
# - file.path(temp,"jira.submitted.RDS"))
# - file.path(temp,"jira.breakout.RDS"))
# - file.path(jiraanon,"jira.others.RDS"))
# - file.path(temp,"jira.nc.RDS"))
# - file.path(temp,"jira.up.RDS"))
# - file.path(temp,"jira.nda.RDS"))
# - file.path(temp,"jira.ext.RDS"))
# - file.path(jiraanon,"jira.others.xlsx") [if not already present]

### Load libraries 
### Requirements: have library *here*
source(here::here("global-libraries.R"),echo=TRUE)
source(here::here("programs","config.R"),echo=TRUE)


# Read in data extracted from Jira, anonymized
if ( file.exists(jira.anon.name) ) {
  message("File exists, proceeding.")
} else {
  message("Attempting to download file")
  try(download.file(jira.anon.url,jira.anon.name,mode="wb"))
  if ( file.exists(jira.anon.name) ) {
    message("Download successful, proceeding.")
  } else {
    stop("Download failed. Please investigate")
  }
}

jira.anon.raw <- readRDS(jira.anon.name)

#
# This should be compared to the published version.
# Note that this is an in-memory computation of the checksum, not of the 
# RDS file!
#
jira.test.chksum <- digest(jira.anon.raw,algo="sha256")
message(paste0("Checksum for main file: ",jira.test.chksum))
if ( jira.test.chksum == jira.anon.sha256) {
  message("SHA256 checksum verified.")
} else {
  stop("SHA256 fails, please verify that you are using the same file. Update config.R if necessary.")
}

jira.anon <- jira.anon.raw %>%
  filter(date_created >= firstday, date_created < lastday,
         Journal != "non-AEA journal",ticket != "AEAREP-7453") %>%
  # manual fixes
  mutate(MCStatus = case_when(
    ticket == "AEAREP-6996" ~ "CA",
    TRUE ~ MCStatus
  ),
  MCRecommendationV2 = case_when(
    ticket == "AEAREP-7559" & As.Of.Date >= "2025-07-01T10:37:32.486-0400" ~ "Accept - with Changes",
    TRUE ~ MCRecommendationV2
  ))

# AEAREP-7453: not in scope

saveRDS(jira.anon,file=file.path(temp,"jira_anon_fixed.RDS"))


# A list of non-issues, typically for information-only
jira.pyear.raw <- jira.anon %>%
  mutate(orig_order = row_number()) %>%
  mutate(DCAF.clean = sub(".*value='([^']+)'.*", "\\1", DCAF_Access_Restrictions))%>%
  mutate(Update.type.clean = sub(".*value='([^']+)'.*", "\\1", Update.type))

# We may need in the future to separately tabulate courtesy reports for non-AEA journals

jira.pyear <- jira.pyear.raw %>%
  arrange(ticket,As.Of.Date,orig_order) %>%
  # identify only the status changes
  mutate(status_change = if_else(str_detect(Changed.Fields,"status"),"yes","no")) %>%
  filter(status_change=="yes"|received=="Yes") %>%
  # process software and reasons
  mutate(Software.used = str_remove_all(Software.used, "\\[|\\]|'")) %>%
    cSplit("Software.used",",")  %>%
    mutate(reason1=grepl("Discrepancy",reason.failure, ## 8 reasons for failutre to reproduce
                       fixed = "TRUE"),
         reason2=grepl("Bugs",reason.failure,
                       fixed = "TRUE"),
         reason3=grepl("Insufficient",reason.failure,
                       fixed = "TRUE"),
         reason4=grepl("Software",reason.failure,
                       fixed = "TRUE"),
         reason5=grepl("functional",reason.failure,
                       fixed = "TRUE"),
         reason6=grepl("Data not available",reason.failure,
                       fixed = "TRUE"),
         reason6.1=grepl("Data,not,available",reason.failure,
                         fixed = "TRUE"),
         reason7=grepl("Data missing",reason.failure,
                       fixed = "TRUE"),
         reason7.1=grepl("Data,missing",reason.failure,
                         fixed = "TRUE"),
         reason8=grepl("Code missing",reason.failure,
                       fixed = "TRUE"),
         reason8.1=grepl("Code,missing",reason.failure,
                         fixed = "TRUE")) %>% 
  mutate(reason1=case_when(reason1==TRUE ~ "Discrepancy in Output",
                           TRUE ~ ""),
         reason2=case_when(reason2==TRUE ~ "Bugs in code",
                           TRUE ~ ""),
         reason3=case_when(reason3==TRUE ~ "Insufficient time available to replicator",
                           TRUE ~ ""),
         reason4=case_when(reason4==TRUE ~ "Software not available to replicator",
                           TRUE ~ ""),
         reason5=case_when(reason5==TRUE ~ "Code not functional",
                           TRUE ~ ""),
         reason6=case_when(reason6==T ~ "Data not available",
                           reason6.1==T ~ "Data not available",
                           TRUE ~ ""),
         reason7=case_when(reason7==T ~ "Data missing",
                           reason7.1==T ~ "Data missing",
                           TRUE ~ ""),
         reason8=case_when(reason8==T ~ "Code missing",
                           reason8.1==T ~ "Code missing",
                           TRUE ~ "")) %>%
  select(-reason6.1,-reason7.1,-reason8.1) 

test.tickets.1 <- jira.pyear %>% distinct(ticket) %>% nrow()
test.rows.1 <- nrow(jira.pyear)

message(paste0("Pyear: Rows ",test.rows.1,", Tickets ",test.tickets.1))

# identifying the list of received tickets
ji <- jira.pyear %>%
  select(ticket,Journal) %>%
  distinct(ticket, .keep_all = TRUE) 

# identifying the list of issues went through alternate workflow
ji_alt <- jira.pyear %>%
  filter(Status == "Alternate"|Status=="Alternate workflow") %>%
  # Careful, as there may be some loops. We take the last such observation
  arrange(ticket,desc(As.Of.Date)) %>%
  group_by(ticket) %>%
  filter(row_number()==1) %>%
  ungroup() %>%
  select(ticket) %>%
  distinct() %>%
  mutate(alternate="Yes")

# identifying the list of submitted issues
jira.filter.submitted.list <- jira.pyear %>%
  filter(Status == "Submitted to MC" & Journal != "AEA P&P") %>%
  group_by(ticket) %>%
  arrange(As.Of.Date,.by_group = TRUE) %>%
  # Keep the last row for each ticket
  dplyr::slice_tail(n = 1) %>%
  ungroup() %>%
  select(ticket,min_date=As.Of.Date)

jira.filter.submitted <- left_join(jira.filter.submitted.list,jira.pyear,by="ticket") %>%
  filter(As.Of.Date >= min_date) %>%
  # Careful, as there may be some loops. We take the last such observation
  group_by(ticket) %>%
  arrange(ticket,desc(As.Of.Date),.by_group = TRUE) %>%
  filter(row_number()==1) %>%
  ungroup() 

jis <- jira.filter.submitted %>%
  select(ticket) %>%
  distinct() %>%
  mutate(submitted="Yes")

# figure out the final status of the issue as of 12/01/

jifstatus <- jira.pyear %>%
  # Careful, as there may be some loops. We take the last such observation
  arrange(ticket,desc(As.Of.Date)) %>%
  group_by(ticket) %>%
  filter(row_number()==1) %>%
  ungroup() %>%select(ticket,final_status = Status,As.Of.Date)

# categorize issues: P&P, Submitted, Not yet submitted, Alternate workflow, Others.
jira.issues.breakout.early <- ji %>%  
  left_join(jis,by="ticket") %>%
  left_join(ji_alt,by="ticket") %>%
  transform(submitted=ifelse(is.na(submitted),"No",as.character(submitted)),
            alternate=ifelse(is.na(alternate),"No",as.character(alternate))) %>%
  select(ticket,Journal,submitted,alternate) %>%
  left_join(jifstatus, by="ticket") 

# we now use the override file, if there is one, to correct some values
# before classifiying further

if (!file.exists(file.path(jiraanon,"jira.others.xlsx")) ) {
  message("Override file not found. Run through this code once, then read instructions.")
  message(paste0("==== ",file.path(jiraanon,"jira.others.xlsx")," ====="))
  jira.issues.breakout.late <- jira.issues.breakout.early
} else {
  message("File exists, proceeding.")
  jira.override <- read_excel(file.path(jiraanon,"jira.others.xlsx"),
                              sheet="override")
  jira.issues.breakout.late <- jira.issues.breakout.early %>%
    left_join(jira.override,by="ticket",suffix = c("",".override")) %>%
    mutate(submitted = if_else(!is.na(submitted != submitted.override),
                               submitted.override,submitted),
           alternate = if_else(!is.na(alternate != alternate.override),
                               alternate.override,alternate),
           final_status = if_else(!is.na(final_status != final_status.override),
                               final_status.override,final_status))
}

jira.issues.breakout <- jira.issues.breakout.late %>%
  # collapse outcomes
  transform(outcome=case_when(
                    submitted == "Yes" ~ "Submitted",
                    final_status %in% c("Open","Assigned","In Progress",
                                        "Code","Data",
                                           "Report Under Review","Write Preliminary Report",
                                           "Verification","Pre-Approved","Approved","Data",
                                           "Waiting for info","Waiting for external report",
                                           "Writing Report") ~ "Not yet submitted",
                    final_status %in% c("Incomplete","Blocked") ~ "Incomplete",
                    alternate=="Yes" ~ "Alternate",
                    TRUE ~ "Others"))  

# summarize the breakdown of the cases
summary.breakout <- jira.issues.breakout %>%  
  group_by(outcome) %>%
  summarise(n_outcome = n_distinct(ticket)) 

## separate the "Others" case
jira.others <- jira.issues.breakout %>%
  filter(outcome=="Others"|outcome=="Alternate") 

# This filters for the cases **submitted** in the past 12 months
issues_all <- jira.pyear %>%
  filter(!(Journal=="")) %>%
  select(ticket) %>%
  distinct() %>% nrow()

manuscript_all <- jira.pyear %>%
  filter(!(Journal=="")) %>%
  select(mc_number_anon) %>% 
  distinct() %>% nrow()

## Non-compliant Cases
jira.search.nc <- jira.pyear.raw %>%
  mutate(Non.compliant2 = if_else(str_detect(Non.compliant,"Yes"),"yes","no")) %>%
  filter(Non.compliant2=="yes") %>%
  group_by(ticket) %>%
  slice(which.max(as.Date(date_asof, '%Y/%m/%d')))%>%
  select(ticket)

jira.search.nc.all <- jira.pyear.raw[jira.pyear.raw$ticket %in% jira.search.nc$ticket, ]%>%
  group_by(ticket) %>%
  slice(which.max(as.Date(As.Of.Date, "%Y-%m-%dT%H:%M:%OS%z")))%>%
  mutate(Non.compliant2 = if_else(str_detect(Non.compliant,"Yes"),"yes","no")) %>%
  filter(Non.compliant2=="yes") %>%
  select(ticket,As.Of.Date,mc_number_anon,Status,assignee_anon,MCStatus,DCAF.clean,Resolution)

## Updates
jira.search.up <- jira.pyear.raw %>%
  filter(MCStatus=="Update")%>%
  group_by(ticket) %>%
  # A few issues are subtasks and should not be here. This needs to be filtered out upstream
  mutate(exclude=(ticket %in% c("AEAREP-4837","AEAREP-5481","AEAREP-5657","AEAREP-5952","AEAREP-5993"))) %>%
  filter(exclude==FALSE) %>%
  # -- end special filter
  # -- Start workaround for incomplete data - manually verified
  mutate(Update.type.clean = if_else(Update.type.clean =="","Data provider",Update.type.clean)) %>%
  # -- end Workaround
  slice(which.max(as.Date(As.Of.Date, "%Y-%m-%dT%H:%M:%OS%z")))%>%
  select(ticket,As.Of.Date,mc_number_anon,Status,assignee_anon,MCStatus,Update.type.clean,Resolution)%>%
  rename(Update.type = Update.type.clean)

#Output missing updatetype
missing.update.type <- subset(jira.search.up, subset = Update.type == "")

# Only export to Excel if there are any empty rows
if (nrow(missing.update.type) > 0) {
  # Create the Excel file
  write.xlsx(missing.update.type, "missing_update_type.xlsx", rowNames = FALSE)
  
  cat("Excel file 'missing_update_type.xlsx' created with missing update type.")
} else {
  cat("Update type always filled; no file created.")
}

## NDAs
jira.search.nda <- jira.pyear.raw %>% 
  # identify only the NDA
  mutate(NDA = if_else(str_detect(Agreement.signed,"NDA"),"yes","no")) %>%
  mutate(DUA = if_else(str_detect(Agreement.signed,"DUA"),"yes","no")) %>%
  filter(NDA=="yes"|DUA=="yes") %>%
  group_by(ticket) %>%
  slice(which.max(as.Date(As.Of.Date, "%Y-%m-%dT%H:%M:%OS%z")))

jira.search.nda$Agreement.cleaned <- sapply(jira.search.nda$Agreement.signed, function(x) {
  # Extract words after "value='"
  values <- unlist(regmatches(x, gregexpr("(?<=value=')\\w+", x, perl=TRUE)))
  
  # If no "value=" pattern was found, split by comma (for already clean entries)
  if (length(values) == 0) {
    values <- strsplit(x, ",")[[1]]
  }
  
  # Join the values with "; " separator
  paste(values, collapse = "; ")
})

jira.search.nda <- jira.search.nda %>%
  select(ticket,As.Of.Date,mc_number_anon,Status,assignee_anon,MCStatus,Agreement.cleaned,Resolution)%>%
  rename(Agreement.signed = Agreement.cleaned)

## External
jira.search.ext <- jira.pyear.raw %>%
  filter(external=="Yes") %>%
  group_by(ticket) %>%
  slice(which.max(as.Date(As.Of.Date, "%Y-%m-%dT%H:%M:%OS%z")))%>%
  select(ticket,As.Of.Date,mc_number_anon,Status,assignee_anon,MCStatus,DCAF.clean,external,External.party.name,Resolution)

# we will re-use these 
saveRDS(jira.pyear,file=file.path(temp,"jira.pyear.RDS"))
saveRDS(jira.filter.submitted,file=file.path(temp,"jira.submitted.RDS"))
saveRDS(jira.issues.breakout ,file=file.path(temp,"jira.breakout.RDS"))
saveRDS(jira.others,file=file.path(jiraanon,"jira.others.RDS"))

saveRDS(jira.search.nc.all,file=file.path(temp,"jira.nc.RDS"))
saveRDS(jira.search.up,file=file.path(temp,"jira.up.RDS"))
saveRDS(jira.search.nda,file=file.path(temp,"jira.nda.RDS"))
saveRDS(jira.search.ext,file=file.path(temp,"jira.ext.RDS"))

# this file will be used to revise the flow above. 
# Copy the sheet "output" to a sheet"override", edit, and then run this code again.

if (file.exists(file.path(jiraanon,"jira.others.xlsx")) ) {
  message("File found. Preserving overrides, then read instructions.")
  override <- read_excel(path=file.path(jiraanon,"jira.others.xlsx"),
                         sheet="override")
} else {
  # file doesn't exist, we instantiate the override sheet with the 
  # current list
  override <- jira.others
}
# now write the file.
  write_xlsx(list(output=jira.others,override=override),
           path=file.path(jiraanon,"jira.others.xlsx"))


# we used the start and end date here, so write them out
update_latexnums("firstday",firstday)
update_latexnums("lastday",lastday)
#update_latexnums("jiraissues",issues_all)
#update_latexnums("jiramcs",manuscript_all)

