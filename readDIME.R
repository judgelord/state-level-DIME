ssh -Y judgelord@linstat.ssc.wisc.edu


cd ../../../project/judgelord/state-level-DIME
ls
git pull
R

library(here)
source(here("setup.R"))

#######################################################
# CGS #
#######
d <- readxl::read_xlsx(here("data/CSG Directory.xlsx")) %>% 
  as_tibble() %>% 
  filter(!is.na(LAST_NAME)) %>% 
  mutate(last_name = tolower(LAST_NAME) ) 
d
# inspect 
head(d$last_name)

# GET DIME DATA (careful, this is >3GB)
# download.file("https://dataverse.harvard.edu/api/access/datafile/2865300?gbrecs=true", 
#              destfile = here("data/dime_contributors.gz") ) 
# 
# DIME DATA
# dime <- read.csv(here("data/dime_contributors.csv"))

load("data/dime_contributors_1979_2018.rdata")
dime <- contribs %>% as_tibble()

dime %<>% mutate_if(is.factor, as.character)

names(dime)

# TRIM DOWN
dime %<>% filter(contributor.type == "I")

# inspect
dime %>% count(is.na(amount_2018)) # note a lot of 0s here may be NAs because SQL data on PAC data shows incomplete data for 2018 cycle
dime %>% count(amount_2012 == 0)
dime %>% count(amount_2016 == 0)
dime %>% count(amount_2018 == 0)
dime %>% count(bonica.cid, sort = T)

# make last name string 
dime %<>% mutate(last_name = str_extract(dime$most.recent.contributor.name, "[a-z]*") )

# inspect 
head(dime$last_name)

# Subset to last names in d (from data/CSG Directory.xlsx)
dime %<>% filter(last_name %in% unique(d$last_name)) # LAST_NAME?

# inspect
dime

# Clean up DIME names
dime %<>% mutate(name = str_replace(most.recent.contributor.name, " dr | jr |[0-9]", " ") )
dime %<>% mutate(name = str_squish(name))

# first name is any string of more than 2 letters after the comma in the cleaned up dime name
dime %<>% mutate(first_name = str_extract(name, ", [a-z][a-z]*") )
dime %<>% mutate(first_name = str_replace(first_name, ", ", ""))

# alternativly, use the original dime name 
dime %<>% mutate(first_name2 = str_extract(dime$most.recent.contributor.name, ", [a-z][a-z]*") )
dime %<>% mutate(first_name2 = str_replace(first_name2, ", ", ""))

# middle initial is any single character at the end of the name string
dime %<>% mutate(middle_initial = str_extract(name, " [a-z]$") )
dime %<>% mutate(middle_initial = str_replace(middle_initial, " ", "") )

# first initial from first name
dime$first_initial <- str_sub(dime$first_name, 1,1)

dime

# SAVE
save(dime, file = here("data/dime_CGS_matches.Rdata"))
