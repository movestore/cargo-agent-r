library(move)
library(ctmm)
library(logger)

# mv <- readRDS("input4_goat.rds") #input2_geese.rds
# rds <- as.telemetry(mv)

# rds is a telemetry.list 
analyzeCtmmTelemetryList <- function(rds) {
  root <- NA
  
  tryCatch(
    {
      if (length(rds)==0)
      {
        # fallback for N=0
        log_debug("Analyzing for N=0")
        root <- mapCtmmTelemetryListOutput(
          n = "empty-result",
          animal_names = NA,
          timezone = NA,
          projection = NA
        )
      }
      else
      {
        if (is(rds,'telemetry'))
        {
          #N=1
          log_debug("Analyzing for N=1")
          n <- "one-item-result"
          animal.name <-  summary(rds)$identity
          tz <- summary(rds)$timezone
          prj <- summary(rds)$projection
        }
        else if (is(rds,'list'))
        {
          #N>1
          log_debug("Analyzing for N>1")
          n <- "non-empty-result"
          animal.name <- unlist(lapply(rds, function(x) summary(x)$identity))
          tz <-  unique(unlist(lapply(rds, function(x) summary(x)$timezone)))
          prj <-  unique(unlist(lapply(rds, function(x) summary(x)$projection)))
        }
        root <- mapCtmmTelemetryListOutput(
          n = n,
          animal_names = animal.name,
          timezone = tz,
          projection = prj
        )

      }
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

mapCtmmTelemetryListOutput <- function(
    n,
    animal_names = NA,
    timezone = NA,
    projection = NA
) {
    list(
        n = n,
        cargo_v = -10,
        animal_names = animal_names,
        timezone = timezone,
        projection = projection
    )
}