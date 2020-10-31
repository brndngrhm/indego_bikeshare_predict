library(tidyverse)
library(lubridate)
library(janitor)
library(prophet)
library(here)
library(darksky)
library(formattable)

source(here::here("R", "util.R"))

weather_forecast <- util.get_weather_forecast(start_date = Sys.Date(), end_date = Sys.Date() + 5)

rides_forecast <- util.make_prophet_forecast(weather_forecast)

ggplot(rides_forecast, aes(x = ds, y = yhat)) + 
  geom_ribbon(aes(ymin = yhat_lower, ymax = yhat_upper), fill = "grey70") + 
  geom_point() + 
  geom_line()

rides_forecast %>%
  select(ds, pred = yhat) %>%
  left_join(., weather_forecast, "ds") %>%
  formattable(.)
       

