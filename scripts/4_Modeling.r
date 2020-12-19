library("FSinR")
library("data.table")
library("magrittr")
library("ggplot2")

train_module_scaled=fread("train_module_scaled.csv")

train_module_scaled$Id=as.factor(train_module_scaled$Id)
train_module_scaled$Channels=as.factor(train_module_scaled$Channels)
train_module_scaled$Segments=as.factor(train_module_scaled$Segments)
train_module_scaled$label=as.factor(train_module_scaled$label)

evaluator <- filterEvaluator('chiSquared')

directSearcher <- directSearchAlgorithm('selectKBest', list(k=10))

results <- directFeatureSelection(train_module_scaled, 'label', directSearcher, evaluator)
results$bestFeatures

results$featuresSelected

results$valuePerFeature

train_select=train_module_scaled[,c(2,3,7,8,9,10,382,383,501,502,504)]

train_select_nofactor=train_module_scaled[,c(7,8,9,10,382,383,501,502,504)]

library("mlr3") # mlr3 base package
library("mlr3misc") # contains some helper functions
library("mlr3pipelines") # create ML pipelines
library("mlr3tuning") # tuning ML algorithms
library("mlr3learners") # additional ML algorithms
library("mlr3viz") # autoplot for benchmarks
library("skimr")
library("GGally")

task = TaskClassif$new(id = "Task", backend = train_select,target = "label")
task

task_nofactor=TaskClassif$new(id = "Task", backend = train_select_nofactor,target = "label")

skim(task$data())

autoplot(task_nofactor, type = "pairs")

library("mlr3learners")
learner_logreg = lrn("classif.log_reg")
learner_logreg$predict_type <- "prob"
print(learner_logreg)

# check original class balance
table(task$truth())

po_under = po("classbalancing",
  id = "undersample", adjust = "major",
  reference = "major", ratio = 58520  / 206360  )
# reduce majority class by factor '1/ratio'
table(po_under$train(list(task))$output$truth())

graph_down = GraphLearner$new(po_under %>>% learner_logreg)
graph_down$predict_type <- "prob"

lrn_up = po("classbalancing", id = "oversample", adjust = "minor", 
     reference = "minor", shuffle = FALSE, ratio =206360 / 58520  ) %>>%
  learner_logreg

graph_up <- GraphLearner$new(lrn_up)
graph_up$predict_type <- "prob"

hld <- rsmp("holdout")

set.seed(123)
hld$instantiate(task)

bmr <- benchmark(design = benchmark_grid(task = task,
                                        learner = list(learner_logreg,graph_up,
                                                       graph_down),
                                        hld),
                store_models = TRUE) #only needed if you want to inspect the models

bmr$aggregate(msr("classif.acc"))

bmr$aggregate(msr("classif.recall"))

bmr$aggregate(msr("classif.precision"))

# train/test split
train_set <- sample(task$nrow, 0.8 * task$nrow)
test_set <- setdiff(seq_len(task$nrow), train_set)

# train the model
learner_logreg$train(task, row_ids = train_set)

# predict data
prediction <- learner_logreg$predict(task, row_ids = test_set)

# calculate performance
prediction$confusion

measure <- list(msr("classif.acc"), msr("classif.precision"))
prediction$score(measure)

# train/test split
train_set <- sample(task$nrow, 0.8 * task$nrow)
test_set <- setdiff(seq_len(task$nrow), train_set)

# train the model
graph_down$train(task, row_ids = train_set)

# predict data
prediction <- graph_down$predict(task, row_ids = test_set)

# calculate performance
prediction$confusion

measure <- list(msr("classif.acc"), msr("classif.precision"), msr("classif.recall") )
prediction$score(measure)

# train/test split
train_set <- sample(task$nrow, 0.8 * task$nrow)
test_set <- setdiff(seq_len(task$nrow), train_set)

# train the model
graph_up$train(task, row_ids = train_set)

# predict data
prediction <- graph_up$predict(task, row_ids = test_set)

# calculate performance
prediction$confusion

measure <- list(msr("classif.acc"), msr("classif.precision"), msr("classif.recall") )
prediction$score(measure)

# automatic resampling
resampling <- rsmp("cv", folds = 3L)
rr <- resample(task, graph_up, resampling)
rr$score(measure)

library("nnet")
library("glmnet")
library("ranger")
library("xgboost")
library("e1071")
library("mlr3keras")
library("keras")

learner_rpart=lrn("classif.rpart")
lrn_up = po("encode",
  affect_columns = selector_type("factor")) %>>% po("classbalancing", id = "oversample", adjust = "minor", 
     reference = "minor", shuffle = FALSE, ratio = 206360 / 58520) %>>%
  learner_rpart
learner_rpart <- GraphLearner$new(lrn_up)
learner_rpart$predict_type <- "prob"

learner_glmnet=lrn("classif.glmnet")
lrn_up = po("encode",
  affect_columns = selector_type("factor")) %>>%po("classbalancing", id = "oversample", adjust = "minor", 
     reference = "minor", shuffle = FALSE, ratio = 206360 / 58520) %>>%
  learner_glmnet
learner_glmnet <- GraphLearner$new(lrn_up)
learner_glmnet$predict_type <- "prob"

learner_log_reg=lrn("classif.log_reg")
lrn_up = po("encode",
  affect_columns = selector_type("factor")) %>>% po("classbalancing", id = "oversample", adjust = "minor", 
     reference = "minor", shuffle = FALSE, ratio = 206360 / 58520) %>>%
  learner_log_reg
