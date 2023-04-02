library(tidyverse)
library(fs)
library(vroom)
library(sfheaders)
library(sf)
long = c(-15L, -10L, -5L, 0L, 5L, 10L, 15L, 20L, 25L, 30L, 35L)

files <- dir_ls(path = "data-raw/itf-clim/")
df <- map_dfr(.x = files,.f = vroom,col_names = FALSE,id = "id") %>% 
  mutate(id = str_remove_all(id,"data-raw/itf-clim/clim_"),
         id = str_remove_all(id,".txt"),
         month = rep(4:10,each = 3),
         dekad = rep(1:3,7)
         ) 
df %>% 
  select(-id) %>% 
  pivot_longer(cols = -c(month,dekad),
               names_to = "lon",
               names_prefix = "X",
               names_transform = list(lon = as.numeric),
               values_to = "lat") %>% 
  unite(month, dekad, col = id) %>% 
  mutate(lon = long[lon]) %>% 
  sfheaders::sf_linestring(
    x = "lon",
    y = "lat",
    linestring_id = "id"
  ) %>% 
  st_set_crs(value = "EPSG:4326") %>% 
  separate(col = id,into = c("month","dekad")) %>% 
  st_write(dsn = "wa-itf",
           layer = "wa-itf-data",
           driver = "ESRI Shapefile"
           )
