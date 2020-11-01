library(testthat)
library(here)
library(purrr)
library(darksky)
library(janitor)
library(dplyr)
library(lubridate)
library(readr)
library(vcr)

# load helper functions
source(here::here("R", "util.R"))
source(here::here("tests", "fixtures.R"))

historical_data_fixture <- readRDS(here::here("tests", "historical_data_fixture.rds"))
prophet_data_fixture <- readRDS(here::here("tests", "prophet_data_fixture.rds"))
prophet_model_fixture <- readRDS(here::here("tests", "prophet_model_fixture.rds"))

test_that("historical data formatting",{
  historical_data <- util.get_trips_data(historical_data_fixture)
  expect_equal(any(is.na(historical_data)), FALSE)
  expect_equal(names(historical_data), expected = expected_names, ignore_attr == TRUE)
})

test_that("prophet data has equivalent rows",{
  prophet_data <- util.format_for_prohpet(prophet_data_fixture)
  historical_data <- util.get_trips_data(historical_data_fixture)
  expect_equal(nrow(prophet_data),nrow(historical_data))
})

test_that("prophet models is class prophet",{
  expect_s3_class(prophet_model_fixture, "prophet")
})
