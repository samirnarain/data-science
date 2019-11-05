#install.packages("dplyr")
#install.packages("ggplot2")
#install.packages("readr")
#install.packages("lubridate")
#install.packages("RPostgreSQL")
#install.packages("tidyverse")
#install.package("rpart.plot")

require(dplyr)
require(ggplot2)
require(readr)
require(lubridate)
require(RPostgreSQL)
require(tidyverse)
library(rpart)
library(rpart.plot)


proj = read.csv2(file = "data/surgical_case_durations.csv")
proj <- na.omit(proj)
proj <- as_tibble(proj)
head(proj)
str(proj)


#DATA PREPARATION (TRANSFORMING AND COMPUTING)

# default coulumn type is factor
# converting required coloumns to numeric for processing  
proj$Geplande.operatieduur <- as.numeric(proj$Geplande.operatieduur)
proj$Operatieduur <- as.numeric(proj$Operatieduur)
proj$BMI <- as.numeric(sub(",", ".", sub(".", "", proj$BMI, fixed=TRUE), fixed=TRUE))
proj$Ziekenhuis.ligduur <- as.numeric(proj$Ziekenhuis.ligduur)
proj$IC.ligduur <- as.numeric(proj$IC.ligduur)
proj$Euroscore1 <- as.numeric(proj$Euroscore1)
proj$Euroscore2 <- as.numeric(proj$Euroscore2)
proj$Leeftijd <- as.numeric(proj$Leeftijd)


#compute time difference
proj <- mutate(proj, time.diff = Operatieduur - Geplande.operatieduur)

# compute age group
proj <- proj %>%
  mutate(age_group = case_when(
    Leeftijd > 70 ~ ">70",
    Leeftijd > 60 & Leeftijd <= 70 ~ "60-70",
    Leeftijd > 50 & Leeftijd <= 60 ~ "50-60",
    Leeftijd > 40 & Leeftijd <= 50 ~ "40-50",
    Leeftijd > 30 & Leeftijd <= 40 ~ "30-40",
    Leeftijd > 20 & Leeftijd <= 30 ~ "20-30",
    Leeftijd > 10 & Leeftijd <= 20 ~ "10-20",
    Leeftijd <= 10 ~ "< 10"))
proj$age_group <- as.factor(proj$age_group)

# compute BMI group
proj <- proj %>%  
  mutate(BMI_group = case_when(
    BMI >= 30              ~ "Obese",
    BMI >= 25   & BMI < 30 ~ "Overweight",
    BMI >= 18.5 & BMI < 25 ~ "Normal",
    BMI <  18.5            ~ "Underweight",))
proj$BMI_group <- as.factor(proj$BMI_group)

# compute delay group
proj <- proj %>%  
  mutate(time_group = case_when(
    time.diff >=  60                     ~ "Very Late",
    time.diff >=  15 & time.diff < 60    ~ "Late but <60min",
    time.diff >= -15 & time.diff < 15    ~ "Within 15 mins",
    time.diff >= -60 &  time.diff < -15  ~ "Early but <60min",
    time.diff <  -60                     ~ "Very Early"))
proj$time_group <- as.factor(proj$time_group)

# write a coloums with the number of operations planned
proj <- mutate(proj, num_of_ops = str_count(proj$Operatietype, '\\+') + 1 )
proj$num_of_ops <- as.factor(proj$num_of_ops)

# attempting to separate the operations - WIP
proj <- mutate(proj, op_types = sub(" + ", " , ", proj$Operatietype, fixed = TRUE)) 

