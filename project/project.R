#install.packages("dplyr")
#install.packages("ggplot2")
#install.packages("readr")
#install.packages("lubridate")
#install.packages("RPostgreSQL")
#install.packages("tidyverse")
#install.package("rpart.plot")

require(dplyr)
require(ggplot2)
require(readr)
require(lubridate)
require(RPostgreSQL)
require(tidyverse)
library(rpart)
library(rpart.plot)


proj = read.csv2(file = "data/surgical_case_durations.csv")
proj <- na.omit(proj)
proj <- as_tibble(proj)
head(proj)
str(proj)


#DATA PREPARATION (TRANSFORMING AND COMPUTING)

# default coulumn type is factor
# converting required coloumns to numeric for processing  
proj$Geplande.operatieduur <- as.numeric(proj$Geplande.operatieduur)
proj$Operatieduur <- as.numeric(proj$Operatieduur)
proj$BMI <- as.numeric(sub(",", ".", sub(".", "", proj$BMI, fixed=TRUE), fixed=TRUE))
proj$Ziekenhuis.ligduur <- as.numeric(proj$Ziekenhuis.ligduur)
proj$IC.ligduur <- as.numeric(proj$IC.ligduur)
proj$Euroscore1 <- as.numeric(proj$Euroscore1)
proj$Euroscore2 <- as.numeric(proj$Euroscore2)
proj$Leeftijd <- as.numeric(proj$Leeftijd)


#compute time difference
proj <- mutate(proj, time.diff = Operatieduur - Geplande.operatieduur)

# compute age group
proj <- proj %>%
  mutate(age_group = case_when(
    Leeftijd > 70 ~ ">70",
    Leeftijd > 60 & Leeftijd <= 70 ~ "60-70",
    Leeftijd > 50 & Leeftijd <= 60 ~ "50-60",
    Leeftijd > 40 & Leeftijd <= 50 ~ "40-50",
    Leeftijd > 30 & Leeftijd <= 40 ~ "30-40",
    Leeftijd > 20 & Leeftijd <= 30 ~ "20-30",
    Leeftijd > 10 & Leeftijd <= 20 ~ "10-20",
    Leeftijd <= 10 ~ "< 10"))
proj$age_group <- as.factor(proj$age_group)

# compute BMI group
proj <- proj %>%  
  mutate(BMI_group = case_when(
    BMI >= 30              ~ "Obese",
    BMI >= 25   & BMI < 30 ~ "Overweight",
    BMI >= 18.5 & BMI < 25 ~ "Normal",
    BMI <  18.5            ~ "Underweight",))
proj$BMI_group <- as.factor(proj$BMI_group)

# compute delay group
proj <- proj %>%  
  mutate(time_group = case_when(
    time.diff >=  60                     ~ "Very Late",
    time.diff >=  15 & time.diff < 60    ~ "Late but <60min",
    time.diff >= -15 & time.diff < 15    ~ "Within 15 mins",
    time.diff >= -60 &  time.diff < -15  ~ "Early but <60min",
    time.diff <  -60                     ~ "Very Early"))
proj$time_group <- as.factor(proj$time_group)

# write a coloums with the number of operations planned
proj <- mutate(proj, num_of_ops = str_count(proj$Operatietype, '\\+') + 1 )
proj$num_of_ops <- as.factor(proj$num_of_ops)

# attempting to separate the operations - WIP
proj <- mutate(proj, op_types = sub(" + ", " , ", proj$Operatietype, fixed = TRUE)) 

# compute Operation time group
# doing this so it can be used as a factor. in its currenct form, operatieduur is a very large factor
proj <- proj %>%  
  mutate(op_time_group = case_when(
    Operatieduur >= 465                      ~ ">465",
    Operatieduur >= 450 & Operatieduur < 465 ~ "450-465",
    Operatieduur >= 435 & Operatieduur < 450 ~ "435-450",
    Operatieduur >= 420 & Operatieduur < 435 ~ "420-435",
    Operatieduur >= 405 & Operatieduur < 420 ~ "405-420",
    Operatieduur >= 390 & Operatieduur < 405 ~ "390-405",
    Operatieduur >= 375 & Operatieduur < 390 ~ "375-390",
    Operatieduur >= 360 & Operatieduur < 375 ~ "360-375",
    Operatieduur >= 345 & Operatieduur < 360 ~ "345-360",
    Operatieduur >= 330 & Operatieduur < 345 ~ "330-345",
    Operatieduur >= 315 & Operatieduur < 330 ~ "315-330",
    Operatieduur >= 300 & Operatieduur < 315 ~ "300-315",
    Operatieduur >= 285 & Operatieduur < 300 ~ "285-300",
    Operatieduur >= 270 & Operatieduur < 285 ~ "270-285",
    Operatieduur >= 255 & Operatieduur < 270 ~ "255-270",
    Operatieduur >= 240 & Operatieduur < 255 ~ "240-255",
    Operatieduur >= 225 & Operatieduur < 240 ~ "225-240",
    Operatieduur >= 210 & Operatieduur < 225 ~ "210-225",
    Operatieduur >= 195 & Operatieduur < 210 ~ "195-210",
    Operatieduur >= 180 & Operatieduur < 195 ~ "180-195",
    Operatieduur >= 165 & Operatieduur < 180 ~ "165-180",
    Operatieduur >= 150 & Operatieduur < 165 ~ "150-165",
    Operatieduur >= 135 & Operatieduur < 150 ~ "135-150",
    Operatieduur >= 120 & Operatieduur < 135 ~ "120-135",
    Operatieduur >= 105 & Operatieduur < 120 ~ "105-120",
    Operatieduur >=  90 & Operatieduur < 105 ~ "90-105",
    Operatieduur >=  75 & Operatieduur <  90 ~ "75-90",
    Operatieduur >=  60 & Operatieduur <  75 ~ "60-75",
    Operatieduur >=  45 & Operatieduur <  60 ~ "45-60",
    Operatieduur >=  30 & Operatieduur <  45 ~ "30-45",
    Operatieduur >=  15 & Operatieduur <  30 ~ "15-30",
    Operatieduur <   15                      ~ "<15"  ))
