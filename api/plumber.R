library(plumber)
library(here)
library(formattable)
library(ggplot2)
library(purrr)
library(darksky)
library(janitor)
library(dplyr)

# load helper functions
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

model <- readRDS("prophet_model.Rds")

#* @apiTitle IndeGo Bike Trips Forecast
#* @apiDescription Endpoint for working with IndeGo forecast

# #* Return the daily ride forecast for next 7 days
# #* @get /7_day_forecast
# function() {
#   
#   weather_forecast <- util.get_weather_forecast(Sys.Date(), Sys.Date() + 1)
#   
#   predict(model, weather_forecast) %>%
#     select(ds, pred = yhat) %>%
#     left_join(., weather_forecast, "ds") %>%
#     formattable()
# }

#* Return the daily ride forecast
#* @param start_date The first date in the range (yyyy-mm-dd format)
#* @param end_date The last date in the range (yyyy-mm-dd format)
#* @post /daily_ride_forecast
function(start_date, end_date){
  
  weather_forecast <- util.get_weather_forecast(start_date, end_date)
  
  predict(model, weather_forecast) %>%
    select(ds, pred = yhat) %>%
    left_join(., weather_forecast, "ds")
}

# #* Return the daily ride forecast in a nice table
# #* @param start_date The first date in the range (yyyy-mm-dd format)
# #* @param end_date The last date in the range (yyyy-mm-dd format)
# #* @serializer html
# #* @post /daily_ride_forecast/table
# function(start_date, end_date) {
#   
#   weather_forecast <- util.get_weather_forecast(start_date, end_date)
#   
#   predict(model, weather_forecast) %>%
#     select(ds, pred = yhat) %>%
#     left_join(., weather_forecast, "ds") %>%
#     formattable()
#   
# }
# 
# #* Return a plot of the daily ride forecast
# #* @param start_date The first date in the range (yyyy-mm-dd format)
# #* @param end_date The last date in the range (yyyy-mm-dd format)
# #* @serializer png
# #* @post /daily_ride_forecast/plot
# function(start_date, end_date) {
#   
#   weather_forecast <- util.get_weather_forecast(start_date, end_date)
#   
#   rides_forecast <- predict(model, weather_forecast)
#   
#   util.plot_forecast(rides_forecast) %>%
#     labs(title = paste("Indego Forecast for", start_date, "to", end_date))
# 
# }
