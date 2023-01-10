source("../../src/analyzer/ctmm_telemetry_list.R", chdir = TRUE)
library(testthat)

test_data <- readRDS(file = "./data/ctmm_telemetry_list/ctmm_telemetry_list.rds")

test_that("analyze one-item-result", {
  expect_equal(analyzeCtmmTelemetryList(rds = test_data)$n[1], "one-item-result")
})