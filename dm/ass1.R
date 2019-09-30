library(foreign)
library(ggplot2)

df = read.spss(file = "data/voorbeeld7_1.sav", to.data.frame = TRUE)

ggplot(data = df, aes(x=leeftijd, y=chol)) +
  geom_point(shape = 1) +
  geom_smooth(method = "lm")

fitobject = ggplot(data = df, aes(x=leeftijd, y=chol)) +
  geom_point(shape = 1) +
  geom_smooth(method = "lm", formula = y~x)

summary(fitobject)


ggplot(data = df, aes(x=bmi, y=chol)) +
  geom_point(shape = 1) +
  geom_smooth(method = "lm", formula = y~x)


ggplot(data = df, aes(x=sekse, y=chol)) +
  geom_boxplot() +
  geom_smooth(method = "lm", formula = y~x)




