

ar <- reactive({
  read_ar() # reactive function for reading in the data
})


# XGB Data
#
ar_data <- reactive({ # this is separate for purposes of validation later
  ar<-ar()
  
  billing_group_sel <- if (is.null(input$billing_group)) levels(ar$billing_group) else input$billing_group
  
  ar2 <- ar %>% filter(billing_group %in% billing_group_sel)
  
  
   # ar2 <- ar %>% 
   #   filter(current_fin_class == input$current_fin_class) 

   
  train_ratio <- input$model_train_size/100 # this is dynamic based on what the "training size" slider is set to from ui_model
  train_size <- floor(train_ratio * nrow(ar2))
  train_split <- sample(1:nrow(ar2), train_size, replace = F)

  ar_data <- train_split
 })


xgb_data <- reactive({

  ar_data <- ar_data()

  
  df_sub_gr_90<-ar()

   
   billing_group_sel <- if (is.null(input$billing_group)) levels(df_sub_gr_90$billing_group) else input$billing_group
   
   df_sub_gr_90Y <- df_sub_gr_90 %>% filter(billing_group %in% billing_group_sel)


   #df_sub_gr_90Y <- df_sub_gr_90 %>% 
   #  filter(current_fin_class == input$current_fin_class)
   

  # this dummy codes the dataset but only creates the xg object. only keeping the variables of interest
  dfin_xg_m <- dummyVars("ar ~ .", data = df_sub_gr_90Y)

  # this converts the xg object to a df with binary dummy variables (1 or 0 for yes or no)
  dfin_xg_m <- data.frame(predict(dfin_xg_m, newdata = df_sub_gr_90Y), check.names = FALSE) # check.names = FALSE fixeS the '...' in long names

  # this binds the target variable back to the dummy coded df
  dfin_xg_m <- cbind(df_sub_gr_90Y$ar,dfin_xg_m)

  # this cleans up the name back to "ar"
  names(dfin_xg_m)[names(dfin_xg_m) == "df_sub_gr_90$ar"] <- "ar"

  set.seed(0823)

  # jumbles the rows
  dfin_xg_m <- dfin_xg_m[sample(1:nrow(dfin_xg_m)), ] #Jumbles the rows

  # creates a matrix of everything except for target variable, ar
  xg_matrix <- data.matrix(dfin_xg_m[c(-1)])

  # pulls all values from only the target variable, ar
  xg_labels <- dfin_xg_m[c(1)]
  
  
  
  xg_train_data <- xg_matrix[ar_data,]
  
  xg_test_data <- xg_matrix[-(ar_data),]
  
  xg_train_labels <- xg_labels[ar_data,]
  
  xg_test_labels <- xg_labels[-(ar_data),]
  
  
  
  
   xg_dtrain <- xgb.DMatrix(data = xg_train_data, label = xg_train_labels)

   xg_dtest <- xgb.DMatrix(data = xg_test_data, label = xg_test_labels)
  
  
  
  
  
  xgb_data <- list(train = xg_dtrain, test = xg_dtest, xg_test_labels = xg_test_labels, 
                   xg_train_data = xg_train_data, xg_train_labels = xg_train_labels,
                   xg_test_data = xg_test_data, xg_test_labels = xg_test_labels)
}) 


xgb_model_and_validation <- reactive({

  xgb_data <- xgb_data() # good
  
  xgb_train <- xgb_data$train # good
  xgb_test <- xgb_data$test # good
  xg_test_labels <- xgb_data$xg_test_labels 
  
  model_iterations <- input$model_iterations
  model_depth <- input$model_depth
  model_rate <- input$model_rate
  model_gamma <- input$model_gamma
  model_weight <- input$model_weight
  model_subsample <- input$model_subsample
  model_colsample <- input$model_colsample
  
  run_model <- function(xgb_model = NULL){
    set.seed(0823)
    xgboost(
      xgb_model = xgb_model,
      data = xgb_train, # the train data
      verbose = 0,
      nround = 1,
      max.depth = model_depth, 
      eta = model_rate,
      gamma = model_gamma,
      min_child_weight = model_weight,
      subsample = model_subsample,
      colsample_bytree = model_colsample,
      objective = "reg:squarederror", # would be "binary:logistic if logistic"
      eval_metric = "rmse" ## either want "rmse" or "rmsle" which is root mean square log error. https://xgboost.readthedocs.io/en/stable/parameter.html. would be "auc" or "aucpr" for logistic
    ) 
  }
  
  
  # Define a vector of validation errors
  test_rmsess <- numeric(model_iterations)
  
  # Run initial model
  initial_model <- run_model()
  initial_prediction <- predict(initial_model, xgb_test) # good
  
  
  test_rmse <- caret::RMSE(xg_test_labels, initial_prediction)

  # normalized RMSE to validate
  #test_rmse <- sqrt(mean(initial_prediction-xg_test_labels)^2)/sd(xg_test_labels)
  
  test_rmsess[1] <- test_rmse
  
  
  
  # Run the models
  if(model_iterations>1){
    previous_model <- initial_model
    set.seed(0823)
    for(i in 2:model_iterations){
      new_model <- run_model(previous_model)
      new_prediction <- predict(new_model, xgb_test)
      
      ## Calculate RMSE
      test_rmse <- caret::RMSE(xg_test_labels, new_prediction)
      
      # normalized RMSE
      #test_rmse <- sqrt(mean(initial_prediction-xg_test_labels)^2)/sd(xg_test_labels)
    
      test_rmsess[i] <- test_rmse # so this is calling the test_rmse of the specific iteration "[i]"
      
      previous_model <- new_model
    }  
  }
  
  list(model = new_model, test_rmsess = test_rmsess, iter_test_rmse = test_rmsess[i])
})



xgb_results <- reactive({
  xgb_model_and_validation <- xgb_model_and_validation()
  xgb_data <- xgb_data()
  
  model <- xgb_model_and_validation$model
  test_rmsess <- xgb_model_and_validation$test_rmsess # test RMSE
  
  xgb_test <- xgb_data$test#xgb_data$test

  
  model_prediction <- predict(model, xgb_test)
  
  
  iter_test_rmse <- xgb_model_and_validation$iter_test_rmse
  
  
  # Training results
  df <- model$evaluation_log
  
  df[['train_rmse']] <- df$train_rmse
  
  
  iter_train_rmse <- df$train_rmse[df$iter == max(df$iter)]
  

  
  results <- list(
        iter_test_rmse = iter_test_rmse,
        iter_train_rmse = iter_train_rmse
    )
  
})


