library("data.table")
library("magrittr")
library("ggplot2")

X_test=fread("https://u2bigdataprojectpredictfrombraina-donotdelete-pr-keui4jukxng1lb.s3.eu.cloud-object-storage.appdomain.cloud/X_test.csv")

Y_train=fread("https://u2bigdataprojectpredictfrombraina-donotdelete-pr-keui4jukxng1lb.s3.eu.cloud-object-storage.appdomain.cloud/y_train.csv")
X_train=fread("https://u2bigdataprojectpredictfrombraina-donotdelete-pr-keui4jukxng1lb.s3.eu.cloud-object-storage.appdomain.cloud/X_train.csv")


X_train$Id = X_train$Id - 1 
X_test$Id = X_test$Id - 1

str(X_train[,1:10])
str(X_test[,1:10])

summary(X_train[,1:10])
summary(X_test[,1:10])

X_test$Id<- as.factor(X_test$Id)
X_test$Channels<- as.factor(X_test$Channels)
X_test$Segments<- as.factor(X_test$Segments)
X_train$Id<- as.factor(X_train$Id)
X_train$Channels<- as.factor(X_train$Channels)
X_train$Segments<- as.factor(X_train$Segments)


Y_train$id<-as.factor(Y_train$id)
Y_train$label<-as.factor(Y_train$label)


train=merge(X_train,Y_train, by.x = 'Id', by.y ='id',all=TRUE,no.dups=TRUE)

p1 <- ggplot(X_train[1:264880,c(1,4,2,3)],aes(x=Id,y=V1,colour=Channels))
p1 + geom_line(group=X_train$Segments)

p1 <- ggplot(X_train[1:264880,c(1,5,2,3)],aes(x=Id,y=V2,colour=Channels))
p1 + geom_line(group=X_train$Segments)

Obs = colnames(train[,-c(1:3,504)])


PlotDT = data.table::melt(train, id.vars = c(1,2,3,504), 
          measure.vars = Obs, 
          variable.name = "Obs",
          value.name = "Value")


Selectedid = c("1","2","3","4","5","6","7")
PlotDT[Channels=="1"& Segments=="1"] %>% 
   ggplot(aes(x = Obs, y = Value, group=Id)) +
   geom_line(aes(colour = `label`))


PlotDT[Channels=="2"& Segments=="1"] %>% 
   ggplot(aes(x = Obs, y = Value, group=Id)) +
   geom_line(aes(colour = `label`))

PlotDT[Channels=="3"& Segments=="1"] %>% 
   ggplot(aes(x = Obs, y = Value, group=Id)) +
   geom_line(aes(colour = `label`))


Selectedid = c("1","2")
PlotDT[Id %in%Selectedid & Channels=="1"& Segments=="1"] %>% 
   ggplot(aes(x = Obs, y = Value, group=Id)) +
   geom_line(aes(colour = `label`))

Selectedid = c("1","2")
PlotDT[Id %in%Selectedid & Channels=="2"& Segments=="1"] %>% 
   ggplot(aes(x = Obs, y = Value, group=Id)) +
   geom_line(aes(colour = `label`))

Selectedid = c("1","2")
PlotDT[Id %in%Selectedid & Channels=="1"& Segments=="2"] %>% 
   ggplot(aes(x = Obs, y = Value, group=Id)) +
   geom_line(aes(colour = `label`))


Selectedid = c("1","2","8","4")
PlotDT[Id %in%Selectedid & Channels=="1"& Segments=="2"] %>% 
   ggplot(aes(x = Obs, y = Value, group=Id)) +
   geom_line(aes(colour = `label`))


summary(Y_train[,-1])
prop.table(table(Y_train$label))

Y_train %>%
  ggplot(aes(label)) +
  geom_bar(fill = "red") +
  theme_minimal()


model_weights <- ifelse(Y_train$label == "0",
                        (1/table(Y_train$label)[1]) * 0.5,
                        (1/table(Y_train$label)[2]) * 0.5)

train_a<-copy(train)


train_fourier=train[, (Obs) := lapply(.SD, fft), .SDcols=Obs]
train_fourier[1,]


train_module <-train_fourier[, (Obs) := lapply(.SD, Mod), .SDcols=Obs]
train_module[1,]

train_module_scaled=train_module[, (Obs) := lapply(.SD, scale), .SDcols=Obs]

PlotDT = data.table::melt(train_module_scaled, id.vars = c(1,2,3,504), 
          measure.vars = Obs, 
          variable.name = "Obs",
          value.name = "Value")

s_id=1
PlotDT[Channels=="1"& Segments=="1" & Id %in% s_id] %>% 
   ggplot(aes(x = Obs, y = Value, group=Id)) +
   geom_line(aes(colour = `label`))


PlotDT[Channels=="1"& Segments=="1"] %>%
  ggplot(aes(x=Value)) +
  geom_density(fill = "red", bins = 1) +
  theme_minimal()

fwrite(train_module_scaled,"train_module_scaled.csv")
