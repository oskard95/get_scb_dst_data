library(here)
library(arrow)
library(dplyr)
library(tidyr)
library(data.table)
source(file.path(here(), "src", "settings.R"), encoding = 'UTF-8', print.eval = TRUE)

# Initialize metadata list
meta <- list()

# Load and prepare geographic codes
meta <- within(meta, {
  geo_codes <- fread(file.path(path$wd, "doc", "scb_regions_kommunes.csv"), 
                     encoding = 'UTF-8')
  geo_codes <- geo_codes %>% 
    select(KODE, NIVEAU, TITEL)
})

# Initialize NUTS columns
meta$geo_codes$nuts2 <- ""
meta$geo_codes$nuts2_label <- ""
meta$geo_codes$nuts3 <- ""
meta$geo_codes$nuts3_label <- ""

# Process hierarchical structure
nuts2_code <- ""
nuts2_label <- ""
nuts3_code <- ""
nuts3_label <- ""

for (i in seq_along(meta$geo_codes$KODE)) {
  current_level <- meta$geo_codes$NIVEAU[i]
  current_code <- meta$geo_codes$KODE[i]
  current_title <- meta$geo_codes$TITEL[i]
  
  if (current_level == 1) {
    # Region level - store as NUTS2
    nuts2_code <- current_code
    nuts2_label <- current_title
    
  } else if (current_level == 2) {
    # County level - store as NUTS3 and assign NUTS2
    nuts3_code <- current_code
    nuts3_label <- current_title
    meta$geo_codes$nuts2[i] <- nuts2_code
    meta$geo_codes$nuts2_label[i] <- nuts2_label
    
  } else if (current_level == 3) {
    # Municipality level - assign both NUTS2 and NUTS3
    meta$geo_codes$nuts2[i] <- nuts2_code
    meta$geo_codes$nuts2_label[i] <- nuts2_label
    meta$geo_codes$nuts3[i] <- nuts3_code
    meta$geo_codes$nuts3_label[i] <- nuts3_label
  }
}

# Create NUTS labels lookup tables
meta <- within(meta, {
  # NUTS2 labels (Regions)
  nuts2_labels <- geo_codes %>%
    select(nuts2, nuts2_label) %>%
    filter(nuts2 != "") %>%
    unique() %>%
    arrange(as.numeric(nuts2))
  
  # NUTS3 labels (Counties)
  nuts3_labels <- geo_codes %>%
    select(nuts3, nuts3_label) %>%
    filter(nuts3 != "") %>%
    unique() %>%
    arrange(as.numeric(nuts3))
})

# Clean up temporary variables
rm(i, nuts2_code, nuts2_label, nuts3_code, nuts3_label)

# Display results
print("Geographic codes with NUTS2 and NUTS3 classification:")
print(meta$geo_codes)

print("\nNUTS2 labels (Regions):")
print(meta$nuts2_labels)

print("\nNUTS3 labels (Counties):")
print(meta$nuts3_labels)

# Create separate municipality dataset
municipalities_se <- meta$geo_codes %>%
  filter(NIVEAU == 3, nuts3 != "") %>%
  select(KODE, TITEL, nuts2, nuts2_label, nuts3, nuts3_label) %>%
  rename(
    municipality_code = KODE,
    municipality_name = TITEL,
    nuts2_code = nuts2,
    nuts2_name = nuts2_label,
    nuts3_code = nuts3,
    nuts3_name = nuts3_label
  ) %>%
  bind_rows(
    data.frame(
      municipality_code = 0,
      municipality_name = "Sweden",
      nuts2_code = "",
      nuts2_name = "",
      nuts3_code = "",
      nuts3_name = ""
    )
  )

rm(current_code, current_level, current_title, meta)