# Download files

if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")

# Unzip files
unzip(zipfile="./data/Dataset.zip",exdir="./data")

# Read in files that are relevant

activitylabelsdata = read.table("./data/UCI HAR Dataset/activity_labels.txt",header=FALSE)
featuresdata = read.table("./data/UCI HAR Dataset/features.txt",header=FALSE)

Xtestdata = read.table("./data/UCI HAR Dataset/Test/X_test.txt",header=FALSE)
Ytestdata = read.table("./data/UCI HAR Dataset/Test/Y_test.txt",header=FALSE)
subject_test = read.table("./data/UCI HAR Dataset/Test/subject_test.txt",header=FALSE)

Xtraindata = read.table("./data/UCI HAR Dataset/Train/X_train.txt",header=FALSE)
Ytraindata = read.table("./data/UCI HAR Dataset/Train/Y_train.txt",header=FALSE)
subject_train = read.table("./data/UCI HAR Dataset/Train/subject_train.txt",header=FALSE)

# Combine the test and training data

totalsubjectdata = rbind(subject_test,subject_train)
totalXdata = rbind(Xtestdata,Xtraindata)
totalYdata = rbind(Ytestdata,Ytraindata)

# Assign names to fields

names(totalsubjectdata)<-c("Subject")
names(totalYdata) = c("Activity")
names(totalXdata) = featuresdata$V2
names(activitylabelsdata) = c("Activity","ActivityDescription")

# Combine the different activities together

totaldata = cbind(totalXdata,totalYdata,totalsubjectdata)

# Extract only the mean and standard deviation for each dataset

# First determine the names with mean() or std(), (also keep Activity for merging on
# activity names and subject for summary by subject)

fieldnames = colnames(totaldata)
meanstdnames <-grepl("mean\\(\\)",fieldnames)|grepl("std\\(\\)", fieldnames)|grepl("Activity",fieldnames)|grepl("Subject",fieldnames)

# Subset to names with mean or std

meanandstddata = totaldata[,meanstdnames == TRUE]

# Merge on the activity description from the activity labels data

meanandstddata1 = merge(meanandstddata,activitylabelsdata,by="Activity",all.x=TRUE)

# Create labels for the dataset with appropriate variable names

names(meanandstddata1)<-gsub("^t","Time",names(meanandstddata1))
names(meanandstddata1)<-gsub("Acc","Acceleration",names(meanandstddata1))
names(meanandstddata1)<-gsub("^f","Frequency",names(meanandstddata1))
names(meanandstddata1)<-gsub("Gyro","Gyroscope",names(meanandstddata1))
names(meanandstddata1)<-gsub("Mag","Magnitude",names(meanandstddata1))

# Create a tidy dataset of the average of each variable for
# each activity and each subject

averagedata = aggregate(. ~ Activity + Subject, meanandstddata1, mean)
averagedata = averagedata[order(averagedata$Subject,averagedata$Activity),]
write.table(averagedata,"./data/Project Tidy Data Set.txt")

