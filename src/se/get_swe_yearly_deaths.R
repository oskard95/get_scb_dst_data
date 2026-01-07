library(pxweb)
library(tidyverse)
library(jsonlite)
library(here)
library(logger)
source(file.path(here(), "src", "settings.R"), encoding = 'UTF-8', print.eval = TRUE)

Sys.setlocale(locale="UTF-8") 


#Mortality
#the API link to the death count data we need
m2_url <- "https://api.scb.se/OV0104/v1/doris/en/ssd/BE/BE0101/BE0101I/DodaFodelsearK"
# If you want to do your own data call otherwise use provided json query
m2_meta <- pxweb_get(m2_url)
#create the query object
m2_q_list <-
  list(
    "Region" = "*",
    "Alder" = "*",
    "Tid" = "*",
    "ContentsCode" = "*"
  )
m2_q <- pxweb_query(m2_q_list)
#Validate the query above with the metadata to make sure nothing is wrong.
pxweb_validate_query_with_metadata(m2_q, m2_meta)
#Download the data - it might take some time.
m2_dati <- pxweb_get(m2_url, m2_q)
#Construct the data frame
m2_df <- as.data.frame(m2_dati, column.name.type = "text", variable.value.type = "text")


fname <- "swe_deaths"
arrow::write_parquet(
  m2_df,
  file.path(path$scb,paste0(fname,".parquet"))
)
# save(m2_df, file = paste0(path$scb,"swe_deaths.RData"))
