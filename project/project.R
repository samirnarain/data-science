#install.packages("dplyr")
#install.packages("ggplot2")
#install.packages("readr")
#install.packages("lubridate")
#install.packages("RPostgreSQL")
#install.packages("tidyverse")
#install.package("rpart.plot")
#install.packages("randomForest")

library(readr)
library(plyr)
library(dplyr)
library(caret)
library(rpart)
library(rpart.plot)
library(tidyverse)
library(ggplot2)
library(randomForest)

#DATA PREPARATION (TRANSFORMING AND COMPUTING)
proj = read.csv2(file = "data/surgical_case_durations.csv")
proj <- na.omit(proj)
proj[proj == "NULL"] <- NA
proj[proj == "Onbekend"] <- NA
proj <- as_tibble(proj)

#default coulumn type is factor, converting required coloumns to numeric for processing 
proj$Geplande.operatieduur <- as.numeric(proj$Geplande.operatieduur)
proj$Operatieduur <- as.numeric(proj$Operatieduur)
proj$BMI <- as.numeric(sub(",", ".", sub(".", "", proj$BMI, fixed=TRUE), fixed=TRUE))
proj$Ziekenhuis.ligduur <- as.numeric(proj$Ziekenhuis.ligduur)
proj$IC.ligduur <- as.numeric(proj$IC.ligduur)
proj$Euroscore1 <- as.numeric(proj$Euroscore1)
proj$Euroscore2 <- as.numeric(proj$Euroscore2)
proj$Leeftijd <- as.numeric(proj$Leeftijd)
sapply(proj, function(x) sum(is.na(x)))

proj_original <- proj
#clearing out null rows -> new proj
proj <- proj %>% filter(!is.na(Geslacht),!is.na(Operatietype))
#clearing not needed columns with to many NAs
proj <- subset(proj, select = -c(Linker.ventrikel.functie, Nierfunctie, Euroscore2, CCS, NYHA, BMI) )
proj <- na.omit(proj)







#CREATION OF NEW VALUES
#create primary key
proj <- tibble::rowid_to_column(proj, "ID")

#compute time difference
proj <- mutate(proj, time.diff = Operatieduur - Geplande.operatieduur)
# write a coloums with the number of operations planned
proj <- mutate(proj, num_of_ops = str_count(proj$Operatietype, '\\+') + 1 )
proj$num_of_ops <- as.factor(proj$num_of_ops)


# # compute BMI group
# proj <- proj %>%  
#   mutate(BMI_group = case_when(
#     BMI >= 30              ~ "Obese",
#     BMI >= 25   & BMI < 30 ~ "Overweight",
#     BMI >= 18.5 & BMI < 25 ~ "Normal",
#     BMI <  18.5            ~ "Underweight",))
# proj$BMI_group <- as.factor(proj$BMI_group)

# compute age group
# proj <- proj %>%
#   mutate(age_group = case_when(
#     Leeftijd > 70 ~ ">70",
#     Leeftijd > 60 & Leeftijd <= 70 ~ "60-70",
#     Leeftijd > 50 & Leeftijd <= 60 ~ "50-60",
#     Leeftijd > 40 & Leeftijd <= 50 ~ "40-50",
#     Leeftijd > 30 & Leeftijd <= 40 ~ "30-40",
#     Leeftijd > 20 & Leeftijd <= 30 ~ "20-30",
#     Leeftijd > 10 & Leeftijd <= 20 ~ "10-20",
#     Leeftijd <= 10 ~ "< 10"))
# proj$age_group <- as.factor(proj$age_group)

# compute delay group
# proj <- proj %>%  
#   mutate(time_group = case_when(
#     time.diff >=  60                     ~ "Very Late",
#     time.diff >=  15 & time.diff < 60    ~ "Late but <60min",
#     time.diff >= -15 & time.diff < 15    ~ "Within 15 mins",
#     time.diff >= -60 &  time.diff < -15  ~ "Early but <60min",
#     time.diff <  -60                     ~ "Very Early"))
# proj$time_group <- as.factor(proj$time_group)

