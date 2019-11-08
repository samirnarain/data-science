
### Data Preparation

##### Star schema
The data was diveded into four tables - Time, Operation, Patient and hospital. 
- The time table was our fact table and it contained the actual time and the time differences(from predicted models and planned times) - the two main variables we were looking at. 
- Patient table contained all the charecteristics of the patient, like age, gender, BMI, EUROScore1 etc. 
- Operation table was created to separate the individual operations performed during surgeries where there multiple operations.
- Hospital table contained variables which were related to the hospital - like Surgon, Operation Room, and anesthesiologist.

#### Variable selection


### Data Mining

Regression was performed on the data set and the operation time was predicted. Four regression models were tested on the data to see which of the models would be best suited for the problem.
- LM - Multiple Linear regression with gaussian distribution
- GLM (using family poisson)
- Decision  Tree (using rpart and method 'anova')
- Random Forest

##### Formula

### Conclusion
RMSE calcluated to compare the different data prediction models. LM was

The reultant R^2 is not enough to predict accurately. 
Though there is an improvement in the predicted values, there is further study required to build an accrate predictive model.  

### Discussion
Have a patient id to link the operation to patient. There can be cases in the data where the same patient undergoes multiple operations and in the current dataset there is no way to link them. 


### Related research




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
