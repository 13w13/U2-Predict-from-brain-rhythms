library("FSinR")
library("data.table")
library("magrittr")
library("ggplot2")

X_test=fread("https://u2bigdataprojectpredictfrombraina-donotdelete-pr-keui4jukxng1lb.s3.eu.cloud-object-storage.appdomain.cloud/X_test.csv")
X_test$Id = X_test$Id - 1
str(X_test[,1:10])
X_test$Id<- as.factor(X_test$Id)
X_test$Channels<- as.factor(X_test$Channels)
X_test$Segments<- as.factor(X_test$Segments)

Obs = colnames(X_test[,-c(1:3)])
test_a<-copy(X_test)
test_fourier=X_test[, (Obs) := lapply(.SD, fft), .SDcols=Obs]
test_module <-test_fourier[, (Obs) := lapply(.SD, Mod), .SDcols=Obs]
test_module_scaled=test_module[, (Obs) := lapply(.SD, scale), .SDcols=Obs]

test_select=test_module_scaled[,c(2,3,7,8,9,10,382,383,501,502)]

prediction

pred_test=at$predict_newdata(test_select)

autoplot(pred_test$reponse)

pred=as.data.table(pred_test)

pred[,3]

final_predict=cbind(pred[,c(3,4,5)], test_module_scaled[,1])

head(final_predict)

final_pred_mean=final_predict[,list(Mean=mean(prob.0)),by=Id]

final_pred_mean$gender=ifelse(final_pred_mean$Mean>0.5,0,1)

final_pred_mean=final_pred_mean[,c(1,3)]

head(final_pred_mean)

final_pred_mean[,.N,by=gender]

getwd()

fwrite(final_pred_mean,"/mnt/batch/tasks/shared/LS_root/mounts/clusters/memoire/code/Users/a.settelen/Y_test.csv")
