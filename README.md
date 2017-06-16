# **Getting and Cleaning Data Course Project**
<br>

## **Overview of the Assigment**
<br>

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained: <http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones>

Here are the data for the project:<https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip>

You should create one R script called run_analysis.R that does the following.
1) Merges the training and the test sets to create one data set.
2) Extracts only the measurements on the mean and standard deviation for each measurement.
3) Uses descriptive activity names to name the activities in the data set
4) Appropriately labels the data set with descriptive variable names.
5) From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

The instructions above (and even the idea of "tidy" data) are open to interpretation in many instances.  I do my best below to explain my rationale and ask the grader to focus not on whether my interpretation of the assigment matches theirs, but rather whether my code does as I intend it to do per my comments.
<br><br>

## **The Script Explained**

load dplyr because I'll need it later
`library(dplyr)`
<br>

### **Getting the data**
Download the file to be used for this project
`if(!file.exists("uci_har.zip")) {`
`  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile="./uci_har.zip")`
`  }`

Unzip the file into the working directory. The unzipped file was actually a directory called UCI HAR Dataset, containing subdirectories and multiple data files 
`unzip("uci_har.zip")`
<br><br>

### **Reading the Data**
A course mentor suggests we do not need the 'Inertial Signals' data files for this assignment:
<https://thoughtfulbloke.wordpress.com/2015/09/09/getting-and-cleaning-the-assignment/>

Step 1) Assign file paths to variables so I can call these variables in a series of read.table() commands.  

`xtrain_path <- "./UCI HAR Dataset/train/X_train.txt"`

`ytrain_path <- "./UCI HAR Dataset/train/y_train.txt"`

`subject_train_path <- "./UCI HAR Dataset/train/subject_train.txt"`

`xtest_path <- "./UCI HAR Dataset/test/X_test.txt"`

`ytest_path <- "./UCI HAR Dataset/test/y_test.txt"`

`subject_test_path <- "./UCI HAR Dataset/test/subject_test.txt"`

`activity_labels_path <- "./UCI HAR Dataset/activity_labels.txt"`

`features_path <- "./UCI HAR Dataset/features.txt"`
<br>

A description of the files being loaded for this assignment:
* 'X_train.txt' and 'X_test.txt' are the measurement data files

* 'y_train.txt' and 'y_test.txt' provide an ID which will help us link each observation in the measurement data to an activity label.  I made this assumption because the subject files have the same number of records in them as their corresponding x data files, and they contain 6 unique values (integers 1-6) which seems to line up with the 6 activities provided in the activity labels file.

* 'subject_test.txt' and 'subject_train.txt' provide and ID to help us link each observation in the measurement data to an individual study participant

* 'activity_labels.txt' provides descriptive names of activities that we can join to the measurement data via the  'y_test.txt' and 'y_train.txt' tables (they are our "crosswalks" to get activity labels into the x tables)

* 'features.txt' provides descriptive names of the variables residing in 'x_test.txt' and 'x_train.txt'
<br><br>

Step 2) Read the data into R. While the data appeared to be single space delimted, it in fact had more than one space in between some columns.  Using sep="" let's R know that any length of white space is to be interpreted as the column delimiter

`xtrain <- read.table(xtrain_path, header=FALSE, sep="")`

`ytrain <- read.table(ytrain_path, header=FALSE, sep="")`

`subject_train <- read.table(subject_train_path, header=FALSE, sep="")`

`xtest <- read.table(xtest_path, header=FALSE, sep="")`

`ytest <- read.table(ytest_path, header=FALSE, sep="")`

`subject_test <- read.table(subject_test_path, header=FALSE, sep="")`

`activity_labels <- read.table(activity_labels_path, header=FALSE, sep="")`

`features <- read.table(features_path, header=FALSE, sep="")`
<br><br>

