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

