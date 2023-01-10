source("../src/analyzer/move_move_stack.R", chdir = TRUE)
library(testthat)

test_data <- readRDS(file = "./data/move_move_stack/input3_stork.rds")

test_that("analyze non-empty-result", {
  actual <- analyzeMoveMoveStack(rds = test_data)
  expect_equal(actual$n[1], "non-empty-result")
})