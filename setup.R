options(stringsAsFactors = F)

# load needed packages 
requires <- c("here", "tidyverse", "magrittr")
to_install <- c(requires %in% rownames(installed.packages()) == FALSE)
install.packages(c(requires[to_install], "NA"), repos = "https://cloud.r-project.org/")

library(tidyverse)
library(magrittr)
library(ggplot2); theme_set(theme_minimal())
library(here)
