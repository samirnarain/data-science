library(foreign)
library(ggplot2)

df = read.spss(file = "data/voorbeeld7_1.sav", to.data.frame = TRUE)

# a)
ggplot(data = df, aes(x=leeftijd, y=chol)) +
  geom_point(shape = 1) +
  geom_smooth(method = "lm")

# b)
fit1 = lm(data = df, formula = chol~leeftijd)
summary(fit1)

# c)
fit2 = lm(data = df, formula = chol ~ leeftijd + sekse + alcohol + bmi )
summary(fit2)

# d)
df <- mutate(df, res = fit2$residuals)

ggplot(data = df, aes(x=res)) +
  geom_histogram()


