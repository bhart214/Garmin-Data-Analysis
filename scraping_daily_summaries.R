library(tidyverse)
library(lubridate)
#library(rvest)
#library(httr)
#library(purrr)
library(RSelenium)
library(fit)
#library(zoo)



### set chrome download location
file_directory <- "C:/Users/bhart/Desktop/garmin"
eCaps <- list(
  FirefoxOptions = 
    list(prefs = list(
      "profile.default_content_settings.popups" = 0L,
      "download.prompt_for_download" = FALSE,
      "download.default_directory" = file_directory)))

### start up firefox remote driver
rD <- rsDriver(browser = "firefox", verbose = FALSE, extraCapabilities = eCaps)
remDr <- rD$client

url <- "https://connect.garmin.com/en-US/signin"
remDr$navigate(url)
remDr$getTitle()

# i'll just sign in manually on the remote driver window



### Create empty dataframe to store data...
# create vector of dates (one for each day since I started wearing the watch)
date_vec = seq(ymd("2016-11-13"), ymd(today()), by = '1 day')
garmin_data <- as_data_frame(matrix(nrow = length(date_vec), ncol = 14))
colnames(garmin_data) <- c("date", 
                           "steps", 
                           "intensity_min",
                           "total_dist",
                           "total_cal", 
                           "resting_hr",
                           "avg_resting_hr", 
                           "floors_climbed",
                           "floors_descended", 
                           "deep_sleep_time", 
                           "light_sleep_time", 
                           "awake_time", 
                           "bed_time", 
                           "wakeup_time")
garmin_data$date <- date_vec




for(i in seq_len(nrow(garmin_data))) {
  url = paste0("https://connect.garmin.com/modern/daily-summary/bhart214/", date_vec[i])
  remDr$navigate(url)
  Sys.sleep(runif(min = 6, max =  10, n = 1))
  
  # data_1
  tryCatch({
  web_elem <- remDr$findElement("css", ".page-content > div:nth-child(1) > div:nth-child(1)")
  text <- web_elem$getElementText()[[1]]
  for (j in seq_along(read_lines(text))) {
    if(read_lines(text)[j] == "Steps") {garmin_data[['steps']][i] <- (read_lines(text)[j-1])}
    if(read_lines(text)[j] == "Intensity Minutes") {garmin_data[['intensity_min']][i] <- (read_lines(text)[j-1])}
    if(read_lines(text)[j] == "Floors Climbed") {garmin_data[['floors_climbed']][i] <- (read_lines(text)[j-1])}
  }
  }, error=function(e){})
  Sys.sleep(runif(min = 1, max =  3, n = 1))
  
  # data_2
  tryCatch({
  web_elem <- remDr$findElement("css", ".daily-summary-stats-placeholder > div:nth-child(1)")
  text <- web_elem$getElementText()[[1]]
  for (j in seq_along(read_lines(text))) {
    if(read_lines(text)[j] == "Total Calories") {garmin_data[['total_cal']][i] <- (read_lines(text)[j-1])}
    if(read_lines(text)[j] == "Avg Resting Heart Rate") {garmin_data[['avg_resting_hr']][i] <- (read_lines(text)[j-1])}
    if(read_lines(text)[j] == "Floors Descended") {garmin_data[['floors_descended']][i] <- (read_lines(text)[j-1])}
    if(read_lines(text)[j] == "Resting Heart Rate") {garmin_data[['resting_hr']][i] <- (read_lines(text)[j-1])}
    if(read_lines(text)[j] == "Total Distance") {garmin_data[['total_dist']][i] <- (read_lines(text)[j-1])}
  }
  }, error=function(e){})
  Sys.sleep(runif(min = 1, max =  3, n = 1))
  
  
  tryCatch({
  ## Click "Sleep"
  web_elem <- remDr$findElement("css", ".nav > li:nth-child(4)")
  web_elem$clickElement()
  Sys.sleep(runif(min = 6, max =  10, n = 1))
  
  # Sleep Times
  web_elem <- remDr$findElement("css", ".sleep-durations-view")
  text <- web_elem$getElementText()[[1]]
  for (j in seq_along(read_lines(text))) {
    if(read_lines(text)[j] == "Deep") {garmin_data[['deep_sleep_time']][i] <- (read_lines(text)[j-1])}
    if(read_lines(text)[j] == "Light") {garmin_data[['light_sleep_time']][i] <- (read_lines(text)[j-1])}
    if(read_lines(text)[j] == "Awake") {garmin_data[['awake_time']][i] <- (read_lines(text)[j-1])}
  }
  Sys.sleep(runif(min = 1, max =  3, n = 1))
  
  
  # Bed Time
  web_elem <- remDr$findElement("css", ".sleep-levels-chart-placeholder > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1)")
  garmin_data[['bed_time']][i] <- web_elem$getElementText()[[1]]
  Sys.sleep(runif(min = 1, max =  3, n = 1))
  
  # Wake Time
  web_elem <- remDr$findElement("css", ".sleep-levels-chart-placeholder > div:nth-child(3) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1)")
  garmin_data[['wakeup_time']][i] <- web_elem$getElementText()[[1]]
  Sys.sleep(runif(min = 1, max =  3, n = 1))
  
  }, error=function(e){})
}

write_rds(garmin_data, "garmin_data.rds")

remDr$close()
rD$server$stop()
rm(rD)
rm(remDr)


