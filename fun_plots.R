# Functions for producing plots from data and parameters

model_plot_f <- function(model, test_rmsess, plot_type = "loss", baseline = 0, max_y = NULL){
  
  df <- model$evaluation_log

  df[['train_rmse']] <- df$train_rmse
  
  if(is.null(max_y)){
    max_y <- max(df$train_rmse)
    max_y <- max(max_y, test_rmsess)
    max_y <- max_y + 500
  }
  
  min_y = max_y
  
  test_rmse_value <- min(test_rmsess)
  ann_msg <- ""
  p <- plot_ly(df, x = ~iter)
  
  if(plot_type == "loss"){
    ann_msg <- "error"
    p <- p %>%
      add_trace(
        y = ~train_rmse, 
        type = 'scatter', 
        mode = 'lines+markers',
        name = 'Train RMSE'
      ) %>%
      add_trace(
        y = test_rmsess,
        type = 'scatter', 
        mode = 'lines+markers',
        name = 'Test RMSE'
      ) %>%
      layout(
        yaxis = list(
          range=c(0, max_y)
        )
      )
  } else {
    ann_msg <- "error"
    p <- p %>%
      add_trace(
        y = ~train_rmse, 
        type = 'scatter', 
        mode = 'lines+markers',
        name = 'Train RMSE'
      ) %>%
      add_trace(
        y = test_rmsess,
        type = 'scatter', 
        mode = 'lines+markers',
        name = 'Test RMSE'
      ) %>%
      layout(
        yaxis = list(
          range=c(0, max_y)
        )
      )
  }
  
  if(baseline!=0){
    hline <- function(y = 0, color = "lightblue") {
      list(
        type = "line", 
        x0 = 0, 
        x1 = 1, 
        xref = "paper",
        y0 = y, 
        y1 = y, 
        line = list(color = color, dash = 'dash')
      )
    }
    
    ann_baseline <- list(xref = 'paper', yref = "y", x = 0.01, y = baseline, 
                         text = paste("baseline ", ann_msg), 
                         textangle = 0, showarrow = FALSE, yanchor = 'bottom', 
                         bgcolor='#FFFFFF', opacity=0.8, color = "lightblue"
    )
    
    ann_validation <- list(xref = 'paper', yref = "y", x = 0.9, y = test_rmse_value, 
                           text = paste("best_test_rmse ", ann_msg), 
                           textangle = 0, showarrow = FALSE, yanchor = 'bottom', 
                           bgcolor='#FFFFFF', opacity=0.8, color = "orange"
    )
    
    p <- p %>% 
      layout(
        shapes = list(
          hline(baseline), 
          hline(test_rmse_value, "orange")
        ),
        annotations= list(
          ann_baseline,
          ann_validation
        )
      )
  }
  
  p %>% plotly::config(displayModeBar = F, showLink = F)
}

