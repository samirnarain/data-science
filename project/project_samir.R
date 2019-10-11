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
proj$Geplande.operatieduur  <- as.numeric(proj$Geplande.operatieduur)
proj$Operatieduur <- as.numeric(proj$Operatieduur)
proj$BMI <- as.numeric(sub(",", ".", proj$BMI, fixed = TRUE))
proj$Euroscore1 <- as.numeric(sub(",", ".", proj$Euroscore1, fixed = TRUE))
proj$Euroscore2 <- as.numeric(sub(",", ".", proj$Euroscore2, fixed = TRUE))
proj$Ziekenhuis.ligduur    <- as.numeric(proj$Ziekenhuis.ligduur)
proj$IC.ligduur <- as.numeric(proj$IC.ligduur)


# compute the time diff between planned duration and actual
proj <- mutate(proj, time.diff = Geplande.operatieduur - Operatieduur)

#see time difference
ggplot(data = proj, aes(x=time.diff)) +
  geom_histogram(bins = 50)



#proj %>%
#  filter(Leeftijd > 70)

# to see impact of age on operationtime difference
ggplot(df, aes(x=Leeftijd, y=Operatieduur.diff))+  
  geom_point()+
  geom_smooth()

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

#upload to database

pw <- {
  "***"
}

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "dpv1a025",
                 host = "castle.ewi.utwente.nl", port = 5432,
                 user = "dpv1a025", password = pw,
                 options="-c search_path=project")
rm(pw)

dbWriteTable(con, "Patients", value = proj, overwrite = T, row.names = F)

summary(proj)
