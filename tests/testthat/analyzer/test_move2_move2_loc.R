source("../../../src/analyzer/move2_move2_loc.R", chdir = TRUE)
#source("src/analyzer/move2_move2_loc.R", chdir = TRUE)
library(testthat)

test_data <- readRDS(file = "../data/move2_move2_loc/input2_move2_whitefgeese.rds")
#test_data <- readRDS(file = "tests/testthat/data/move2_move2_loc/input2_move2_whitefgeese.rds")

test_that("non-empty-result", {
  actual <- analyzeMove2Move2_loc(rds = test_data)
  expect_equal(actual$n[1], "non-empty-result")
  expect_equal(actual$animals_total_number,3)
})

test_that("bbox", {
  actual <- analyzeMove2Move2_loc(rds = test_data)
  expect_true(is.numeric(actual$positions_bounding_box[1,1]))
  expect_true(is.numeric(actual$positions_bounding_box[1,2]))
  expect_true(is.numeric(actual$positions_bounding_box[2,1]))
  expect_true(is.numeric(actual$positions_bounding_box[2,2]))
})

test_that("proj", {
  actual <- analyzeMove2Move2_loc(rds = test_data)
  expect_equal(substring(actual$projection,1,5),"+proj")
})

test_that("timestamps", {
  actual <- analyzeMove2Move2_loc(rds = test_data)
  expect_equal(length(actual$timestamps_range),2)
})

test_that("animals", {
  actual <- analyzeMove2Move2_loc(rds = test_data)
  iddata <- mt_track_data(test_data)
  names(iddata) <- make.names(names(iddata),allow_=FALSE)
  if (!is.null(iddata$individual.local.identifier)) animalNames <- iddata$individual.local.identifier else animalNames <- iddata$local.identifier

  # expect_equal(actual$animals_total_number[1], 3)
  expect_equal(actual$animals_total_number[1], mt_n_tracks(test_data))
  # expect_equal(actual$animal_names[1], 742)
  expect_equal(actual$animal_names[1], animalNames[1])
})

test_that("attribs", {
  actual <- analyzeMove2Move2_loc(rds = test_data)
  expect_true(all(is.character(actual$animal_attributes)))
  # expect_equal(length(actual$animal_attributes),5)
  expect_equal(length(actual$animal_attributes),length(names(unique(mt_track_data(test_data))[,!sapply(mt_track_data(test_data), function(x) all(is.na(x)))])))
  # expect_equal(length(actual$track_attributes),16)
  expect_equal(length(actual$track_attributes),length(names(test_data[,!sapply(test_data, function(x) all(is.na(x)))])))
})

test_that("tracks", {
  actual <- analyzeMove2Move2_loc(rds = test_data)
  # expect_equal(actual$tracks_total_number[1], 3)
  expect_equal(actual$tracks_total_number, length(as.character(unique(mt_track_id(test_data)))))
  # expect_equal(actual$track_names[1], "X742")
  expect_equal(actual$track_names[1], unique(as.character(mt_track_id(test_data)))[1])
})

test_that("null-result", {
  actual <- analyzeMove2Move2_loc(readRDS("../data/move2_move2_loc/input0_move2_null.rds"))
  #actual <- analyzeMove2Move2_loc(readRDS("tests/testthat/data/move2_move2_loc/input0_move2_null.rds"))
  expect_equal(actual$n[1], "empty-result")
  expect_equal(actual$animals_total_number,0)
})
