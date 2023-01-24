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
      
      # if one of the telemetry elements has no locations, take them out here
      idlen <- unlist(lapply(rds,function(x) dim(x)[1]))
      if (any(idlen==0))
      {
        rds <- rds[-which(idlen==0)]
        log_debug("removed individual(s) with no locations")
        if (length(rds)==0) rds <- NULL
      }
      
      if (length(rds)==0) 
      {
        # fallback for N=0
        log_debug("Analyzing for N=0")
        root <- mapCtmmTelemetryListOutput(
          n = "empty-result",
          animals_total_number=0,
          animal_names = NA,
          timezone = NA,
          projection = NA
        )
      }
      else
      {
        if (is(rds,'list') & length(rds)>1) # should always be list, as simple telemetry elements are not passed on (should not be)
        {
          #N>1
          log_debug("Analyzing for N>1")
          n <- "non-empty-result"
          animals_total_number <- length(rds)
          animal.name <- unlist(lapply(rds, function(x) summary(x)$identity))
          tz <-  unique(unlist(lapply(rds, function(x) summary(x)$timezone)))
          prj <-  unique(unlist(lapply(rds, function(x) summary(x)$projection)))
        }
        if (is(rds,'list') & length(rds)==1)
        {
          #N=1
          log_debug("Analyzing for N=1")
          n <- "one-item-result"
          animals_total_number <- 1
          animal.name <-  summary(rds[[1]])$identity
          tz <- summary(rds[[1]])$timezone
          prj <- summary(rds[[1]])$projection
        }

        root <- mapCtmmTelemetryListOutput(
          n = n,
          animals_total_number <- animals_total_number,
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
    animals_total_number=NA,
    timezone = NA,
    projection = NA
) {
    list(
        n = n,
        animals_total_number = animals_total_number,
        animal_names = animal_names,
        timezone = timezone,
        projection = projection
    )
}