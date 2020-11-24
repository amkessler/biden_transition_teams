library(tidyverse)
library(janitor)
library(writexl)


#### AGENCY TEAMS ##### --------------------------------------------------------


### COMPARE agency teams with previous version to find changes ######

#load current data
transition_data_current <- readRDS("processed_data/transition_data_scraped.rds")
transition_data_current

# load archived data to compare against
transition_data_previous <- readRDS("archived_data/transition_data_archived_2020_11_24t09_52_05.rds")
transition_data_previous

#find new records of names added since previous
anti_join(transition_data_current, transition_data_previous, by = "idstring")


#compare totals by department 
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



#### Analysis ############

#we'll create a newly named object to use from here on out 
agencyteams <- transition_data_current

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


employers_count <- agencyteams %>% 
  count(most_recent_employment, sort = TRUE)
employers_count
#note: the employment field likely needs to be standardized...Deliotte, etc

agencyteams %>% 
  filter(most_recent_employment == "Georgetown University") 


