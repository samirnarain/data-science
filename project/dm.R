source("project.R")

#Preparaion for LM
# Using Linear Regression and rpart on the data
ops_fusion <- proj %>%
  full_join(ops_tbl, type = "inner", by = 'ID')

#FORMULA
imp_data_and_ops <- Operatieduur ~ ASD +AVP +AVR +AVR.via.minithoracotomie +Ascendensvervanging +Bentall.procedure +Bilobectomie.open.procedure +Biventriculaire.pacemaker +Boxlaesie +Bullectomie.met.partiele.pleurectomie +CABG +CABG.via.minithoracotomie +CABGPacemakerdraad.tijdelijk +Decorticatie.long +Decorticatie.long.VATS +Diagnostische.pleurapunctie +ECMO +Endoscopische.lobectomie.of.segmentresectie +Endoscopische.ok.empyema.thoracis +Epicardiale.LV.lead +Grote.borstwandresectie.in.verband.met.een.doorgegroeide.maligniteit +Inbrengen.LVAD.BIVAD +Klassieke.Aortabroek.Prothese +Klassieke.aortabuisprothese.met.zijtak +Lobectomie.of.segmentresectie +MVP +MVP.via.minithoracotomie +MVPVentrikelaneurysma +MVR +MVR.via.minithoracotomie +Mamma.ablatio +Maze +Mediastinoscopie +Morrow +Nuss.procedure +Open.operatie.van.een.of.meerdere.mediastinumtumoren.eventueel.midsternaal +Openen.hartzakje.zonder.hartingreep.eventueel.drainage.van.een.pericarditis.via.een.thoracotomie +Operatie.wegens.een.perforerende.hartverwonding +Operatieve.behandeling.van.een.empyema.VATS +PVI +Partiele.pericardresectie.via.thoracotomie +Percardiectomie +Pericard.drainage +Plaatsen.epicardiale.electrode.na.openen.pericard +Pleurabiopsie +Pleuro.pneumonectomie.open.procedure +Pneumonectomie +Pneumonectomie.met.uitgebreide.verwijdering.lymfklieren.open.procedure +Pneumonectomie.open.procedure +Poging.tot.VATS.PVI +Proefthoracotomie +Ravitch.procedure +Rethoracotomie +Sleeve.resectie +Sleeve.resectie.VATS +TAVI.II +TVP +Tumor.atrium +Tumor.mediastinum +Tumor.ventrikel +VATS.Boxlaesie +VATS.PVI +VSD +Ventrikelaneurysma +Vervangen.pacemaker.of.ICD +Vervanging.aorta.ascendens.met.aortaboog +Vervanging.aortawortel +Vervanging.aortawortel.aorta.ascendens.en.boog +Verwijderen.Corpus.Alienum +Verwijderen.pacemaker.of.ICD +Wigresectie +Wondtoilet+
  
  num_of_ops + Anesthesioloog + OK + Chirurg + Benadering +
  Casustype + Eerdere.hartchirurgie + Actieve.endocarditis + Aorta.chirurgie + 
  Aantal.anastomosen + HLM+Leeftijd+  IC.ligduur+AF+Dagdeel+
  Geslacht+Chronische.longziekte+Extracardiale.vaatpathie+Kritische.preoperatieve.status+
  Myocard.infact..90.dagen+Euroscore1+Ziekenhuis.ligduur+IC.ligduur+Hypercholesterolemie

#LM
fit_lm <- lm(formula = imp_data_and_ops, data = ops_fusion)
summary(fit_lm)
#preditcion out of LM
fitted_lm <- fitted(fit_lm)
proj <- mutate(proj,fitted_lm)
fitted_lm_diff <- proj$Operatieduur - fitted_lm
proj <- mutate(proj,fitted_lm_diff)

#GLM poisson
fit_glm_poisson <- glm(formula = imp_data_and_ops, data = ops_fusion, family = "poisson")
summary(fit_glm_poisson)
#prediction out of GLM
fitted_glm <- fitted(fit_glm_poisson)
proj <- mutate(proj,fitted_glm)
fitted_glm_diff <- proj$Operatieduur - fitted_glm
proj <- mutate(proj,fitted_glm_diff)


# rpart with anova
fit_tree <- rpart(imp_data_and_ops, data = ops_fusion,
                  method = "anova")
summary(fit_tree)
rpart.plot(fit_tree, fallen.leaves = T, type = 2, box.palette="Blues")
predict_rpart <- predict(fit_tree)
predicr_part_rounded <- round_any(predict_rpart, 5, ceiling)


# random forest prediction 
fit_rf <- randomForest::randomForest(imp_data_and_ops , data = ops_fusion)
predict_rf <- predict(fit_rf)
predict_rf_rounded <- round_any(predict_rf, 5, ceiling)

#Comparison GLM, LM and planned Time
ggplot()+ geom_histogram(data=proj, aes(x=proj$fitted_glm_diff), bins = 100, colour="darkblue") + 
  geom_histogram(data=proj, aes(x=fitted_lm_diff),bins = 100, colour="red")+
  geom_histogram(data=proj, aes(x=time.diff),bins = 100, colour="black")