learner_log_reg <- GraphLearner$new(lrn_up)
learner_log_reg$predict_type <- "prob"

learner_nnet=lrn("classif.nnet")
lrn_up = po("encode",
  affect_columns = selector_type("factor")) %>>% po("classbalancing", id = "oversample", adjust = "minor", 
     reference = "minor", shuffle = FALSE, ratio = 206360 / 58520) %>>%
  learner_nnet
learner_nnet <- GraphLearner$new(lrn_up)
learner_nnet$predict_type <- "prob"

design = benchmark_grid(
  tasks = task,
  learners = list(learner_rpart, learner_glmnet,learner_log_reg,learner_nnet),
  resamplings = rsmp("cv", folds = 5)
)
print(design)

bmr = benchmark(design)

measures <- list(msr("classif.acc"), msr("classif.precision"), msr("classif.recall") )
performances = bmr$aggregate(measures)
performances[, c("learner_id", "classif.acc","classif.precision", "classif.recall")]

 # Define a model for Neural Net with default parameters
 model = keras_model_sequential() %>%
 layer_dense(units = 256, activation = 'relu') %>%
  layer_dropout(rate = 0.4) %>% 
  layer_dense(units = 128, activation = 'relu') %>%
  layer_dropout(rate = 0.3) %>%
  layer_dense(units = 2, activation = 'softmax') %>%
  compile(optimizer = "adam",
     loss = "categorical_crossentropy",
     metrics = "accuracy")
 # Create the learner
 learner_keras_nn = LearnerClassifKeras$new()
 learner_keras_nn$param_set$values$model = model
 # Create pipeline with oversample
 lrn_up = po("encode",
  affect_columns = selector_type("factor")) %>>% po("classbalancing", id = "oversample", adjust = "minor", 
     reference = "minor", shuffle = FALSE, ratio = 206360 / 58520) %>>%
 learner_keras_nn

 learner_keras_nn <- GraphLearner$new(lrn_up)

learner_keras_nn

design = benchmark_grid(
  tasks = task,
  learners = list(learner_rpart, learner_glmnet,learner_log_reg,learner_nnet,learner_keras_nn),
  resamplings = rsmp("cv", folds = 2)
)
print(design)

bmr = benchmark(design)

measures <- list(msr("classif.acc"), msr("classif.precision"), msr("classif.recall") )
performances = bmr$aggregate(measures)
performances[, c("learner_id", "classif.acc","classif.precision", "classif.recall")]

set.seed(8008135)
cv5_instance = rsmp("cv", folds = 5)

# fix the train-test splits using the $instantiate() method
cv5_instance$instantiate(task)

# have a look at the test set instances per fold
cv5_instance$instance

library(paradox)

learner_rpart=lrn("classif.rpart")
lrn_up = po("encode",
  affect_columns = selector_type("factor")) %>>% po("classbalancing", id = "oversample", adjust = "minor", 
     reference = "minor", shuffle = FALSE, ratio = 206360 / 58520) %>>%
  learner_rpart
learner_rpart <- GraphLearner$new(lrn_up)
learner_rpart$predict_type <- "prob"

learner_rpart$param_set

ps_encode <- ParamSet$new(list(ParamFct$new("encode.method",levels="one-hot")))
ps_class_balance<-ParamSet$new(list(ParamDbl$new("oversample.ratio",lower =3, upper = 4),
      ParamFct$new("oversample.reference",levels="minor"),
      ParamFct$new("oversample.adjust",levels="minor"),
      ParamLgl$new("oversample.shuffle")))
ps_random<-ParamSet$new(list(ParamInt$new("classif.rpart.minsplit", lower = 1, upper = 30),
    ParamInt$new("classif.rpart.cp", lower = 0, upper = 1),
      ParamInt$new("classif.rpart.maxdepth", lower = 1, upper = 30)))


param_set <- ParamSetCollection$new(list(
  ps_encode, 
  ps_class_balance,
    ps_random
))

at = AutoTuner$new(learner_rpart, resampling=rsmp("cv", folds = 2), measure = msr("classif.prauc"),
  param_set, terminator= trm("evals", n_evals = 36), tuner = tnr("grid_search"))

at

# predict data with tunned parameters
at$train(task)
prediction <- at$predict(task, row_ids = test_set)

# calculate performance
prediction$confusion

grid = benchmark_grid(
  task = task,
  learner = list(at, learner_rpart,learner_keras_nn),
  resampling = rsmp("cv", folds = 5)
)

# avoid console output from mlr3tuning
logger = lgr::get_logger("bbotk")
logger$set_threshold("warn")

bmr = benchmark(grid)
bmr$aggregate(msrs(c("classif.ce", "time_train","classif.precision","classif.recall")))

measures <- list(msr("classif.acc"), msr("classif.precision"), msr("classif.recall"))
performances = bmr$aggregate(measures)
performances

rr = bmr$aggregate()[learner_id == "encode.oversample.classif.rpart.tuned", resample_result][[1]]

rr$predictions()[[1]]$confusion

rr_keras=bmr$aggregate()[learner_id == "encode.oversample.classif.keras", resample_result][[1]]

rr_keras$predictions()[[1]]$confusion

# predict data for keras_learner without resamplin
learner_keras_nn$train(task)
prediction_keras <- learner_keras_nn$predict(task, row_ids = test_set)

# calculate performance
prediction_keras$confusion
