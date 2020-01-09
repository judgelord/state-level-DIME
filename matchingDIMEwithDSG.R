ssh -Y judgelord@linstat.ssc.wisc.edu


cd ../../../project/judgelord/state-level-DIME
ls
git pull
R

library(here)
source(here("setup.R"))

# LOAD DIME (FROM readDIME.R)
load(here("data/dime_CGS_matches.Rdata"))

# inspect
dime %>% select(last_name, first_name, middle_initial, most.recent.contributor.name) %>% top_n(100) %>% kable()

dime %<>% mutate_if(is.factor, as.character)

dime$most.recent.contributor.zipcode %>% head() %>% str_squish() %<>% str_sub(1,5) 
dime$most.recent.contributor.zipcode %<>% str_squish() %<>% str_sub(1,5) 
#######################################################
# CGS #
#######
d <- readxl::read_xlsx(here("data/CSG Directory.xlsx")) %>% 
  filter(!is.na(LAST_NAME)) %>%
  mutate(id = row_number(), 
         match = NA) %>% # add id
  rename(WORK_CITY = CITY) %>% 
  rename(WORK_ADDRESS_1 = ADDRESS_1) %>%
  rename(WORK_ADDRESS_2 = ADDRESS_2) 

original <- d %<>% 
  mutate(last_name = tolower(LAST_NAME) ) %>%
  mutate(first_name = tolower(FIRST_NAME) )
d <- original

# d %<>% mutate(name = tolower(paste0(LAST_NAME,", ",FIRST_NAME))) 
# d %<>% mutate(name2 = tolower(paste0(LAST_NAME,", ",FIRST_NAME, MIDDLE_NAME)))
# CGSnames <- c(unique(d$name), unique() )

# shared var names
names(dime)[names(dime) %in% names(d)]


# zip = most restrictive match = 61, 130
head(d$ZIP)
head(dime$most.recent.contributor.zipcode)
d %<>% mutate(most.recent.contributor.zipcode = ZIP)
d1 <- inner_join(d, dime) %>% mutate(match_method = "fullname-zip")
write.csv(d1 %>% select(match, LAST_NAME, FIRST_NAME, MIDDLE_NAME, most.recent.contributor.name, WORK_CITY, most.recent.contributor.city, WORK_ADDRESS_1,WORK_ADDRESS_2,most.recent.contributor.address, most.recent.contributor.occupation, most.recent.contributor.employer, bonica.cid, id), 
          "data/DIME-DSG-fullname-zip-matches.csv")
d %<>% filter(!id %in% d1$id)

# city = next most restrictive = 765, 667, 1196, 937
d %<>% select(-most.recent.contributor.zipcode)
d %<>% mutate(most.recent.contributor.city = tolower(WORK_CITY))
d2 <- inner_join(d, dime) %>% mutate(match_method = "fullname-city")
write.csv(d2 %>% select(match, LAST_NAME, FIRST_NAME, MIDDLE_NAME, most.recent.contributor.name, WORK_CITY, most.recent.contributor.city, WORK_ADDRESS_1,WORK_ADDRESS_2,most.recent.contributor.address, most.recent.contributor.occupation, most.recent.contributor.employer, bonica.cid, id), 
          "data/DIME-DSG-fullname-city-matches.csv")
d %<>% filter(!id %in% d2$id)

# state = next most restrictive match = 4130, 2182, 2964
d %<>% select(-most.recent.contributor.city)
d %<>% mutate(most.recent.contributor.state = STATE_PROVINCE)
d3 <- inner_join(d, dime) %>% mutate(match_method = "fullname-state")
write.csv(d2 %>% select(match, LAST_NAME, FIRST_NAME, MIDDLE_NAME, most.recent.contributor.name, WORK_CITY, most.recent.contributor.city, WORK_ADDRESS_1,WORK_ADDRESS_2,most.recent.contributor.address, most.recent.contributor.occupation, most.recent.contributor.employer, bonica.cid, id), 
          "data/DIME-DSG-fullname-state-matches.csv")
d %<>% filter(!id %in% d3$id)

# NOW JUST FIRST INITIAL 
# restore if you want to include those matched above (this means duplicates)
# d <- original
d$first_initial <- str_sub(d$first_name, 1,1)
d %<>% select(-first_name)



# zip = most restrictive match = 78
# d %<>% select(-most.recent.contributor.state)
d %<>% mutate(most.recent.contributor.zipcode = ZIP)
d4 <- inner_join(d, dime) %>% mutate(match_method = "first-initial-zip")
write.csv(d4 %>% select(match, LAST_NAME, FIRST_NAME, MIDDLE_NAME, most.recent.contributor.name, WORK_CITY, most.recent.contributor.city, WORK_ADDRESS_1,WORK_ADDRESS_2,most.recent.contributor.address, most.recent.contributor.occupation, most.recent.contributor.employer, bonica.cid, id), 
          "data/DIME-DSG-first-initial-zip-matches.csv")
d %<>% filter(!id %in% d4$id)

# city = next most restrictive = 765, 667, 813
d %<>% select(-most.recent.contributor.zipcode)
d %<>% mutate(most.recent.contributor.city = tolower(WORK_CITY))
d5 <- inner_join(d, dime) %>% mutate(match_method = "first-initial-city")
write.csv(d5 %>% select(match, LAST_NAME, FIRST_NAME, MIDDLE_NAME, most.recent.contributor.name, WORK_CITY, most.recent.contributor.city, WORK_ADDRESS_1,WORK_ADDRESS_2,most.recent.contributor.address, most.recent.contributor.occupation, most.recent.contributor.employer, bonica.cid, id), 
          "data/DIME-DSG-first-initial-city-matches.csv")
d %<>% filter(!id %in% d5$id)

# state = next most restrictive match = 4130, 2182, 2690
d %<>% select(-most.recent.contributor.city)
d %<>% mutate(most.recent.contributor.state = STATE_PROVINCE)
d6 <- inner_join(d, dime) %>% mutate(match_method = "fullname-state")
write.csv(d6 %>% select(match, LAST_NAME, FIRST_NAME, MIDDLE_NAME, most.recent.contributor.name, WORK_CITY, most.recent.contributor.city, WORK_ADDRESS_1,WORK_ADDRESS_2,most.recent.contributor.address, most.recent.contributor.occupation, most.recent.contributor.employer, bonica.cid, id), 
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
df %<>% select(potential_matches, match, LAST_NAME, FIRST_NAME, MIDDLE_NAME, most.recent.contributor.name, EMAIL, CATEGORY, most.recent.contributor.occupation, DEPARTMENT, most.recent.contributor.employer, WORK_CITY, most.recent.contributor.city, WORK_ADDRESS_1,WORK_ADDRESS_2,most.recent.contributor.address, DSG.id, bonica.cid)
# write out best guesses in order
write.csv(df, 
          "data/DIME-DSG-matches.csv")

n_distinct(df)

# top professions
df %>% group_by(most.recent.contributor.occupation) %>% 
  summarise(n = n()) %>% arrange(-n)







