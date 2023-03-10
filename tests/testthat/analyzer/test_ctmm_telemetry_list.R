source("../../../src/analyzer/ctmm_telemetry_list.R", chdir = TRUE)
library(testthat)

test_data <- readRDS(file = "../data/ctmm_telemetry_list/ctmm_telemetry_list_geese.rds")
test0 <-  readRDS("../data/ctmm_telemetry_list/N0.rds")
test <- c(test_data,test0)

test_that("analyze one-item-result", {
  actual <- analyzeCtmmTelemetryList(rds = test_data)
  expect_equal(actual$n[1], "non-empty-result")
  expect_equal(actual$animals_total_number,3)
  # expect_equal(actual$animals_total_number,length(test_data))
})

test_that("proj", {
  actual <- analyzeCtmmTelemetryList(rds = test_data)
  expect_equal(substring(actual$projection,1,5),"+proj")
})

test_that("null-result",{
  actual <- analyzeCtmmTelemetryList(NULL)
  expect_equal(actual$n[1],"empty-result")
})

test_that("null-result",{
  actual <- analyzeCtmmTelemetryList(rds = readRDS("../data/ctmm_telemetry_list/N0.rds"))
  expect_equal(actual$n[1],"empty-result")
})
# if no locations, all properties end up in a warning, thus better to return same as for NULL

test_that("one-result",{
  actual <- analyzeCtmmTelemetryList(rds = readRDS("../data/ctmm_telemetry_list/N1.rds"))
  expect_equal(actual$n[1],"one-item-result")
})

test_that("mix-with-empty-id",{
  actual <- analyzeCtmmTelemetryList(test)
  expect_equal(actual$n[1],"non-empty-result")
  expect_equal(actual$animals_total_number,3) # this 3 is hardcoded, just note for the future in case there is a problem
})
# remove individuals for which no locations are provided. need to discuss



