library(shiny)
library(logger)
# Run the app

log.file <- "logs/recommender.log"
file <- file()

log_appender(appender = appender_tee(log.file, append = T))
log_info("App started.")

runApp()
