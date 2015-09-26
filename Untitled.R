rm(list=ls())
dtFeatures <- fread("features.txt", header = FALSE)
dtFeatures[,V2:= make.names(V2)]

#reformat feature names

dtFeatures$V2 <- str_replace_all(dtFeatures$V2, "[[:punct:]]", "")
dtFeatures[,V2:= sub("std","Std",V2)]
dtFeatures[,V2:= sub("mean","Mean",V2)]
dtFeatures[,V2:= sub("^t","Time",V2)]
dtFeatures[,V2:= sub("^f","Frequency",V2)]