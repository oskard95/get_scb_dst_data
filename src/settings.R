library(data.table)
library(pxweb)
library(httr)
library(jsonlite)
library(data.table)
library(arrow)
library(crayon)

# Define paths
path <- list(wd = here(),
             fin = file.path(here(),'dat','final', sep = .Platform$file.sep),
             dat = file.path(here(),'dat', sep = .Platform$file.sep),
             raw = file.path(here(),'dat','raw', sep = .Platform$file.sep),
             dst = file.path(here(),'dat','dst', sep = .Platform$file.sep),
             scb = file.path(here(),'dat','scb', sep = .Platform$file.sep))
