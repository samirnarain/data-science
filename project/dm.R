source("project_final.R")




# Using Linear Regression and rpart on the data

# we can use the actual time of the operation and see its relation with the other variables 

fit_lm <- glm(formula = Operatieduur ~ num_of_ops, data = proj, family = "gaussian")
summary(fit_lm)

fit_tree <- rpart(formula = op_time_group ~ num_of_ops + age_group + Operatietype, 
                  data = proj,
                  method = "poisson")
summary(fit_tree)
rpart.plot(fit_tree, fallen.leaves = T, type = 2)

# plots 
plot(proj$time.diff~proj$num_of_ops , data = proj)

plot(proj$Geplande.operatieduur,proj$time.diff)

