# get_scb_dst_data

A data pipeline for downloading demographic data (mortality, births, migration, population) from Statistics Denmark (DST) and Statistics Sweden (SCB) APIs.

## Project Structure

```
get_scb_dst_data/
├── src/
│   ├── dk/                 # Danish (DST) scripts
│   ├── se/                 # Swedish (SCB) scripts
│   ├── _main_.R            # Main execution script
│   ├── se_main_.R          # Swedish main script
│   ├── functions.R         # Custom DST API functions
│   ├── geo_data.R          # Geographic data processing
│   ├── prep_dk_data.R      # Danish data preparation
│   ├── prep_swe_data.R     # Swedish data preparation
│   ├── se_geo_data.R       # Swedish geographic data
│   └── settings.R          # File paths and configuration
├── dat/
│   ├── dst/                # DST data storage
│   ├── final/              # Final processed data
│   ├── raw/                # Raw API responses
│   └── scb/                # SCB data storage
└── doc/                    # NUTS region mappings
    ├── dst_regions_kommunes.csv
    └── scb_regions_kommunes.csv
```

## Quick Start

1. **Install packages:**
```r
install.packages(c("pxweb", "arrow", "data.table", "dplyr", "here", "httr", "jsonlite"))
```

2. **Set up paths in `src/settings.R`**

3. **Run main scripts: `src/_main_.R` or `src/se_main_.R`**

## How It Works

### Statistics Denmark (DST)
- Build queries using the [DST API Console](https://api.statbank.dk/console#subjects)
- Use custom functions in `functions.R` to execute queries
- Scripts organized in `src/dk/`

### Statistics Sweden (SCB)
- Uses `pxweb` package
- Interactive mode: `pxweb_interactive()` 
- Programmatic mode: Define queries in JSON or use direct API URLs
- Scripts organized in `src/se/`

## NUTS Region Mappings

Standardized geographic codes mapping municipalities to NUTS2/NUTS3 regions:
- `doc/dst_regions_kommunes.csv`
- `doc/scb_regions_kommunes.csv`
