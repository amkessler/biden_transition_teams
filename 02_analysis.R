library(tidyverse)
library(janitor)
library(writexl)

#load saved data from step 01
transition_data_scraped <- readRDS("processed_data/transition_data_scraped.rds")

transition_data_scraped