# compute Operation time group
# doing this so it can be used as a factor. in its currenct form, operatieduur is a very large factor
# proj <- proj %>%  
#   mutate(op_time_group = case_when(
#     Operatieduur >= 465                      ~ ">465",
#     Operatieduur >= 450 & Operatieduur < 465 ~ "450-465",
#     Operatieduur >= 435 & Operatieduur < 450 ~ "435-450",
#     Operatieduur >= 420 & Operatieduur < 435 ~ "420-435",
#     Operatieduur >= 405 & Operatieduur < 420 ~ "405-420",
#     Operatieduur >= 390 & Operatieduur < 405 ~ "390-405",
#     Operatieduur >= 375 & Operatieduur < 390 ~ "375-390",
#     Operatieduur >= 360 & Operatieduur < 375 ~ "360-375",
#     Operatieduur >= 345 & Operatieduur < 360 ~ "345-360",
#     Operatieduur >= 330 & Operatieduur < 345 ~ "330-345",
#     Operatieduur >= 315 & Operatieduur < 330 ~ "315-330",
#     Operatieduur >= 300 & Operatieduur < 315 ~ "300-315",
#     Operatieduur >= 285 & Operatieduur < 300 ~ "285-300",
#     Operatieduur >= 270 & Operatieduur < 285 ~ "270-285",
#     Operatieduur >= 255 & Operatieduur < 270 ~ "255-270",
#     Operatieduur >= 240 & Operatieduur < 255 ~ "240-255",
#     Operatieduur >= 225 & Operatieduur < 240 ~ "225-240",
#     Operatieduur >= 210 & Operatieduur < 225 ~ "210-225",
#     Operatieduur >= 195 & Operatieduur < 210 ~ "195-210",
#     Operatieduur >= 180 & Operatieduur < 195 ~ "180-195",
#     Operatieduur >= 165 & Operatieduur < 180 ~ "165-180",
#     Operatieduur >= 150 & Operatieduur < 165 ~ "150-165",
#     Operatieduur >= 135 & Operatieduur < 150 ~ "135-150",
#     Operatieduur >= 120 & Operatieduur < 135 ~ "120-135",
#     Operatieduur >= 105 & Operatieduur < 120 ~ "105-120",
#     Operatieduur >=  90 & Operatieduur < 105 ~ "90-105",
#     Operatieduur >=  75 & Operatieduur <  90 ~ "75-90",
#     Operatieduur >=  60 & Operatieduur <  75 ~ "60-75",
#     Operatieduur >=  45 & Operatieduur <  60 ~ "45-60",
#     Operatieduur >=  30 & Operatieduur <  45 ~ "30-45",
#     Operatieduur >=  15 & Operatieduur <  30 ~ "15-30",
#     Operatieduur <   15                      ~ "<15"  ))
# proj$op_time_group <- as.factor(proj$op_time_group)

# compute the group for planned opertaion time. We plan to use this later to compare predicted and planned opertaion times.
# proj <- proj %>%  
#   mutate(op_planned_time_group = case_when(
#     Geplande.operatieduur >= 465                               ~ ">465",
#     Geplande.operatieduur >= 450 & Geplande.operatieduur < 465 ~ "450-465",
#     Geplande.operatieduur >= 435 & Geplande.operatieduur < 450 ~ "435-450",
#     Geplande.operatieduur >= 420 & Geplande.operatieduur < 435 ~ "420-435",
#     Geplande.operatieduur >= 405 & Geplande.operatieduur < 420 ~ "405-420",
#     Geplande.operatieduur >= 390 & Geplande.operatieduur < 405 ~ "390-405",
#     Geplande.operatieduur >= 375 & Geplande.operatieduur < 390 ~ "375-390",
#     Geplande.operatieduur >= 360 & Geplande.operatieduur < 375 ~ "360-375",
#     Geplande.operatieduur >= 345 & Geplande.operatieduur < 360 ~ "345-360",
#     Geplande.operatieduur >= 330 & Geplande.operatieduur < 345 ~ "330-345",
#     Geplande.operatieduur >= 315 & Geplande.operatieduur < 330 ~ "315-330",
#     Geplande.operatieduur >= 300 & Geplande.operatieduur < 315 ~ "300-315",
#     Geplande.operatieduur >= 285 & Geplande.operatieduur < 300 ~ "285-300",
#     Geplande.operatieduur >= 270 & Geplande.operatieduur < 285 ~ "270-285",
#     Geplande.operatieduur >= 255 & Geplande.operatieduur < 270 ~ "255-270",
#     Geplande.operatieduur >= 240 & Geplande.operatieduur < 255 ~ "240-255",
#     Geplande.operatieduur >= 225 & Geplande.operatieduur < 240 ~ "225-240",
#     Geplande.operatieduur >= 210 & Geplande.operatieduur < 225 ~ "210-225",
#     Geplande.operatieduur >= 195 & Geplande.operatieduur < 210 ~ "195-210",
#     Geplande.operatieduur >= 180 & Geplande.operatieduur < 195 ~ "180-195",
#     Geplande.operatieduur >= 165 & Geplande.operatieduur < 180 ~ "165-180",
#     Geplande.operatieduur >= 150 & Geplande.operatieduur < 165 ~ "150-165",
#     Geplande.operatieduur >= 135 & Geplande.operatieduur < 150 ~ "135-150",
#     Geplande.operatieduur >= 120 & Geplande.operatieduur < 135 ~ "120-135",
#     Geplande.operatieduur >= 105 & Geplande.operatieduur < 120 ~ "105-120",
#     Geplande.operatieduur >=  90 & Geplande.operatieduur < 105 ~ "90-105",
#     Geplande.operatieduur >=  75 & Geplande.operatieduur <  90 ~ "75-90",
#     Geplande.operatieduur >=  60 & Geplande.operatieduur <  75 ~ "60-75",
#     Geplande.operatieduur >=  45 & Geplande.operatieduur <  60 ~ "45-60",
#     Geplande.operatieduur >=  30 & Geplande.operatieduur <  45 ~ "30-45",
#     Geplande.operatieduur >=  15 & Geplande.operatieduur <  30 ~ "15-30",
#     Geplande.operatieduur < 15                                 ~ "<15")
#   )
# proj$op_planned_time_group <- as.factor(proj$op_planned_time_group)












