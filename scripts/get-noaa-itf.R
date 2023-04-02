library(tidyverse)
library(httr)
library(janitor)

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
      sfheaders::sf_linestring( x = "lon",
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

# download multiple year, month, dekad using above function 

year <- 2013:2014
month <- 4:10
dekad <- 1:3

params <- expand_grid(year,month,dekad) %>% 
  map(.f = pluck)

itf_sf <- pmap_dfr(.l = params,.f = get_noaa_itf)
