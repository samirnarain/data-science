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

head(proj)
str(proj)

proj <- na.omit(proj)

proj <- mutate(proj, time.diff = as.numeric(Geplande.operatieduur) - as.numeric(Operatieduur))

ggplot(data = proj, aes(x=time.diff)) +
  geom_histogram(bins = 50)

summary(proj$time.diff)
