library(tidyverse)
library(httr)  
library(rvest) 
library(janitor)
library(writexl)

#set url for nominees list page
myurl <- 'https://buildbackbetter.com/the-administration/nominees-and-appointees/'
#perform the GET call
website1 <- GET(myurl) 
#determine how many names on the page exist to be captureds
n <- html_nodes(content(website1), "h3")
num_names <- length(n)
num_names



### STEP BY STEP FOR ONCE ####

#set url for nominees list page
url <- 'https://buildbackbetter.com/the-administration/nominees-and-appointees/'

#perform the GET call
website1 <- GET(url)

#let's see what we have in content
print(content(website1))


#grab the names
names <- html_nodes(content(website1), "h3")
#show them all
print(html_text(names, trim = TRUE))
#show just one
name1 <- print(html_text(names, trim = TRUE)[[1]])
name1


#grab the titles
titles <- html_nodes(content(website1), "h4")
#show them all
print(html_text(titles, trim = TRUE))
#show just one
title1 <- print(html_text(titles, trim = TRUE)[[1]])
title1


#grab the links
links <- html_nodes(content(website1), "a.full-link")
#show them all
html_attr(links, 'href')
#show just one
link1 <- html_attr(links, 'href')[[1]]
link1


df <- data.frame("name" = name1, "title" = title1, "link" = link1)
df



### FUNCTION FOR SCRAPING NAMES ####

#set url for transition list page
scrape_names <- function(namenum) {
  #set url for nominees list page
  url <- 'https://buildbackbetter.com/the-administration/nominees-and-appointees/'
  #perform the GET call
  website1 <- GET(url)
  #grab the names
  names <- html_nodes(content(website1), "h3")
  #isolate just one
  name1 <- print(html_text(names, trim = TRUE)[[1]])
  name1
  
  
  #grab the titles
  titles <- html_nodes(content(website1), "h4")
  #show them all
  print(html_text(titles, trim = TRUE))
  #show just one
  title1 <- print(html_text(titles, trim = TRUE)[[1]])
  title1
  
  
  #grab the links
  links <- html_nodes(content(website1), "a.full-link")
  #show them all
  html_attr(links, 'href')
  #show just one
  link1 <- html_attr(links, 'href')[[1]]
  link1
  

}

#run function once
scrape_table(1)



#### LOOP THROUGH ALL TABLES ####

#we'll use the map function to loop through all the tables at once and combine

#above we measured how many tables were on the page
num_tables
#we'll use this variable to determine how many table numbers we'll want
num_sequence <- seq(1, num_tables)
num_sequence

#now we'll feed the sequence of numbers into the function
transition_data_scraped <- map_df(num_sequence, scrape_table)

transition_data_scraped

#add a unique ID field string
transition_data_scraped <- transition_data_scraped %>% 
  mutate(
    idstring = str_trim(paste0(name, most_recent_employment, agency))
  )



#save results
saveRDS(transition_data_scraped, "processed_data/transition_data_scraped.rds")
write_xlsx(transition_data_scraped, "processed_data/transition_data_scraped.xlsx")


#save archived copy to use for identifying changes later on
filestring <- paste0("archived_data/transition_data_archived_", Sys.time(), ".rds")
filestring <- str_replace_all(filestring, "-", "_")
filestring <- str_replace_all(filestring, ":", "_")
filestring <- str_replace(filestring, " ", "t")

saveRDS(transition_data_scraped, filestring)



