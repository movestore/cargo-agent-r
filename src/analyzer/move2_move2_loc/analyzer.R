library(logger)
library(move2)
library(sf)

# rds is `move2::mt`
analyze <- function(rds) {
  root <- NA

  tryCatch(
    {
      if (nrow(rds) == 0) # no locations is possible
        {
          # fallback for N=0
          log_debug("Analyzing for N=0")
          root <- mapMove2Move2_locOutput(
            n = "empty-result",
            positions_bounding_box = rep(NA, 4),
            projection = NA,
            sensor_types = NA,
            timestamps_range = rep(NA, 2),
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
        } else {
        ids <- as.character(unique(mt_track_id(rds)))
        n <- "non-empty-result"

        id_posis <- table(mt_track_id(rds))

        track_data <- mt_track_data(rds)
        names(track_data) <- make.names(names(track_data), allow_ = FALSE)

        if ("individual.local.identifier" %in% names(track_data)) {
          animals <- unique(track_data$individual.local.identifier)
        } else if ("local.identifier" %in% names(track_data)) {
          animals <- unique(track_data$local.identifier)
        } else {
          animals <- "no appropriate animal names available"
        }

        # addition for varying taxa names
        if ("individual.taxon.canonical.name" %in% names(track_data)) {
          taxa <- as.character(unique(track_data$individual.taxon.canonical.name))
        } else if ("taxon.canonical.name" %in% names(track_data)) {
          taxa <- as.character(unique(track_data$taxon.canonical.name))
        } else {
          taxa <- "no appropriate taxa names available"
        }
        rds_clean_names <- make.names(names(rds), allow_ = FALSE)

        sensorinfo <- data.frame("id"=c(397, 653, 673, 82798, 2365682, 2365683, 3886361, 7842954, 9301403, 77740391, 77740402, 819073350, 914097241, 1239574236, 1297673380, 2206221896, 2299894820, 2645090675),"name"=c("Bird Ring", "GPS", "Radio Transmitter", "Argos Doppler Shift", "Natural Mark", "Acceleration", "Solar Geolocator", "Accessory Measurements", "Solar Geolocator Raw", "Barometer", "Magnetometer", "Orientation", "Solar Geolocator Twilight", "Acoustic Telemetry", "Gyroscope", "Heart Rate", "Sigfox Geolocation", "Proximity"))
        
        if ("sensor.type" %in% rds_clean_names) {
          unique_sensor_types <- as.character(unique(as.data.frame(rds)[, which(rds_clean_names=="sensor.type")]))
        } else if ("sensor.type" %in% names(track_data)) {
          unique_sensor_types <- as.character(unique(track_data$sensor.type))
        } else if ("sensor.type.id" %in% rds_clean_names) {
          unique_sensor_types <- as.character(sensorinfo$name[which(sensorinfo$id==unique(as.data.frame(rds)[, rds_clean_names=="sensor.type.id"]))])
        } else {
          unique_sensor_types <- "no sensor type data found"
        }

        root <- mapMove2Move2_locOutput(
          n = n,
          positions_bounding_box = data.frame(matrix(st_bbox(rds), ncol = 2)), # row and col names differ, I kind of like the named vector more than the data frame as it is very clear what each element is
          projection = st_crs(rds)$input,
          sensor_types = unique_sensor_types,
          timestamps_range = as.character(range(mt_time(rds))), # Now timezones are not included in the printing
          positions_total_number = nrow(rds),
          animals_total_number = length(animals),
          animal_names = animals,
          animal_attributes = names(mt_track_data(rds)[, !sapply(track_data, function(x) all(is.na(x)))]),# I changed to mt_track_data as it contains the unmodified names
          taxa = taxa,
          tracks_total_number = mt_n_tracks(rds),
          track_names = ids,
          number_positions_by_track = data.frame("animal" = names(id_posis), "positions_number" = id_posis),
          track_attributes = names(rds[, !sapply(rds, function(x) all(is.na(x)))])
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

mapMove2Move2_locOutput <- function(
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
    track_attributes = NA) {
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
