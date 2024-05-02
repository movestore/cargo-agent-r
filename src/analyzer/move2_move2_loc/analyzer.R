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
            M_n = "empty-result",
            A_positions_bounding_box = rep(NA, 4),
            B_projection = NA,
            C_sensor_types = NA,
            D_timestamps_range = rep(NA, 2),
            E_positions_total_number = 0,
            F_animals_total_number = 0,
            G_animal_names = NA,
            L_track_attributes = NA,
            H_taxa = NA,
            I_tracks_total_number = 0,
            J_track_names = NA,
            K_number_positions_by_track = NA,
            N_event_attributes = NA
          )
        } else {
          ids <- as.character(unique(mt_track_id(rds)))
          M_n <- "non-empty-result"

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
          M_n = M_n,
          A_positions_bounding_box = data.frame(matrix(st_bbox(rds), ncol = 2)), # row and col names differ, I kind of like the named vector more than the data frame as it is very clear what each element is
          B_projection = st_crs(rds)$input,
          C_sensor_types = unique_sensor_types,
          D_timestamps_range = as.character(range(mt_time(rds))), # Now timezones are not included in the printing
          E_positions_total_number = nrow(rds),
          F_animals_total_number = length(animals),
          G_animal_names = animals,
          L_track_attributes = names(mt_track_data(rds)[, !sapply(track_data, function(x) all(is.na(x)))]),# I changed to mt_track_data as it contains the unmodified names
          H_taxa = taxa,
          I_tracks_total_number = mt_n_tracks(rds),
          J_track_names = ids,
          K_number_positions_by_track = data.frame("animal" = names(id_posis), "positions_number" = id_posis),
          N_event_attributes = names(rds[, !sapply(rds, function(x) all(is.na(x)))])
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
    M_n,
    A_positions_bounding_box = NA,
    B_projection = NA,
    C_sensor_types = NA,
    D_timestamps_range = NA,
    E_positions_total_number = NA,
    F_animals_total_number = NA,
    G_animal_names = NA,
    L_track_attributes = NA,
    H_taxa = NA,
    I_tracks_total_number = NA,
    J_track_names = NA,
    K_number_positions_by_track = NA,
    N_event_attributes = NA) {
  list(
    list(positions_bounding_box = A_positions_bounding_box),
    list(projection = B_projection),
    list(sensor_types = C_sensor_types),
    list(timestamps_range = D_timestamps_range),
    list(positions_total_number = E_positions_total_number),
    list(animals_total_number = F_animals_total_number),
    list(animal_names = G_animal_names),
    list(taxa = H_taxa),
    list(tracks_total_number = I_tracks_total_number),
    list(track_names = J_track_names),
    list(number_positions_by_track = K_number_positions_by_track),
    list(track_attributes = L_track_attributes),
    list(event_attributes = N_event_attributes),
    list(n = M_n)
  )
}
