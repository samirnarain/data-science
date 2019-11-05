source("project.R")

summary(proj$time.diff)
summary(proj)
glimpse(proj)


#PLOTS
#time difference 
ggplot(proj, aes(x=time.diff)) + geom_histogram(bins = 50)

#planned operationtime to actual operationtime -> the shorter the planned operation, the earlier it is finished compared to planned time
plot(proj$Geplande.operatieduur,proj$time.diff)

#ggplot of variables to operatieduur  (1.not important, 2.maybe important, 3. probably important, 4. important)
plot(proj$Operatieduur~proj$BMI_group , data = proj) #maybe important
plot(proj$Operatieduur~proj$age_group , data = proj) #important
plot(proj$Operatieduur~proj$Hypercholesterolemie , data = proj) #not important
plot(proj$Operatieduur~proj$Hypertensie , data = proj) #not important
plot(proj$Operatieduur~proj$Aantal.anastomosen , data = proj) #important
plot(proj$Operatieduur~proj$NYHA , data = proj) #maybe important
plot(proj$Operatieduur~proj$HLM , data = proj) #important
plot(proj$Operatieduur~proj$CCS , data = proj) #maybe important
plot(proj$Operatieduur~proj$Perifeer.vaatlijden , data = proj) #not important
plot(proj$Operatieduur~proj$DM, data = proj) #not important
plot(proj$Operatieduur~proj$Slechte.mobiliteit , data = proj) #not important
plot(proj$Operatieduur~proj$Nierfunctie , data = proj) #probably important
plot(proj$Operatieduur~proj$Linker.ventrikel.functie , data = proj) #important
plot(proj$Operatieduur~proj$Pulmonale.hypertensie , data = proj) #probably important
plot(proj$Operatieduur~proj$Kritische.preoperatieve.status , data = proj) #maybe important
plot(proj$Operatieduur~proj$Actieve.endocarditis , data = proj) #important
plot(proj$Operatieduur~proj$Myocard.infact..90.dagen , data = proj) #not important
plot(proj$Operatieduur~proj$Aorta.chirurgie , data = proj) #important
plot(proj$Operatieduur~proj$Eerdere.hartchirurgie , data = proj) #important
plot(proj$Operatieduur~proj$Extracardiale.vaatpathie , data = proj) #not important
plot(proj$Operatieduur~proj$Chronische.longziekte , data = proj) #not important
plot(proj$Operatieduur~proj$Geslacht , data = proj) #maybe important
plot(proj$Operatieduur~proj$Dagdeel , data = proj) #important
plot(proj$Operatieduur~proj$Casustype , data = proj) #important
plot(proj$Operatieduur~proj$Benadering , data = proj) #important
plot(proj$Operatieduur~proj$Chirurg , data = proj) #maybe important
plot(proj$Operatieduur~proj$Operatietype , data = proj) #important
plot(proj$Operatieduur~proj$AF , data = proj) #maybe important
ggplot(proj, aes(x=Operatieduur, y=Leeftijd))+geom_point() + geom_smooth() #maybe important
ggplot(proj, aes(x=Operatieduur, y=Ziekenhuis.ligduur))+geom_point() + geom_smooth() #maybe important
ggplot(proj, aes(x=Operatieduur, y=IC.ligduur))+geom_point() + geom_smooth() #important
ggplot(proj, aes(x=Operatieduur, y=BMI))+geom_point() + geom_smooth() #not important
ggplot(proj, aes(x=Operatieduur, y=Euroscore2))+geom_point() + geom_smooth() #not important
ggplot(proj, aes(x=Operatieduur, y=Euroscore1))+geom_point() + geom_smooth() #not important

#plots of variables to time difference
plot(proj$time.diff~proj$BMI_group , data = proj) #maybe important
plot(proj$time.diff~proj$age_group , data = proj) #important
plot(proj$time.diff~proj$Hypercholesterolemie , data = proj) #not important
plot(proj$time.diff~proj$Hypertensie , data = proj) #not important
plot(proj$time.diff~proj$Aantal.anastomosen , data = proj) #important
plot(proj$time.diff~proj$NYHA , data = proj) #maybe important
plot(proj$time.diff~proj$HLM , data = proj) #important
plot(proj$time.diff~proj$CCS , data = proj) #maybe important
plot(proj$time.diff~proj$Perifeer.vaatlijden , data = proj) #not important
plot(proj$time.diff~proj$DM, data = proj) #not important
plot(proj$time.diff~proj$Slechte.mobiliteit , data = proj) #not important
plot(proj$time.diff~proj$Nierfunctie , data = proj) #probably important
plot(proj$time.diff~proj$Linker.ventrikel.functie , data = proj) #important
plot(proj$time.diff~proj$Pulmonale.hypertensie , data = proj) #probably important
plot(proj$time.diff~proj$Kritische.preoperatieve.status , data = proj) #maybe important
plot(proj$time.diff~proj$Actieve.endocarditis , data = proj) #important
plot(proj$time.diff~proj$Myocard.infact..90.dagen , data = proj) #not important
plot(proj$time.diff~proj$Aorta.chirurgie , data = proj) #important
plot(proj$time.diff~proj$Eerdere.hartchirurgie , data = proj) #important
plot(proj$time.diff~proj$Extracardiale.vaatpathie , data = proj) #not important
plot(proj$time.diff~proj$Chronische.longziekte , data = proj) #not important
plot(proj$time.diff~proj$Geslacht , data = proj) #maybe important
plot(proj$time.diff~proj$Dagdeel , data = proj) #important
plot(proj$time.diff~proj$Casustype , data = proj) #important
plot(proj$time.diff~proj$Benadering , data = proj) #important
plot(proj$time.diff~proj$Chirurg , data = proj) #maybe important
plot(proj$time.diff~proj$Operatietype , data = proj) #important
plot(proj$time.diff~proj$AF , data = proj) #maybe important
ggplot(proj, aes(x=time.diff, y=Leeftijd))+geom_point() + geom_smooth() #maybe important
ggplot(proj, aes(x=time.diff, y=Ziekenhuis.ligduur))+geom_point() + geom_smooth() #maybe important
ggplot(proj, aes(x=time.diff, y=IC.ligduur))+geom_point() + geom_smooth() #important
ggplot(proj, aes(x=BMI, y=time.diff))+geom_point() + geom_smooth() #not important
ggplot(proj, aes(x=time.diff, y=Euroscore2))+geom_point() + geom_smooth() #not important
ggplot(proj, aes(x=time.diff, y=Euroscore1))+geom_point() + geom_smooth() #not important

# doesnt seem to be a helpful graph, but maybe we can try different variables for x & y
proj %>%
  ggplot(aes(x=time_group, y= Leeftijd)) +
  geom_violin() +
  scale_fill_viridis_c(alpha = .6)+
  geom_jitter(color="black", size = 0.4, alpha=0.9)





