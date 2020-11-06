library(tidyverse)
library(lubridate)
library(janitor)
library(prophet)
library(here)
library(darksky)
library(formattable)

source(here::here("api", "util.R"))

model <- readRDS(here::here("api", "prophet_model.Rds"))

weather_forecast <- util.get_weather_forecast(start_date = "2020-11-05", end_date = "2020-11-06")
class(weather_forecast)

rides_forecast <- predict(model, weather_forecast)

ggplot(rides_forecast, aes(x = ds, y = yhat)) + 
  geom_ribbon(aes(ymin = yhat_lower, ymax = yhat_upper), fill = "grey70") + 
  geom_point() + 
  geom_line()

rides_forecast %>%
  select(ds, pred = yhat) %>%
  left_join(., weather_forecast, "ds") %>%
  formattable(.)
