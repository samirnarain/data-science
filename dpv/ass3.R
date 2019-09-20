library("readr")
library("dplyr")
library("lubridate")
library("tidyverse")

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




# prepare date to load

returnStauts <- data.frame(idReturnStatus = 0:1,
                           ReturnValue = c("Not Returned", "Returned"))

Customer <- Main %>%
  select(Customer.Name, Province, Region, Customer.Segment) %>%
  rename(name = Customer.Name, segment = Customer.Segment)%>%
  arrange(name, Province ) %>%
  group_by(name) %>%
  distinct() %>%
  ungroup() %>%
  mutate(customerid = row_number())


Product <- Main %>%
  select(Product.Name, Product.Category, Product.Sub.Category) %>%
  rename(name = Product.Name, category = Product.Category, 
         subcategory = Product.Sub.Category) %>%
  arrange() %>%
  distinct() %>%
  mutate(productid = row_number())


Sales <- Main %>%
  right_join(Customer, by = c("Customer.Name" = "name",
                             "Customer.Segment" = "segment",
                             "Province", "Region")) %>%
  right_join(Product, by = c("Product.Name" = "name",
                             "Product.Category" = "category", 
                             "Product.Sub.Category" = "subcategory")) %>%
  full_join(Returns, type = "inner", by = 'Order.ID') %>%
  mutate(idReturnStatus = ifelse(is.na(Status), 0, 1)) %>%
  mutate(Delay = as.numeric(interval(dmy(Main$Order.Date),
                                     dmy(Main$Ship.Date))/ddays())) %>%
  mutate(Late = ifelse(Delay < 3, "Not Late", "Late")) %>%
  select (productid, Order.Date, Sales, Order.Quantity, Unit.Price, 
          Profit, Shipping.Cost, Late, idReturnStatus, customerid)

# connect to db and write to tables


