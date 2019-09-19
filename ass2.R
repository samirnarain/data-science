#install.packages("tidyverse")

library("tidyverse")
library("readr")

df <- read_delim("data/BI_Raw_Data.csv", delim = ";", 
                 col_names = TRUE, col_types = NULL)

