library(tidyverse)
library(lubridate)
library(janitor)
library(prophet)
library(here)

source(here::here("R", "util.R"))

# https://nbviewer.jupyter.org/github/nicolasfauchereau/Auckland_Cycling/blob/master/notebooks/Auckland_cycling_and_weather.ipynb
# https://github.com/nicolasfauchereau/Auckland_Cycling/blob/master/code/utils.py
# https://facebook.github.io/prophet/docs/seasonality,_holiday_effects,_and_regressors.html#additional-regressors

# load and format data
data <- util.get_trips_data(read_csv(here::here("data", "daily_trips_and_weather.csv"))) 

prophet_data <- util.format_for_prohpet(data)

prophet_train <- prophet_data %>%
  filter(ds < as.Date("2019-01-01"))

prophet_test <- prophet_data %>%
  filter(ds >= as.Date("2019-01-01"))

#specify
model <- prophet()
model <- add_regressor(m = model, name = "summary", standardize = FALSE)
model <- add_regressor(m = model, name = "icon", standardize = FALSE)
model <- add_regressor(m = model, name = "precip_type", standardize = FALSE)
model <- add_regressor(m = model, name = "precip_intensity", standardize = TRUE)
model <- add_regressor(m = model, name = "precip_intensity_max", standardize = TRUE)
model <- add_regressor(m = model, name = "precip_probability", standardize = TRUE)
model <- add_regressor(m = model, name = "dew_point", standardize = TRUE)
model <- add_regressor(m = model, name = "humidity", standardize = TRUE)
model <- add_regressor(m = model, name = "pressure", standardize = TRUE)
model <- add_regressor(m = model, name = "wind_speed", standardize = TRUE)
model <- add_regressor(m = model, name = "cloud_cover", standardize = TRUE)
model <- add_regressor(m = model, name = "uv_index", standardize = TRUE)
model <- add_regressor(m = model, name = "visibility", standardize = TRUE)
model <- add_regressor(m = model, name = "apparent_temperature_max", standardize = TRUE)

# model <- fit.prophet(model, prophet_train)

future <- make_future_dataframe(model, periods = nrow(prophet_test), freq = 'day') %>%
  inner_join(., prophet_data %>% select(-c(y, day_nm, month, era)), "ds") %>%
  mutate_if(is.character, as.factor)
  
forecast <- predict(model, future)

forecast %>%
  select(ds, pred = yhat) %>%
  inner_join(., prophet_data %>% select(ds,obs= y), "ds") %>% 
  summarise(mae = caret::MAE(pred = pred, obs = obs))

# fit full model and save
model_full <- fit.prophet(model, prophet_data)

model_full <- readRDS("R/models/prophet_model.Rds")

predict(model_full, weather_forecast %>%
          mutate_if(is.character, as.factor)
)

# saveRDS(model_full, "R/models/prophet_model.Rds")

