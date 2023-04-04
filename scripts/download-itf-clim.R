library(dplyr)
library(tidyr)
library(httr)
library(fs)
library(purrr)

if (!dir_exists(path = "data-raw")) dir_create("data-raw")

if (!dir_exists(path = "data-raw/itf-clim")) dir_create(path = "data-raw/itf-clim")

# grab itf climatologies from noaa ftp server 
base_url <- "https://ftp.cpc.ncep.noaa.gov/fews/itf/clim/"
file <- paste0("clim_",sprintf(fmt ="%02d",rep(4:10,each = 3)),
               rep(1:3,7),".txt")

url <- paste0(base_url,file)

destfile <- paste0("data-raw/itf-clim/",file)

# download itf climatology files 
map2(.x = url,.y = destfile,.f = download.file)
