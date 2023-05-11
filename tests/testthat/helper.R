sut <- function(io_type_slug) {
    sut <- file.path("..", "..", "src", "analyzer", io_type_slug, "analyzer.R")
    source(sut)
}

test_data <- function(io_type_slug, test_file) {
    test_data_root_dir <- test_path("data", io_type_slug)
    readRDS(file = file.path(test_data_root_dir, test_file))
}