
## 2 RELATED WORK

Optimization of schedules falls under the study of Operation Research and there have been prior research done for optimization of the OR schedules at hospitals. Recently more hospitals have started to scheduling systems, like open-scheuling and block-scheduling, which have been studied by Weiss (2014) who concludedthat it has resulted in better utilization of ORs but there has been a continued drive in improving it further. Pulido et al. (2014) concluded that the duration of surgery depends highly of the surgon performing it, higher the expertise of the surgon, lower would be the probability of delay. As TCT is a multiple OR, there is also an affect of the prior sugreries perfomred in the same OR [Zheng Zhang & Xiaolan Xie (2015)] and the delay of one surgery has cascading affect on the surgeries planned for the rest of the day [Denton et al. (2007)]. 

## 3 APPROACH


### 3.2 Data Preparation


### 3.3 Data Mining

Regression analysis was performed on the data to predict the Operation time to analyse how much effect each of the predictor in the dataset had. Four regression models were tested to see which of the models would be best suited for the problem.
Two Linear regression and two decision tree methods were applied. 
- Multiple Linear regression with gaussian distribution - The was the simplest LM which could be applied to the dataset.  
- Poisson regression
- Decision  Tree (using rpart and method 'anova')
- Random Forest



## 4 EXPERIMENTS

### 4.1 Data set description (Outcomes of Data preparation)

The data was diveded into four tables - Time, Operation, Patient and hospital. The time table was our fact table and the others were dimension tables. 
-  The time table contained the actual time and the computed time difference - the two main variables we were looking at, along with other variables related to the time of the operation and the days the patient spent in the hospital. This way we were able to separate all variables related to time into a separate table.   
- Patient table contained all the charecteristics of the patient. These are individual to each patient and hence put in a separate table. A flaw in the data discovered here was that there was no track of operations per individual, this is further discussed in the Discussion section. 
- Operation table was created to separate the individual operations performed during surgeries where there multiple operations. All the operations left in the final dataset were created as coloumns, and data for each operation was filled in the as a 1 or 0. For opertaion rows with single operation surgeries, only one field was 1 and rest were 0, while for multiple operations surgeries, all the coloumns which were going to be performed were 1 and rest were 0.  
- Hospital table contained variables which were related to the hospital. These are the variables on which the hospital as direct control over and can decide based on the nature of surgery and availability. 

As the data in the regression function needs to be in a single dataframe in R, all the tables were combined together in one. 

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

Denton, B., Viapiano, J. & Vogl, A. Health Care Manage Sci (2007) 10: 13. https://doi.org/10.1007/s10729-006-9005-4 

Pulido, R., Aguirre, A.M., Ortega-Mier, M. et al. BMC Health Serv Res (2014) 14: 464. https://doi.org/10.1186/1472-6963-14-464 

Weiss, Rebecca, "The Impact of Block Scheduling and Release Time on Operating Room Efficiency" (2014).All Theses. 1875. https://tigerprints.clemson.edu/all_theses/1875

Zheng Zhang & Xiaolan Xie (2015) Simulation-based optimization for surgery appointment scheduling of multiple operating rooms, IIE Transactions, 47:9, 998-1012, DOI: 10.1080/0740817X.2014.999900 


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
