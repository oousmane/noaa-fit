library(tidyverse)
library(httr)
library(janitor)
library(sf)
library(sfheaders)

# this function retrieved itf position data for a particular year, month, dekad
# in two possible format type = "sf" return a sf linestring and type = "tibble" for
# a dataframe

get_noaa_itf <- function(year,month,dekad, type = "sf"){
  
  mon_dekad<- paste0(sprintf("%02d",month),dekad)
  fname <- paste0("itf_",year,"_",mon_dekad,".txt")
  url <- paste0("https://ftp.cpc.ncep.noaa.gov/fews/itf/data/",fname)
  query <- GET(url = url)
  if (query$status_code == 404) {
    stop("There's no data for the selected period.Keep in mind : ITF data is 
         only available from Apr (4),to Oct (10)")
  } else{
    if (type == "sf"){
    id <- paste(year,sprintf("%02d",month),dekad,sep="_")
    read_csv(file = url) %>% 
      mutate(id = id,.before = lat) %>% 
      sf_linestring( x = "lon",
                     y = "lat",
                     linestring_id = "id") %>% 
      st_set_crs(value = "EPSG:4326") %>% 
      separate(col = id,into = c("year","month","dekad"))  
    } else {
      read_csv(file = url) %>% 
      mutate(year = year,month = month,dekad = dekad,.before = lat)
  }
  }
}

# ITF monthy mean position computation 

itf_monthly_position <- function(year,month){
dekad <- 1:3
type = "tibble"
params <- expand_grid(year,month,dekad,type) %>% 
  map(.f = pluck)

itf_tibble <- pmap_dfr(.l = params,.f = get_noaa_itf)

itf_tibble %>% 
  group_by(year, month, lon) %>% 
  summarise(lat= mean(lat)) %>% 
  ungroup()
}

