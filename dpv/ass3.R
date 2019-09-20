library("readr")
library("dplyr")

# using read.delim2 to parse European stype decimal place

Main <- read.delim2("data/SuperstoreSales_main.csv",
                         sep = ';')
                         
Mgr <- read.delim2("data/SuperstoreSales_manager.csv",
                   sep = ';')

Returns <- read.delim2("data/SuperstoreSales_returns.csv",
                       sep = ';')


# top product category making losses

Main %>%
  group_by(Product.Sub.Category) %>%
  summarise_at(vars(Profit), sum) %>%
  arrange(Profit) %>%
  head(5)

# top products making loss

Main %>%
  group_by(Product.Name) %>%
  summarise_at(vars(Profit), sum) %>%
  arrange(Profit)


