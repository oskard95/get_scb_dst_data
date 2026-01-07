# Title     : Fetch and prepare statistics on deaths for Denmark
# Objective : Extract table DOD: Døde efter køn og alder
# Created by: Aleksandrs Aleksandrovs
# Created on: 2025-02-25
# Status    : Development

library(here)
library(logger)

logger::log_layout(layout_glue_colors)

source(file.path(here(), "src", "settings.R"), encoding = 'UTF-8', print.eval = TRUE)
source(file.path(here(), "src", "functions.R"), encoding = 'UTF-8', print.eval = TRUE)


table <- "FLY66"
get_dst_meta(table, path$raw)
get_dst_data(
  table,
  paste0(
    "https://api.statbank.dk/v1/data/FLY66/BULK?valuePresentation=Code&TILKOMMUNE=*&FRAKOMMUNE=*&ALDER=*&K%C3%98N=*&TID=*"),
  path$raw
)

dat_raw <- arrow::read_parquet(file.path(path$raw, paste0("raw_", tolower(table), ".parquet")))
src_names <- names(dat_raw)

rm(table, dat_raw, src_names)
