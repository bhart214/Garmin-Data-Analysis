library(tidyverse)
library(lubridate)

garmin_data <- read_rds("garmin_data.rds")
glimpse(garmin_data)

### Cleaning
# remove "--" where data is missing (change to NA)

# date:              OK
# steps:             Convert to integer
# intensity_min:     Convert to integer
# total_dist:        Convert to numeric (miles)
# total_cal:         Convert to integer
# resting_hr:        Convert to integer
# avg_resting_hr:    Convert to integer
# floors_climbed:    Convert to integer
# floors_descended:  Convert to integer
# deep_sleep_time:   Convert to integer (minutes duration)
# light_sleep_time:  Convert to integer (minutes duration)
# awake_time:        Convert to integer (minutes duration)
# bed_time:          Convert to time (hm)
# wakeup_time:       Convert to time (hm)

garmin_data <- garmin_data %>% 
  separate(total_dist, into = c("total_dist", "units"), sep = " ", extra = "drop") %>% 
  select(-units)

garmin_data$steps <- as.numeric(gsub(",", "", garmin_data$steps))
garmin_data$intensity_min <- as.numeric(gsub(",", "", garmin_data$intensity_min))
garmin_data$total_cal <- as.numeric(gsub(",", "", garmin_data$total_cal))
garmin_data$total_dist <- as.numeric(garmin_data$total_dist)
garmin_data$resting_hr <- as.numeric(garmin_data$resting_hr)
garmin_data$avg_resting_hr <- as.numeric(garmin_data$avg_resting_hr)
garmin_data$floors_climbed <- as.numeric(garmin_data$floors_climbed)
garmin_data$floors_descended <- as.numeric(garmin_data$floors_descended)




### Impute missing data

### Create new features...