proj$op_time_group <- as.factor(proj$op_time_group)

# compute the group for planned opertaion time. We plan to use this later to compare predicted and planned opertaion times.
proj <- proj %>%  
  mutate(op_planned_time_group = case_when(
    Geplande.operatieduur >= 465                               ~ ">465",
    Geplande.operatieduur >= 450 & Geplande.operatieduur < 465 ~ "450-465",
    Geplande.operatieduur >= 435 & Geplande.operatieduur < 450 ~ "435-450",
    Geplande.operatieduur >= 420 & Geplande.operatieduur < 435 ~ "420-435",
    Geplande.operatieduur >= 405 & Geplande.operatieduur < 420 ~ "405-420",
    Geplande.operatieduur >= 390 & Geplande.operatieduur < 405 ~ "390-405",
    Geplande.operatieduur >= 375 & Geplande.operatieduur < 390 ~ "375-390",
    Geplande.operatieduur >= 360 & Geplande.operatieduur < 375 ~ "360-375",
    Geplande.operatieduur >= 345 & Geplande.operatieduur < 360 ~ "345-360",
    Geplande.operatieduur >= 330 & Geplande.operatieduur < 345 ~ "330-345",
    Geplande.operatieduur >= 315 & Geplande.operatieduur < 330 ~ "315-330",
    Geplande.operatieduur >= 300 & Geplande.operatieduur < 315 ~ "300-315",
    Geplande.operatieduur >= 285 & Geplande.operatieduur < 300 ~ "285-300",
    Geplande.operatieduur >= 270 & Geplande.operatieduur < 285 ~ "270-285",
    Geplande.operatieduur >= 255 & Geplande.operatieduur < 270 ~ "255-270",
    Geplande.operatieduur >= 240 & Geplande.operatieduur < 255 ~ "240-255",
    Geplande.operatieduur >= 225 & Geplande.operatieduur < 240 ~ "225-240",
    Geplande.operatieduur >= 210 & Geplande.operatieduur < 225 ~ "210-225",
    Geplande.operatieduur >= 195 & Geplande.operatieduur < 210 ~ "195-210",
    Geplande.operatieduur >= 180 & Geplande.operatieduur < 195 ~ "180-195",
    Geplande.operatieduur >= 165 & Geplande.operatieduur < 180 ~ "165-180",
    Geplande.operatieduur >= 150 & Geplande.operatieduur < 165 ~ "150-165",
    Geplande.operatieduur >= 135 & Geplande.operatieduur < 150 ~ "135-150",
    Geplande.operatieduur >= 120 & Geplande.operatieduur < 135 ~ "120-135",
    Geplande.operatieduur >= 105 & Geplande.operatieduur < 120 ~ "105-120",
    Geplande.operatieduur >=  90 & Geplande.operatieduur < 105 ~ "90-105",
    Geplande.operatieduur >=  75 & Geplande.operatieduur <  90 ~ "75-90",
    Geplande.operatieduur >=  60 & Geplande.operatieduur <  75 ~ "60-75",
    Geplande.operatieduur >=  45 & Geplande.operatieduur <  60 ~ "45-60",
    Geplande.operatieduur >=  30 & Geplande.operatieduur <  45 ~ "30-45",
    Geplande.operatieduur >=  15 & Geplande.operatieduur <  30 ~ "15-30",
    Geplande.operatieduur < 15                                 ~ "<15")
  )
 proj$op_planned_time_group <- as.factor(proj$op_planned_time_group)   

#clearing out null rows
proj_orig <- proj
proj <- proj %>% filter(Geslacht != "NULL")














# UPLOAD
# require("RPostgreSQL")
# 
# pw <- {
#   "***"
# }
# 
# drv <- dbDriver("PostgreSQL")
# con <- dbConnect(drv, dbname = "dpv1a025",
#                  host = "castle.ewi.utwente.nl", port = 5432,
#                  user = "dpv1a025", password = pw,
#                  options="-c search_path=project")
# rm(pw)
# 
# dbWriteTable(con, "Patients", value = proj, overwrite = T, row.names = F)
