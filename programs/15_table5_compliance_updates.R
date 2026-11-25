# Tabulate statistics and make graphs for the AEA data editor report
# Harry Son
# 2/18/2021
# Updated by Takshil Sachdev (12/3/2024)

# Inputs
#   - file.path(jiraanon,"jira.anon.RDS") 
#   - file.path(temp,"jira.others.RDS)
# Outputs


### Load libraries 
### Requirements: have library *here*
source(here::here("global-libraries.R"),echo=TRUE)
source(here::here("programs","config.R"),echo=TRUE)

library(stargazer)

jira.noncompliance <- readRDS(file.path(temp,"jira.nc.RDS")) 

jira.noncompliance %>% 
  group_by(`mc_number_anon`) %>%
  summarize(n=n()) %>%
  ungroup() %>%
  # we ignore the n because it is just a trick to get distinct char vars
  summarize(`Non-compliant`=n())  -> summary_compliance

update_latexnums("mcpubnoncompl",summary_compliance$`Non-compliant`)

## Summarize updates - same thing
jira.updates <- readRDS(file.path(temp,"jira.up.RDS"))

jira.updates %>% 
  # this should be grouped by mc_number_anon, but for updates in particular,
  # there is a problem, so we use `ticket`
  group_by(`ticket`) %>%
  summarize(n=n()) %>%
  ungroup() %>%
  summarize(`Updates`=n()) %>%
  ungroup()  %>% pull() -> summary_updates

update_latexnums("mcpubupdates",summary_updates)

# create table by update type

jira.updates %>% 
  # this should be grouped by mc_number_anon, but for updates in particular,
  # there is a problem, so we use `ticket`
  group_by(`Update.type`,ticket) %>%
  summarize(n=n()) %>%
  ungroup() %>%
  group_by(`Update.type`) %>%
  # here we actually allow for multiple updates per MC
  summarize(`Manuscripts`=sum(n)) %>%
  rename(Origin = `Update.type`) %>%
  ungroup() -> update_types

# create table by journal
update_types %>%
  mutate(Manuscripts =replace_na(as.character(Manuscripts),"")) %>%
  stargazer(style = "aer",
            summary = FALSE,
            out = file.path(tables,"n_updates_manuscript.tex"),
            out.header = FALSE,
            float = FALSE,
            rownames = FALSE)

# now for information on NDAs
jira.nda <- readRDS(file.path(temp,"jira.nda.RDS"))

# get at the total count 
nda_types <- jira.nda %>%
  group_by(`Agreement.signed`,mc_number_anon) %>%
  summarize(n=n()) %>%
  ungroup() %>%
  # Replace some strings in Agreement.signed for clarity
  mutate(Type = `Agreement.signed`,
         Type = str_replace_all(Type, 
                                c("NDA; Implicit" = "informal",
                                  "NDA" = "NDA (formal)",
                                  "DUA" = "Data Use Agreement"))) %>%
  # split out Type into multiple rows from semi-colon separated values
  separate_rows(Type, sep = ";\\s*") %>%
  # Now cleanup a bit more
  mutate(Type = case_when(Type == "informal" ~ "NDA (informal)",
                          TRUE ~ Type)) %>%
  group_by(Type) %>%
  summarize(`Manuscripts`=n()) %>%
  ungroup() 

update_latexnums("mcpubnda",sum(nda_types$Manuscripts))

# create table by type
nda_types %>%
  mutate(Manuscripts =replace_na(as.character(Manuscripts),"")) %>%
  select(Type,Manuscripts) %>%
  stargazer(style = "aer",
            summary = FALSE,
            out = file.path(tables,"n_ndas_manuscript.tex"),
            out.header = FALSE,
            float = FALSE,
            rownames = FALSE
  )

# Information by external
jira.external <- readRDS(file.path(temp,"jira.ext.RDS"))

# get at the total count 
jira.external %>%
  group_by(`External.party.name`,mc_number_anon) %>%
  summarize(n=n()) %>%
  ungroup() %>%
  group_by(`External.party.name`) %>%
  # here we do not allow for multiple externals per MC
  summarize(`Manuscripts`=n()) -> jira.external.details

jira.external.details %>%
  mutate(`External.party.name` = if_else(grepl("tudent",`External.party.name`,fixed=TRUE),
                                         "Graduate Student",
                                         `External.party.name`)) %>%
  group_by(`External.party.name`) %>%
  summarize(`Manuscripts` = sum(Manuscripts)) -> external_types

update_latexnums("mcpubexternal",sum(external_types$Manuscripts))

# create table by type
external_types %>%
  mutate(Manuscripts =replace_na(as.character(Manuscripts),"")) %>%
  stargazer(style = "aer",
            summary = FALSE,
            out = file.path(tables,"n_externals_manuscript.tex"),
            out.header = FALSE,
            float = FALSE,
            rownames = FALSE)
