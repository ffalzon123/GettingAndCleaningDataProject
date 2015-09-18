############################################################
# Write the tidy data set to the test file "GroupedTidyDataSet.txt"
############################################################

dtInput <- copy(dtCombinedVolunteerData)

dtSumarizeData <- dtInput[, lapply(.SD, base::mean, na.rm=TRUE), by=c("Activity","Subject") ]


write.table(dtSumarizeData, file = "TidyDataSet.txt", row.names = FALSE)