### **Cleaning/Preparing/Tidying the Data**
The following code merges join the y-tables to the activity labels on a common key (V1), essentially giving me an activity name for every observation in the measurement data. In this case, the default column name "V1" existed in both data sets and represented the same piece of information in both files (i.e. a key to join the tables). If the names were different, I'd need to add more arguments to the merge() function to tell it which column in ytrain (for example) matches to which column in the activity labels
`activity_xtrain <- merge(activity_labels, ytrain)`
`activity_xtest <- merge(activity_labels, ytest)`
<br>

I adding a "partition" variable to help me keep track which data set each record came from ("test" vs. "train"...just in case)
`xtrain_step1 <- mutate(xtrain, partition = as.factor("train"))`
`xtest_step1 <- mutate(xtest, partition = as.factor("test"))`
<br>

Here I combine the activity labels and subject IDs with their respective train and test measurement data sets.  I rename columns so they match between 'xtrain_step2' and 'xtest_step2', which seemed necessary in order for the subsequent rbind() to work
`xtrain_step2 <- cbind(subject = subject_train, activity = activity_xtrain[ , 2], xtrain_step1)`
`xtest_step2 <- cbind(subject = subject_test, activity = activity_xtest[ , 2], xtest_step1)`
<br>

Now that the training and test data sets have subject and activity names added to them, I can combine them into one data set
`xAll <- rbind(xtest_step2, xtrain_step2)`
<br>

This next line of code uses the descriptive variable names from the 'features' table to replace the default variable names in the measurement data that carried over when we combined the training and test data sets (i.e. V1, V2, V3) 
`names(xAll) <- c("subject", "activity", as.vector(features[,2]), "partition")`
<br>

Now I need to subset 'xAll' to "extract only the measurements on the mean and standard deviation for each measurement".  First I create a character vector with names of only those variables that contain the mean or standard deviation of a measurement.  I use grep to keep only variables whose names contain "mean(" or "std", in addition to subject and activity created above, as I will need those for the final step (step 5 in the instructions)
I intentionally exclude the following (R script requirement #2 was not specifc, so this is what I chose to do):
* variables with 'meanFreq' in the name
* angle(tBodyAccMean,gravity)
* angle(tBodyAccJerkMean),gravityMean)
* angle(tBodyGyroMean,gravityMean)
* angle(tBodyGyroJerkMean,gravityMean)
* angle(X,gravityMean)
* angle(Y,gravityMean)
* angle(Z,gravityMean)
`columns_keep <- grep ("subject|activity|mean\\(|std", names(xAll))`
<br>

I use the character vector of targeted variable names above ('columns_keep') to subset 'xAll' to only the variables needed for analysis.  xKeep represents the fully merged data sets, with lables provided, activity names, and subject ID, for only the variables of interest
`xKeep <- xAll[ ,columns_keep]`
<br>

Now I clean up xKeep variable names to make them more readable. I remove "-" character and parenthesis, change "std" to "StdDev" in an attempt to be more descriptive, and capitalize the "M" in "mean" for readability.  There is probably a more efficient way to do this (perhaps nesting grep functions?) but I opted for the following:
`namesClean1 <- gsub("mean\\(\\)", "Mean", names(xKeep))`
`namesClean2 <- gsub("std\\(\\)", "StdDev", namesClean1)`
`namesClean3 <- gsub("-", "", namesClean2)`
`names(xKeep) <- namesClean3`
<br><br>

### **Step 5 from the Instructions**
I create "a second, independent tidy data set with the average of each variable for each activity and each subject".  I utilize chaining for this task.  I struggled to get the output I wanted and found the 'summarize_each()' function through researching how to do what I wanted.  I interpreted "the average of each variable for each activity and each subject" to mean that we should group xKeep by both subject and activity, and then perform a mean on each measurement variable.
`tidyMeans <- xKeep %>% group_by(subject, activity) %>% summarize_each(funs(mean))`
<br>

Finally, I write tidyMeans to a txt file so I can upload to Coursera
`write.table(tidyMeans, file="./CourseProject_TidyMeans.txt", row.name=FALSE)`
