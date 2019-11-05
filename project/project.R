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
    Operatieduur >=  480                         ~ ">480",
    Operatieduur >=  420 & Operatieduur < 480    ~ "420-480",
    Operatieduur >=  360 & Operatieduur < 420    ~ "360-420",
    Operatieduur >=  300 & Operatieduur < 360    ~ "300-360",
    Operatieduur >=  240 & Operatieduur < 300    ~ "240-300",
    Operatieduur >=  180 & Operatieduur < 240    ~ "180-240",
    Operatieduur >=  120 & Operatieduur < 180    ~ "120-180",
    Operatieduur >=  60  & Operatieduur < 120    ~ "60-120",
    Operatieduur <  60                           ~ "<60"))
proj$op_time_group <- as.factor(proj$op_time_group)


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
