
# Series of helper functions for modeling IndeGo bike trips

##############################################

# more info on the creation of this in `data_explore.Rmd`

get_trips_data <- function(data){
  
  trips <- data %>%
    rename(trips = n) %>%
    mutate(month = month(date, label = T, abbr = T),
           day_nm = wday(date, label = T, abbr = T)) %>%
    clean_names() %>%
    select(-ends_with(c("time", "min", "low")), starts_with("temperature"), -c(row_num, ozone, precip_accumulation, wind_bearing, wind_gust, moon_phase)) %>%
    mutate(precip_type = ifelse(is.na(precip_type), "none", precip_type)) %>%
    na.omit()
  
  return(trips)
  
}
