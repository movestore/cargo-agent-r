# system under test (SUT)
io_type_slug = "move2_move2_loc"
sut(io_type_slug)

# test data
test_data <- test_data(io_type_slug, "input2_move2_whitefgeese.rds")

# unit tests

test_that("non-empty-result", {
  actual <- analyze(rds = test_data)
  expect_equal(actual$M_n[1], "non-empty-result")
  expect_equal(actual$F_animals_total_number,3)
})

test_that("bbox", {
  actual <- analyze(rds = test_data)
  expect_true(is.numeric(actual$A_positions_bounding_box[1,1]))
  expect_true(is.numeric(actual$A_positions_bounding_box[1,2]))
  expect_true(is.numeric(actual$A_positions_bounding_box[2,1]))
  expect_true(is.numeric(actual$A_positions_bounding_box[2,2]))
})

test_that("proj", {
  actual <- analyze(rds = test_data)
  expect_equal(substring(actual$B_projection,1,5),"+proj")
})

test_that("timestamps", {
  actual <- analyze(rds = test_data)
  expect_equal(length(actual$D_timestamps_range),2)
})

test_that("animals", {
  actual <- analyze(rds = test_data)
  iddata <- mt_track_data(test_data)
  names(iddata) <- make.names(names(iddata),allow_=FALSE)
  if (!is.null(iddata$individual.local.identifier)) animalNames <- iddata$individual.local.identifier else animalNames <- iddata$local.identifier

  # expect_equal(actual$animals_total_number[1], 3)
  expect_equal(actual$F_animals_total_number[1], mt_n_tracks(test_data))
  # expect_equal(actual$animal_names[1], 742)
  expect_equal(actual$G_animal_names[1], animalNames[1])
})

test_that("attribs", {
  actual <- analyze(rds = test_data)
  expect_true(all(is.character(actual$L_track_attributes)))
  # expect_equal(length(actual$L_track_attributes),5)
  expect_equal(length(actual$L_track_attributes),length(names(unique(mt_track_data(test_data))[,!sapply(mt_track_data(test_data), function(x) all(is.na(x)))])))
  # expect_equal(length(actual$N_event_attributes),16)
  expect_equal(length(actual$N_event_attributes),length(names(test_data[,!sapply(test_data, function(x) all(is.na(x)))])))
})

test_that("tracks", {
  actual <- analyze(rds = test_data)
  # expect_equal(actual$I_tracks_total_number[1], 3)
  expect_equal(actual$I_tracks_total_number, length(as.character(unique(mt_track_id(test_data)))))
  # expect_equal(actual$J_track_names[1], "X742")
  expect_equal(actual$J_track_names[1], unique(as.character(mt_track_id(test_data)))[1])
})

test_that("null-result", {
  actual <- analyze(test_data(io_type_slug, "input0_move2_null.rds"))
  expect_equal(actual$M_n[1], "empty-result")
  expect_equal(actual$F_animals_total_number,0)
})
