## This script is designed soley for execution.  
## For complete explanation and comments about of the following code, please refer to my README.md file residing 
## on the github repo I created for this project:
## https://github.com/jmetcalf78/Getting-and-Cleaning-Data-Course-Project/blob/master/README.md

library(dplyr)

if(!file.exists("uci_har.zip")) {
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile="./uci_har.zip")
  }
 
unzip("uci_har.zip")

xtrain_path <- "./UCI HAR Dataset/train/X_train.txt"
ytrain_path <- "./UCI HAR Dataset/train/y_train.txt"
subject_train_path <- "./UCI HAR Dataset/train/subject_train.txt"
xtest_path <- "./UCI HAR Dataset/test/X_test.txt"
ytest_path <- "./UCI HAR Dataset/test/y_test.txt"
subject_test_path <- "./UCI HAR Dataset/test/subject_test.txt"
activity_labels_path <- "./UCI HAR Dataset/activity_labels.txt"
features_path <- "./UCI HAR Dataset/features.txt"

xtrain <- read.table(xtrain_path, header=FALSE, sep="")
ytrain <- read.table(ytrain_path, header=FALSE, sep="")
subject_train <- read.table(subject_train_path, header=FALSE, sep="")
xtest <- read.table(xtest_path, header=FALSE, sep="")
ytest <- read.table(ytest_path, header=FALSE, sep="")
subject_test <- read.table(subject_test_path, header=FALSE, sep="")
activity_labels <- read.table(activity_labels_path, header=FALSE, sep="")
features <- read.table(features_path, header=FALSE, sep="")

activity_xtrain <- merge(activity_labels, ytrain)
activity_xtest <- merge(activity_labels, ytest)

xtrain_step1 <- mutate(xtrain, partition = as.factor("train"))
xtest_step1 <- mutate(xtest, partition = as.factor("test"))

xtrain_step2 <- cbind(subject = subject_train, activity = activity_xtrain[ , 2], xtrain_step1)
xtest_step2 <- cbind(subject = subject_test, activity = activity_xtest[ , 2], xtest_step1)

xAll <- rbind(xtest_step2, xtrain_step2)

names(xAll) <- c("subject", "activity", as.vector(features[,2]), "partition")

columns_keep <- grep ("subject|activity|mean\\(|std", names(xAll))

xKeep <- xAll[ ,columns_keep]

namesClean1 <- gsub("mean\\(\\)", "Mean", names(xKeep)) 
namesClean2 <- gsub("std\\(\\)", "StdDev", namesClean1) 
namesClean3 <- gsub("-", "", namesClean2)
names(xKeep) <- namesClean3

tidyMeans <- xKeep %>% group_by(subject, activity) %>% summarize_each(funs(mean))

write.table(tidyMeans, file="./CourseProject_TidyMeans.txt", row.name=FALSE)



