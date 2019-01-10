
library(here)
source(here("setup.R"))

# GET DIME DATA (careful, this is >3GB)
# download.file("https://dataverse.harvard.edu/api/access/datafile/2865300?gbrecs=true", 
#              destfile = here("data/dime_contributors.gz") ) 
# 
# DIME DATA
# dime <- read.csv(here("data/dime_contributors.csv"))

# TRIM DOWN
# dime %<>% filter(contributor.type == "I")
# dime %<>% mutate(last_name = str_extract(dime$most.recent.contributor.name, "[a-z]*") )
# dime %<>% filter(last_name %in% d$last_name)

# Clean up DIME names 
# dime %<>% mutate(name = str_replace(most.recent.contributor.name, " dr | jr |[0-9]", " ") )
# dime %<>% mutate(name = str_replace(most.recent.contributor.name, "  ", " ") )
# dime %<>% mutate(first_name = str_extract(name, ", [a-z][a-z]*") )
# dime %<>% mutate(first_name = str_replace(first_name, ", ", ""))
# dime %<>% mutate(first_name2 = str_extract(dime$most.recent.contributor.name, ", [a-z]{2}*") )
# dime %<>% mutate(middle_initial = str_extract(name, " [a-z]$") )
# dime %<>% mutate(middle_initial = str_replace(middle_initial, " ", "") )
# dime$first_initial <- str_sub(dime$first_name, 1,1)

# SAVE
# save(dime, file = here("data/dime_CGS_matches.Rdata"))

# LOAD
# load(here("data/dime_CGS_matches.Rdata"))

# inspect
cbind(
  dime$last_name[1:100],
  dime$first_name[1:100],
  dime$middle_initial[1:100],
  dime$most.recent.contributor.name[1:100])


#######################################################
# CGS #
#######
d <- readxl::read_xlsx(here("data/CSG-Directory.xlsx")) %>% 
  filter(!is.na(LAST_NAME)) %>%
  mutate(id = row_number(), match = NA) %>%
  select(-num.records, -num.distinct, -contributor.cfscore) 

original <- d %<>% 
  mutate(last_name = tolower(LAST_NAME) ) %>%
  mutate(first_name = tolower(FIRST_NAME) )

# d %<>% mutate(name = tolower(paste0(LAST_NAME,", ",FIRST_NAME))) 
# d %<>% mutate(name2 = tolower(paste0(LAST_NAME,", ",FIRST_NAME, MIDDLE_NAME)))
# CGSnames <- c(unique(d$name), unique() )

names(dime)[names(dime) %in% names(d)]


# zip = most restrictive match = 61
d %<>% mutate(most.recent.contributor.zipcode = as.integer(ZIP)) 
d1 <- inner_join(d, dime) 
write.csv(d1 %>% select(match, LAST_NAME, FIRST_NAME, MIDDLE_NAME, most.recent.contributor.name, `WORK CITY`, most.recent.contributor.city, `WORK ADDRESS_1`,`WORK ADDRESS_2`,most.recent.contributor.address, most.recent.contributor.occupation, most.recent.contributor.employer, bonica.cid, id), 
          "data/DIME-DSG-fullname-zip-matches.csv")
d %<>% filter(!id %in% d1$id)

# city = next most restrictive = 765, 667
d %<>% select(-most.recent.contributor.zipcode)
d %<>% mutate(most.recent.contributor.city = tolower(`WORK CITY`))
d2 <- inner_join(d, dime) 
write.csv(d2 %>% select(match, LAST_NAME, FIRST_NAME, MIDDLE_NAME, most.recent.contributor.name, `WORK CITY`, most.recent.contributor.city, `WORK ADDRESS_1`,`WORK ADDRESS_2`,most.recent.contributor.address, most.recent.contributor.occupation, most.recent.contributor.employer, bonica.cid, id), 
          "data/DIME-DSG-fullname-city-matches.csv")
