# Importing the necessary libraries
library(dplyr)
library(ggplot2)
library(randomForest)
library(ggcorrplot)

#Reading the raw Dataset
HR_Data <- read.csv('~/Downloads/aug_train.csv') #Data

summary(HR_Data)
colnames(HR_Data)[5] <- "relevant_experience"

# Data Quality Checks
HR_Data %>%
  summarise_all(funs(sum(is.na(.)))) #values are blanks but not null as such

# Checking the dependent variable
HR_Data %>%
  count(target)   #24% target is 1
ggplot(HR_Data, aes(x = factor(target))) + geom_bar() +
  geom_text(aes(label = ..count..), stat = "count", vjust = 1.5, colour = "white")
#Therefore we might not need to resample the dataset

sapply(HR_Data, n_distinct)
#Exploring unique values for few variables

#Univariaete Analysis
ggplot(HR_Data, aes(x = factor(relevant_experience))) + geom_bar() +
  geom_text(aes(label = ..count..), stat = "count", vjust = 1.5, colour = "white")

ggplot(HR_Data, aes(x = factor(enrolled_university))) + geom_bar() +
  geom_text(aes(label = ..count..), stat = "count", vjust = 1.5, colour = "white")

ggplot(HR_Data, aes(x = factor(education_level))) + geom_bar() +
  geom_text(aes(label = ..count..), stat = "count", vjust = 1.5, colour = "white")

ggplot(HR_Data, aes(x = factor(gender))) + geom_bar() +
  geom_text(aes(label = ..count..), stat = "count", vjust = 1.5, colour = "white")

ggplot(HR_Data, aes(x = factor(company_type))) + geom_bar() +
  geom_text(aes(label = ..count..), stat = "count", vjust = 1.5, colour = "white")

ggplot(HR_Data, aes(x = factor(last_new_job))) + geom_bar() +
  geom_text(aes(label = ..count..), stat = "count", vjust = 1.5, colour = "white")

ggplot(HR_Data, aes(x = factor(major_discipline))) + geom_bar() +
  geom_text(aes(label = ..count..), stat = "count", vjust = 1.5, colour = "white")

#Bivariate Analysis

ggplot(HR_Data, aes(x = factor(relevant_experience))) +
  geom_bar(aes(fill = factor(target)),position="dodge") +
  geom_text(aes(label = ..count..), stat = "count", vjust = 1.5, colour = "black") 

ggplot(HR_Data, aes(x = factor(enrolled_university))) +
  geom_bar(aes(fill = factor(target)),position="dodge") +
  geom_text(aes(label = ..count..), stat = "count", vjust = 1.5, colour = "black")

ggplot(HR_Data, aes(x = factor(education_level))) +
  geom_bar(aes(fill = factor(target)),position="dodge") +
  geom_text(aes(label = ..count..), stat = "count", vjust = 1.5, colour = "black")

#Correlation
HR_Data1 <- as.data.frame(lapply(HR_Data, as.numeric))
corr <- round(cor(HR_Data1), 1)
ggcorrplot(
  corr,
  hc.order = TRUE,
  type = "lower",
  outline.color = "white",
  ggtheme = ggplot2::theme_gray,
  colors = c("#6D9EC1", "white", "#E46726")
)
ggcorrplot(corr,lab = TRUE)

#Data Cleaning and Transformation
names <- c('city', 'gender', 'relevant_experience', 'enrolled_university',
           'education_level','major_discipline','company_type','experience',
           'company_size','last_new_job')
HR_Data[, names][HR_Data[, names] == ''] <- "Missing"
HR_Data[,names] <- lapply(HR_Data[,names] , factor)

# Model tested with all features and subset of features

#All features
smp_size <- floor(0.75 * nrow(HR_Data))
set.seed(111)
train_index <- sample(seq_len(nrow(HR_Data)), size = smp_size)
train <- HR_Data[train_index, ]
test <- HR_Data[-train_index, ]

set.seed(1)
boost.HR = gbm(target~.-enrollee_id ,data=train, 
                    distribution="bernoulli",n.trees =1000 ,shrinkage = 0.01,
                    interaction.depth =4)
summary(boost.HR)
yhat.boost=predict(boost.HR ,newdata =test,
                   n.trees =1000, type = "response")
predicted_class <- yhat.boost > 0.45
a <- table(predicted_class, test$target)
a
test <- test %>%
  mutate(target1 = ifelse(target == 0,FALSE,TRUE))
confusionMatrix(factor(predicted_class), factor(test$target1))

#Running model on subset of features
imp_features_for_the_model <- c('city','company_size','experience','education_level',
                                'company_type','last_new_job')
formula_for_model = as.formula(paste("target ~ ", paste(imp_features_for_the_model, collapse= "+")))
#boost.HR = gbm(formula_for_model ,data=train, 
#               distribution="bernoulli",n.trees =1000 ,shrinkage = 0.01,
#               interaction.depth =4)
boost_HR_cv = gbm(formula_for_model, data=train, 
                  distribution="bernoulli",n.trees =5000 ,shrinkage = 0.001,
                  interaction.depth =3, cv.folds = 10)
summary(boost_HR_cv)
yhat.boost=predict(boost_HR_cv ,newdata =test,
                   n.trees =5000, type = "response")
predicted_class <- yhat.boost > 0.45
a <- table(predicted_class, test$target)
a
test <- test %>%
  mutate(target1 = ifelse(target == 0,FALSE,TRUE))
confusionMatrix(factor(predicted_class), factor(test$target1))

#Ridge
grid =10^ seq (10,-2, length =100)
x <-model.matrix(formula_for_model,HR_Data)
y <- HR_Data$target
set.seed (1)
train=sample (1: nrow(x), nrow(x)/1.3333)
test=(-train )
y.test=y[test]
ridge.mod =glmnet(x[train ,],y[train],alpha =0, lambda =grid ,
                  thresh =1e-12, family = 'binomial')
set.seed(1)
cv_ridge_model =cv.glmnet(x[train,],y[train],alpha =0,family = 'binomial')
plot(cv_ridge_model)
bestlam =cv_ridge_model$lambda.min
bestlam #0.0172
ridge.pred=predict (ridge.mod ,s=bestlam ,newx=x[test ,],type = 'response')
predicted_class <- ridge.pred > 0.45
a <- table(predicted_class, y.test)
a
predicted_class_mod <- ifelse(predicted_class == FALSE,0,1)
confusionMatrix(factor(predicted_class_mod), factor(y.test))


# Lasso
lasso.mod =glmnet (x[train ,],y[train],alpha =1, lambda =grid)
set.seed(1)
cv_lasso_model =cv.glmnet(x,y,alpha =1)
plot(cv_lasso_model)
bestlam =cv_lasso_model$lambda.min
bestlam 
lasso.pred=predict (lasso.mod ,s=bestlam ,newx=x[test ,])
predicted_class <- lasso.pred > 0.45
a <- table(predicted_class, y.test)
a
predicted_class_mod <- ifelse(predicted_class == FALSE,0,1)
confusionMatrix(factor(predicted_class_mod), factor(y.test))
