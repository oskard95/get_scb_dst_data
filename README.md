# get_scb_dst_data
A data download pipeline for accessing Danish Statistics and Sweden Statistics API and downloading Mortality, Birth, Migration Counts and Population counts. Built to support other projects that require the data.

How to use:
Settings script controls save locations, mostly based on setting parquet / raw data files correctly. Save locations are found in dat contains file structure needed to download data.
Function is custom function to download Danisht Statistics API data, to create a query, follow this link https://api.statbank.dk/console#subjects. 

SCB data uses pxweb package and is a bit easier to use but requires either manual link creation via the interactive command or json query. 