d %<>% filter(!id %in% d2$id)

# state = next most restrictive match = 4130, 2182
d %<>% select(-most.recent.contributor.city)
d %<>% mutate(most.recent.contributor.state = STATE_PROVINCE)
d3 <- inner_join(d, dime) 
write.csv(d2 %>% select(match, LAST_NAME, FIRST_NAME, MIDDLE_NAME, most.recent.contributor.name, `WORK CITY`, most.recent.contributor.city, `WORK ADDRESS_1`,`WORK ADDRESS_2`,most.recent.contributor.address, most.recent.contributor.occupation, most.recent.contributor.employer, bonica.cid, id), 
          "data/DIME-DSG-fullname-state-matches.csv")
d %<>% filter(!id %in% d3$id)

# NOW JUST FIRST INITIAL 
# restore
d <- original
d$first_initial <- str_sub(d$first_name, 1,1)
d %<>% select(-first_name)



# zip = most restrictive match = 61
# d %<>% select(-most.recent.contributor.state)
d %<>% mutate(most.recent.contributor.zipcode = as.integer(ZIP)) 
d4 <- inner_join(d, dime) 
write.csv(d4 %>% select(match, LAST_NAME, FIRST_NAME, MIDDLE_NAME, most.recent.contributor.name, `WORK CITY`, most.recent.contributor.city, `WORK ADDRESS_1`,`WORK ADDRESS_2`,most.recent.contributor.address, most.recent.contributor.occupation, most.recent.contributor.employer, bonica.cid, id), 
          "data/DIME-DSG-first-initial-zip-matches.csv")
d %<>% filter(!id %in% d4$id)

# city = next most restrictive = 765, 667
d %<>% select(-most.recent.contributor.zipcode)
d %<>% mutate(most.recent.contributor.city = tolower(`WORK CITY`))
d5 <- inner_join(d, dime) 
write.csv(d5 %>% select(match, LAST_NAME, FIRST_NAME, MIDDLE_NAME, most.recent.contributor.name, `WORK CITY`, most.recent.contributor.city, `WORK ADDRESS_1`,`WORK ADDRESS_2`,most.recent.contributor.address, most.recent.contributor.occupation, most.recent.contributor.employer, bonica.cid, id), 
          "data/DIME-DSG-first-initial-city-matches.csv")
d %<>% filter(!id %in% d5$id)

# state = next most restrictive match = 4130, 2182
d %<>% select(-most.recent.contributor.city)
d %<>% mutate(most.recent.contributor.state = STATE_PROVINCE)
d6 <- inner_join(d, dime) 
write.csv(d6 %>% select(match, LAST_NAME, FIRST_NAME, MIDDLE_NAME, most.recent.contributor.name, `WORK CITY`, most.recent.contributor.city, `WORK ADDRESS_1`,`WORK ADDRESS_2`,most.recent.contributor.address, most.recent.contributor.occupation, most.recent.contributor.employer, bonica.cid, id), 
          "data/DIME-DSG-fullname-state-matches.csv")
d %<>% filter(!id %in% d6$id)


## COMBINE TO WRITE OUT 
df <- rbind(d1,d4,d2, d5, d3, d6) 
df %<>% group_by(id) %>%
  mutate(potential_matches = n()) %>% 
  ungroup()  # %>%  arrange(-potential_matches)
sum(df$potential_matches>1)
df %<>% rename(DSG.id = id)

# select 
df %<>% select(potential_matches, match, LAST_NAME, FIRST_NAME, MIDDLE_NAME, most.recent.contributor.name, most.recent.contributor.occupation, most.recent.contributor.employer, `WORK CITY`, most.recent.contributor.city, `WORK ADDRESS_1`,`WORK ADDRESS_2`,most.recent.contributor.address, bonica.cid, DSG.id)
# write out best guesses in order
write.csv(df, 
          "data/DIME-DSG-matches.csv")