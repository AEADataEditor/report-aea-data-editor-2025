# Tabulate the categories

### Load libraries 
### Requirements: have library *here*
source(here::here("global-libraries.R"),echo=TRUE)
source(here::here("programs","config.R"),echo=TRUE)

# Fixes
dcaf_fixes <- read.csv(file.path(jiraanon,"jira_dcaf_fixes.csv"),
                       stringsAsFactors = FALSE)


jira.anon <- readRDS(file=file.path(temp,"jira_anon_fixed.RDS"))

# Load the cleaned JIRA access data
# Still contains multiple categories in the fields
# e.g. "Moderately Easy to Obtain;Moderately Difficult to Obtain;Yes, data can be made available privately"
jira_access_cleaned <- jira.anon %>%
    filter(date_created >= firstday, date_created < lastday,
         Journal != "non-AEA journal",
         ticket != "AEAREP-7453") %>%
    # Keep only if MCStatus contains "CA"
    filter(grepl("CA", MCStatus)) %>%
    # Collapse to to keep the latest value for each ticket by As.Of.Date
    select(ticket, DCAF_Access_Restrictions_V2, As.Of.Date,
           DataAccessReplicationTeam,mc_number_anon,MCStatus,
           Journal) %>%
    group_by(ticket) %>%
    arrange(As.Of.Date,.by_group = TRUE) %>%
    # Keep the last row for each ticket
    dplyr::slice_tail(n = 1) %>%
    ungroup() %>%
    # now grab the latest for each manuscript
    group_by(mc_number_anon) %>%
    mutate(cases = n()) %>%
    arrange(As.Of.Date,.by_group = TRUE) %>%
    # fill in later values if missing with earlier values
    tidyr::fill(DCAF_Access_Restrictions_V2, .direction = "down") %>%
    # fill in with fixes
    left_join(dcaf_fixes, by = "ticket") %>%
    mutate(DCAF_Access_Restrictions_V2 = ifelse(DCAF_Access_Restrictions_V2.x=="",
                                                DCAF_Access_Restrictions_V2.y,
                                                DCAF_Access_Restrictions_V2.x)) %>%
    select(-DCAF_Access_Restrictions_V2.x,-DCAF_Access_Restrictions_V2.y) %>%
    ungroup() %>%
    # Now clean up this field. 
    # It is formatted as a JSON field, needs to be converted to a straight up ";" separated character string
    # Example: [<JIRA CustomFieldOption: value='Very Easy to Obtain', id='10180'>, <JIRA CustomFieldOption: value='Moderately Easy to Obtain', id='10181'>, <JIRA CustomFieldOption: value='Moderately Difficult to Obtain', id='10182'>, <JIRA CustomFieldOption: value='Very Difficult to Obtain', id='10183'>] 
    # Goal: "Very Easy to Obtain;Moderately Easy to Obtain;Moderately Difficult to Obtain;Very Difficult to Obtain"
    mutate(DCAF_Access_Restrictions_V2 = gsub("\\[|\\]", "", DCAF_Access_Restrictions_V2)) %>%
    mutate(DCAF_Access_Restrictions_V2 = stringr::str_extract_all(DCAF_Access_Restrictions_V2, "value='([^']+)'")) %>%
    mutate(DCAF_Access_Restrictions_V2 = sapply(DCAF_Access_Restrictions_V2, function(x) {
      vals <- stringr::str_match(x, "value='([^']+)'")[,2]
      paste(vals, collapse = ";")
    })) %>%
    #
    # Now clean up the shareable
    #
    # if one of the ;-separated fields is "Yes, data can be made available privately", set the variable "Privately shareable" to "Yes"
    dplyr::mutate(Privately_shareable = ifelse(grepl("Yes, data can be made available privately", DCAF_Access_Restrictions_V2), "Yes", "No")) %>%
    # now remove that value from field DCAF_Access_Restrictions_V2
    dplyr::mutate(DCAF_Access_Restrictions_V2 = gsub("Yes, data can be made available privately", "", DCAF_Access_Restrictions_V2)) %>%
    # split the field DCAF_Access_Restrictions_V2 into multiple rows
    tidyr::separate_rows(DCAF_Access_Restrictions_V2, sep = ";") %>%
    # drop rows with empty DCAF_Access_Restrictions_V2
    dplyr::filter(DCAF_Access_Restrictions_V2 != "") %>%
    # remove leading and trailing whitespaces
    dplyr::mutate(DCAF_Access_Restrictions_V2 = stringr::str_trim(DCAF_Access_Restrictions_V2)) %>%
    # recode confused authors
    dplyr::mutate(Privately_shareable = ifelse(DCAF_Access_Restrictions_V2=="No","No",Privately_shareable)) %>%
    dplyr::mutate(DCAF_Access_Restrictions_V2 = 
                    factor(DCAF_Access_Restrictions_V2, 
                           levels = c("No", "Very Easy to Obtain", 
                                      "Moderately Easy to Obtain", 
                                      "Moderately Difficult to Obtain", 
                                      "Very Difficult to Obtain"))) 

# Cross-Tabulate access categories and "Privately shareable"
# with rows coming from the access categories and columns from the "Privately shareable" variable
# and count the number of occurrences
# Order should be: No, Very Easy to Obtain, Moderately Easy to Obtain, Moderately Difficult to Obtain, Very Difficult to Obtain   
	
access_table <- jira_access_cleaned %>%
    dplyr::count(DCAF_Access_Restrictions_V2, Privately_shareable) %>%
    tidyr::pivot_wider(names_from = Privately_shareable, values_from = n, values_fill = list(n = 0)) %>%
    dplyr::mutate(Total = Yes + No) 


## Save the jira_access_cleaned file for later use

saveRDS(jira_access_cleaned, 
        file = file.path(jiraanon, "jira_access_cleaned.RDS"))
write_csv(jira_access_cleaned, 
          file = file.path(jiraanon, "jira_access_cleaned.csv"))
