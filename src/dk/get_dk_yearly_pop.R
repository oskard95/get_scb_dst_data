# Title     : Fetch and prepare Denmark population data
# Objective : Exctract and create entire population counts split on NUTS-3, age and sex
# Created by: Aleksandrs Aleksandrovs
# Created on: 09-02-2022
# Status    : Development

library(here)

source(file.path(here(), "src", "settings.R"), encoding = 'UTF-8', print.eval = TRUE)
source(file.path(here(), "src", "functions.R"), encoding = 'UTF-8', print.eval = TRUE)

# Folk1A - Population at the first day of the quarter
# Warning: takes long time to download the data
table <- "Folk1A"
get_dst_meta(table, path$raw)
get_dst_data(
  table,
  "https://api.statbank.dk/v1/data/FOLK1A/BULK?lang=en&valuePresentation=Code&OMR%C3%85DE=*&K%C3%98N=*&ALDER=*&CIVILSTAND=TOT&Tid=*",
  path$raw
)

# 
# # FAM122N
# # Warning: takes long time to download the data
# table <- "FAM122N"
# get_dst_meta(table, path$raw)
# get_dst_data(
#   table,
#   "https://api.statbank.dk/v1/data/FAM122N/BULK?lang=en&valuePresentation=Code&OMR%C3%85DE=*&K%C3%98N=*&ALDER=*&Tid=*&HUSTYP=*&ANTPERSH=*&ANTBORNH=*",
#   path$raw
# )
# 
# 
# # FAM133N
# # Warning: takes long time to download the data
# table <- "FAM133N"
# get_dst_meta(table, path$raw)
# get_dst_data(
#   table,
#   "https://api.statbank.dk/v1/data/FAM133N/BULK?lang=en&valuePresentation=Code&OMR%C3%85DE=*&HUSTYP=*&ANTPERSH=*&ANTBORNH=*&K%C3%98N=*&ALDER=*&Tid=*",
#   path$raw)

# 
# # SOGN1
# table <- "SOGN1"
# get_dst_meta(table, path$raw)
# get_dst_data(
#   table,
#   "https://api.statbank.dk/v1/data/SOGN1/BULK?lang=en&valuePresentation=Code&SOGN=*&K%C3%98N=*&ALDER=*&Tid=*",
#   path$raw
# )
# 

# BY2
table <- "BY2"
get_dst_meta(table, path$raw)
get_dst_data(
  table,
  "https://api.statbank.dk/v1/data/BY2/BULK?lang=en&valuePresentation=Code&KOMK=*&ALDER=*&K%C3%98N=*&Tid=*&BYST=*",
  path$raw
)

rm(table)