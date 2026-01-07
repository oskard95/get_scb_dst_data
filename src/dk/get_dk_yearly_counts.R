# Title     : Fetch and prepare statistics on births,migration,deaths for Denmark
# Objective : Extract tables: DOD: Døde efter køn og alder
# Created by: Aleksandrs Aleksandrovs
# Created on: 2025-02-25
# Status    : Development

library(here)
library(logger)

logger::log_layout(layout_glue_colors)

source(file.path(here(), "src", "settings.R"), encoding = 'UTF-8', print.eval = TRUE)
source(file.path(here(), "src", "functions.R"), encoding = 'UTF-8', print.eval = TRUE)

table <- "FODIE"
get_dst_meta(table, path$raw)
get_dst_data(
  table,
  paste0(
    "https://api.statbank.dk/v1/data/FODIE/BULK?valuePresentation=Code&OMR%C3%85DE=*&Tid=*&modersalder=*&moherk=*&mooprind=*&mostat=*&barnkon=*"),
  path$dst
)


table <- "FOD207"
get_dst_meta(table, path$raw)
get_dst_data(
  table,
  paste0(
    "https://api.statbank.dk/v1/data/FOD207/BULK?valuePresentation=Code&OMR%C3%85DE=*&Alder=*&Tid=*&k%C3%B8n=*"),
  path$dst
)


table <- "FLY66"
get_dst_meta(table, path$raw)
get_dst_data(
  table,
  paste0(
    "https://api.statbank.dk/v1/data/FLY66/BULK?valuePresentation=Code&TILKOMMUNE=*&FRAKOMMUNE=*&ALDER=*&K%C3%98N=*&TID=*"),
  path$dst
)




table <- "VAN1AAR"
get_dst_meta(table, path$raw)
get_dst_data(
  table,
  paste0(
    "https://api.statbank.dk/v1/data/VAN1AAR/BULK?valuePresentation=Code&OMR%C3%85DE=*&K%C3%98N=*&ALDER=*&INDVLAND=*&STATSB=*&Tid=*"),
  path$dst
)


table <- "VAN2AAR"
get_dst_meta(table, path$raw)
get_dst_data(
  table,
  paste0(
    "https://api.statbank.dk/v1/data/VAN2AAR/BULK?valuePresentation=Code&OMR%C3%85DE=*&K%C3%98N=*&UDVLAND=*&STATSB=*&Tid=*&ALDER=*"),
  path$dst
)
dat_raw <- arrow::read_parquet(file.path(path$raw, paste0("raw_", tolower(table), ".parquet")))
src_names <- names(dat_raw)

rm(table, dat_raw, src_names)
