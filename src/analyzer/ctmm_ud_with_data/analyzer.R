library(ctmm)
library(purrr)
library(logger)

# rds <- readRDS("tests/testthat/data/ctmm_ud_with_data/buffalo.rds")
# rds <- N1 <- readRDS("tests/testthat/data/ctmm_ud_with_data/N1.rds")

# rds is a telemetry.list 
analyzeCtmmUDWithData <- function(rds) {
  
  root <- NA
  tryCatch({
    
    # `rds` is a list with two elements: 
    # 1. A list of fitted ctmm models
    # 2. A list of telemetry objects
    
    if (is.null(rds)) {
      log_debug("Analyzing for N = 0")
      n <- "empty-result"
      animals_total_number <- NA
      animal.name <- NA
      tz <- NA
      prj <- NA
      model <- NA
      uds <- NA
    } else if (length(rds$data) >= 1) {
      #N>1
      log_debug("Analyzing for N>1")
      n <- "non-empty-result"
      animals_total_number <- length(rds$data)
      animal.name <- map_chr(rds$data, ~ slot(.x, "info")$identity) |> unname()
      tz <- map_chr(rds$data, ~ slot(.x, "info")$timezone) |> unname()
      prj <- map_chr(rds$data, ~ slot(.x, "info")$projection) |> unname()
      model <- map_chr(rds$model, ~ summary(.x)$name)
      uds <- map_chr(rds$uds, ~ attr(summary(.x), "class"))
    }
    
    root <- mapCtmmModelWithUDOutput(
      n = n,
      animals_total_number <- animals_total_number,
      animal_names = animal.name,
      timezone = tz,
      projection = prj,
      model = model, 
      uds = uds
    )
    
  },
  error = function(cond) {
    log_error("{cond}")
  },
  warning = function(cond) {
    log_warn("{cond}")
  }
  )
  
  # provide in any case the json file (in case of an exception the empty one)
  return(root)
}

mapCtmmModelWithUDOutput <- function(
    n,
    animal_names = NA,
    animals_total_number=NA,
    timezone = NA,
    projection = NA, 
    model = NA,
    uds = NA
) {
  list(
    n = n,
    animals_total_number = animals_total_number,
    animal_names = animal_names,
    timezone = timezone,
    projection = projection,
    model = model, 
    uds = uds
  )
}