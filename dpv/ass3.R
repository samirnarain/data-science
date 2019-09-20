library("readr")
library("dplyr")

Main <- read.delim2("data/SuperstoreSales_main.csv",
                         sep = ';')
                         
Mgr <- read.delim2("data/SuperstoreSales_manager.csv",
                   sep = ';')

Returns <- read.delim2("data/SuperstoreSales_returns.csv",
                       sep = ';')


Main %>%
  group_by(Product.Sub.Category) %>%
  summarise_at(vars(Profit), sum) %>%
  arrange(Profit) %>%
  head(5)


