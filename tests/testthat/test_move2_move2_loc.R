# system under test (SUT)
io_type_slug = "move2_move2_loc"
sut(io_type_slug)

# test data
test_data <- test_data(io_type_slug, "input2_move2_whitefgeese.rds")

# unit tests

test_that("non-empty-result", {
  actual <- analyze(rds = test_data)
  expect_equal(actual[14][[1]]$n, "non-empty-result")
  expect_equal(actual[3][[1]]$animals_total_number,3)
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
  expect_equal(substring(actual[8][[1]]$projection,1,5),"+proj")
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

  # expect_equal(actual[3][[1]]$animals_total_number[1], 3)
  expect_equal(actual[3][[1]]$animals_total_number[1], mt_n_tracks(test_data))
  # expect_equal(actual[4][[1]]$animal_names[1], 742)
  expect_equal(actual[4][[1]]$animal_names[1], animalNames[1])
})

test_that("animal names should be sorted", {
  actual <- analyze(rds = test_data)
  expect_equal(actual[4][[1]]$animal_names[1], "742")
  expect_equal(actual[4][[1]]$animal_names[2], "746")
  expect_equal(actual[4][[1]]$animal_names[3], "749")
})

test_that("event_attribs", {
  actual <- analyze(rds = test_data)
  expect_true(all(is.character(actual[12][[1]]$track_attributes)))
  # expect_equal(length(actual[12][[1]]$track_attributes),5)
  expect_equal(length(actual[12][[1]]$track_attributes),length(names(unique(mt_track_data(test_data))[,!sapply(mt_track_data(test_data), function(x) all(is.na(x)))])))
  # expect_equal(length(actual[13][[1]]$event_attributes),16)
  expect_equal(length(actual[13][[1]]$event_attributes),length(names(test_data[,!sapply(test_data, function(x) all(is.na(x)))])))
})

test_that("event_attribs should be sorted", {
  actual <- analyze(rds = test_data)
  expect_equal(actual[13][[1]]$event_attributes[1], "event.id")
  expect_equal(actual[13][[1]]$event_attributes[2], "geometry")
  expect_equal(actual[13][[1]]$event_attributes[3], "gps.satellite.count")
  # 4-10
  expect_equal(actual[13][[1]]$event_attributes[11], "track")
})

test_that("track_attribs should be sorted", {
  actual <- analyze(rds = test_data)
  expect_equal(actual[12][[1]]$track_attributes[1], "animalName")
  expect_equal(actual[12][[1]]$track_attributes[2], "comments")
  expect_equal(actual[12][[1]]$track_attributes[3], "death.comments")
  # 4-23
  expect_equal(actual[12][[1]]$track_attributes[24], "visible")
})

test_that("tracks", {
  actual <- analyze(rds = test_data)
  # expect_equal(actual[9][[1]]$tracks_total_number[1], 3)
  expect_equal(actual[9][[1]]$tracks_total_number, length(as.character(unique(mt_track_id(test_data)))))
  # expect_equal(actual[10][[1]]$track_names[1], "X742")
  expect_equal(actual[10][[1]]$track_names[1], unique(as.character(mt_track_id(test_data)))[1])
})

test_that("track names should be sorted", {
  actual <- analyze(rds = test_data)
  expect_equal(actual[10][[1]]$track_names[1], "X742")
  expect_equal(actual[10][[1]]$track_names[2], "X746")
  expect_equal(actual[10][[1]]$track_names[3], "X749")
})

test_that("null-result", {
  actual <- analyze(test_data(io_type_slug, "input0_move2_null.rds"))
  expect_equal(actual[14][[1]]$n[1], "empty-result")
  expect_equal(actual[3][[1]]$animals_total_number,0)
})
