#install.packages("dplyr")
#install.packages("ggplot2")
#install.packages("readr")
#install.packages("lubridate")
#install.packages("RPostgreSQL")
#install.packages("tidyverse")


require(dplyr)
require(ggplot2)
require(readr)
require(lubridate)
require(RPostgreSQL)
require(tidyverse)



proj = read.csv2(file = "data/surgical_case_durations.csv")
proj <- na.omit(proj)

proj <- as_tibble(proj)

head(proj)
str(proj)

# default coulumn type is factor
# converting required coloumns to numeric for processing  

proj$Leeftijd <- as.numeric(proj$Leeftijd)
proj$Anesthesioloog  <- as.numeric(proj$Anesthesioloog )
proj$Chirurg <- as.numeric(proj$Chirurg)
proj$BMI <- as.numeric(sub(",", ".", proj$BMI, fixed = TRUE))
proj$Euroscore1 <- as.numeric(sub(",", ".", proj$Euroscore1, fixed = TRUE))
proj$Euroscore2 <- as.numeric(sub(",", ".", proj$Euroscore2, fixed = TRUE))
proj$Operatieduur <- as.numeric(proj$Operatieduur)
proj$Ziekenhuis.ligduur    <- as.numeric(proj$Ziekenhuis.ligduur)
proj$IC.ligduur <- as.numeric(proj$IC.ligduur)


# compute the time diff between planned duration and actual

proj <- mutate(proj, time.diff = as.numeric(Geplande.operatieduur) - as.numeric(Operatieduur))

ggplot(data = proj, aes(x=time.diff)) +
  geom_histogram(bins = 50)

summary(proj)


#proj %>%
#  filter(Leeftijd > 70)



  
proj <- proj %>%
  mutate(age_group = case_when(
      Leeftijd > 70 ~ ">70",
      Leeftijd > 60 & Leeftijd <= 70 ~ "60-70",
      Leeftijd > 50 & Leeftijd <= 60 ~ "50-60",
      Leeftijd > 40 & Leeftijd <= 50 ~ "40-50",
      Leeftijd <= 40 ~ "< 40"))

proj$age_group <- as.factor(proj$age_group)
  
proj <- proj %>%  
  mutate(BMI_group = case_when(
      BMI >= 30              ~ "Obese",
      BMI >= 25   & BMI < 30 ~ "Overweight",
      BMI >= 18.5 & BMI < 25 ~ "Normal",
      BMI <  18.5            ~ "Underweight",))
     

proj$BMI_group <- as.factor(proj$BMI_group)



# connect to the DB and write 
