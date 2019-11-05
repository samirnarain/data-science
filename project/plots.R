source("project.R")


#PLOTS

ggplot(proj, aes(x=time.diff)) + geom_histogram(bins = 50)
summary(proj$time.diff)
summary(proj)
glimpse(proj)

#try to see if daytime impacts time diff
# ggplot(proj, aes(x=Dagdeel, y=time.diff))+
#   geom_bar(stat = "identity")

# to see impact of age on operationtime difference
ggplot(proj, aes(x=Leeftijd, y=time.diff))+  
  geom_point()+
  geom_smooth()

# doesnt seem to be a helpful graph, but maybe we can try different variables for x & y
proj %>%
  ggplot(aes(x=time_group, y= Leeftijd)) +
  geom_violin() +
  scale_fill_viridis_c(alpha = .6)+
  geom_jitter(color="black", size = 0.4, alpha=0.9)



proj %>%
  ggplot(aes(x=Chirurg, y= time.diff)) +
  geom_boxplot() +
  coord_flip()






plot(proj$time.diff~proj$num_of_ops , data = proj)

plot(proj$Geplande.operatieduur,proj$time.diff)



