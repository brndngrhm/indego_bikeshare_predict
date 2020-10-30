
# Series of helper functions for modeling IndeGo bike trips

##############################################

get_trips_data <- function(){
  
  trips <- read_csv("data/daily_indego_bikeshare_trips.csv") %>%
    clean_names() %>%
    # remove time columns and `ozone`, `precip_accumulation` which have a lot of missing obs
    select(-ends_with("time"), -c(ozone, precip_accumulation)) %>%
    # remove dates with no weather data
    filter(!(is.na(summary))) %>%
    # assuming `NA` here means there was no precip that day
    mutate(precip_type = ifelse(is.na(precip_type), "none", precip_type))
  
  return(trips)
  
}