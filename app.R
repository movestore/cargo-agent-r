library(move)
library(jsonlite)
library(dplyr)
library(logger)
library(httr)
library(benchmarkme)
Sys.setenv(tz = "UTC")
log_threshold(Sys.getenv(x = "LOG_LEVEL_CARGO_AGENT_R", "WARN"))

source("src/common/helper.R")

if (Sys.getenv(x = "ENV", "dev") == "dev") {
  # override defaults if not in prod env
  source("src/common/local_dev.R")
}

watchFileName <- coPilotOutputFile()
outputWorkingCopyFileName <- Sys.getenv(x = "OUTPUT_WORKING_COPY_FILE", "/tmp/output_cargo-agent_copy")
myResultFileName <- myOutputFile()
lastAnalyzedMemoryFileName <- Sys.getenv(x = "LAST_ANALYZED_FILE", "/tmp/cargo-agent-r_last-analyzed.txt")
currentAppStateFileName <- Sys.getenv(x = "CURRENT_APP_STATE_FILE", "/tmp/current-app-state.txt")

sleep <- 2 # seconds
monitor <- TRUE

writeResult <- function(root) {
  json <- toJSON(root)
  write(paste(json), file = myResultFileName)
  log_info("json: {json}")
}

readRdsFile <- function() {
  # this copy is perhaps not necessary. but now we have it and it is not bad at all..
  file.copy(watchFileName, outputWorkingCopyFileName)
  if (file.info(outputWorkingCopyFileName)$size == 0) {
    # special case: the `null`-result
    log_debug("Handling the NULL-result")
    root <- list(n = NA)
    writeResult(root)
    return(NULL)
  }
  log_debug("reading the RDS from '{outputWorkingCopyFileName}'...")
  rds <- readRDS(file = outputWorkingCopyFileName)
  return(rds)
}

invokeAnalyzer <- function() {
  tryCatch(
    {
      rds <- readRdsFile()
      if (!is.null(rds)) {
        if (file.exists(myResultFileName)) {
          # clean up
          log_debug("removing last result-file of cargo-agent-r")
          file.remove(myResultFileName)
        }
        
        # source the concrete analyzer file
        output_type_slug <- Sys.getenv(x = "OUTPUT_TYPE_SLUG")
        analyzer.source = file.path("src", "analyzer", output_type_slug, "analyzer.R")
        source(analyzer.source)
        # do it
        log_debug("analyzing the RDS for `{output_type_slug}`...")
        result <- analyze(rds = rds)
        # persist it
        writeResult(result)
      }
    },
    error = function(cond) {
      log_error("I caught this error: '{cond}'")
      root <- list(n = NA)
      writeResult(root)
    },
    warning = function(cond) {
      log_warn("I caught this warning: '{cond}'")
      root <- list(n = NA)
      writeResult(root)
    },
    finally = {
      now <- as.numeric(Sys.time())
      log_debug("writing the `lastAnalyzedMemoryFile`...")
      cat(now, file = lastAnalyzedMemoryFileName)
      log_info("Analysis complete.")
      if (file.exists(outputWorkingCopyFileName)) {
        # clean up
        log_debug("removing '{outputWorkingCopyFileName}'...")
        file.remove(outputWorkingCopyFileName)
      }
    }
  )
}

inDesiredAppState <- function() {
  if (file.exists(currentAppStateFileName)) {
    currentAppState <- gsub("[\r\n]", "", readChar(currentAppStateFileName, file.info(currentAppStateFileName)$size))
    log_debug("current app-state is '{currentAppState}'.")
    if (currentAppState == "APP_DONE") {
      return(TRUE)
    } else {
      return(FALSE)
    }
  } else {
    log_debug("current-app-state file does not exist. Looked at '{currentAppStateFileName}'.")
    return(FALSE)
  }
}

watcher <- function() {
  while (monitor) {
    if (file.exists(watchFileName)) {
      # the to analyze file exists
      if (inDesiredAppState()) {
        change <- file.info(watchFileName)$mtime
        if (file.exists(lastAnalyzedMemoryFileName)) {
          # a last-analyzed timestamp exists
          memory <- .POSIXct(readChar(lastAnalyzedMemoryFileName, file.info(lastAnalyzedMemoryFileName)$size))
          if (change > as.numeric(memory)) {
            log_debug("output-file is newer than last analyzed [{change} > {memory}]")
            invokeAnalyzer()
          } else {
            log_debug("no newer output found, existing output is dated at {change}, last analyze run at {memory}. waiting..")
          }
        } else {
          # this script never analyzed a file, but the output exists -> so do it now!
          log_debug("output-file detected first time!")
          invokeAnalyzer()
        }
      } else {
        log_debug("app not in desired state. waiting..")
      }
    } else {
      log_debug("{watchFileName} does not exists. waiting..")
    }
    Sys.sleep(sleep)
  }
}

log_info("Your machine: {.Machine$sizeof.pointer} (8 means 64-bit version of R)")
log_info("RAM {benchmarkme::get_ram()}, CPU {benchmarkme::get_cpu()}")

watcher()

