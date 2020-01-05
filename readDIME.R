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
  filter(!is.na(LAST_NAME))

# GET DIME DATA (careful, this is >3GB)
# download.file("https://dataverse.harvard.edu/api/access/datafile/2865300?gbrecs=true", 
#              destfile = here("data/dime_contributors.gz") ) 
# 
# DIME DATA
# dime <- read.csv(here("data/dime_contributors.csv"))

load("data/dime_contributors_1979_2018.rdata")
dime <- contribs
# TRIM DOWN
dime %<>% filter(contributor.type == "I")
names(dime)

dime %>% count(is.na(amount_2018))
dime %<>% mutate(last_name = str_extract(dime$most.recent.contributor.name, "[a-z]*") )

# Subset to last names in d (from )
dime %<>% filter(last_name %in% unique(d$last_name))

# Clean up DIME names
dime %<>% mutate(name = str_replace(most.recent.contributor.name, " dr | jr |[0-9]", " ") )
dime %<>% mutate(name = str_replace(most.recent.contributor.name, "  ", " ") )
dime %<>% mutate(first_name = str_extract(name, ", [a-z][a-z]*") )
dime %<>% mutate(first_name = str_replace(first_name, ", ", ""))
dime %<>% mutate(first_name2 = str_extract(dime$most.recent.contributor.name, ", [a-z]{2}*") )
dime %<>% mutate(middle_initial = str_extract(name, " [a-z]$") )
dime %<>% mutate(middle_initial = str_replace(middle_initial, " ", "") )
dime$first_initial <- str_sub(dime$first_name, 1,1)

# SAVE
save(dime, file = here("data/dime_CGS_matches.Rdata"))