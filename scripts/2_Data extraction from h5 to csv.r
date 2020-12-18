library(magrittr)
library(data.table)
#install.packages("BiocManager")
library(BiocManager)
#BiocManager::install(c("rhdf5"))
library(rhdf5)

x_train=H5Fopen("X_train_new.h5")
View(x_train$features[,,1,1]) #(500, 7, 40, 946)
x_train.new <- aperm(x_train$features, c(4,2,1,3)) #(946, 7, 500, 40)
View(x_train.new[946,1,1,1]) #(946, 7, 500, 40)

df_aux <- data.table(matrix(ncol=3, nrow= 1))
df_aux[,1] = 1
df_aux[,2] = 1
df_aux[,3] = 1
df_aux = cbind(df_aux, t(x_train.new[1,1,,1]))

df <- df_aux

c=0
for (i in 1:946) {
  for(j in 1:7) {
    for(k in 1:40) {
       df_aux <- data.table(matrix(ncol=3, nrow= 1))
       df_aux[,1] = i
       df_aux[,2] = j
       df_aux[,3] = k
       
       df_aux = cbind(df_aux, t(x_train.new[i,j,,k]))
       ###valeurs 
       df = rbind(df, df_aux)
       
       c=c+1
       
       print(c)
    }
  }

fwrite(df,"X_train.csv")

x_test=H5Fopen("X_test_new.h5")
View(x_test$features[,,1,1]) #(500, 7, 40, 946)
x_test.new <- aperm(x_test$features, c(4,2,1,3)) #(946, 7, 500, 40)
View(x_test[946,1,1,1]) #(946, 7, 500, 40)
df_aux <- data.table(matrix(ncol=3, nrow= 1))
df_aux[,1] = 1
df_aux[,2] = 1
df_aux[,3] = 1
df_aux = cbind(df_aux, t(x_train.new[1,1,,1]))

df <- df_aux
c=0
for (i in 1:946) {
  for(j in 1:7) {
    for(k in 1:40) {
       df_aux <- data.table(matrix(ncol=3, nrow= 1))
       df_aux[,1] = i
       df_aux[,2] = j
       df_aux[,3] = k
       
       df_aux = cbind(df_aux, t(x_train.new[i,j,,k]))
       ###valeurs 
       df = rbind(df, df_aux)
       
       c=c+1
       
       print(c)
    }
  }
fwrite(df,"X_test.csv")

X_train=fread("X_train.csv")
X_train<-X_train[-1,]
X_train[1,]

setnames(X_train, "V1", "Idligne")
setnames(X_train, "V1", "Id")
setnames(X_train, "V2", "Channels")
setnames(X_train, "V3", "Segments")


x_train_h5=H5Fopen("X_train_new.h5")
x_train_h5 <- aperm(x_train_h5$features, c(4,2,1,3)) #(946, 7, 500, 40)


h5closeAll()

First ID check, 1st channel, 1 st Segment

(X_train[1,])
View(x_train_h5[1,1,,1])


Ok

(X_train[3,])
View(x_train_h5[1,1,,2])

(X_train[X_train$Channel==1 & X_train$Segments==1 & X_train$Id==1])


X_train<-X_train[-c(1:9389),]
X_train<-X_train[,-1]

X_test=fread("X_test_new.csv")
X_test[1:4,]


X_test<-X_test[-c(1,2),]#Remove first and second line
X_test[1,]
setnames(X_test, "V1", "Id")
setnames(X_test, "V2", "Channels")
setnames(X_test, "V3", "Segments")



x_test_h5=H5Fopen("X_test_new.h5")


x_test_h5 <- aperm(x_test_h5$features, c(4,2,1,3)) #(946, 7, 500, 40)


h5closeAll()


h5ls("X_train_new.h5", all=TRUE)


First ID check, 1st channel, 1 st Segment


(X_test[1,])
View(x_test_h5[1,1,,1])

Ok ! 

(X_test[X_test$Channel==2 & X_test$Segments==2 & X_test$Id==1])
View(x_test_h5[1,2,,2])

but OK ! 

fwrite(X_test,"X_test_clean")
fwrite(X_train,"X_train_clean")