# compute Operation time group
# doing this so it can be used as a factor. in its currenct form, operatieduur is a very large factor
proj <- proj %>%  
  mutate(op_time_group = case_when(
    Operatieduur >= 465                      ~ ">465",
    Operatieduur >= 450 & Operatieduur < 465 ~ "450-465",
    Operatieduur >= 435 & Operatieduur < 450 ~ "435-450",
    Operatieduur >= 420 & Operatieduur < 435 ~ "420-435",
    Operatieduur >= 405 & Operatieduur < 420 ~ "405-420",
    Operatieduur >= 390 & Operatieduur < 405 ~ "390-405",
    Operatieduur >= 375 & Operatieduur < 390 ~ "375-390",
    Operatieduur >= 360 & Operatieduur < 375 ~ "360-375",
    Operatieduur >= 345 & Operatieduur < 360 ~ "345-360",
    Operatieduur >= 330 & Operatieduur < 345 ~ "330-345",
    Operatieduur >= 315 & Operatieduur < 330 ~ "315-330",
    Operatieduur >= 300 & Operatieduur < 315 ~ "300-315",
    Operatieduur >= 285 & Operatieduur < 300 ~ "285-300",
    Operatieduur >= 270 & Operatieduur < 285 ~ "270-285",
    Operatieduur >= 255 & Operatieduur < 270 ~ "255-270",
    Operatieduur >= 240 & Operatieduur < 255 ~ "240-255",
    Operatieduur >= 225 & Operatieduur < 240 ~ "225-240",
    Operatieduur >= 210 & Operatieduur < 225 ~ "210-225",
    Operatieduur >= 195 & Operatieduur < 210 ~ "195-210",
    Operatieduur >= 180 & Operatieduur < 195 ~ "180-195",
    Operatieduur >= 165 & Operatieduur < 180 ~ "165-180",
    Operatieduur >= 150 & Operatieduur < 165 ~ "150-165",
    Operatieduur >= 135 & Operatieduur < 150 ~ "135-150",
    Operatieduur >= 120 & Operatieduur < 135 ~ "120-135",
    Operatieduur >= 105 & Operatieduur < 120 ~ "105-120",
    Operatieduur >=  90 & Operatieduur < 105 ~ "90-105",
    Operatieduur >=  75 & Operatieduur <  90 ~ "75-90",
    Operatieduur >=  60 & Operatieduur <  75 ~ "60-75",
    Operatieduur >=  45 & Operatieduur <  60 ~ "45-60",
    Operatieduur >=  30 & Operatieduur <  45 ~ "30-45",
    Operatieduur >=  15 & Operatieduur <  30 ~ "15-30",
    Operatieduur <   15                      ~ "<15"  ))
proj$op_time_group <- as.factor(proj$op_time_group)

proj <- proj %>%  
  mutate(op_planned_time_group = case_when(
    Geplande.operatieduur >= 465                               ~ ">465",
    Geplande.operatieduur >= 450 & Geplande.operatieduur < 465 ~ "450-465",
    Geplande.operatieduur >= 435 & Geplande.operatieduur < 450 ~ "435-450",
    Geplande.operatieduur >= 420 & Geplande.operatieduur < 435 ~ "420-435",
    Geplande.operatieduur >= 405 & Geplande.operatieduur < 420 ~ "405-420",
    Geplande.operatieduur >= 390 & Geplande.operatieduur < 405 ~ "390-405",
    Geplande.operatieduur >= 375 & Geplande.operatieduur < 390 ~ "375-390",
    Geplande.operatieduur >= 360 & Geplande.operatieduur < 375 ~ "360-375",
    Geplande.operatieduur >= 345 & Geplande.operatieduur < 360 ~ "345-360",
    Geplande.operatieduur >= 330 & Geplande.operatieduur < 345 ~ "330-345",
    Geplande.operatieduur >= 315 & Geplande.operatieduur < 330 ~ "315-330",
    Geplande.operatieduur >= 300 & Geplande.operatieduur < 315 ~ "300-315",
    Geplande.operatieduur >= 285 & Geplande.operatieduur < 300 ~ "285-300",
    Geplande.operatieduur >= 270 & Geplande.operatieduur < 285 ~ "270-285",
    Geplande.operatieduur >= 255 & Geplande.operatieduur < 270 ~ "255-270",
    Geplande.operatieduur >= 240 & Geplande.operatieduur < 255 ~ "240-255",
    Geplande.operatieduur >= 225 & Geplande.operatieduur < 240 ~ "225-240",
    Geplande.operatieduur >= 210 & Geplande.operatieduur < 225 ~ "210-225",
    Geplande.operatieduur >= 195 & Geplande.operatieduur < 210 ~ "195-210",
    Geplande.operatieduur >= 180 & Geplande.operatieduur < 195 ~ "180-195",
    Geplande.operatieduur >= 165 & Geplande.operatieduur < 180 ~ "165-180",
    Geplande.operatieduur >= 150 & Geplande.operatieduur < 165 ~ "150-165",
    Geplande.operatieduur >= 135 & Geplande.operatieduur < 150 ~ "135-150",
    Geplande.operatieduur >= 120 & Geplande.operatieduur < 135 ~ "120-135",
    Geplande.operatieduur >= 105 & Geplande.operatieduur < 120 ~ "105-120",
    Geplande.operatieduur >=  90 & Geplande.operatieduur < 105 ~ "90-105",
    Geplande.operatieduur >=  75 & Geplande.operatieduur <  90 ~ "75-90",
    Geplande.operatieduur >=  60 & Geplande.operatieduur <  75 ~ "60-75",
    Geplande.operatieduur >=  45 & Geplande.operatieduur <  60 ~ "45-60",
    Geplande.operatieduur >=  30 & Geplande.operatieduur <  45 ~ "30-45",
    Geplande.operatieduur >=  15 & Geplande.operatieduur <  30 ~ "15-30",
    Geplande.operatieduur < 15                                 ~ "<15")
  )
    


