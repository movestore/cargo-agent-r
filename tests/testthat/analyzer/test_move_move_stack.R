source("../../../src/analyzer/move_move_stack.R", chdir = TRUE)
library(testthat)

test_data <- readRDS(file = "../data/move_move_stack/input3_stork.rds")

test_that("non-empty-result", {
  actual <- analyzeMoveMoveStack(rds = test_data)
  expect_equal(actual$n[1], "non-empty-result")
})

test_that("null-result", {
  actual <- analyzeMoveMoveStack(rds = readRDS(file = "../data/N0.rds"))
  expect_equal(actual$n[1], "empty-result")
})

test_that("null-result", {
  actual <- analyzeMoveMoveStack(rds = readRDS(file = "../data/N1.rds"))
  expect_equal(actual$n[1], "one-item-result")
})