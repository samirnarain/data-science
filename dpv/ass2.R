#install.packages("tidyverse")

library("tidyverse")
library("readr")

df <- read_delim("data/BI_Raw_Data.csv", delim = ";", 
                 col_names = TRUE, col_types = NULL)

df %>%
  group_by(Customer_Name) %>%
  summarise_at(vars(Product_Order_Price_Total), sum) %>%
  arrange(desc(Product_Order_Price_Total)) %>%
  head(5)


df %>%
  group_by(Product_Name) %>%
  summarise_at(vars(Product_Order_Price_Total), sum) %>%
  arrange(desc(Product_Order_Price_Total)) %>%
  head(5)

# Step 2

# Prepare the data

product <- df %>%
  select(Product_Name, Product_Category) %>%
  rename(name = Product_Name, category = Product_Category) %>%
  arrange(name, category) %>%
  group_by(name, category) %>%
  distinct() %>%
  ungroup() %>%
  mutate(productid = row_number())
  

customer <- df %>%
  select(Customer_Name, Customer_Country) %>%
  rename(name = Customer_Name, country = Customer_Country) %>%
  arrange(name, country) %>%
  group_by(name, country) %>%
  distinct() %>%
  ungroup() %>%
  mutate(customerid = row_number())
  

# Sales data

sales <- df %>%
  select(Order_Date_Day, Customer_Name, Product_Name, Product_Order_Price_Total) %>%
  full_join(product, by = c("Product_Name" = "name")) %>%
  full_join(customer, by = c("Customer_Name" = "name")) %>%
  select("Order_Date_Day","customerid", "productid", "Product_Order_Price_Total")
