## Set working directory
setwd("C:/Users/ouelletva/Documents/GettingCleaningData_Project/UCI HAR Dataset/")

#################################################################
##1.Merges the training and the test sets to create one data set.

##A.Read in the data from files into the main, train and test folder
features = read.table('./features.txt',header=FALSE)
activityType = read.table('./activity_labels.txt',header=FALSE)
subjectTrain = read.table('./train/subject_train.txt',header=FALSE)
xTrain = read.table('./train/x_train.txt',header=FALSE)
yTrain = read.table('./train/y_train.txt',header=FALSE)
subjectTest = read.table('./test/subject_test.txt',header=FALSE)
xTest = read.table('./test/x_test.txt',header=FALSE)
yTest = read.table('./test/y_test.txt',header=FALSE)

##B.Assign names to each column of the dataset
colnames(activityType) = c('activityId','activityType')
colnames(subjectTrain) = "subjectId"
colnames(xTrain) = features[,2] 
colnames(yTrain) = "activityId"
colnames(subjectTest) = "subjectId"
colnames(xTest) = features[,2] 
colnames(yTest) = "activityId"

##C.Merge A) the three subsets: yTrain, subjectTrain, and xTrain and B) the three test subsets: xTest, yTest and subjectTest data
trainingData = cbind(yTrain,subjectTrain,xTrain)
testData = cbind(yTest,subjectTest,xTest)

##D.Combine the data set created en C and D to get the final data set
finalData = rbind(trainingData,testData)

##E.Create a vector for the column names from the finalData, which will be used in step 2 for the mean and standard deviation
colNames = colnames(finalData)


###########################################################################################
##2.Extracts only the measurements on the mean and standard deviation for each measurement.  

##A.Create a logicalVector that contains TRUE values for requieres info: ID, mean() & stddev() columns and FALSE for rest
logicalVector = (grepl("activity..",colNames) | grepl("subject..",colNames) | grepl("-mean..",colNames) & !grepl("-meanFreq..",colNames) & !grepl("mean..-",colNames) | grepl("-std..",colNames) & !grepl("-std()..-",colNames))

##B.Subset finalData table created in 1D using the logicalVector
finalData = finalData[logicalVector==TRUE]


###########################################################################
##3.Uses descriptive activity names to name the activities in the data set.

##A.Merge the finalData updated in 2B with the acitivityType table to include the activity names
finalData = merge(finalData,activityType,by='activityId',all.x=TRUE)

##B.Update the colNames vector to include the new info about activity
colNames = colnames(finalData) 


######################################################################
##4.Appropriately labels the data set with descriptive variable names. 

##A.Clean up the variable names
for (i in 1:length(colNames)) 
{
        colNames[i] = gsub("\\()","",colNames[i])
        colNames[i] = gsub("-std$","StdDev",colNames[i])
        colNames[i] = gsub("-mean","Mean",colNames[i])
        colNames[i] = gsub("^(t)","time",colNames[i])
        colNames[i] = gsub("^(f)","freq",colNames[i])
        colNames[i] = gsub("([Gg]ravity)","Gravity",colNames[i])
        colNames[i] = gsub("([Bb]ody[Bb]ody|[Bb]ody)","Body",colNames[i])
        colNames[i] = gsub("[Gg]yro","Gyro",colNames[i])
        colNames[i] = gsub("AccMag","AccMagnitude",colNames[i])
        colNames[i] = gsub("([Bb]odyaccjerkmag)","BodyAccJerkMagnitude",colNames[i])
        colNames[i] = gsub("JerkMag","JerkMagnitude",colNames[i])
        colNames[i] = gsub("GyroMag","GyroMagnitude",colNames[i])
}

##B.Use vector created in 3B to assign the new column names
colnames(finalData) = colNames


##################################################################################################################################################
##5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

##A.Create tidy data set with the average of each variable
finalData_2 = finalData[,names(finalData) != 'activityType']
tidyData = aggregate(finalData_2[,names(finalData_2) != c('activityId','subjectId')],by=list(activityId=finalData_2$activityId,subjectId = finalData_2$subjectId),mean)

##B.Merge the tidy data set with activity type to data for each activity/subject
tidyData = merge(tidyData,activityType,by='activityId',all.x=TRUE)

##C.Write the tidy data set into folder
write.table(tidyData, './tidyData.txt',row.names=TRUE,sep='\t')