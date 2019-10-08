#install.packages("caret")
#install.packages("e1071")

library(readr)
library(dplyr)
library(caret)
library(rpart)
library(rpart.plot)
library(e1071)

df = read.csv(file = "data/births.csv")
head(df)


df <- mutate(df, home = if_else(child_birth == "first line child birth, at home", 
                            "at_home", "not_at_home"))

df <- mutate(df, pari = if_else(parity == 1, "primi", "multi" ))

head(df)

df <- mutate(df, etni = if_else(etnicity == "Dutch",
                                "Dutch", "Not Dutch"))


# starting LM

df$pari <- as.factor(df$pari)
df$etni <- as.factor(df$etni)

# we compute home and not at home as 
# 0 is at home
# 1 is not at home
# initially it is stored in a temp column home01
# we then copy home01 to home column
# this is done because in glm, family="binomial" needs 0<=y<=1

df <- mutate(df, home01 = if_else(df$home == "at_home", "0", "1" ))
df$home01 <- as.numeric(df$home01)
df$home <- df$home01
df$home <- as.factor(df$home)

head(df)
str(df)

# logistic regression model

fit_lm <- glm(formula = home ~ pari + age_cat + etni + urban, 
              data = df, family = "binomial")

summary(fit_lm)

# decision tree model 

fit_tree <- rpart(formula = home ~ pari + age_cat + etni + urban,
                  data= df , method = "class")

summary(fit_tree)

# 0 is at home birth, and 
# 1 is not at home birth

rpart.plot(fit_tree, fallen.leaves = T, type = 2)
