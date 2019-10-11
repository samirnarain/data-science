require(dplyr)
require(ggplot2)
require(readr)



proj = read.csv2(file = "data/surgical_case_durations.csv")


head(proj)
str(proj)
proj <- na.omit(proj)
proj <- mutate(proj, time.diff = as.numeric(Geplande.operatieduur) - as.numeric(Operatieduur))

ggplot(data = proj, aes(x=time.diff)) +
  geom_histogram(bins = 50)


summary(proj$time.diff)


