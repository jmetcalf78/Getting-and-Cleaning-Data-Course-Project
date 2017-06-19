# **Getting and Cleaning Data  - Course Project**
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

## **The Script, Explained**

load dplyr for later use in the program

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`library(dplyr)`
<br>

### **Getting the data**
Download the file to be used for this project, if it hasn't been downloaded yet

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`if(!file.exists("uci_har.zip")) {`
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile="./uci_har.zip")`
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`  }`

Unzip the downloaded file to access individual data files. The unzipped file was actually a directory called UCI HAR Dataset, containing subdirectories and multiple data files

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`unzip("uci_har.zip")`
<br><br>

### **Reading the Data**
A course mentor suggests we do not need the 'Inertial Signals' data files for this assignment:
<https://thoughtfulbloke.wordpress.com/2015/09/09/getting-and-cleaning-the-assignment/>

Step 1) Assign file paths to variables so I can call these variables in a series of subsequent `read.table()` commands.
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`xtrain_path <- "./UCI HAR Dataset/train/X_train.txt"`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`ytrain_path <- "./UCI HAR Dataset/train/y_train.txt"`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`subject_train_path <- "./UCI HAR Dataset/train/subject_train.txt"`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`xtest_path <- "./UCI HAR Dataset/test/X_test.txt"`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`ytest_path <- "./UCI HAR Dataset/test/y_test.txt"`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`subject_test_path <- "./UCI HAR Dataset/test/subject_test.txt"`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`activity_labels_path <- "./UCI HAR Dataset/activity_labels.txt"`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`features_path <- "./UCI HAR Dataset/features.txt"`
<br>

A description of the files being loaded for this assignment:
* 'X_train.txt' and 'X_test.txt' are the measurement data files.

* 'y_train.txt' and 'y_test.txt' provide what amounts to "activity codes" which will help us link each observation in the measurement data to an activity description (i.e. walking, laying, sitting, etc.).  I made this assumption because the subject files have the same number of records in them as their corresponding measurement data files, and they contain 6 unique values (integers 1-6) which seems to line up with the 6 activities provided in the activity labels file.

* 'subject_test.txt' and 'subject_train.txt' provide and ID to help us link each observation in the measurement data to an individual study participant.

* 'activity_labels.txt' provides descriptive names of activities that we can join to the measurement data via the 'y_test.txt' and 'y_train.txt' tables.  The y tables are our "crosswalks" to map activity labels to each observation in the measurement data.

* 'features.txt' provides descriptive names of the variables residing in 'x_test.txt' and 'x_train.txt'.
<br><br>

Step 2) Read the data into R. While the data appeared to be single space delimted, it in fact had more than one space in between some columns.  Using sep="" let's R know that any length of white space is to be interpreted as the column delimiter.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`xtrain <- read.table(xtrain_path, header=FALSE, sep="")`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`ytrain <- read.table(ytrain_path, header=FALSE, sep="")`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`subject_train <- read.table(subject_train_path, header=FALSE, sep="")`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`xtest <- read.table(xtest_path, header=FALSE, sep="")`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`ytest <- read.table(ytest_path, header=FALSE, sep="")`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`subject_test <- read.table(subject_test_path, header=FALSE, sep="")`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`activity_labels <- read.table(activity_labels_path, header=FALSE, sep="")`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`features <- read.table(features_path, header=FALSE, sep="")`
<br><br>

### **Cleaning/Preparing/Tidying the Data**
First, I use chaining to

  1) add a flag to the measurement data so I can determine (if needed) whether the record came from the test or training set
  
  2) add a "match" index to each table, derived from the row.names
  
  3) sort by the new index so that I can cleanly combine these tables later using `cbind()`. I experienced issues with `cbind()` when I did not sort, where the columns bound without error but row numbers from the measurement data were not aligning with row numbers from the subject or y table (activity) data.  
  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`xtrain_1 <- xtrain %>%`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`mutate(partition = as.factor("train"), match_index=as.numeric(row.names(xtrain))) %>%`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`arrange(match_index)`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`ytrain_1 <- ytrain %>%`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`mutate(match_index=as.numeric(row.names(ytrain))) %>%`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`arrange(match_index)`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`subject_train_1 <- subject_train %>%`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`mutate(match_index=as.numeric(row.names(subject_train))) %>%`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`arrange(match_index)`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`xtest_1 <- xtest %>%`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`mutate(partition = as.factor("test"), match_index=as.numeric(row.names(xtest))) %>%`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`arrange(match_index)`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`ytest_1 <- ytest %>%`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`mutate(match_index=as.numeric(row.names(ytest))) %>%`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`arrange(match_index)`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`subject_test_1 <- subject_test %>%`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`mutate(match_index=as.numeric(row.names(subject_test))) %>%`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`arrange(match_index)`
<br><br>

I then assign descriptive column names to the data sets.  The names for the measurement variables are sourced from the features data set.
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`names(xtrain_1) <- c(as.vector(features[,2]), "partition", "match_index")`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`names(ytrain_1) <- c("activity_code", "match_index")`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`names(subject_train_1) <- c("subject_id", "match_index")`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`names(xtest_1) <- c(as.vector(features[,2]), "partition", "match_index")`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`names(ytest_1) <- c("activity_code", "match_index")`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`names(subject_test_1) <- c("subject_id", "match_index")`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`names(activity_labels) <- c("activity_code", "activity")`
<br>

For both the test and training measurement data sets, I use `cbind()` to effectively add a subject identifier and an activity identifier to each observation.  These results were not as expected when I performed this without sort our 'match_index' from the contributing tables.
I use subsetting to only take the columns of interest from the subject and y tables.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`xtrain_2 <- cbind(xtrain_1, "subject_id"=subject_train_1[ ,"subject_id"], "activity_code"=ytrain_1[ ,"activity_code"])`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`xtest_2 <- cbind(xtest_1, "subject_id"=subject_test_1[ ,"subject_id"], "activity_code"=ytest_1[,"activity_code"])`
<br>

Next, I use `merge()` to bring activity labels into the measurement data 
This generates a warning about duplicates. I ran several tests to determine that this warning can be dismissed and the results did not contain any duplication.
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`xtrain_3 <- merge(xtrain_2, activity_labels, by.x="activity_code", by.y ="activity_code")`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`xtest_3 <- merge(xtest_2, activity_labels, by.x="activity_code", by.y ="activity_code")`
<br><br>

Now that the training and test data sets have subject and activity names added to them, I can combine them into one data set.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`xAll <- rbind(xtest_3, xtrain_3)`
<br><br>

Next, I need to subset 'xAll' to "extract only the measurements on the mean and standard deviation for each measurement".  First I create a character vector with names of only those variables that contain the mean or standard deviation of a measurement.  I use `grep()` to keep only variables whose names contain "mean(" or "std", in addition to subject and activity created above, as I will need those for the final step (step 5 in the instructions).

I intentionally exclude the following (R script requirement #2 was not specifc, so this is what I chose to do):

* variables with 'meanFreq' in the name

* angle(tBodyAccMean,gravity)

* angle(tBodyAccJerkMean),gravityMean)

* angle(tBodyGyroMean,gravityMean)

* angle(tBodyGyroJerkMean,gravityMean)

* angle(X,gravityMean)

* angle(Y,gravityMean)

* angle(Z,gravityMean)
<br>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`columns_keep <- c("subject_id","activity", grep ("mean\\(|std", names(xAll),value=TRUE))`
<br><br>

I use the character vector of targeted variable names above ('columns_keep') to subset 'xAll' to only the variables needed for analysis.  xKeep represents the fully merged data sets, with lables provided, activity descriptions, and subject ID, for only the variables of interest.
<br>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`xKeep <- xAll[ ,columns_keep]`
<br><br>

Now I clean up xKeep variable names to make them more readable. I remove "-" and parenthesis, change "std" to "StdDev" in an attempt to be more descriptive, and capitalize the "M" in "mean" for readability. The escape "\\" tells R to treat the character following the "\\" as test and not as a metacharacter.
<br>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`namesClean1 <- gsub("mean\\(\\)", "Mean", names(xKeep))`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`namesClean2 <- gsub("std\\(\\)", "StdDev", namesClean1)`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`namesClean3 <- gsub("-", "", namesClean2)`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`names(xKeep) <- namesClean3`
<br><br>

### **Step 5 - The Tidy Dataset**
I create "a second, independent tidy data set with the average of each variable for each activity and each subject".  I utilize chaining for this task.  I struggled to get the output I wanted and found the 'summarize_all()' function through researching how to do what I wanted.  I interpreted "the average of each variable for each activity and each subject" to mean that we should group xKeep by both subject and activity, and then perform a mean on each measurement variable.
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`tidyMeans <- xKeep %>% group_by(subject_id, activity) %>% summarize_all(funs(mean))`
<br>

tidyMeans is a "tidy" dataset, meaning that it satisfies the following three criteria:

1) Each variable forms a column
2) Each observation forms a 
3) Each type of observational unit forms a table
<br>

Finally, I write tidyMeans to a txt file so I can upload to Coursera

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`write.table(tidyMeans, file="./CourseProject_TidyMeans.txt", row.name=FALSE)`
<br>

The tidyMeans table has 180 observations and 68 variables.  Each observation represents a unique grouping of subject and activity. (30 subjects) x (6 activities) = 180 observations. Each variable represents one of the subset of variables of interest from the measurement data. The values represent the mean of those variables of interest (those that were means or standard devfiations of some vector of measurement values).
