#install.packages("caret")

library(readr)
library(dplyr)
library(caret)
library(rpart)
library(rpart.plot)

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

# 0 is at home
# 1 is not at home

df <- mutate(df, home01 = if_else(df$home == "at_home", "0", "1" ))
df$home01 <- as.numeric(df$home01)


head(df)
str(df)

# logistic regression model

fit_lm <- glm(formula = home01 ~ pari + age_cat + etni + urban, data = df
              ,family = "binomial")

summary(fit_lm)

#varImp(fit, scale = FALSE)

# decision tree model 

fit_tree <- rpart(formula = home ~ pari + age_cat + etni + urban,
      data= df , method = "class")

summary(fit_tree)

# 1 is at home birth, and 
# 2 is not at home birth

rpart.plot(fit_tree, fallen.leaves = T, type = 2)


# training set

set.seed(100)

trainRowNumber <- createDataPartition(df$home, p=0.8, list = F)

colnames(trainRowNumber)

trainData <- df[trainRowNumber, c(2,4,8,9,10)]

testData <- df[-trainRowNumber, c(2,4,8,9,10)]

fit_logreg <- train(home ~ pari + age_cat + etni + urban,
                    data=trainData, method = "glm") #, family = "binomial")

predicted <- predict(fit_logreg, testData) 

confusionMatrix(reference = testData$home, data = predicted,
                mode='everything', positive='at_home')




















