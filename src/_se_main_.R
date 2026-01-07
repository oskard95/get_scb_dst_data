# Title     : Fetching and prepping statistics on deaths for Denmark and Sweden
# Objective : Main file to launch the modules
# Created by: Aleksandrs Aleksandrovs
# Created on: 22-02-2021


library(here)
library(logger)


#Population
source(file.path(here(), "src", "se/get_swe_yearly_counts.R"), print.eval = TRUE)
#Births
source(file.path(here(), "src", "se/get_swe_yearly_births.R"), print.eval = TRUE) 
#Mortality
source(file.path(here(), "src", "se/get_swe_yearly_deaths.R"), print.eval = TRUE)
#Migration
source(file.path(here(), "src", "se/get_swe_yearly_mig.R"), print.eval = TRUE)




# Run only if no recent downloaded data is available, because downloads take long time
# source(file.path(here(), "src", "get_swe_population.R"), encoding = 'UTF-8', print.eval = TRUE) # Under development
source(file.path(here(), "src", "prep_swe_data.R"), encoding = 'UTF-8', print.eval = TRUE)

rm(list = ls())
