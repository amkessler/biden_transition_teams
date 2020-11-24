library(tidyverse)
library(janitor)
library(writexl)

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
  filter(most_recent_employment == "Georgetown University") %>% View()
