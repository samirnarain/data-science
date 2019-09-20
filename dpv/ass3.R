library("readr")
library("dplyr")
library("lubridate")

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


Main %>%
  mutate(Delay = as.numeric(interval(dmy(Main$Order.Date),
                            dmy(Main$Ship.Date))/ddays())) %>%
  mutate(LateOrNot = ifelse(Delay < 3, "Not Late", "Late")) %>%
  filter(LateOrNot == "Late") %>%
  group_by(Product.Sub.Category) %>%
  count(sort = TRUE)
  

Main %>%
  full_join(Returns, type = "inner", by = 'Order.ID') %>%
  filter(Status == "Returned") %>%
  group_by(Product.Sub.Category) %>%
  count(sort = T)

Main %>%
  full_join(Returns, type = "inner", by = 'Order.ID') %>%
  filter(Status == "Returned") %>%
  group_by(Product.Name) %>%
  count(sort = T)



Main %>%
  mutate(Delay = as.numeric(interval(dmy(Main$Order.Date),
                                     dmy(Main$Ship.Date))/ddays())) %>%
  mutate(LateOrNot = ifelse(Delay < 3, "Not Late", "Late")) %>%
  filter(LateOrNot == "Late") %>%
  group_by(Product.Name) %>%
  count(sort = TRUE)

