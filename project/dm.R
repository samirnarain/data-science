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
#summary(fit_lm)
#preditcion out of LM
fitted_lm <- fitted(fit_lm)
fitted_lm_rounded <- round_any(fitted_lm, 5, ceiling)
proj <- mutate(proj,fitted_lm_rounded)
fitted_lm_diff <- proj$Operatieduur - fitted_lm_rounded
proj <- mutate(proj,fitted_lm_diff)

#GLM poisson
fit_glm_poisson <- glm(formula = imp_data_and_ops, data = ops_fusion, family = "poisson")
#summary(fit_glm_poisson)
#prediction out of GLM
fitted_glm <- fitted(fit_glm_poisson)
fitted_glm_rounded <- round_any(fitted_glm, 5, ceiling)
proj <- mutate(proj,fitted_glm_rounded)
fitted_glm_diff <- proj$Operatieduur - fitted_glm_rounded
proj <- mutate(proj,fitted_glm_diff)


# rpart with anova
fit_tree <- rpart(imp_data_and_ops, data = ops_fusion,
                  method = "anova")
#summary(fit_tree)
rpart.plot(fit_tree, fallen.leaves = T, type = 2, box.palette="Blues")
rpart_predict <- predict(fit_tree)
rpart_predict_rounded <- round_any(rpart_predict, 5, ceiling)
proj <- mutate(proj,rpart_predict_rounded)
rpart_predict_diff <- proj$Operatieduur - rpart_predict_rounded
proj <- mutate(proj,rpart_predict_diff)

# random forest prediction 
fit_rf <- randomForest::randomForest(imp_data_and_ops , data = ops_fusion)
predict_rf <- predict(fit_rf)
predict_rf_rounded <- round_any(predict_rf, 5, ceiling)
proj <- mutate(proj,predict_rf_rounded)
predict_rf_diff <- proj$Operatieduur - predict_rf_rounded
proj <- mutate(proj,predict_rf_diff)
fit_rf

## root mean sqare errors for the predicted vales 
## and the planned value - clear difference

RMSE(fitted_lm,proj$Operatieduur)
RMSE(fitted_glm,proj$Operatieduur)
RMSE(predict_rf,proj$Operatieduur)
RMSE(rpart_predict,proj$Operatieduur)

RMSE(proj$Geplande.operatieduur,proj$Operatieduur)

