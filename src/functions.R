# Title     : Utility functions
# Objective :
# Created by: Aleksandrs Aleksandrovs
# Created on: 09-02-2022
# Status    : Development

validate_string_param <- function(param_value, param_name) {
  if (!is.character(param_value) || length(param_value) != 1 || nchar(param_value) == 0) {
    stop(sprintf("Parameter '%s' must be a non-empty character string", param_name), call. = FALSE)
  }
}

#' Get DST table metadata
#'
#' @param table character vector with table name
#' @param save_path character vector with path to save the metadata
#' @return metadata in JSON format
#' @export
#' @examples
#' get_dst_meta(table = "FOLK1A", save_path = here("data", "raw", "dst"))
#'

get_dst_meta <- function(table, save_path) {
  require(httr)
  require(jsonlite)
  require(logger)

  logger::log_layout(layout_glue_colors)

  validate_string_param(table, "table")
  validate_string_param(save_path, "save_path")

  res <- tryCatch({
    logger::log_info("Getting table ", toupper(table), " metadata... ")
    call <- paste0("https://api.statbank.dk/v1/tableinfo/",tolower(table),"?lang=en&format=JSON")
    response <- httr::GET(call)
    meta <- httr::content(response, type = "text", encoding = "UTF-8")
    meta <- jsonlite::fromJSON(meta)
    jsonlite::write_json(
      meta,
      file.path(
        save_path,
        paste0("meta_dst_",tolower(table),".json"),
        fsep = .Platform$file.sep),
      pretty = TRUE)

    rm(call, response, meta)
    logger::log_success("Table ", toupper(table), " metadata downloaded and saved to ", save_path)
  },
    error = function(e){
      logger::log_error("{message(e)}")
    },
    warning = function(w){
      logger::log_error("{message(w)}")
    }
  )
}



#' Get DST table data
#'
#' @param table character vector with table name
#' @param  api_url DST API URL (see https://api.statbank.dk/console#data)
#' @param save_path character vector with path to save the metadata
#' @return void
#' @export
#' @examples
#' get_dst_data(table = "DOD", api_url="https://api.statbank.dk/v1/data/DOD/BULK?lang=en&valuePresentation=Code&Tid=*&K%C3%98N=*&ALDER=*", path=file.path("dir"))
#'

get_dst_data <- function(table, api_url, save_path) {
  required_packages <- c("httr", "data.table", "logger", "arrow")
  
  for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      stop(sprintf("Package '%s' is required but not installed. Please install it with: install.packages('%s')", 
                   pkg, pkg), call. = FALSE)
    }
  }

  validate_string_param(table, "table")
  validate_string_param(api_url, "api_url")  
  validate_string_param(save_path, "save_path")
  
  if (!dir.exists(save_path)) {
    stop(sprintf("Save directory does not exist: %s", save_path), call. = FALSE)
  }
  
  # Validate URL format
  if (!grepl("^https?://", api_url)) {
    logger::log_warn("API URL does not start with http:// or https://. This might cause issues.")
  }
  
  if (!grepl("statbank\\.dk", api_url)) {
    logger::log_warn("API URL does not appear to be from Danmarks Statistik (statbank.dk)")
  }

  res <- tryCatch(
  {
    logger::log_info("Getting table ", toupper(table), " data... ")
    call <- api_url
    response <- httr::GET(call)
    dat_raw <- httr::content(response, as = "text", encoding = "UTF-8")
    dat_raw <- data.table::fread(dat_raw, encoding = 'UTF-8', showProgress = TRUE)
    arrow::write_parquet(
      dat_raw,
      file.path(
        save_path,
        paste0("raw_",tolower(table), ".parquet")))

    rm(call, response, dat_raw)
    logger::log_success("Table ", toupper(table), " data downloaded and saved to ", save_path)
  },
    error = function(e){
      message(e)
    },
    warning = function(w){
      message(w)
    }
  )
}

