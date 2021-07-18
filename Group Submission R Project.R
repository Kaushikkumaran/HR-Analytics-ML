# Importing Libraries and Setting up Workspace
library(dplyr)
library(kknn)
library(randomForest)
getwd()

# Reading the files
HR_Data_Train_Set <- read.csv('~/Downloads/aug_train.csv') #Train Data
HR_Data_Test_Set <- read.csv('~/Downloads/aug_test.csv') #Test Data

# Data Quality Checks
summary(HR_Data_Train_Set)
HR_Data_Train_Set %>%
  summarise_all(funs(sum(is.na(.)))) #Many values as blanks but not null as such

# Checking the dependent variable
HR_Data_Train_Set %>%
  count(target)   #24% target is 1

# Building a Boosting model

train=HR_Data_Train_Set[1:(nrow(HR_Data_Train_Set)/2),]
test=HR_Data_Train_Set[9580:nrow(HR_Data_Train_Set),]

names <- c('city', 'gender', 'relevent_experience', 'enrolled_university',
           'education_level','major_discipline','company_type','experience',
           'company_size','last_new_job')
train[,names] <- lapply(train[,names] , factor)
test[,names] <- lapply(test[,names] , factor)

##
set.seed(1)
boost.caravan = gbm(target~. ,data=train, 
                    distribution="bernoulli",n.trees =1000 ,shrinkage = 0.01,
                    interaction.depth =4)
yhat.boost=predict(boost.caravan ,newdata =test,
                   n.trees =5000, type = "response")
predicted_class <- yhat.boost > 0.2
a <- table(predicted_class, test$target)
a
test <- test %>%
  mutate(target1 = ifelse(target == 0,FALSE,TRUE))
confusionMatrix(factor(predicted_class), factor(test$target1))









##########
# Splitting for test in the train set itself
#train = HR_Data_Train_Set[1:13410,]
#test = HR_Data_Train_Set[13411:19158,]

# For later reference
#full.model <- lm(target ~., data = HR_Data_Train_Set)
#step_model <- stepAIC(full.model, direction = "both", 
#                      trace = FALSE)
#step_model$coefficients


# Building a Knn model 
HR_Data_Train_Set_scaled = 
  HR_Data_Train_Set %>%
  mutate_if(is.numeric, scale)

train = HR_Data_Train_Set_scaled
test = HR_Data_Train_Set_scaled

n = dim(HR_Data_Train_Set_scaled)[1]
kcv = 10
n0 = round(n/kcv,0)

out_MSE = matrix(0,kcv,100)

used = NULL
set = 1:n

for(j in 1:kcv){
  
  if(n0<length(set)){val = sample(set,n0)}
  if(n0>=length(set)){val=set}
  
  train_i = train[-val,]
  test_i = test[val,]
  
  near = kknn(target~.,train_i,test_i,k=5,kernel = "rectangular")
  for(i in 1:100){
    print('a')
    near = kknn(target~.,train_i,test_i,k=i,kernel = "rectangular")
    print('b')
    aux = mean((test[,1]-near$fitted)^2)
    
    out_MSE[j,i] = aux
  }
  
  used = union(used,val)
  set = (1:n)[-used]
  
  cat(j,'\n')
}

mMSE = apply(out_MSE,2,mean)
par(mfrow=c(1,1))
plot(log(1/(1:100)),sqrt(mMSE),type="l",ylab="out-of-sample RMSE",col=4,lwd=2,main="HR Predictions",xlab="Complexity")
best = which.min(mMSE)
text(log(1/best),sqrt(mMSE[best])+0.01,paste("k=",best))
text(log(1/100)+0.4,sqrt(mMSE[100]),"k=100")
text(log(1/1),sqrt(mMSE[1])+0.001,"k=1")

train = HR_Data_Train_Set[10:13410,]
test = HR_Data_Train_Set[13411:19155,]
near = kknn(target~.,train,test,k=5,kernel = "rectangular")
aux = mean((test_i[,1]-near$fitted)^2)
out_MSE[j,i] = aux
mMSE = apply(out_MSE,2,mean)
