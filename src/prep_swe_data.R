#manage data
library(here)
library(tidyverse)
source(file.path(here(), "src", "settings.R"), encoding = 'UTF-8', print.eval = TRUE)
source(file.path(here(), "src", "se_geo_data.R"))

# load("Data/swe/population/swe_population.RData")
# raw_folk1a <- arrow::open_dataset(file.path(path$dst, "raw_folk1a.parquet"))


pop_df <- arrow::open_dataset(file.path(path$scb,"swe_population.parquet")) %>% collect()

p1 <- pop_df %>% 
  filter(grepl("M07",month)) %>% 
  mutate(year = as.character(str_remove(month, "M07")),
         age = as.numeric(str_remove_all(age, "[A-Za-z-+]"))) %>% 
  rename(mid.pop = `Number`) %>% 
  select(-month) %>% 
  filter(age != "total",
         !grepl("county", region)) %>% 
  group_by(region ,age, year) %>% 
  summarise(mid.pop=sum(mid.pop)) %>% 
  mutate(id_var = paste0(age, "_", year, "_", region)) %>% 
  ungroup()


# load("Data/swe/migration/swe_migration.RData")
# load(paste0(file = paste0(path$scb,"swe_migration.RData")))
io_df <- arrow::open_dataset(file.path(path$scb,"swe_migration.parquet")) %>% collect()

io34 <- io_df %>%
  filter(age != "total",
         !grepl("county", region),
         !grepl("Greater", region)) %>% 
  group_by(region,year) %>% 
  mutate(age = as.numeric(str_remove_all(age, "[A-Za-z-+]")), 
         id_var = paste0(age, "_", year, "_", region)) %>% 
  mutate(migr_ex_in = Immigrations, #International migration
         migr_ex_out = Emigrations, #International outmigration
         migr_in = `Internal Inmigrations`, #Internal inmigration
         migr_out = `Internal Outmigrations`) %>% #internal outmigration
  select(-c(`Internal Outmigrations`, `Internal Inmigrations`, Emigrations, Immigrations))
rm(io_df)


# load(paste0(file = paste0(path$scb,"swe_deaths.RData")))
# load("Data/swe/deaths/swe_deaths.RData")
m2_df <- arrow::open_dataset(file.path(path$scb,"swe_deaths.parquet")) %>% collect()
m2 <- m2_df %>%
  filter( age != "total",
         !grepl("county", region)) %>% 
  group_by(region,year) %>% 
  mutate(age = as.numeric(str_remove_all(age, "[A-Za-z-+]")), 
         id_var = paste0(age, "_", year, "_", region)) %>% 
  rename(deaths = Number)
rm(m2_df)


# load("Data/swe/births/swe_births.RData")
# load(paste0(file = paste0(path$scb,"swe_births.RData")))
b1_df <- arrow::open_dataset(file.path(path$scb,"swe_births.parquet")) %>% collect()

b1 <-  b1_df %>%
  mutate(age = `age of the Mother`) %>% 
  filter(age != "total",
         !grepl("county", region)) %>% 
  group_by(region,year) %>% 
  mutate(age = as.numeric(str_remove_all(age, "[A-Za-z-+]")), 
         id_var = paste0(age, "_", year, "_", region)) %>% 
  select(-`age of the Mother`) %>% 
  rename(births = Number)
rm(b1_df)

swedf <- left_join(x = p1,y = select(b1, -c(age,year,region))) %>% 
  left_join(., y = select(m2, -c(age,year,region))) %>% 
  left_join(., y = select(io34, -c(age,year,region))) %>% 
  rename(municipality = region) %>% 
  select(-id_var) %>% 
  group_by(year,municipality) %>% 
  arrange(year, municipality)
swedf[is.na(swedf)] <- 0
swemodeldf <- swedf %>% full_join(municipalities_se, by = c("municipality" = c("municipality_name")))
rm(swedf,b1,io34,m2,p1)

# dput(swemodeldf, file = "dat/final/se_df.R")

fname <- "se_df"
arrow::write_parquet(
  swemodeldf,
  file.path(
    path$fin, paste0(fname,".parquet"))
)