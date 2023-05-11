# system under test (SUT)
io_type_slug = "move_move_stack"
sut(io_type_slug)

# test data
test_data <- test_data(io_type_slug, "input2_geese.rds")

# unit tests

test_that("non-empty-result", {
  actual <- analyze(rds = test_data)
  expect_equal(analyze(rds = test_data)$n[1], "non-empty-result")
})

test_that("bbox", {
  actual <- analyze(rds = test_data)
  expect_true(is.numeric(actual$positions_bounding_box[1,1]))
  expect_true(is.numeric(actual$positions_bounding_box[1,2]))
  expect_true(is.numeric(actual$positions_bounding_box[2,1]))
  expect_true(is.numeric(actual$positions_bounding_box[2,2]))
})

test_that("proj", {
  actual <- analyze(rds = test_data)
  expect_equal(substring(actual$projection,1,5),"+proj")
})

test_that("timestamps", {
  actual <- analyze(rds = test_data)
  expect_equal(length(actual$timestamps_range),2)
})

test_that("animals", {
  actual <- analyze(rds = test_data)
  iddata <- idData(test_data)
  names(iddata) <- make.names(names(iddata),allow_=FALSE)
  animalNames <- if(is.null(iddata$individual.local.identifier)){iddata$local.identifier}

  # expect_equal(actual$animals_total_number[1], 3)
  expect_equal(actual$animals_total_number[1], n.indiv(test_data))
  # expect_equal(actual$animal_names[1], 742)
  expect_equal(actual$animal_names[1], animalNames[1])
})

test_that("attribs", {
  actual <- analyze(rds = test_data)
  expect_true(all(is.character(actual$animal_attributes)))
  # expect_equal(length(actual$animal_attributes),5)
  expect_equal(length(actual$animal_attributes),length(names(unique(test_data@idData)[,!sapply(test_data@idData, function(x) all(is.na(x)))])))
  # expect_equal(length(actual$track_attributes),16)
  expect_equal(length(actual$track_attributes),length(names(test_data@data[,!sapply(test_data@data, function(x) all(is.na(x)))])))
})

test_that("tracks", {
  actual <- analyze(rds = test_data)
  # expect_equal(actual$tracks_total_number[1], 3)
  expect_equal(actual$tracks_total_number[1], length(namesIndiv(test_data))[1])
  # expect_equal(actual$track_names[1], "X742")
  expect_equal(actual$track_names[1], namesIndiv(test_data)[1])
})

test_that("null-result", {
  actual <- analyze(NULL)
  expect_equal(actual$n[1], "empty-result")
})
#file N0.rds can never be received by an App, because it is not a moveStack, then it automatically becomes NULL

test_that("one-item-result", {
  actual <- analyze(test_data(io_type_slug, "N1.rds"))
  expect_equal(actual$n[1], "one-item-result") 
  expect_equal(actual$animals_total_number[1],1)
})
#data of 1 individual in moveStack, had to adapt cargo agent analyze code to capture this (in which way does MoveApps work with $n[1]? where is one-item-result actually shown/used???)



