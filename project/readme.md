
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

------------------

### Report Text 


## 2 RELATED WORK

Optimization of schedules falls under the study of Operation Research and there have been prior research done for optimization of the OR schedules at hospitals. Denton et al. (2007) highlighted the importance of schedule time and sequencing decisions on OR planning for the day. Recently more hospitals have started to use scheduling systems, like open-scheduling and block-scheduling, which were studied by Weiss (2014) who showed that it has resulted in better utilization of ORs but there has been a continued drive in improving it further. Pulido et al. (2014) concluded that the duration of surgery depends highly of the surgeon performing it, higher the expertise of the surgeon, lower would be the probability of delay. As TCT is a multiple OR hospital, we found a similar study by Zheng Zhang & Xiaolan Xie (2015) which was for scheduling the start time of surgeries in hospitals with multiple operation rooms. They concluded that "... optimal surgeon arrival times are quite different from those of a single OR and are highly dependent on OR number and surgery duration variability." 

## 3 APPROACH


### 3.2 Data Preparation

The Dataset was received in a csv file with European format decimal comma. As it was being loaded into R, it needed to be transformed to the decimal point format to be interpreted as numbers. There was a significant amount of incomplete data, which was filled with 'NULL' or 'Onbekend' which had to be fixed before it could be used. The columns by default were treated as factors and the variables which were required to be numeric had been converted explicitly. For each operation, the 'Operatietype' value was split at + symbol to extract the individual operation being performed as part of the surgery and effectively analyse the impact of each operation on the operation duration. All the data was stored in tibble as it made working with the data easier, however, as we needed most columns as factors, it was converted to tibble after we loaded the data.

### 3.3 Data Mining

Regression analysis was performed on the data to predict the Operation time and to analyse how strong an effect each of the predictor in the dataset had. Four regression models were tested to see which of the models would be best suited for the problem. Of these, two  linear regression methods and two decision tree methods were applied. While linear regression is very robust and can be used to get several insights on the data it is applied to, we wanted further information the other models provided. Decision trees offer the ability to quickly analyse the results because of their visual outcome while at the cost of being not being flexible to slight changes in predictor. Hence our decision to analyse the four regression models listed below: 
- Multiple Linear regression with Gaussian distribution - The was the simplest LM which could be applied to the dataset. The main insight received from this was the degree to which the R-squared value was affected by the presence of variables in the formula. 
- Poisson regression - mainly performed to compare the predictions of the Linear Regression model between the two distributions - Gaussian and Poisson. 
- Decision Tree using rpart function and method 'anova' - Decision tree was created to visualize the effect of the top variables in the dataset. The nodes closer to the root node indicated such a relationship. The method anova was used as the operation time variable was continuous. 
- Random Forest - As a single decision tree is known to suffer from high variance, random forest was used to lower this variance and improve the quality of prediction. 



## 4 EXPERIMENTS

### 4.1 Data set description

As part of data preparation, we started with data cleansing, removing the rows and columns which did not have actual values. All the NULLs and "Onbekend" were replaced by NAs so R could identify them correctly as missing values. From the analysis of the data, we identified 554 rows which had mostly NA in all the columns or in the operation type column, so these rows were deleted. The columns Linker.ventrikel.functie, Nierfunctie, Euroscore2, CCS, NYHA and BMI were deleted from the data as they either had too many NAs or were having low or negative impact on the accuracy of regression. 

The variables age, planned & actual operation, BMI, hospital bedding & IC duration, Euroscore 1&2 were transformed to of numeric type. This operation also included converting decimal comma to decimal point for R to properly interpret the numbers. 

The data was divided into four tables - Time, Operation, Patient and hospital. The time table was our fact table and the others were dimension tables. 
-  The time table contained the actual time and the computed time difference, the two main variables we were looking at, along with other variables related to the time of the operation and the days the patient spent in the hospital. This way we were able to separate all variables related to time into one table.
- Patient table contained all the characteristics of the patient. These are individual to each patient and hence put in a separate table. A flaw in the data discovered here was that there was no track of operations per individual, this is further discussed in the Discussion section. 
- Operation table was created to separate the individual operations performed during surgeries where there were multiple operations. All the operations left in the final dataset were created as columns, and data for each operation was filled in the as a 1 or 0. For operation rows with single operation surgeries, only one field was 1 and rest were 0, while for multiple operations surgeries, all the columns which were going to be performed were 1 and rest were 0. The num_of_ops variable was also added to the table and it indicated how many of the fields would be '1' in the row. 
- Hospital table contained variables which were related to the hospital. These are the variables on which the hospital as direct control over and can decide based on the nature of surgery and availability. 

