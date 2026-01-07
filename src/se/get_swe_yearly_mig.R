library(pxweb)
library(tidyverse)
library(jsonlite)
library(here)
library(logger)
source(file.path(here(), "src", "settings.R"), encoding = 'UTF-8', print.eval = TRUE)
Sys.setlocale(locale="UTF-8") 


#migration
#the API link to the death count data we need
io_url <- "https://api.scb.se/OV0104/v1/doris/en/ssd/BE/BE0101/BE0101J/Flyttningar97"
# If you want to do your own data call otherwise use provided json query
io_meta <- pxweb_get(io_url)
#create the query object
io_q_list <-
  list(
    "Region" = "*",
    "Alder" = "*",
    "Tid" = "*",
    "ContentsCode" = c("BE0101AX","BE0101AY","BE0101A2","BE0101A3")
  )
io_q <- pxweb_query(io_q_list)
#Validate the query above with the metadata to make sure nothing is wrong.
pxweb_validate_query_with_metadata(io_q, io_meta)
#Download the data - it might take some time.
io_dati <- pxweb_get(io_url, io_q)
#Construct the data frame
io_df <- as.data.frame(io_dati, column.name.type = "text", variable.value.type = "text")

#Save the data.
fname <- "swe_migration"
arrow::write_parquet(
  io_df,
  file.path(path$scb,paste0(fname,".parquet"))
)
# save(io_df, file = paste0(path$scb,"swe_migration.RData"))