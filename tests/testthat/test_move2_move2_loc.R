# system under test (SUT)
io_type_slug = "move2_move2_loc"
sut(io_type_slug)

# test data
test_data <- test_data(io_type_slug, "test_data_move2_loc.rds")

# unit tests

test_that("non-empty-result", {
  actual <- analyze(rds = test_data)
  expect_equal(actual[14][[1]]$n, "non-empty-result")
  expect_equal(actual[3][[1]]$animals_total_number,4)
})

test_that("bbox", {
  actual <- analyze(rds = test_data)[7][[1]]$positions_bounding_box
  expect_true(is.numeric(actual[1,1]))
  expect_true(is.numeric(actual[1,2]))
  expect_true(is.numeric(actual[2,1]))
  expect_true(is.numeric(actual[2,2]))
})

test_that("proj", {
  actual <- analyze(rds = test_data)
  expect_equal(substring(actual[8][[1]]$projection,1,5),"EPSG:")
})

test_that("timestamps", {
  actual <- analyze(rds = test_data)
  expect_equal(length(actual[2][[1]]$timestamps_range),2)
})

test_that("animals", {
  actual <- analyze(rds = test_data)
  iddata <- mt_track_data(test_data)
  names(iddata) <- make.names(names(iddata),allow_=FALSE)
  if (!is.null(iddata$individual.local.identifier)) animalNames <- iddata$individual.local.identifier else animalNames <- iddata$local.identifier

  expect_equal(actual[3][[1]]$animals_total_number[1], mt_n_tracks(test_data))
  expect_equal(actual[4][[1]]$animal_names[1], "742")
})

test_that("animal names should be sorted", {
  actual <- analyze(rds = test_data)
  expect_equal(actual[4][[1]]$animal_names[1], "742")
  expect_equal(actual[4][[1]]$animal_names[2], "746")
  expect_equal(actual[4][[1]]$animal_names[3], "749")
  expect_equal(actual[4][[1]]$animal_names[4], "Prinzesschen")
})

test_that("event_attribs", {
  actual <- analyze(rds = test_data)
  expect_true(all(is.character(actual[12][[1]]$track_attributes)))
  expect_equal(length(actual[12][[1]]$track_attributes),50)
  expect_equal(length(actual[13][[1]]$event_attributes), 27)
})

test_that("event_attribs should be sorted", {
  actual <- analyze(rds = test_data)
  expect_equal(actual[13][[1]]$event_attributes[1], "argos_altitude")
  expect_equal(actual[13][[1]]$event_attributes[2], "argos_best_level")
  expect_equal(actual[13][[1]]$event_attributes[3], "argos_calcul_freq")
  # 4-10
  expect_equal(actual[13][[1]]$event_attributes[11], "argos_pass_duration")
})

test_that("track_attribs should be sorted", {
  actual <- analyze(rds = test_data)
  expect_equal(actual[12][[1]]$track_attributes[1], "acknowledgements")
  expect_equal(actual[12][[1]]$track_attributes[2], "capture_location")
  expect_equal(actual[12][[1]]$track_attributes[3], "citation")
  # 4-23
  expect_equal(actual[12][[1]]$track_attributes[24], "latest_date_born")
})

test_that("tracks", {
  actual <- analyze(rds = test_data)
  expect_equal(actual[9][[1]]$tracks_total_number, length(as.character(unique(mt_track_id(test_data)))))
  expect_equal(actual[10][[1]]$track_names[1], "742")
})

test_that("track names should be sorted", {
  actual <- analyze(rds = test_data)
  expect_equal(actual[10][[1]]$track_names[1], "742")
  expect_equal(actual[10][[1]]$track_names[2], "746")
  expect_equal(actual[10][[1]]$track_names[4], "Prinzesschen")
})

test_that("if track names are a factor, drop empty levels", {
  actual <- analyze(rds = test_data)
  expect_equal(length(actual[10][[1]]$track_names),length(levels(droplevels(mt_track_id(test_data)))))
})

test_that("track attributes are not a list", {
  actual <- analyze(rds = test_data)
  expect_equal(actual[5][[1]]$taxa,sort(as.character(unique(unlist(mt_track_data(test_data)$taxon_canonical_name)))))
})

test_that("null-result", {
  actual <- analyze(test_data(io_type_slug, "input0_move2_null.rds"))
  expect_equal(actual[14][[1]]$n[1], "empty-result")
  expect_equal(actual[3][[1]]$animals_total_number,0)
})
