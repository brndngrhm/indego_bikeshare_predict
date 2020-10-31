library(plumber)
library(here)
library(formattable)
library(ggplot2)
library(purrr)
library(darksky)
library(janitor)
library(dplyr)

# load helper functions
source(here::here("R", "util.R"))

#* @apiTitle IndeGo Bike Trips Forecast
#* @apiDescription Endpoint for working with IndeGo forecast

#* Return the daily ride forecast
#* @param start_date The first date in the range (yyyy-mm-dd format)
#* @param end_date The last date in the range (yyyy-mm-dd format)
#* @post /daily_ride_forecast
function(start_date, end_date){
  
  weather_forecast <- util.get_weather_forecast(start_date, end_date)
  
  util.make_prophet_forecast(weather_forecast) %>%
    select(ds, pred = yhat) %>%
    left_join(., weather_forecast, "ds")
}

#* Return the daily ride forecast in a nice table
#* @param start_date The first date in the range (yyyy-mm-dd format)
#* @param end_date The last date in the range (yyyy-mm-dd format)
#* @serializer html
#* @post /daily_ride_forecast/table
function(start_date, end_date) {
  
  weather_forecast <- util.get_weather_forecast(start_date, end_date)
  
  util.make_prophet_forecast(weather_forecast) %>%
    select(ds, pred = yhat) %>%
    left_join(., weather_forecast, "ds") %>%
    formattable(.)
  
}

#* Return a plot of the daily ride forecast
#* @param start_date The first date in the range (yyyy-mm-dd format)
#* @param end_date The last date in the range (yyyy-mm-dd format)
#* @serializer png
#* @post /daily_ride_forecast/plot
function(start_date, end_date) {
  
  weather_forecast <- util.get_weather_forecast(start_date, end_date)
  
  plot <- util.make_prophet_forecast(weather_forecast) %>%
    ggplot(., aes(x = ds, y = yhat)) + 
    geom_ribbon(aes(ymin = yhat_lower, ymax = yhat_upper), fill = "grey70") + 
    geom_point() + 
    geom_line()
  
  print(plot)
  
}

