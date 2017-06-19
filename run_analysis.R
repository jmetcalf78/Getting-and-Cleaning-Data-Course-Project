## Load dplyr for use later in the program
library(dplyr)

## Download the file needed for the assigment, if it haven't already been downloaded
if(!file.exists("uci_har.zip")) {
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile="./uci_har.zip")
}

## Unzip the downloaded file to access individual data files
unzip("uci_har.zip")

# Write path names as variables to pass later into read.table statements
xtrain_path <- "./UCI HAR Dataset/train/X_train.txt"
ytrain_path <- "./UCI HAR Dataset/train/y_train.txt"
subject_train_path <- "./UCI HAR Dataset/train/subject_train.txt"
xtest_path <- "./UCI HAR Dataset/test/X_test.txt"
ytest_path <- "./UCI HAR Dataset/test/y_test.txt"
subject_test_path <- "./UCI HAR Dataset/test/subject_test.txt"
activity_labels_path <- "./UCI HAR Dataset/activity_labels.txt"
features_path <- "./UCI HAR Dataset/features.txt"

## Read the data into R
xtrain <- read.table(xtrain_path, header=FALSE, sep="")
ytrain <- read.table(ytrain_path, header=FALSE, sep="")
subject_train <- read.table(subject_train_path, header=FALSE, sep="")
xtest <- read.table(xtest_path, header=FALSE, sep="")
ytest <- read.table(ytest_path, header=FALSE, sep="")
subject_test <- read.table(subject_test_path, header=FALSE, sep="")
activity_labels <- read.table(activity_labels_path, header=FALSE, sep="")
features <- read.table(features_path, header=FALSE, sep="")

## Use chaining to 
##  1) add a flag to the measurement data so I can determine (if needed) whether the record came from the test or training set
##  2) add an index based on the row.names
##  3) sort by the new index so that I can cleanly combine these tables later using cbind
xtrain_1 <- xtrain %>%
  mutate(partition = as.factor("train"), match_index=as.numeric(row.names(xtrain))) %>%
  arrange(match_index)
ytrain_1 <- ytrain %>%
  mutate(match_index=as.numeric(row.names(ytrain))) %>%
  arrange(match_index)
subject_train_1 <- subject_train %>%
  mutate(match_index=as.numeric(row.names(subject_train))) %>%
  arrange(match_index)
xtest_1 <- xtest %>%
  mutate(partition = as.factor("test"), match_index=as.numeric(row.names(xtest))) %>%
  arrange(match_index)
ytest_1 <- ytest %>%
  mutate(match_index=as.numeric(row.names(ytest))) %>%
  arrange(match_index)
subject_test_1 <- subject_test %>%
  mutate(match_index=as.numeric(row.names(subject_test))) %>%
  arrange(match_index)

## Assign descriptive column names to the data sets
names(xtrain_1) <- c(as.vector(features[,2]), "partition", "match_index")
names(ytrain_1) <- c("activity_code", "match_index")
names(subject_train_1) <- c("subject_id", "match_index")
names(xtest_1) <- c(as.vector(features[,2]), "partition", "match_index")
names(ytest_1) <- c("activity_code", "match_index")
names(subject_test_1) <- c("subject_id", "match_index")
names(activity_labels) <- c("activity_code", "activity")

## For both the test and training measurement data sets, I use cbind to effectively add a subject identifier and an activity identifier
xtrain_2 <- cbind(xtrain_1, "subject_id"=subject_train_1[ ,"subject_id"], "activity_code"=ytrain_1[ ,"activity_code"])
xtest_2 <- cbind(xtest_1, "subject_id"=subject_test_1[ ,"subject_id"], "activity_code"=ytest_1[,"activity_code"])

## Use merge to bring activity labels into the measurement data 
## This does generate a warning, and I've determined that this warning can be dismissed
xtrain_3 <- merge(xtrain_2, activity_labels, by.x="activity_code", by.y ="activity_code")
xtest_3 <- merge(xtest_2, activity_labels, by.x="activity_code", by.y ="activity_code")

## Combine the test and training measurement data sets
xAll <- rbind(xtest_3, xtrain_3)

## Create a vector to use to subset the combined measurement data to only those columns targeted for this assignment
columns_keep <- c("subject_id","activity", grep ("mean\\(|std", names(xAll),value=TRUE))

## Use the above vector of column names to subset those of interest
xKeep <- xAll[ ,columns_keep]

##  Clean names in xKeep for readability
namesClean1 <- gsub("mean\\(\\)", "Mean", names(xKeep)) 
namesClean2 <- gsub("std\\(\\)", "StdDev", namesClean1) 
namesClean3 <- gsub("-", "", namesClean2)
names(xKeep) <- namesClean3

## Create the "tidy data set that"second, independent tidy data set with the average of each variable for each activity abd each subject" 
tidyMeans <- xKeep %>% group_by(subject_id, activity) %>% summarize_all(funs(mean))

## Write tidyMeans to a text file for uploading to Coursera
write.table(tidyMeans, file="./CourseProject_TidyMeans.txt", row.name=FALSE)