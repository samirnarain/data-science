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

# product category Late

Main %>%
  mutate(Delay = as.numeric(interval(dmy(Main$Order.Date),
                            dmy(Main$Ship.Date))/ddays())) %>%
  mutate(LateOrNot = ifelse(Delay < 3, "Not Late", "Late")) %>%
  filter(LateOrNot == "Late") %>%
  group_by(Product.Sub.Category) %>%
  count(sort = TRUE)
  
# products late

Main %>%
  mutate(Delay = as.numeric(interval(dmy(Main$Order.Date),
                                     dmy(Main$Ship.Date))/ddays())) %>%
  mutate(LateOrNot = ifelse(Delay < 3, "Not Late", "Late")) %>%
  filter(LateOrNot == "Late") %>%
  group_by(Product.Name) %>%
  count(sort = TRUE)

# product category returned

Main %>%
  full_join(Returns, type = "inner", by = 'Order.ID') %>%
  filter(Status == "Returned") %>%
  group_by(Product.Sub.Category) %>%
  count(sort = T)

# products returned 
Main %>%
  full_join(Returns, type = "inner", by = 'Order.ID') %>%
  filter(Status == "Returned") %>%
  group_by(Product.Name) %>%
  count(sort = T)








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



require("RPostgreSQL")

pw <- {
  "***"
}

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "***",
                 host = "***", port = 5432,
                 user = "***", password = pw,
                 options="-c search_path=***")
rm(pw)

dbListTables(con)


dbWriteTable(con, "Product", value = Product, overwrite = T, row.names = F)     
dbWriteTable(con, "Customer", value = Customer, overwrite = T, row.names = F)   
dbWriteTable(con, "ReturnStatus", value = returnStatus, overwrite = T, row.names = F) 
dbWriteTable(con, "Sales", value = Sales, overwrite = T, row.names = F) 



dbGetQuery(con, "SELECT table_name FROM information_schema.tables WHERE table_schema='ass3'") 
str(dbReadTable(con, c("ass3", "Customer")))      
str(dbReadTable(con, c("ass3", "Product")))       
str(dbReadTable(con, c("ass3", "ReturnStatus")))
str(dbReadTable(con, c("ass3", "Sales")))  

