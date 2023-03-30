####--UI MODEL--------------------------------------------------------------------------------------------

#
# MODEL
#

                
tabItem_model <-
  tabItem(tabName = "model",
          fluidRow(
            column(width = 11, align="right",textOutput("userDisplayName")),
            column(width = 1, align="right",actionButton("btnLogout", "Logout", class = "btn btn-primary btn-xs")),
            
            column(width = 6,align="left",
                   h3(HTML("&nbsp;"),
                      "Drivers of AR $ amount >90 days")),
            column(width = 6,align="right",
                   h3(HTML("&nbsp;"),
                      "ORG NAME")
            ),
            
            
            box(
              title = "Model predictions - This will take a few moments, please read 'info' while waiting"
              ,collapsible = TRUE
              ,collapsed = FALSE
              ,width = 12
              ,background = NULL
              ,status = "primary"
              ,solidHeader = TRUE
              ,fluidRow(
                 column(4, sidebarPanel(
                                      #,uiOutput("payor_filter")#,width = 12)
                                      uiOutput("bg_filter"),width = 12))
               
                ,column(4, valueBoxOutput("model_test_vb", width = 12))
                ,column(4, valueBoxOutput("model_training_vb", width = 12))
              )
              ,fluidRow(
                column(
                  width = 6,
                  plotlyOutput("model_plot") %>% withSpinner(type = 5, color = '#808080')
                ),
                column(
                  width = 6,
                  DT::dataTableOutput("model_feature_importance_dt") %>% withSpinner(type = 5, color = '#808080')
                )
              )
              ,tags$h4("Parameters")
              
              ,box(
                title = "Parameters"
                ,collapsible = TRUE
                ,collapsed = TRUE
                ,width = 12
                ,background = NULL
                ,status = "primary"
                ,solidHeader = TRUE
                ,fluidRow(
                  
              
              column(
                width = 6
                ,setSliderColor(c("#008744", "#0057e7", "#d62d20", "#ffa700", "#6f7c85", "#75838d", "#7e8d98 ", "#8595a1"), c(1, 2, 3, 4, 5, 6, 7, 8))
                ,sliderInput("model_train_size", "Training size",
                             min = 20, max = 99, value = 80, step = 1
                )
                ,sliderInput("model_iterations", "Boosting iterations",
                             min = 1, max = 100, value = 10, step = 1
                )
                ,sliderInput("model_depth", "Maximum tree depth",
                             min = 1, max = 20, value = 2, step = 1
                )
                ,sliderInput("model_rate", "Learning rate (eta)",
                             min = 0.1, max = 0.5, value = 0.3, step = 0.05
                )             
              )
              ,column(
                width = 6
                ,sliderInput("model_gamma", "Minimum loss reduction for split (gamma)",
                             min = 0, max = 1, value = 0, step = 0.01
                )
                ,sliderInput("model_weight", "Minimum child weight",
                             min = 1, max = 10, value = 3, step = 1
                )
                ,sliderInput("model_subsample", "Subsample ratio of rows",
                             min = 0.1, max = 1, value = 0.5, step = 0.1
                )
                ,sliderInput("model_colsample", "Subsample ratio of columns",
                             min = 0.1, max = 1, value = 1, step = 0.1
                )
              ))
              
              ,fluidRow(
                column(
                  width = 12
                  ,align = "center"
                  ,actionBttn(
                    inputId = "model_learn_more_button"
                    ,label = "Learn more"
                    ,color = "default"
                    ,style = "jelly"
                  )
                )
              )
              ,hidden(
                div(
                  id = "model_learn_more_div"
                  ,fluidRow(
                    column(
                      width = 12
                      ,tags$ul(
                        tags$li(tags$strong("Training size"), "is the percentage of the data to use as the training set.")
                        ,tags$li(tags$strong("Boosting iterations"), "is the maximum number of iterations")
                        ,tags$li(tags$strong("Maximum tree depth"), "maximum depth of a tree")
                        ,tags$li(tags$strong("Learning rate (eta)"), "the rate at which the model learns patterns in data")
                        ,tags$li(tags$strong("Minimum loss reduction for split (gamma)"), "minimum loss reduction required to make a further partition on a leaf node of the tree")
                        ,tags$li(tags$strong("Minimum child weight"), "if a leaf node has less weights then it stops splitting")
                        ,tags$li(tags$strong("Subsample ratio of rows"), "randomly select subsample of the training instance rows")
                        ,tags$li(tags$strong("Subsample ratio of columns"), "randomly select subsample of the training instance rows")
                        ,tags$li(tags$strong("Gain"), "the relative contribution of the feature to the model")
                        ,tags$li(tags$strong("Cover"), "the relative number of observation related to this feature")
                        ,tags$li(tags$strong("Frequency"), "the relative number of times a particular feature occurs in the trees of the model")
                      )
                    )
                  )
                )
              ))
            )
          )
  )
