pacman::p_load(rio,          # File import
               here,         # File locator
               tsibble,      # handle time series datasets
               slider,       # for calculating moving averages
               imputeTS,     # for filling in missing values
               feasts,       # for time series decomposition and autocorrelation
               forecast,     # fit sin and cosin terms to data (note: must load after feasts)
               trending,     # fit and assess models 
               tmaptools,    # for getting geocoordinates (lon/lat) based on place names
               ecmwfr,       # for interacting with copernicus sateliate CDS API
               stars,        # for reading in .nc (climate data) files
               units,        # for defining units of measurement (climate data)
               yardstick,    # for looking at model accuracy
               surveillance,  # for aberration detection
               tidyverse     # data management + ggplot2 graphics
)



library(tsibble)
l
?campyDE

data("campyDE")
view(campyDE)

counts <- campyDE

## ensure the date column is in the appropriate format
counts$date <- as.Date(counts$date)

## create a calendar week variable 
## fitting ISO definitons of weeks starting on a monday
counts <- counts %>% 
  mutate(epiweek = yearweek(date, week_start = 1))

# Now we download the climate data
install.packages("ecmwfr")
library("ecmwfr")

## retrieve location coordinates
coords <- geocode_OSM("Germany", geometry = "point")

## pull together long/lats in format for ERA-5 querying (bounding box) 
## (as just want a single point can repeat coords)
request_coords <- str_glue_data(coords$coords, "{y}/{x}/{y}/{x}")


## Pulling data modelled from copernicus satellite (ERA-5 reanalysis)
## https://cds.climate.copernicus.eu/cdsapp#!/software/app-era5-explorer?tab=app
## https://github.com/bluegreen-labs/ecmwfr

## set up key for weather data

# The original v1.x.x call
wf_request(
  request,
  user = "a4171075-22ac-45c4-9cd4-897057eceb2b"
)

# The new v2.x.x call
wf_request(
  request
)


wf_set_key(user = "a4171075-22ac-45c4-9cd4-897057eceb2b",
           key = "af9ae5bb-23c5-463d-93fb-4a47d996af14"
           )

## run for each year of interest (otherwise server times out)
for (i in 2002:2011) {
  
  ## pull together a query 
  ## see here for how to do: https://bluegreen-labs.github.io/ecmwfr/articles/cds_vignette.html#the-request-syntax
  ## change request to a list using addin button above (python to list)
  ## Target is the name of the output file!!
  request <- request <- list(
    product_type = "reanalysis",
    format = "netcdf",
    variable = c("2m_temperature", "total_precipitation"),
    year = c(i),
    month = c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"),
    day = c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12",
            "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24",
            "25", "26", "27", "28", "29", "30", "31"),
    time = c("00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00", "07:00",
             "08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00",
             "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00"),
    area = request_coords,
    dataset_short_name = "reanalysis-era5-single-levels",
    target = paste0("germany_weather", i, ".nc")
  )
  
  ## download the file and store it in the current working directory
  file <- wf_request(user     = "XXXXX",  # user ID (for authentication)
                     request  = request,  # the request
                     transfer = TRUE,     # download the file
                     path     = here::here("data", "Weather")) ## path to save the data
}
