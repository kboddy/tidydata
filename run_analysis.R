# R version 3.1.2
library(dplyr)

# save data file (if it does not exist) and upzip it
fileLocal <- "activity.zip"
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
if(!file.exists(fileLocal)){
    download.file(fileURL,destfile=fileLocal,method="curl")
    unzip(fileLocal)
}

# read in labels that describe activity associated with each observation
actLabel <- read.table("./UCI HAR Dataset/activity_labels.txt",as.is=TRUE)[[2]]

# read in and clean up labels that describe features made in each observation
featLabelFull <- read.table("./UCI HAR Dataset/features.txt",as.is=TRUE)[[2]]
# note: non-alpha/numeric characters in featLabel are converted into periods
# when assigning these labels as column names of a data frame
featLabelClean <- gsub("\\(\\)","",featLabelFull)
featLabelClean <- gsub("-|,|\\(|\\)",".",featLabelClean)

# read in activity done for each measurement
actTest <- read.table("./UCI HAR Dataset/test/y_test.txt",
                      col.names=c("activity"))
actTrain <- read.table("./UCI HAR Dataset/train/y_train.txt",
                       col.names=c("activity"))

# read in subject ID for each measurement, range is [1,30]
subTest<-read.table("./UCI HAR Dataset/test/subject_test.txt",
                    col.names=c("id"))
subTrain<-read.table("./UCI HAR Dataset/train/subject_train.txt",
                     col.names=c("id"))

# read in measurements for features labeled by featLabel
featTestFull <- read.table("./UCI HAR Dataset/test/X_test.txt",
                           col.names=featLabelClean)
featTrainFull <- read.table("./UCI HAR Dataset/train/X_train.txt",
                            col.names=featLabelClean)

# keep only measurements of mean() or std()
featIdx <- grep("mean\\(\\)|std\\(\\)",featLabelFull)
featTest <- featTestFull[featIdx]
featTrain <- featTrainFull[featIdx]

# associate activity and subject ID to feature measurements of each observation
test <- cbind(subTest,actTest,featTest)
train <- cbind(subTrain,actTrain,featTrain)

# combine test and train data sets
data <- rbind(test,train)

# associate activity integer codes with descriptive names
# i.e. make activity into a factor variable
data$activity<-factor(data$activity,labels=actLabel)

# make subject id into a factor variable
data$id<-factor(data$id,labels="subject")

# split data by subject id and activity
dataSplit<-split(data,list(data$id,data$activity))

# take column means of each variable (for each subject and each activity)
dataMeans<-lapply(dataSplit, function(x) colMeans(x[,featLabelClean[featIdx]]))
dataMeans<-as.data.frame(t(as.data.frame(dataMeans)))

# reconstruct subject id and activity labels (convoluted from split)
dataMeansRowNames<-gsub("subject","",rownames(dataMeans))
dataMeansRowNamesSplit<-strsplit(dataMeansRowNames,"\\.")
dataMeansID<-as.integer(sapply(dataMeansRowNamesSplit,function(x) x[1]))
dataMeansAct<-sapply(dataMeansRowNamesSplit,function(x) x[2])

# add subject id and activity as explicit rows in data frame
dataMeans<-mutate(dataMeans,id=dataMeansID,activity=dataMeansAct)
dataMeans<-arrange(
    select(dataMeans,id,activity,tBodyAcc.mean.X:fBodyBodyGyroJerkMag.std),id)

# save to file
write.table(dataMeans,file="dataMeans.txt",row.names=FALSE)