coPilotOutputFile <- function() {
  result <- Sys.getenv(x = "OUTPUT_FILE", "/tmp/output_file")
  log_debug("outputFile: {result}")
  result
}

pilotEndpoint <- function() {
  Sys.getenv(x = "PILOT_ENDPOINT", "http://localhost:8100")
}

myOutputFile <- function() {
  # file-name must match with post-processing-configuration!
  result <- Sys.getenv(x = "OUTPUT_FILE_CARGO_AGENT_R", "/tmp/cargo-agent-r_movement-metadata.json")
  log_debug("outputFileCargoAgentR: {result}")
  result
}

appInstanceId <- function() {
  appInstanceId <- Sys.getenv(x = "pilot.app-instance-id")
  log_debug("appInstanceId: {appInstanceId}")
  appInstanceId
}