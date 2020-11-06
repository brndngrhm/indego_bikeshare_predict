
# helper functions for formatting and modeling IndeGo bike trips

##############################################

util.get_trips_data <- function(data){
  
  trips <- data %>%
    janitor::clean_names() %>%
    dplyr::rename(trips = n) %>%
    dplyr::mutate(month = month(date, label = T, abbr = T),
                  day_nm = wday(date, label = T, abbr = T)) %>%
    dplyr::ungroup() %>%
    dplyr::select(!(ends_with(c("_time", "_min", "_low"), ignore.case = TRUE))) %>%
    dplyr::select(!(starts_with("temperature_", ignore.case = TRUE))) %>%
    dplyr::select(-c(row_num, ozone, precip_accumulation, wind_bearing, wind_gust, moon_phase)) %>%
    dplyr::mutate(precip_type = ifelse(is.na(precip_type), "none", precip_type)) %>%
    na.omit()
  
  return(trips)
  
}

util.format_for_prohpet <- function(data){
  
  prophet_data <- data %>%
    dplyr::rename(ds = date,
                  y = trips) %>%
    dplyr::mutate(era = if_else(ds < as.Date('2020-03-01'), "pre_covid", "post_covid")) %>%
    dplyr::mutate_if(is.character, as.factor)
  
  return(prophet_data)
}

util.get_weather_forecast <- function(start_date, end_date){
  
  predictors <- c("date", "summary", "icon", "precip_intensity", "precip_intensity_max", 
                  "precip_probability", "precip_type", "apparent_temperature_high", 
                  "dew_point", "humidity", "pressure", "wind_speed", "cloud_cover", 
                  "uv_index", "visibility", "apparent_temperature_max")
  
  weather_forecast <- seq(as.Date(start_date)+1, as.Date(end_date)+1, "1 day") %>% 
    purrr::map(~darksky::get_forecast_for(39.9528, -75.1635, .x)) %>% 
    purrr::map_dfr("daily") %>%
    janitor::clean_names() %>%
    dplyr::ungroup() %>%
    dplyr::mutate(date = as.Date(time)+1) %>%
    dplyr::select(all_of(predictors)) %>%
    dplyr::mutate(precip_type = ifelse(is.na(precip_type), "none", precip_type)) %>%
    dplyr::mutate_if(is.character, as.factor) %>%
    dplyr::rename(ds = date) %>%
    na.omit()
  
  return(weather_forecast)
}

util.plot_forecast <- function(data){
  
  plot <- data %>%
    ggplot(., aes(x = as.Date(ds), y = yhat, group = 1)) + 
    geom_ribbon(aes(ymin = yhat_lower, ymax = yhat_upper), fill = "grey70") + 
    geom_point() + 
    geom_line() + 
    labs(x = "Date", y = "Forecast Rides", title = "Indego Rides Forecast") + 
    scale_x_date(breaks = "1 day")
  
  print(plot)
         
}