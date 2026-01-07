library(here)
library(tidyverse)
source(file.path(here(), "src", "settings.R"), encoding = 'UTF-8', print.eval = TRUE)
source(file.path(here(), "src", "geo_data.R"))


raw_folk1a <- arrow::open_dataset(file.path(path$dst, "raw_folk1a.parquet"))
raw_folk1a

folk1a <- raw_folk1a |> 
  filter(KØN == "TOT", CIVILSTAND == "TOT") |> 
  group_by(OMRÅDE,ALDER,TID) |>
  summarise(population = sum(INDHOLD)) |>
  collect()|> 
  arrange(ALDER, TID) |> 
  filter(str_ends(TID, "K1|K3"), ALDER != "IALT") |> 
  mutate(ALDER = ifelse(as.numeric(ALDER) >= 100, "100", ALDER)) |>
  group_by(OMRÅDE, ALDER, TID) |>
  summarise(population = sum(population), .groups = "drop") |>
  mutate(year = as.numeric(substr(TID,1,4)),
         quarter = substr(TID, 5,6),
         ALDER = as.numeric(ALDER)
  ) |> 
  select(-TID) |> 
  pivot_wider(values_from = population, names_from = quarter) |> 
  rename("population" = "K1", "mid.pop" = "K3", "mun" = "OMRÅDE", "age" = "ALDER")

# raw_by2 <- arrow::open_dataset(file.path(path$raw, "raw_by2.parquet"))
# by2 <- raw_by2 %>%
#   group_by(KOMK,ALDER,TID) |> 
#   summarise(population = sum(INDHOLD)) |> 
#   collect() |> 
#   arrange(ALDER, TID) 

#Birth counts
raw_fodie <- arrow::open_dataset(file.path(path$dst, "raw_fodie.parquet"))
fodie <- raw_fodie %>%
  group_by(TID,MODERSALDER,OMRÅDE) |>
  summarise(births = sum(INDHOLD)) |>
  collect() |> 
  rename("year" = "TID", "age" = "MODERSALDER", "mun" = "OMRÅDE")

#death counts
raw_fod207 <- arrow::open_dataset(file.path(path$dst, "raw_fod207.parquet"))
fod207 <- raw_fod207 %>%
  group_by(TID,OMRÅDE,ALDER) |>
  summarise(deaths = sum(INDHOLD)) |>
  collect() |> 
  filter(ALDER != "TOT") |>
  mutate(ALDER = as.numeric(ifelse(ALDER == "99-", "99",ALDER))) |> 
  rename("year" = "TID","mun" = "OMRÅDE", "age" = "ALDER")

#International Immigration
raw_van1aar <- arrow::open_dataset(file.path(path$dst, "raw_van1aar.parquet"))
van1aar <- raw_van1aar %>%
  group_by(TID,OMRÅDE,ALDER) |>
  summarise(immigration = sum(INDHOLD)) |>
  collect() |> 
  arrange(ALDER, TID) |> 
  rename("year" = "TID","mun" = "OMRÅDE", "age" = "ALDER") |> 
  mutate(age = ifelse(age >= 100, 100, age)) |>
  group_by(mun, age, year) |>
  summarise(migr_ex_in = sum(immigration), .groups = "drop")

#International Emigration
raw_van2aar <- arrow::open_dataset(file.path(path$dst, "raw_van2aar.parquet"))
van2aar <- raw_van2aar %>%
  group_by(TID,OMRÅDE,ALDER) |>
  summarise(emigration = sum(INDHOLD)) |>
  collect() |> 
  arrange(ALDER, TID) |> 
  rename("year" = "TID","mun" = "OMRÅDE", "age" = "ALDER") |> 
  mutate(age = ifelse(age >= 100, 100, age)) |>
  group_by(mun, age, year) |>
  summarise(migr_ex_out = sum(emigration), .groups = "drop")

#Internal Migration
raw_fly66 <- arrow::open_dataset(file.path(path$dst, "raw_fly66.parquet"))
fly66_in <- raw_fly66 %>%
   group_by(TID,ALDER,TILKOMMUNE) |>
  summarise(inm = sum(INDHOLD)) |>
  collect() |> 
  rename("year" = "TID","mun" = "TILKOMMUNE", "age" = "ALDER") |> 
  mutate(age = ifelse(age >= 100, 100, age)) |>
  group_by(mun, age, year) |>
  summarise(migr_in = sum(inm), .groups = "drop")
#Internal OUmitgration
fly66_out <- raw_fly66 %>%
  group_by(TID,ALDER,FRAKOMMUNE) |>
  summarise(outm = sum(INDHOLD)) |>
  collect() |> 
  rename("year" = "TID","mun" = "FRAKOMMUNE", "age" = "ALDER") |> 
  mutate(age = ifelse(age >= 100, 100, age)) |>
  group_by(mun, age, year) |>
  summarise(migr_out = sum(outm), .groups = "drop")



main_df <- folk1a |> 
  left_join(fodie) |> 
  left_join(fod207) |> 
  left_join(fly66_in) |> 
  left_join(fly66_out) |> 
  left_join(van1aar) |> 
  left_join(van2aar) 
main_df[is.na(main_df)] <- 0



dk_level_sum <- main_df |> 
  filter(mun > 100) |> 
  group_by(year,age) |> 
  summarise(migr_in = sum(migr_in),
            migr_out = sum(migr_out),
            .groups = "drop") %>% 
  arrange(year, age) |> 
  mutate(mun = 0)

main_df <- main_df %>%
  rows_update(
    dk_level_sum %>% select(year, age, mun, migr_in, migr_out),
    by = c("year", "age", "mun")
  )

main_df_muni <- main_df |> full_join(municipalities, by = c("mun" = c("municipality_code")))

rm(main_df,municipalities,dk_level_sum,folk1a,fodie,fod207,fly66_in,fly66_out,van1aar,van2aar,raw_fly66,
   raw_fod207,raw_fodie,raw_folk1a,raw_van1aar,raw_van2aar,path)

# dput(main_df_muni, file = "dat/final/dk_df.R")
fname <- "dk_df"
arrow::write_parquet(
  main_df_muni,
  file.path(
    path$fin, paste0(fname,".parquet"))
  )
