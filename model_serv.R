
  #### Model ####
  
  output$model_test_vb <- renderValueBox({
    req(input$billing_group)
    model_results <- xgb_results()
    iter_test_rmse <- round(model_results$iter_test_rmse,2)
    
    valueBox(
      iter_test_rmse
      ,"Test RMSE"
      ,color ="yellow")
    
  })
  

     output$bg_filter <- renderUI({
       ar <- ar()
       
       selectizeInput('billing_group', 'Billing Group', choices = c("Select" = "", 
                                                                    levels(ar$billing_group)),
                      multiple=TRUE,
                      selected="DEPARTMENT OF SURGERY")
     })
     
     
  output$model_training_vb <- renderValueBox({ # i think train rmse
    req(input$billing_group)
    model_results <- xgb_results()
    iter_train_rmse <- round(model_results$iter_train_rmse,2)


    valueBox(
      iter_train_rmse
      ,"Train RMSE"
      ,color = "yellow")
  })
  
  
  output$model_plot <- renderPlotly({
    req(input$billing_group)
    
    xgb_model_and_validation <- xgb_model_and_validation()
    my_model <- xgb_model_and_validation$model
    test_rmsess <- xgb_model_and_validation$test_rmsess

    my_results <- xgb_results()


    model_plot_f(my_model, test_rmsess, plot_type = "accuracy")
  })
  
  
  
  output$model_feature_importance_dt <- DT::renderDataTable({ 
    req(input$billing_group)
    xgb_model_and_validation <- xgb_model_and_validation()
    xgb_model <- xgb_model_and_validation$model
    df <- xgb.importance(model = xgb_model)
    
    DT::datatable(
      df %>% head(10), 
      selection = 'none',
      style = 'bootstrap',
      options = list(
        dom = 't', # 'f' makes it searchable
        ordering = FALSE
      )
    ) %>% 
      
      DT::formatPercentage(c("Gain", "Cover", "Frequency"), digits = 2) %>%   
      DT::formatStyle(
        'Gain',
        background = DT::styleColorBar(df$Gain, 'lightgray'),
        backgroundSize = '98% 88%',
        backgroundRepeat = 'no-repeat',
        backgroundPosition = 'center'
      ) %>%
      DT::formatStyle(
        'Cover',
        background = DT::styleColorBar(df$Cover, 'lightblue'),
        backgroundSize = '98% 88%',
        backgroundRepeat = 'no-repeat',
        backgroundPosition = 'center'
      ) %>%
      DT::formatStyle(
        'Frequency',
        background = DT::styleColorBar(df$Frequency, 'lemonchiffon'),
        backgroundSize = '98% 88%',
        backgroundRepeat = 'no-repeat',
        backgroundPosition = 'center'
      ) 
    
  })
  
  
  observeEvent(input$model_learn_more_button, {
    toggle("model_learn_more_div")  
  })
  
  
  
  
  output$added_features_dt <- DT::renderDataTable({
    DT::datatable(added_features(), 
                  selection = 'none',
                  style = 'bootstrap',
                  server = FALSE,
                  options = list(
                    dom = 't',
                    ordering = FALSE, 
                    pageLength = 14

                  )
    ) 
  })
  