All the tables were combined together in one as the data in the regression function needs to be in a single dataframe in R. The final table contained 106 variables and was used to perform all the data mining operations. 



## 5 DISCUSSION

All the regression models show an improvement in the prediction of operation time compared to the original planned time. The results are evident from the RMSE values, the planned operation time had a RMSE of 110.48 while all the four prediction models had much lower RMSE. Figures xx and xxx show graphical representations of predictions from all the four models and the planned time. Figure xx shows the histogram of the time differences and we see that the planned time is clustered left all the prediction models. Figure xxx is a plot of the smooth function between the actual time and the predicted time, in addition to the identity line plotted for reference. Here again, all the prediction models are closer to the identity line than the planned time plot. 

Of the four regression models tested, the best outcome is of the multiple Linear regression. It provided the least RMSE and the highest R-squared out of the two LMs. The Random Forest showed a slight improvement in RMSE over the single optimized decision tree model, which was in line with the expectations. The decision tree also provided us with the five most important variables that have an impact on the operation time are: number of operations, HLM, Aorta.Chirurgie and Dagdeel. 

However, none of the model can be put to use in its current state because of the low R-squared value of 49%. Researchers agree that the R-squared should be above 80% for a model to be considered a reliable predictor. Further study and tweaking the model would need to be performed to accurately predict the operation time. 

There are some flaws which we could identify in the current models and would need to be addressed to get better results: 
- Overfitting - the predictions are made on all the available data in the data set. This leads to overfitting, i.e. the model is dependent on the data to be of the same form, and if there are any operations, or other parameters, not present in the present data set, the model will give unreliable results. A better model would be trained on a subset of the provided dataset and tested for the remaining data. 
- There were a number of rows deleted from the data to build the models. While the reason for deletion are mentioned in the ‘Data set description’, it leads to under-representation for some set of operations. We noted that there were some operation types that were not part of our final dataset because they had too many missing values and not suitable for our model. For improving the results, reasonable approximations would need to made - like using mean or median values or making use of libraries like MICE for approximation. 
- There was no link between the rows of operations which prevents us from assessing if the relationship between patients and operation. One patient can undergo multiple operations at different times in the hospital, but the data fails to represent this. A patient ID field would help in this situation.
- Details about the time and day of operation - in the literature we reviewed as part of this research, the time and sequence of operation in the day have been shown to have a significant impact OR planning. However this information was missing from the dataset on which we trained the model. 




## 6 SUMMARY 

Recommendation:
- Have a patient id to link the operation to patient. There can be cases in the data where the same patient undergoes multiple operations and in the current dataset there is no way to link them. 
- Collect data about the time the operation was performed - Date and time of the surgery. 

## REFERENCES 

Denton, B., Viapiano, J. & Vogl, A. Health Care Manage Sci (2007) 10: 13. https://doi.org/10.1007/s10729-006-9005-4 

James, G., Witten, D., Hastie, T., Tibshirani, R.: An Introduction to Statistical Learning. Springer, New York (2013). https://doi.org/10.1007/978-1-4614-7138-7

Pulido, R., Aguirre, A.M., Ortega-Mier, M. et al. BMC Health Serv Res (2014) 14: 464. https://doi.org/10.1186/1472-6963-14-464 

Weiss, Rebecca, "The Impact of Block Scheduling and Release Time on Operating Room Efficiency" (2014).All Theses. 1875. https://tigerprints.clemson.edu/all_theses/1875

Zheng Zhang & Xiaolan Xie (2015) Simulation-based optimization for surgery appointment scheduling of multiple operating rooms, IIE Transactions, 47:9, 998-1012, DOI: 10.1080/0740817X.2014.999900 



---------------------




