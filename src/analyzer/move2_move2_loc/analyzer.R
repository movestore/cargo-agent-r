library("logger")
library("move2")
library("sf")
library("dplyr")
library("vctrs")
library("purrr")
library("rlang")

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
            positions_bounding_box = rep(NA, 4),
            projection = NA,
            sensor_types = NA,
            timestamps_range = rep(NA, 2),
            positions_total_number = 0,
            animals_total_number = 0,
            animal_names = NA,
            taxa = NA,
            tracks_total_number = 0,
            track_names = NA,
            number_positions_by_track = NA,
            track_attributes = NA,
            event_attributes = NA,
            n = "empty-result"
          )
        } else {
          ## checking if there are columns in the track data that are a list. If yes, check if the content is the same, if yes remove list. If list columns are left over because content is different transform these into a character string (could be done as well as json, but think that average user will be more comfortable with text?)
          ## unlisting track data columns of class list
          if(any(sapply(mt_track_data(rds), is_bare_list))){
            ## reduce all columns were entry is the same to one (so no list anymore)
            rds <- rds |> mutate_track_data(across(
              where( ~is_bare_list(.x) && all(purrr::map_lgl(.x, function(y) 1==length(unique(y)) ))),
              ~do.call(vctrs::vec_c,purrr::map(.x, head,1))))
            if(any(sapply(mt_track_data(rds), is_bare_list))){
              ## transform those that are still a list into a character string
              rds <- rds |> mutate_track_data(across(
                where( ~is_bare_list(.x) && any(purrr::map_lgl(.x, function(y) 1!=length(unique(y)) ))),
                ~unlist(purrr::map(.x, paste, collapse=","))))
            }
          }
          
          if(is.factor(mt_track_id(rds))){
            mt_track_id(rds) <- droplevels(mt_track_id(rds))
            }
          
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
          
          positions_bounding_box = data.frame(matrix(st_bbox(rds), ncol = 2)), # row and col names differ, I kind of like the named vector more than the data frame as it is very clear what each element is
          projection = st_crs(rds)$input,
          sensor_types = unique_sensor_types,
          timestamps_range = as.character(range(mt_time(rds))), # Now timezones are not included in the printing
          positions_total_number = nrow(rds),
          animals_total_number = length(animals),
          animal_names = sort(as.character(animals)),
          taxa = taxa,
          tracks_total_number = mt_n_tracks(rds),
          track_names = sort(ids),
          number_positions_by_track = data.frame("animal" = names(id_posis), "positions_number" = as.vector(id_posis)),
          track_attributes = sort(names(mt_track_data(rds)[, !sapply(track_data, function(x) all(is.na(x)))])),# I changed to mt_track_data as it contains the unmodified names
          event_attributes = sort(names(rds[, !sapply(rds, function(x) all(is.na(x)))])),
          n = n
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
    positions_bounding_box = NA,
    projection = NA,
    sensor_types = NA,
    timestamps_range = NA,
    positions_total_number = NA,
    animals_total_number = NA,
    animal_names = NA,
    taxa = NA,
    tracks_total_number = NA,
    track_names = NA,
    number_positions_by_track = NA,
    track_attributes = NA,
    event_attributes = NA,
    n
) {
  # use unnamed list on root level to control order in resulting JSON file
  list(
    list(positions_total_number = positions_total_number),          # 1
    list(timestamps_range = timestamps_range),
    list(animals_total_number = animals_total_number),              # 3
    list(animal_names = animal_names),
    list(taxa = taxa),                                              # 5
    list(sensor_types = sensor_types),
    list(positions_bounding_box = positions_bounding_box),          # 7
    list(projection = projection),                            
    list(tracks_total_number = tracks_total_number),
    list(track_names = track_names),                                #10
    list(number_positions_by_track = number_positions_by_track),
    list(track_attributes = track_attributes),                      #12
    list(event_attributes = event_attributes),
    list(n = n)                                                     #14
  )
}
