
## 2 RELATED WORK

There have ben prior reseasrch done for optimization of the OR schedule and 

## 3 APPROACH


### 3.2 Data Preparation

##### Variable selection

##### How the data was transformed


### 3.3 Data Mining

Regression analysis was performed on the data to predict the Operation time. Four regression models were tested to see which of the models would be best suited for the problem.
Two Linear regression and two decision tree models were taken. 
- LM - Multiple Linear regression with gaussian distribution
- GLM (using family poisson)
- Decision  Tree (using rpart and method 'anova')
- Random Forest



## 4 EXPERIMENTS

### 4.1 Data set description (Outcomes of Data preparation)

##### Star schema

The data was diveded into four tables - Time, Operation, Patient and hospital. 
- The time table was our fact table and it contained the actual time and the time differences(from predicted models and planned times) - the two main variables we were looking at. 
- Patient table contained all the charecteristics of the patient. These are individual to each patient and hence put in a separate table.
- Operation table was created to separate the individual operations performed during surgeries where there multiple operations.
- Hospital table contained variables which were related to the hospital. These are the variables on which the hospital as direct control over and can decide on them based on the nature of surgery. 


##### Formula



## 5 Discussion

RMSE calcluated to compare the different data prediction models. 

The reultant R^2 is not enough to predict accurately. 

Though there is an improvement in the predicted values, there is further study required to build an accrate predictive model.  



## 6 Summary 

Recommendation:
- Have a patient id to link the operation to patient. There can be cases in the data where the same patient undergoes multiple operations and in the current dataset there is no way to link them. 
- Collect data about the time the operation was performed - Date and time of the surgery. 

## REFERENCES 

[1] Pulido, R., Aguirre, A.M., Ortega-Mier, M. et al. BMC Health Serv Res (2014) 14: 464. https://doi.org/10.1186/1472-6963-14-464 



---------------------
Content below this line does not go into the report.


#### File Distribution

- project.R - contains code for reading the dataset, Data preparation, and uploading the data to the Database.
  - Packages used:
     1. dplyr
     2. tidyverse
     3. plyr
     5. RPostgreSQL
    
    
- dm.R - code for the data mining part of the project. Creating the formula, the dataset for modeling, and the four data models. Also will contian the sampling the dataset, training and testing the models.
  - Packages used:
    1. caret
    2. rpart
    3. rpart.plot
    4. randomForest

- plots.R - code for all the plots in the project. 
  - Packages used:
    1. ggplot2
    
- data/surgical_case_durations.csv - the dataset for the project.

##### TODO / Notes from the presentation 

- Sampling, training and testing
- make Math's equations of the formula
- include reference/citations
  - related to TCT
  - related to OR-utilization
- numbers in the tables to be max. 1 or 2 decimal places
