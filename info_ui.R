####--UI INFO--------------------------------------------------------------------------------------------

#
# INFO
#

tabItem_info <-
  tabItem(tabName = "info",
          fluidRow(
            column(width = 3,
                   h2(icon("question-circle"), HTML("&nbsp;"),"Info")
            )
            ,box(
              title = "What influences the amount of AR>90 days?",
              width = 12,
              collapsible = TRUE,
              collapsed = FALSE,
              status = "primary",
              solidHeader = TRUE,
              tags$ol(
                tags$li("The model uses a machine learning method called XGBoost to determine what drives the $ amount of AR > 90days."),
                tags$li("Top 10 drivers are listed to the right of the page"),
                tags$dd("The higher the feature, the more important the model thinks it is in predicting $AR > 90 days."),
                tags$li("The model is trained on the last 4 weeks of data and analyzes based on the following features:
                 Billing Group,
                 Current Payor,
                 Bill Area,
                 Denial Class,
                 CPT Code,
                 Place of Service")
                ,tags$li(tags$strong("Test and Train RMSE"), "are the performance metrics of the model")
                ,tags$li(tags$strong("Gain"), "is the relative importance of the feature in driving $ amount of AR")
                ,tags$li(tags$strong("Cover"), "is the relative number of observations related to this feature")
                ,tags$li(tags$strong("Frequency"), "is the relative number of times a feature occurs in the trees of the model")
                
               )
            )
          )
  )
