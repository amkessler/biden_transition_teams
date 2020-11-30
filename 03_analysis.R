library(tidyverse)
library(janitor)
library(readxl)
library(writexl)

#to run new scrape(s), uncomment out one or both of these lines
#otherwise can leave commented out and use existing saved datasets

source("01_scrape_agencyteams.R")
# source("02_scrape_nominees.R")



#### AGENCY TEAMS ##### --------------------------------------------------------


### COMPARE agency team members with previous archived version ######

#load current data
transition_data_current <- readRDS("processed_data/transition_data_scraped.rds")
transition_data_current

# load archived data to compare against
transition_data_previous <- readRDS("archived_data/transition_data_archived_2020_11_26t10_19.rds")
# transition_data_previous <- readRDS("archived_data/transition_data_archived_2020_11_25t09_34.rds")
transition_data_previous

#find new records of names added since previous
newnames <- anti_join(transition_data_current, transition_data_previous, by = "idstring")

newnames # %>% View()



transition_data_current %>% 
  count(source_of_funding)

transition_data_previous %>% 
  count(source_of_funding)



# Compare totals by department #######
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




#### Analysis of current agency team members ############

#we'll create a newly named object to use from here on out 
agencyteams <- transition_data_current


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



### Employer Standardization ####

#create lookup table to work on separately for employer standardization
forlookup <- agencyteams %>% 
  count(most_recent_employment)

## use manually standardized lookup table to then match with
standardization_lookup <- read_excel("processed_data/agencyreviewteam_standardization_lookup.xlsx")

#join to main agencyteams table
agencyteams <- left_join(agencyteams, standardization_lookup, by = "most_recent_employment")

#move new columns further left
agencyteams <- agencyteams %>% 
  select(1:5,
         most_recent_employment_standardized,
         employment_retired_indicated,
         everything())
        
#flag if any didn't join
agencyteams %>% 
  filter(is.na(most_recent_employment_standardized))
  


### SAVE RESULTS #### 

#names of new agency review team members
saveRDS(newnames, "processed_data/newnames.rds")

#aggregate county of agency totals compared
saveRDS(agencycount_compare, "processed_data/agencycount_compare.rds")

#entire combined agency teams file
saveRDS(agencyteams, "processed_data/agencyteams.rds")


### EXPORT EXCEL FILES FOR SHARING #### ----------------

#names of new agency review team members
newnames %>% 
  select(-idstring, -namestring) %>% 
  write_xlsx("output/newnames.xlsx")

#aggregate county of agency totals compared
agencycount_compare %>% 
  write_xlsx("output/agencycount_compare.xlsx")

#entire combined agency teams file
agencyteams %>% 
  select(-idstring, -namestring) %>% 
  write_xlsx("output/agencyreviewteams.xlsx")

#lookup file to standarize separately
forlookup %>% 
  write_xlsx("output/forlookup.csv")
