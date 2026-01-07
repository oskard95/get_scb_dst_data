library(pxweb)
library(tidyverse)
library(jsonlite)
library(here)
library(logger)
source(file.path(here(), "src", "settings.R"), encoding = 'UTF-8', print.eval = TRUE)

Sys.setlocale(locale="UTF-8") 

# pxweb_interactive(pop_url)
#------------------------------
#Births
#the API link to the death count data we need
b1_url <- "https://api.scb.se/OV0104/v1/doris/en/ssd/BE/BE0101/BE0101H/FoddaK"
# If you want to do your own data call otherwise use provided json query
b1_meta <- pxweb_get(b1_url)
#create the query object
b1_q_list <-
  list(
    "Region" = "*",
    "AlderModer" = "*",
    "Tid" = "*",
    "ContentsCode" = "*"
  )
b1_q <- pxweb_query(b1_q_list)
#Validate the query above with the metadata to make sure nothing is wrong.
pxweb_validate_query_with_metadata(b1_q, b1_meta)
#Download the data - it might take some time.
b1_dati <- pxweb_get(b1_url, b1_q)
#Construct the data frame
b1_df <- as.data.frame(b1_dati, column.name.type = "text", variable.value.type = "text")
#Save the data.
fname <- "swe_births"
arrow::write_parquet(
  b1_df,
  file.path(path$scb,paste0(fname,".parquet"))
)
# save(b1_df, file = paste0(path$scb,"swe_births.RData"))
