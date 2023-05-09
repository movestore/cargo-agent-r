library(logger)
library(foreach)
library(move)

# rds is `move::moveStack`
analyzeMoveMoveStack <- function(rds) {
  root <- NA

  tryCatch(
    {
      if (length(rds)==0) #can only be met if NULL input
      {
        # fallback for N=0
        log_debug("Analyzing for N=0")
        root <- mapMoveMoveStackOutput(
          n = "empty-result",
          positions_bounding_box = rep(NA,4),
          projection = NA,
          sensor_types = NA,
          timestamps_range = rep(NA,2),
          positions_total_number = 0,
          animals_total_number = 0,
          animal_names = NA,
          animal_attributes = NA,
          taxa = NA,
          tracks_total_number = 0,
          track_names = NA,
          number_positions_by_track = NA,
          track_attributes = NA
        )
      }
      else
      {
        # these are the names of the move objects,
        # which are not necessarily the animals (only),
        # but this seems easier to generalise
        ids <- namesIndiv(rds)
        n <- NA
        if (is(rds,'MoveStack')) #always true if not NULL
        {
          #N>=1
          log_debug("Analyzing for N>=1")
          n <- "non-empty-result"
          rds_spl <- move::split(rds)
          id_posis <- foreach(rdsi = rds_spl, .combine=c) %do% {
            length(rdsi)
          }
        }
        if (length(move::split(rds))==1)
        {
          #N=1
          log_debug("Analyzing for N=1")
          n <- "one-item-result"
          id_posis <- length(rds)
        }
        iddata <- idData(rds)
        names(iddata) <- make.names(names(iddata),allow_=FALSE)
        
        if (any(names(iddata)=="individual.local.identifier")) {
          animals <- unique(iddata$individual.local.identifier)
        } else if (any(names(iddata)=="local.identifier")) {
          animals <- unique(iddata$local.identifier)
        } else {
          animals <- "no appropriate animal names available"
        }
        
        #addition for varying taxa names
        if (any(names(iddata)=="individual.taxon.canonical.name")) {
          taxa <- as.character(unique(iddata$individual.taxon.canonical.name))
        } else if (any(names(iddata)=="taxon.canonical.name")) {
          taxa <- as.character(unique(iddata$taxon.canonical.name))
        } else {
          taxa <- "no appropriate taxa names available"
        }

        root <- mapMoveMoveStackOutput(
          n = n,
          positions_bounding_box = data.frame(bbox(rds)),
          projection = projection(rds),
          sensor_types = unique(as.character(sensor(rds))),
          timestamps_range = as.character(range(timestamps(rds))),
          positions_total_number = length(rds),
          animals_total_number = length(animals),
          animal_names = animals,
          animal_attributes = names(unique(iddata)[,!sapply(iddata, function(x) all(is.na(x)))]),
          taxa = taxa,
          tracks_total_number = length(ids),
          track_names = ids,
          number_positions_by_track = data.frame("animal"=ids,"positions_number"=id_posis),
          track_attributes = names(rds@data[,!sapply(rds@data, function(x) all(is.na(x)))])
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

mapMoveMoveStackOutput <- function(
  n,
  positions_bounding_box = NA,
  projection = NA,
  sensor_types = NA,
  timestamps_range = NA,
  positions_total_number = NA,
  animals_total_number = NA,
  animal_names = NA,
  animal_attributes = NA,
  taxa = NA,
  tracks_total_number = NA,
  track_names = NA,
  number_positions_by_track = NA,
  track_attributes = NA
) {
  list(
    n = n,
    positions_bounding_box = positions_bounding_box,
    projection = projection,
    sensor_types = sensor_types,
    timestamps_range = timestamps_range,
    positions_total_number = positions_total_number,
    animals_total_number = animals_total_number,
    animal_names = animal_names,
    animal_attributes = animal_attributes,
    taxa = taxa,
    tracks_total_number = tracks_total_number,
    track_names = track_names,
    number_positions_by_track = number_positions_by_track,
    track_attributes = track_attributes
  )
}