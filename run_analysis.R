
############################################################
# Initalize environment 
############################################################

## Clear Objects from current working directory
rm(list = ls())

## load required packages
library(data.table)
library(dplyr)
library(stringr)


############################################################
# Load the Test Activity Labels and Feature from UCI HAR Dataset directory 
############################################################

dtActivityLabels <- fread("activity_labels.txt", header = FALSE)
setnames(dtActivityLabels,c("ActivityId", "Activity"))

dtFeatures <- fread("features.txt", header = FALSE)
dtFeatures[,V2:= make.names(V2)]

#reformat feature names

dtFeatures$V2 <- str_replace_all(dtFeatures$V2, "[[:punct:]]", "")
dtFeatures[,V2:= sub("std","Std",V2)]
dtFeatures[,V2:= sub("mean","Mean",V2)]
dtFeatures[,V2:= sub("angle","Angle",V2)]
dtFeatures[,V2:= sub("^t","Time",V2)]
dtFeatures[,V2:= sub("^f","Frequency",V2)]



############################################################
# Load the Test data from UCI HAR Dataset directory 
############################################################

dtSubjectTest <- fread("Test/subject_Test.txt", header = FALSE)
dfXTest <- read.table("Test/X_Test.txt"); dtXTest <- data.table(dfXTest)
dfYTest <- read.table("Test/y_Test.txt"); dtYTest <- data.table(dfYTest)


############################################################
# Format the Test data set
############################################################

## Set column names of data tables
setnames(dtXTest,dtFeatures[,V2])

# Filter data to return only mean and standard variation values
dtFilteredXTest <- cbind(select(dtXTest, contains("mean")),select(dtXTest, contains("std")))

# Combine dtSubjectTest and dtXTest, and label the first column "Subject"
dtCombinedTest <- cbind(dtSubjectTest, dtFilteredXTest)
setnames(dtCombinedTest,1,"Subject")

# Combine dtYTest and dtCombinedTest, and label the first column "ActivityId"
dtCombinedTest <- cbind(dtYTest, dtCombinedTest)
setnames(dtCombinedTest,1,"ActivityId")

# set key in dtCombinedTest and dtActivityLabels
setkey(dtCombinedTest, ActivityId)
setkey(dtActivityLabels, ActivityId)

# Replace Activity identifier with the activity name
dtLabelledCombinedTest <- merge(dtActivityLabels,dtCombinedTest)

# Remove ActivityId column as it is not required
dtLabelledCombinedTest <- select(dtLabelledCombinedTest, -ActivityId)

############################################################
# Load the Train data from UCI HAR Dataset directory 
############################################################

dtSubjectTrain <- fread("Train/subject_Train.txt", header = FALSE)
dfXTrain <- read.table("Train/X_Train.txt"); dtXTrain <- data.table(dfXTrain)
dfYTrain <- read.table("Train/y_Train.txt"); dtYTrain <- data.table(dfYTrain)

## Set column names of data tables
setnames(dtXTrain,dtFeatures[,V2])

############################################################
# Format the Train data set
############################################################

## Set column names of data tables
setnames(dtXTrain,dtFeatures[,V2])

# Filter data to return only mean and standard variation values
dtFilteredXTrain <- cbind(select(dtXTrain, contains("mean")),select(dtXTrain, contains("std")))

# Combine dtSubjectTrain and dtXTrain, and label the first column "Subject"
dtCombinedTrain <- cbind(dtSubjectTrain, dtFilteredXTrain)
setnames(dtCombinedTrain,1,"Subject")

# Combine dtYTrain and dtCombinedTrain, and label the first column "ActivityId"
dtCombinedTrain <- cbind(dtYTrain, dtCombinedTrain)
setnames(dtCombinedTrain,1,"ActivityId")

# set key in dtCombinedTrain and dtActivityLabels
setkey(dtCombinedTrain, ActivityId)
setkey(dtActivityLabels, ActivityId)

# Replace Activity identifier with the activity name
dtLabelledCombinedTrain <- merge(dtActivityLabels,dtCombinedTrain)

# Remove ActivityId column as it is not required
dtLabelledCombinedTrain <- select(dtLabelledCombinedTrain, -ActivityId)

############################################################
# Combine the Test and Train data sets
############################################################
dtCombinedVolunteerData <- rbind(dtLabelledCombinedTest,dtLabelledCombinedTrain)

# coerce Activity and Subject in Factors
dtCombinedVolunteerData$Activity <- as.factor(dtCombinedVolunteerData$Activity)
dtCombinedVolunteerData$Subject <- as.factor(dtCombinedVolunteerData$Subject)

############################################################
# Summarize the tidy data to give the average of each variable for each activity and each subject
############################################################
dtSummarizeData <- dtCombinedVolunteerData[, lapply(.SD, base::mean, na.rm=TRUE), by=c("Activity","Subject") ]

# write the result to the text file "SummarizedHARData.txt"
write.table(dtSummarizeData, file = "SummarizedHARData.txt", row.names = FALSE)

