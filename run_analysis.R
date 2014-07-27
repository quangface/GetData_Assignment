## read in features list

features <- read.table("UCI HAR Dataset/features.txt")

## look for only features that deal with mean or standard deviation

mean_search <- glob2rx("*mean()*")
sd_search <- glob2rx("*std()*")

mean_feat <- features[grep(mean_search, features$V2),]
sd_feat <- features[grep(sd_search, features$V2),]

## create data frame of the mean and standard deviation features

feat_df <- rbind(mean_feat, sd_feat)
feat_df <- feat_df[with(feat_df,order(V1)),]
f_col <- feat_df$V1

## read in test information
test_subject <- read.table("UCI HAR Dataset/test/subject_test.txt")
test_ytest <- read.table("UCI HAR Dataset/test/y_test.txt")
test_xtest <- read.table("UCI HAR Dataset/test/X_test.txt")

## new df with only relevant columns

new_xtest <- data.frame(1:nrow(test_xtest))
i <- 1
while(i <= length(f_col)) {
  new_xtest <- cbind(new_xtest, test_xtest[,f_col[i]])
  i <- i + 1
}
colnames(test_subject) <- "subject"
colnames(test_ytest) <- "activity"
colnames(new_xtest) <- c("uid", as.character(feat_df$V2))

## read in the train information
train_subject <- read.table("UCI HAR Dataset/train/subject_train.txt")
test_ytrain <- read.table("UCI HAR Dataset/train/y_train.txt")
test_xtrain <- read.table("UCI HAR Dataset/train/X_train.txt")

## new df with only relevant columns
new_xtrain <- data.frame(1:nrow(test_xtrain))
i <- 1
while(i <= length(f_col)) {
  new_xtrain <- cbind(new_xtrain, test_xtrain[,f_col[i]])
  i <- i + 1
}
colnames(train_subject) <- "subject"
colnames(test_ytrain) <- "activity"
colnames(new_xtrain) <- c("uid", as.character(feat_df$V2))


## create the final data frame
train_df <- cbind(train_subject, test_ytrain, new_xtrain)
test_df <- cbind(test_subject, test_ytest, new_xtest)

hwdf <- rbind(test_df, train_df)
hwdf <- subset(hwdf, select = -c(uid))

## read in activities labels

activities <- read.table("UCI HAR Dataset/activity_labels.txt")
activities$V2 <- as.character(activities$V2)
hwdf$activity <- as.character(hwdf$activity)

## replace activity numbers with names
i2 <- 1
while(i2 <= nrow(activities)) {
  hwdf$activity[hwdf$activity == as.character(i2)] <- activities$V2[i2]
  i2 <- i2 + 1
}

## get the average by subject and activity
hwdf2 <- aggregate(hwdf[3:68], by = list(hwdf$subject, hwdf$activity), FUN = mean)
colnames(hwdf2)[1:2] <- c("subject", "activity")

# write csv

write.table(hwdf2, "hw2_tidydata.txt", sep="\t")