proj_orig <- proj

proj <- proj %>% filter(Geslacht != "NULL")

ops_tbl <- as_tibble(proj$Operatietype) %>%
  distinct()

colnames(ops_tbl) <- c("Ops.performed")

ops_tbl <- ops_tbl %>%
  mutate(ops = str_split(ops_tbl$Ops.performed,"\\+"))
  
ops_tbl$Ascendensvervanging <- 0
ops_tbl$ASD <- 0
ops_tbl$AVP <- 0
ops_tbl$AVR <- 0
ops_tbl$AVR.via.minithoracotomie <- 0
ops_tbl$Bentall.procedure <- 0
ops_tbl$Bilobectomie.open.procedure <- 0
ops_tbl$Bilobectomie.VATS <- 0
ops_tbl$Biventriculaire.pacemaker <- 0
ops_tbl$Boxlaesie <- 0
ops_tbl$Bullectomie.met.partiele.pleurectomie <- 0
ops_tbl$Bullectomie.met.partiÃle.pleurectomie.VATS <- 0
ops_tbl$CABG <- 0
ops_tbl$CABG.via.minithoracotomie <- 0
ops_tbl$CABGPacemakerdraad.tijdelijk <- 0
ops_tbl$Capsulotomie/capsulectomie.met.verwijderen.mammaprothese.na.augmentatie <- 0
ops_tbl$Decorticatie.long <- 0
ops_tbl$Decorticatie.long.VATS <- 0
ops_tbl$Diagnostische.pleurapunctie <- 0
ops_tbl$ECMO <- 0
ops_tbl$Endoscopische.bullectomie.met.partiele.pleurectomie <- 0
ops_tbl$Endoscopische.lobectomie.of.segmentresectie <- 0
ops_tbl$Endoscopische.longbiopsie <- 0
ops_tbl$Endoscopische.ok.empyema.thoracis <- 0
ops_tbl$Endoscopische.wigresectie <- 0
ops_tbl$Epicardiale.LV-lead <- 0
ops_tbl$Excisie.aandoening.thoraxwand.VATS <- 0
ops_tbl$Grote.borstwandresectie.in.verband.met.een.doorgegroeide.maligniteit. <- 0
ops_tbl$Inbrengen.endocardiale.electrode.en.bevestigen.tweede.electrode.op.het.epicard.of.bevestigen.beide <- 0
ops_tbl$Inbrengen.LVAD.BIVAD <- 0
ops_tbl$Inbrengen.van.stimulatie-electrode.en.aansluiten.subc..geplaatste.pacemaker <- 0
ops_tbl$Klassieke.Aortabroek.Prothese <- 0
ops_tbl$Klassieke.aortabuisprothese.met.zijtak.ken <- 0
ops_tbl$Lobectomie.of.segmentresectie <- 0
ops_tbl$Longbiopsie.VATS <- 0
ops_tbl$Mamma.ablatio <- 0
ops_tbl$Maze <- 0
ops_tbl$Mediastinoscopie <- 0
ops_tbl$Morrow <- 0
ops_tbl$MVP <- 0
ops_tbl$MVP.via.minithoracotomie <- 0
ops_tbl$MVPVentrikelaneurysma <- 0
ops_tbl$MVR <- 0
ops_tbl$MVR.via.minithoracotomie <- 0
ops_tbl$Nuss.bar.verwijderen <- 0
ops_tbl$Nuss-procedure <- 0
ops_tbl$Ok.empyema.thoracis <- 0
ops_tbl$Open.operatie.van.een.of.meerdere.mediastinumtumoren.eventueel.midsternaal. <- 0
ops_tbl$Openen.hartzakje.zonder.hartingreep.eventueel.drainage.van.een.pericarditis.via.een.thoracotomie <- 0
ops_tbl$Operatie.wegens.een.perforerende.hartverwonding. <- 0
ops_tbl$Operatieve.behandeling.van.een.empyema.thoracis.open.procedure. <- 0
ops_tbl$Operatieve.behandeling.van.een.empyema.VATS. <- 0
ops_tbl$Operatieve.verwijdering.gezwellenRavitch-procedure <- 0
ops_tbl$Partiele.pericardresectie.via.thoracotomie. <- 0
ops_tbl$PartiÃle.pleurectomie <- 0
ops_tbl$Percardiectomie.subtotaal <- 0
ops_tbl$Pericard.drainage <- 0
ops_tbl$Pericard-fenestratie.via.VATS. <- 0
ops_tbl$Plaatsen.epicardiale.electrode.na.openen.pericard <- 0
ops_tbl$Pleurabiopsie. <- 0
ops_tbl$Pleurectomie.VATS <- 0
ops_tbl$Pleuro-pneumonectomie.open.procedure. <- 0
ops_tbl$Pneumonectomie <- 0
ops_tbl$Pneumonectomie.met.uitgebreide.verwijdering.lymfklieren.open.procedure. <- 0
ops_tbl$Pneumonectomie.open.procedure. <- 0
ops_tbl$Poging.tot.VATS.PVI <- 0
ops_tbl$Proefthoracotomie <- 0
ops_tbl$PVI <- 0
ops_tbl$Ravitch-procedure <- 0
ops_tbl$Refixatie.sternum <- 0
ops_tbl$Rethoracotomie <- 0
ops_tbl$Sleeve.resectie <- 0
ops_tbl$Sleeve-resectie.VATS. <- 0
ops_tbl$Staaldraden.verwijderen <- 0
ops_tbl$TAVI-1 <- 0
ops_tbl$TAVI-II <- 0
ops_tbl$Tumor.atrium <- 0
ops_tbl$Tumor.mediastinum <- 0
ops_tbl$Tumor.ventrikel <- 0
ops_tbl$TVP <- 0
ops_tbl$VATS.Boxlaesie <- 0
ops_tbl$VATS.PVI <- 0
ops_tbl$Ventrikelaneurysma <- 0
ops_tbl$Vervangen.pacemaker.of.ICD <- 0
ops_tbl$Vervanging.aorta.ascendens.met.aortaboog <- 0
ops_tbl$Vervanging.aortawortel <- 0
ops_tbl$Vervanging.aortawortel.aorta.ascendens.en.boog <- 0
ops_tbl$Verwijderen.Corpus.Alienum <- 0
ops_tbl$Verwijderen.pacemaker.of.ICD <- 0
ops_tbl$VSD <- 0
ops_tbl$Wigresectie <- 0
ops_tbl$Wigresectie.VATS <- 0
ops_tbl$Wondtoilet <- 0


#ops_tbl <- ops_tbl %>%
#  mutate(Wondtoilet = ifelse(grep("CABG", Ops.performed), 1, 0))






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
 
              
              