#create different table with operationtypes
ops_tbl <- proj %>%
  select(ID, Operatietype#, Benadering, num_of_ops
        ) %>%
  distinct()
ops_tbl <- as_tibble(ops_tbl)

#create columns with operationtypes
ops_tbl <- ops_tbl %>% mutate(Ascendensvervanging = ifelse(grepl("Ascendensvervanging", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(ASD = ifelse(grepl("ASD", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(AVP = ifelse(grepl("AVP", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(AVR = ifelse(grepl("AVR", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(AVR.via.minithoracotomie = ifelse(grepl("AVR via minithoracotomie", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Bentall.procedure = ifelse(grepl("Bentall procedure", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Bilobectomie.open.procedure = ifelse(grepl("Bilobectomie, open procedure", Operatietype) == TRUE, 1, 0))
#ops_tbl <- ops_tbl %>% mutate(Bilobectomie.VATS = ifelse(grepl("Bilobectomie, VATS", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Biventriculaire.pacemaker = ifelse(grepl("Biventriculaire pacemaker", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Boxlaesie = ifelse(grepl("Boxlaesie", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Bullectomie.met.partiele.pleurectomie = ifelse(grepl("Bullectomie met partiele pleurectomie", Operatietype) == TRUE, 1, 0))
#ops_tbl <- ops_tbl %>% mutate(Bullectomie.met.partiele.pleurectomie.VATS = ifelse(grepl("Bullectomie met partiële pleurectomie, VATS", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(CABG = ifelse(grepl("CABG", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(CABG.via.minithoracotomie = ifelse(grepl("CABG via minithoracotomie", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(CABGPacemakerdraad.tijdelijk = ifelse(grepl("CABGPacemakerdraad tijdelijk", Operatietype) == TRUE, 1, 0))
#ops_tbl <- ops_tbl %>% mutate(Capsulotomie.capsulectomie.met.verwijderen.mammaprothese.na.augmentatie = ifelse(grepl("Capsulotomie/capsulectomie met verwijderen mammaprothese na augmentatie", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Decorticatie.long = ifelse(grepl("Decorticatie long", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Decorticatie.long.VATS = ifelse(grepl("Decorticatie long, VATS", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Diagnostische.pleurapunctie = ifelse(grepl("Diagnostische pleurapunctie", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(ECMO = ifelse(grepl("ECMO", Operatietype) == TRUE, 1, 0))
#ops_tbl <- ops_tbl %>% mutate(Endoscopische.bullectomie.met.partiele.pleurectomie = ifelse(grepl("Endoscopische bullectomie met partiele pleurectomie", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Endoscopische.lobectomie.of.segmentresectie = ifelse(grepl("Endoscopische lobectomie of segmentresectie", Operatietype) == TRUE, 1, 0))
#ops_tbl <- ops_tbl %>% mutate(Endoscopische.longbiopsie = ifelse(grepl("Endoscopische longbiopsie", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Endoscopische.ok.empyema.thoracis = ifelse(grepl("Endoscopische ok empyema thoracis", Operatietype) == TRUE, 1, 0))
#ops_tbl <- ops_tbl %>% mutate(Endoscopische.wigresectie = ifelse(grepl("Endoscopische wigresectie", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Epicardiale.LV.lead = ifelse(grepl("Epicardiale LV-lead", Operatietype) == TRUE, 1, 0))
#ops_tbl <- ops_tbl %>% mutate(Excisie.aandoening.thoraxwand.VATS = ifelse(grepl("Excisie aandoening thoraxwand, VATS", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Grote.borstwandresectie.in.verband.met.een.doorgegroeide.maligniteit = ifelse(grepl("Grote borstwandresectie in verband met een doorgegroeide maligniteit.", Operatietype) == TRUE, 1, 0))
#ops_tbl <- ops_tbl %>% mutate(Inbrengen.endocardiale.electrode.en.bevestigen.tweede.electrode.op.het.epicard.of.bevestigen.beide = ifelse(grepl("Inbrengen endocardiale electrode en bevestigen tweede electrode op het epicard, of bevestigen beide", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Inbrengen.LVAD.BIVAD = ifelse(grepl("Inbrengen LVAD / BIVAD", Operatietype) == TRUE, 1, 0))
#ops_tbl <- ops_tbl %>% mutate(Inbrengen.van.stimulatie.electrode.en.aansluiten.subc.geplaatste.pacemaker = ifelse(grepl("Inbrengen van stimulatie-electrode en aansluiten subc. geplaatste pacemaker", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Klassieke.Aortabroek.Prothese = ifelse(grepl("Klassieke Aortabroek Prothese", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Klassieke.aortabuisprothese.met.zijtak = ifelse(grepl("Klassieke aortabuisprothese met zijtak", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Lobectomie.of.segmentresectie = ifelse(grepl("Lobectomie of segmentresectie", Operatietype) == TRUE, 1, 0))
#ops_tbl <- ops_tbl %>% mutate(Longbiopsie.VATS = ifelse(grepl("Longbiopsie, VATS", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Mamma.ablatio = ifelse(grepl("Mamma ablatio", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Maze = ifelse(grepl("Maze", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Mediastinoscopie = ifelse(grepl("Mediastinoscopie", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Morrow = ifelse(grepl("Morrow", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(MVP = ifelse(grepl("MVP", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(MVP.via.minithoracotomie = ifelse(grepl("MVP via minithoracotomie", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(MVPVentrikelaneurysma = ifelse(grepl("MVPVentrikelaneurysma", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(MVR = ifelse(grepl("MVR", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(MVR.via.minithoracotomie = ifelse(grepl("MVR via minithoracotomie", Operatietype) == TRUE, 1, 0))
#ops_tbl <- ops_tbl %>% mutate(Nuss.bar.verwijderen = ifelse(grepl("Nuss bar verwijderen", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Nuss.procedure = ifelse(grepl("Nuss-procedure", Operatietype) == TRUE, 1, 0))
#ops_tbl <- ops_tbl %>% mutate(Ok.empyema.thoracis = ifelse(grepl("Ok empyema thoracis", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Open.operatie.van.een.of.meerdere.mediastinumtumoren.eventueel.midsternaal = ifelse(grepl("Open operatie van een of meerdere mediastinumtumoren, eventueel midsternaal.", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Openen.hartzakje.zonder.hartingreep.eventueel.drainage.van.een.pericarditis.via.een.thoracotomie = ifelse(grepl("Openen hartzakje zonder hartingreep eventueel drainage van een pericarditis via een thoracotomie", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Operatie.wegens.een.perforerende.hartverwonding = ifelse(grepl("Operatie wegens een perforerende hartverwonding.", Operatietype) == TRUE, 1, 0))
#ops_tbl <- ops_tbl %>% mutate(Operatieve.behandeling.van.een.empyema.thoracis.open.procedure = ifelse(grepl("Operatieve behandeling van een empyema thoracis, open procedure.", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Operatieve.behandeling.van.een.empyema.VATS = ifelse(grepl("Operatieve behandeling van een empyema, VATS.", Operatietype) == TRUE, 1, 0))
#ops_tbl <- ops_tbl %>% mutate(Operatieve.verwijdering.gezwellenRavitch.procedure = ifelse(grepl("Operatieve verwijdering gezwellenRavitch-procedure", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Partiele.pericardresectie.via.thoracotomie = ifelse(grepl("Partiele pericardresectie via thoracotomie.", Operatietype) == TRUE, 1, 0))
#ops_tbl <- ops_tbl %>% mutate(Partiele.pleurectomie = ifelse(grepl("Partiële pleurectomie", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Percardiectomie = ifelse(grepl("Percardiectomie", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Pericard.drainage = ifelse(grepl("Pericard drainage", Operatietype) == TRUE, 1, 0))
#ops_tbl <- ops_tbl %>% mutate(Pericard.fenestratie.via.VATS = ifelse(grepl("Pericard-fenestratie via VATS.", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Plaatsen.epicardiale.electrode.na.openen.pericard = ifelse(grepl("Plaatsen epicardiale electrode na openen pericard", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Pleurabiopsie = ifelse(grepl("Pleurabiopsie.", Operatietype) == TRUE, 1, 0))
#ops_tbl <- ops_tbl %>% mutate(Pleurectomie.VATS = ifelse(grepl("Pleurectomie, VATS", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Pleuro.pneumonectomie.open.procedure = ifelse(grepl("Pleuro-pneumonectomie, open procedure.", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Pneumonectomie = ifelse(grepl("Pneumonectomie", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Pneumonectomie.met.uitgebreide.verwijdering.lymfklieren.open.procedure = ifelse(grepl("Pneumonectomie met uitgebreide verwijdering lymfklieren, open procedure.", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Pneumonectomie.open.procedure = ifelse(grepl("Pneumonectomie, open procedure.", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Poging.tot.VATS.PVI = ifelse(grepl("Poging tot VATS PVI", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Proefthoracotomie = ifelse(grepl("Proefthoracotomie", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(PVI = ifelse(grepl("PVI", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Ravitch.procedure = ifelse(grepl("Ravitch-procedure", Operatietype) == TRUE, 1, 0))
#ops_tbl <- ops_tbl %>% mutate(Refixatie.sternum = ifelse(grepl("Refixatie sternum", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Rethoracotomie = ifelse(grepl("Rethoracotomie", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Sleeve.resectie = ifelse(grepl("Sleeve resectie", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Sleeve.resectie.VATS = ifelse(grepl("Sleeve-resectie, VATS.", Operatietype) == TRUE, 1, 0))
#ops_tbl <- ops_tbl %>% mutate(Staaldraden.verwijderen = ifelse(grepl("Staaldraden verwijderen", Operatietype) == TRUE, 1, 0))
#ops_tbl <- ops_tbl %>% mutate(TAVI.1 = ifelse(grepl("TAVI-1", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(TAVI.II = ifelse(grepl("TAVI-II", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Tumor.atrium = ifelse(grepl("Tumor atrium", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Tumor.mediastinum = ifelse(grepl("Tumor mediastinum", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Tumor.ventrikel = ifelse(grepl("Tumor ventrikel", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(TVP = ifelse(grepl("TVP", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(VATS.Boxlaesie = ifelse(grepl("VATS Boxlaesie", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(VATS.PVI = ifelse(grepl("VATS PVI", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Ventrikelaneurysma = ifelse(grepl("Ventrikelaneurysma", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Vervangen.pacemaker.of.ICD = ifelse(grepl("Vervangen pacemaker of ICD", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Vervanging.aorta.ascendens.met.aortaboog = ifelse(grepl("Vervanging aorta ascendens met aortaboog", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Vervanging.aortawortel = ifelse(grepl("Vervanging aortawortel", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Vervanging.aortawortel.aorta.ascendens.en.boog = ifelse(grepl("Vervanging aortawortel, aorta ascendens en boog", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Verwijderen.Corpus.Alienum = ifelse(grepl("Verwijderen Corpus Alienum", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Verwijderen.pacemaker.of.ICD = ifelse(grepl("Verwijderen pacemaker of ICD", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(VSD = ifelse(grepl("VSD", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Wigresectie = ifelse(grepl("Wigresectie", Operatietype) == TRUE, 1, 0))
#ops_tbl <- ops_tbl %>% mutate(Wigresectie.VATS = ifelse(grepl("Wigresectie, VATS", Operatietype) == TRUE, 1, 0))
ops_tbl <- ops_tbl %>% mutate(Wondtoilet = ifelse(grepl("Wondtoilet", Operatietype) == TRUE, 1, 0))

#as factors
ops_tbl$Ascendensvervanging <- as.factor(ops_tbl$Ascendensvervanging)
ops_tbl$ASD <- as.factor(ops_tbl$ASD)
ops_tbl$AVP <- as.factor(ops_tbl$AVP)
ops_tbl$AVR <- as.factor(ops_tbl$AVR)
ops_tbl$AVR.via.minithoracotomie <- as.factor(ops_tbl$AVR.via.minithoracotomie)
ops_tbl$Bentall.procedure <- as.factor(ops_tbl$Bentall.procedure)
ops_tbl$Bilobectomie.open.procedure <- as.factor(ops_tbl$Bilobectomie.open.procedure)
#ops_tbl$Bilobectomie.VATS <- as.factor(ops_tbl$Bilobectomie.VATS)
ops_tbl$Biventriculaire.pacemaker <- as.factor(ops_tbl$Biventriculaire.pacemaker)
ops_tbl$Boxlaesie <- as.factor(ops_tbl$Boxlaesie)
ops_tbl$Bullectomie.met.partiele.pleurectomie <- as.factor(ops_tbl$Bullectomie.met.partiele.pleurectomie)
#ops_tbl$Bullectomie.met.partiele.pleurectomie.VATS <- as.factor(ops_tbl$Bullectomie.met.partiele.pleurectomie.VATS)
ops_tbl$CABG <- as.factor(ops_tbl$CABG)
ops_tbl$CABG.via.minithoracotomie <- as.factor(ops_tbl$CABG.via.minithoracotomie)
ops_tbl$CABGPacemakerdraad.tijdelijk <- as.factor(ops_tbl$CABGPacemakerdraad.tijdelijk)
#ops_tbl$Capsulotomie.capsulectomie.met.verwijderen.mammaprothese.na.augmentatie <- as.factor(ops_tbl$Capsulotomie.capsulectomie.met.verwijderen.mammaprothese.na.augmentatie)
ops_tbl$Decorticatie.long <- as.factor(ops_tbl$Decorticatie.long)
ops_tbl$Decorticatie.long.VATS <- as.factor(ops_tbl$Decorticatie.long.VATS)
ops_tbl$Diagnostische.pleurapunctie <- as.factor(ops_tbl$Diagnostische.pleurapunctie)
ops_tbl$ECMO <- as.factor(ops_tbl$ECMO)
#ops_tbl$Endoscopische.bullectomie.met.partiele.pleurectomie <- as.factor(ops_tbl$Endoscopische.bullectomie.met.partiele.pleurectomie)
ops_tbl$Endoscopische.lobectomie.of.segmentresectie <- as.factor(ops_tbl$Endoscopische.lobectomie.of.segmentresectie)
#ops_tbl$Endoscopische.longbiopsie <- as.factor(ops_tbl$Endoscopische.longbiopsie)
ops_tbl$Endoscopische.ok.empyema.thoracis <- as.factor(ops_tbl$Endoscopische.ok.empyema.thoracis)
#ops_tbl$Endoscopische.wigresectie <- as.factor(ops_tbl$Endoscopische.wigresectie)
ops_tbl$Epicardiale.LV.lead <- as.factor(ops_tbl$Epicardiale.LV.lead)
#ops_tbl$Excisie.aandoening.thoraxwand.VATS <- as.factor(ops_tbl$Excisie.aandoening.thoraxwand.VATS)
ops_tbl$Grote.borstwandresectie.in.verband.met.een.doorgegroeide.maligniteit <- as.factor(ops_tbl$Grote.borstwandresectie.in.verband.met.een.doorgegroeide.maligniteit)
#ops_tbl$Inbrengen.endocardiale.electrode.en.bevestigen.tweede.electrode.op.het.epicard.of.bevestigen.beide <- as.factor(ops_tbl$Inbrengen.endocardiale.electrode.en.bevestigen.tweede.electrode.op.het.epicard.of.bevestigen.beide)
ops_tbl$Inbrengen.LVAD.BIVAD <- as.factor(ops_tbl$Inbrengen.LVAD.BIVAD)
#ops_tbl$Inbrengen.van.stimulatie.electrode.en.aansluiten.subc.geplaatste.pacemaker <- as.factor(ops_tbl$Inbrengen.van.stimulatie.electrode.en.aansluiten.subc.geplaatste.pacemaker)
ops_tbl$Klassieke.Aortabroek.Prothese <- as.factor(ops_tbl$Klassieke.Aortabroek.Prothese)
ops_tbl$Klassieke.aortabuisprothese.met.zijtak <- as.factor(ops_tbl$Klassieke.aortabuisprothese.met.zijtak)
ops_tbl$Lobectomie.of.segmentresectie <- as.factor(ops_tbl$Lobectomie.of.segmentresectie)
#ops_tbl$Longbiopsie.VATS <- as.factor(ops_tbl$Longbiopsie.VATS)
ops_tbl$Mamma.ablatio <- as.factor(ops_tbl$Mamma.ablatio)
ops_tbl$Maze <- as.factor(ops_tbl$Maze)
ops_tbl$Mediastinoscopie <- as.factor(ops_tbl$Mediastinoscopie)
ops_tbl$Morrow <- as.factor(ops_tbl$Morrow)
ops_tbl$MVP <- as.factor(ops_tbl$MVP)
ops_tbl$MVP.via.minithoracotomie <- as.factor(ops_tbl$MVP.via.minithoracotomie)
ops_tbl$MVPVentrikelaneurysma <- as.factor(ops_tbl$MVPVentrikelaneurysma)
ops_tbl$MVR <- as.factor(ops_tbl$MVR)
ops_tbl$MVR.via.minithoracotomie <- as.factor(ops_tbl$MVR.via.minithoracotomie)
#ops_tbl$Nuss.bar.verwijderen <- as.factor(ops_tbl$Nuss.bar.verwijderen)
ops_tbl$Nuss.procedure <- as.factor(ops_tbl$Nuss.procedure)
#ops_tbl$Ok.empyema.thoracis <- as.factor(ops_tbl$Ok.empyema.thoracis)
ops_tbl$Open.operatie.van.een.of.meerdere.mediastinumtumoren.eventueel.midsternaal <- as.factor(ops_tbl$Open.operatie.van.een.of.meerdere.mediastinumtumoren.eventueel.midsternaal)
ops_tbl$Openen.hartzakje.zonder.hartingreep.eventueel.drainage.van.een.pericarditis.via.een.thoracotomie <- as.factor(ops_tbl$Openen.hartzakje.zonder.hartingreep.eventueel.drainage.van.een.pericarditis.via.een.thoracotomie)
ops_tbl$Operatie.wegens.een.perforerende.hartverwonding <- as.factor(ops_tbl$Operatie.wegens.een.perforerende.hartverwonding)
#ops_tbl$Operatieve.behandeling.van.een.empyema.thoracis.open.procedure <- as.factor(ops_tbl$Operatieve.behandeling.van.een.empyema.thoracis.open.procedure)
ops_tbl$Operatieve.behandeling.van.een.empyema.VATS <- as.factor(ops_tbl$Operatieve.behandeling.van.een.empyema.VATS)
#ops_tbl$Operatieve.verwijdering.gezwellenRavitch.procedure <- as.factor(ops_tbl$Operatieve.verwijdering.gezwellenRavitch.procedure)
ops_tbl$Partiele.pericardresectie.via.thoracotomie <- as.factor(ops_tbl$Partiele.pericardresectie.via.thoracotomie)
#ops_tbl$Partiele.pleurectomie <- as.factor(ops_tbl$Partiele.pleurectomie)
ops_tbl$Percardiectomie <- as.factor(ops_tbl$Percardiectomie)
ops_tbl$Pericard.drainage <- as.factor(ops_tbl$Pericard.drainage)
#ops_tbl$Pericard.fenestratie.via.VATS <- as.factor(ops_tbl$Pericard.fenestratie.via.VATS)
ops_tbl$Plaatsen.epicardiale.electrode.na.openen.pericard <- as.factor(ops_tbl$Plaatsen.epicardiale.electrode.na.openen.pericard)
ops_tbl$Pleurabiopsie <- as.factor(ops_tbl$Pleurabiopsie)
#ops_tbl$Pleurectomie.VATS <- as.factor(ops_tbl$Pleurectomie.VATS)
ops_tbl$Pleuro.pneumonectomie.open.procedure <- as.factor(ops_tbl$Pleuro.pneumonectomie.open.procedure)
ops_tbl$Pneumonectomie <- as.factor(ops_tbl$Pneumonectomie)
ops_tbl$Pneumonectomie.met.uitgebreide.verwijdering.lymfklieren.open.procedure <- as.factor(ops_tbl$Pneumonectomie.met.uitgebreide.verwijdering.lymfklieren.open.procedure)
ops_tbl$Pneumonectomie.open.procedure <- as.factor(ops_tbl$Pneumonectomie.open.procedure)
ops_tbl$Poging.tot.VATS.PVI <- as.factor(ops_tbl$Poging.tot.VATS.PVI)
ops_tbl$Proefthoracotomie <- as.factor(ops_tbl$Proefthoracotomie)
ops_tbl$PVI <- as.factor(ops_tbl$PVI)
ops_tbl$Ravitch.procedure <- as.factor(ops_tbl$Ravitch.procedure)
#ops_tbl$Refixatie.sternum <- as.factor(ops_tbl$Refixatie.sternum)
ops_tbl$Rethoracotomie <- as.factor(ops_tbl$Rethoracotomie)
ops_tbl$Sleeve.resectie <- as.factor(ops_tbl$Sleeve.resectie)
ops_tbl$Sleeve.resectie.VATS <- as.factor(ops_tbl$Sleeve.resectie.VATS)
#ops_tbl$Staaldraden.verwijderen <- as.factor(ops_tbl$Staaldraden.verwijderen)
#ops_tbl$TAVI.1 <- as.factor(ops_tbl$TAVI.1)
ops_tbl$TAVI.II <- as.factor(ops_tbl$TAVI.II)
ops_tbl$Tumor.atrium <- as.factor(ops_tbl$Tumor.atrium)
ops_tbl$Tumor.mediastinum <- as.factor(ops_tbl$Tumor.mediastinum)
ops_tbl$Tumor.ventrikel <- as.factor(ops_tbl$Tumor.ventrikel)
ops_tbl$TVP <- as.factor(ops_tbl$TVP)
ops_tbl$VATS.Boxlaesie <- as.factor(ops_tbl$VATS.Boxlaesie)
ops_tbl$VATS.PVI <- as.factor(ops_tbl$VATS.PVI)
ops_tbl$Ventrikelaneurysma <- as.factor(ops_tbl$Ventrikelaneurysma)
ops_tbl$Vervangen.pacemaker.of.ICD <- as.factor(ops_tbl$Vervangen.pacemaker.of.ICD)
ops_tbl$Vervanging.aorta.ascendens.met.aortaboog <- as.factor(ops_tbl$Vervanging.aorta.ascendens.met.aortaboog)
ops_tbl$Vervanging.aortawortel <- as.factor(ops_tbl$Vervanging.aortawortel)
ops_tbl$Vervanging.aortawortel.aorta.ascendens.en.boog <- as.factor(ops_tbl$Vervanging.aortawortel.aorta.ascendens.en.boog)
ops_tbl$Verwijderen.Corpus.Alienum <- as.factor(ops_tbl$Verwijderen.Corpus.Alienum)
ops_tbl$Verwijderen.pacemaker.of.ICD <- as.factor(ops_tbl$Verwijderen.pacemaker.of.ICD)
ops_tbl$VSD <- as.factor(ops_tbl$VSD)
ops_tbl$Wigresectie <- as.factor(ops_tbl$Wigresectie)
#ops_tbl$Wigresectie.VATS <- as.factor(ops_tbl$Wigresectie.VATS)
ops_tbl$Wondtoilet <- as.factor(ops_tbl$Wondtoilet)
summary(ops_tbl)



#create different table with operationtypes
patients_tbl <- proj %>%
  select(ID, Leeftijd, Geslacht ,AF ,Chronische.longziekte ,
         Extracardiale.vaatpathie ,Actieve.endocarditis ,
         Eerdere.hartchirurgie ,Kritische.preoperatieve.status ,
         Myocard.infact..90.dagen  ,Aorta.chirurgie ,Pulmonale.hypertensie ,Euroscore1 ,
         Slechte.mobiliteit  ,DM )
patients_tbl <- as_tibble(patients_tbl)
       
hospital_tbl <- proj %>%
  select(ID,Chirurg, Anesthesioloog, OK)
hospital_tbl <- as_tibble(hospital_tbl)
  
time_tbl <- proj %>%
  select(ID, Casustype, Dagdeel, Geplande.operatieduur,Operatieduur,         
         Ziekenhuis.ligduur, IC.ligduur,time.diff)
time_tbl <- as_tibble(time_tbl)




# UPLOAD
# require("RPostgreSQL")
# 
# pw <- {
#   "***"
# }
# 
# drv <- dbDriver("PostgreSQL")
# con <- dbConnect(drv, dbname = "dpv1a025",
#                  host = "castle.ewi.utwente.nl", port = 5432,
#                  user = "dpv1a025", password = pw,
#                  options="-c search_path=project")
# rm(pw)
# 
# dbWriteTable(con, "Operations", value = ops_tbl, overwrite = T, row.names = F)
 
              
              
