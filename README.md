# Project: Cleaning data

## Files
* 'README.md'
* 'CodeBook.md': describes source data and analysis done to clean data
* 'run_analysis.R': analysis code to clean data

## Overview of analysis
* The code downloads (if not already present in the current directory) and unzips the source data files into a directory named 'UCI HAR Dataset'.
* It reads in the test and training data, along with files that label various aspects of the data, and combines the test and training data.
* It extracts only the features that represent the mean and standard deviation for each quantity measured.
* It creates a new tidy data set that takes the average of each feature for each activity and each subject (see CodeBook.md for details).
* This tidy data set is saved to the file dataMeans.txt in the current directory.
