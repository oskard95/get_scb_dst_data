library(pxweb)
library(tidyverse)
library(jsonlite)
library(here)
library(logger)
source(file.path(here(), "src", "settings.R"), encoding = 'UTF-8', print.eval = TRUE)

Sys.setlocale(locale="UTF-8") 

#population counts
#the API link to the  count data we need
pop_url <- "https://api.scb.se/OV0104/v1/doris/en/ssd/BE/BE0101/BE0101A/BefolkManad"
# If you want to do your own data call otherwise use provided json query
pop_meta <- pxweb_get(pop_url)
#create the query object
pop_q_list <-
  list(
    "Region" = "*",
    "Alder" = "*",
    "Tid" = "*",
    "ContentsCode" = c("000003O5")
  )
pop_q <- pxweb_query(pop_q_list)
#Validate the query above with the metadata to make sure nothing is wrong.
pxweb_validate_query_with_metadata(pop_q, pop_meta)
#Download the data - it might take some time.
pop_dati <- pxweb_get(pop_url, pop_q)
#Construct the data frame
pop_df <- as.data.frame(pop_dati, column.name.type = "text", variable.value.type = "text")
#Save the data.
fname <- "swe_population"
arrow::write_parquet(
  pop_df,
  file.path(path$scb,paste0(fname,".parquet"))
)
# save(pop_df, file = paste0(path$scb,"swe_population.RData"))

