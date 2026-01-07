# Title     : Fetching and prepping statistics on population change for Denmark (this file) and Sweden (se_main)
# Objective : Main file to launch the modules
# Created by: Óskar Daði Jóhannsson based on code from Aleksandrs Aleksandrovs
# Created on: 06/01/2026


library(here)
library(logger)

# Run only if no recent downloaded data is available, because downloads take long time
#Population
source(file.path(here(), "src", "dk/get_dk_yearly_counts.R"), encoding = 'UTF-8', print.eval = TRUE)
#Births
source(file.path(here(), "src", "dk/get_dk_yearly_births.R"), encoding = 'UTF-8', print.eval = TRUE) 
#Mortality
source(file.path(here(), "src", "dk/get_dk_yearly_deaths.R"), encoding = 'UTF-8', print.eval = TRUE)
#Migration
source(file.path(here(), "src", "dk/get_dk_yearly_internal_migration.R"), encoding = 'UTF-8', print.eval = TRUE)

source(file.path(here(), "src", "dk/get_dk_yearly_immigration.R"), encoding = 'UTF-8', print.eval = TRUE)

source(file.path(here(), "src", "dk/get_dk_yearly_emigration.R"), encoding = 'UTF-8', print.eval = TRUE)


#This will call up created data based on above scripts and clean the data for analysis, it will also save a file in dat/final/
source(file.path(here(), "src", "prep_dk_data.R"), encoding = 'UTF-8', print.eval = TRUE)

rm(list = ls())
