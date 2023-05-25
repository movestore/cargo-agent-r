library(testthat)

io_type_slug = "ctmm_ud_with_data"
sut(io_type_slug)

test.data <- test_data(io_type_slug, "buffalo.rds")
test0 <- test_data(io_type_slug, "N1.rds")
test <- c(test.data, test0)

test_that("analyze one-item-result", {
  actual <- analyzeCtmmUDWithData(rds = test.data)
  expect_equal(actual$n[1], "non-empty-result")
  expect_equal(actual$animals_total_number, 2)
})

test_that("proj", {
  actual <- analyzeCtmmUDWithData(rds = test.data)
  expect_true(all(substring(actual$projection, 1, 5) == "+proj"))
})

test_that("null-result",{
  actual <- analyzeCtmmUDWithData(NULL)
  expect_equal(actual$n[1],"empty-result")
})


test_that("one-result",{
  actual <- analyzeCtmmUDWithData(rds = test0)
  expect_equal(actual$n[1],"non-empty-result")
})

test_that("mix-with-empty-id",{
  actual <- analyzeCtmmUDWithData(test)
  expect_equal(actual$n[1],"non-empty-result")
  expect_equal(actual$animals_total_number, 2) # this 2 is hardcoded, just note for the future in case there is a problem
})

