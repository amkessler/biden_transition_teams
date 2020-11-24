library(tidyverse)
library(janitor)
library(writexl)


#### AGENCY TEAMS ##### --------------------------

#load saved data from step 01
transition_data_scraped <- readRDS("processed_data/transition_data_scraped.rds")

#some names have title after denoting they are the team lead
#we'll capture that and remove title from name field
agencyteams <- transition_data_scraped %>% 
  mutate(
    team_lead = if_else(str_detect(name, "Team Lead"), "Y", ""),
    name = str_remove(name, ", Team Lead")
  ) %>% 
  select(agency, name, team_lead, everything())

agencyteams

#export for sharing
agencyteams %>% 
  select(-idstring) %>% 
  write_xlsx("output/agencyreviewteams.xlsx")


#quick counts
agencyteams %>% 
  count(agency, sort = TRUE)

agencyteams %>% 
  count(most_recent_employment, sort = TRUE)

agencyteams %>% 
  count(source_of_funding, sort = TRUE)


count_of_employment <- agencyteams %>% 
  count(most_recent_employment, sort = TRUE)
count_of_employment
#note: the employment field likely needs to be standardized...Deliotte, etc

agencyteams %>% 
  filter(most_recent_employment == "Georgetown University") 



### COMPARE agency teams with archived to find changes #### -------------------

#load current data
transition_data_current <- readRDS("processed_data/transition_data_scraped.rds")
transition_data_current

# load archived data to compare against
transition_data_previous <- readRDS("archived_data/transition_data_archived_2020_11_24t09_52_05.rds")
transition_data_previous

#find new records added since previous
anti_join(transition_data_current, transition_data_previous, by = "idstring")

#compare departments by totals 
agencycount_current <- transition_data_current %>% 
  count(agency, name = "current_count")

agencycount_current

agencycount_previous <- transition_data_previous %>% 
  count(agency, name = "previous_count")

agencycount_previous

#join
agencycount_compare <- left_join(agencycount_current, agencycount_previous, by = "agency")
agencycount_compare

#add change columns
agencycount_compare <- agencycount_compare %>% 
  mutate(
    change = current_count - previous_count
  )

#export for sharing
write_xlsx(agencycount_compare, "output/agencycount_compare.xlsx")





