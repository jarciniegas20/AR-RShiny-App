####--UI--------------------------------------------------------------------------------------------


header <- 
dashboardHeader(
title = "AR >90 Days App")


sidebar <-
  dashboardSidebar(uiOutput("ui_sidebar"))

body <- 
                dashboardBody(
                  tags$head(
                    tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap.css"),
                    tags$script(src = "app.js")
                  ),
                  useShinyjs(),
                  # define the application panels
                  div(id="pnlLogin",
                      title = "Welcome!    Login with your username and password",
                      textOutput("loginErrorMsg"),
                      textInput("userName", "Username"),
                      passwordInput("passwd", "Password"),
                      br(),actionButton("btnLogin", "Log in", class="btn btn-primary")),
                  shinyjs::hidden(
                    div(id="pnl2FA",
                        title = "Enter DUO Passcode",
                        HTML("<center>"),
                        span(textOutput("duoMsg"), class = "text-info"),
                        HTML("</center>"),
                        actionButton("btn2FaPush", "Send Me a Push", class="btn btn-primary"),br(),
                        textInput("duoPasscode", "Alternatively, enter a Duo Passcode"),
                        br(),actionButton("btn2FaLogin", "Log in", class="btn btn-primary")
                    )
                  ),
                    
                    tags$style(".small-box.bg-yellow { background-color: rgb(117,142,153) !important; color: rgb(117,142,153) !important; }"),
                    fluidPage(
                    fluidRow(
                    valueBoxOutput("iter_test_rmse"),
                    valueBoxOutput("iter_train_rmse"))),
                shinyDashboardThemeDIY(### general
                  appFontFamily = "Arial"
                  ,appFontColor = "rgb(0,0,0)" # the size of the text in boxes
                  ,primaryFontColor = "rgb(0,0,0)"
                  ,infoFontColor = "rgb(0,0,0)"
                  ,successFontColor = "rgb(0,0,0)"
                  ,warningFontColor = "rgb(0,0,0)"
                  ,dangerFontColor = "rgb(0,0,0)"
                  ,bodyBackColor = "rgb(248,248,248)"
     
                    
                  ### header
                  ,logoBackColor = "rgb(130-0-0)"
                  
                  ,headerButtonBackColor = "rgb(226,230,230)"
                  ,headerButtonIconColor = "rgb(75,75,75)"
                  ,headerButtonBackColorHover = "rgb(210,210,210)"
                  ,headerButtonIconColorHover = "rgb(0,0,0)"
                  
                  ,headerBackColor = "rgb(226,230,230)"
                  ,headerBoxShadowColor = "#aaaaaa"
                  ,headerBoxShadowSize = "2px 2px 2px"
                  
                  ### sidebar
                  ,sidebarBackColor = cssGradientThreeColors(
                    direction = "down"
                    ,colorStart = "rgb(130-0-0)"
                    ,colorMiddle = "rgb(130-0-0)"
                    ,colorEnd = "rgb(204-0-0)"
                    ,colorStartPos = 0
                    ,colorMiddlePos = 50
                    ,colorEndPos = 100
                  )
                  ,sidebarPadding = 0
                  
                  ,sidebarMenuBackColor = "transparent"
                  ,sidebarMenuPadding = 0
                  ,sidebarMenuBorderRadius = 0
                  
                  ,sidebarShadowRadius = "3px 5px 5px"
                  ,sidebarShadowColor = "#aaaaaa"
                  
                  ,sidebarUserTextColor = "rgb(255,255,255)"
                  
                  ,sidebarSearchBackColor = "rgb(55,72,80)"
                  ,sidebarSearchIconColor = "rgb(153,153,153)"
                  ,sidebarSearchBorderColor = "rgb(55,72,80)"
                  
                  ,sidebarTabTextColor = "rgb(255,255,255)" # model and info text
                  ,sidebarTabTextSize = 13
                  ,sidebarTabBorderStyle = "none none solid none"
                  ,sidebarTabBorderColor = "rgb(130-0-0)"
                  ,sidebarTabBorderWidth = 1
                  
                  ,sidebarTabBackColorSelected = cssGradientThreeColors(
                    direction = "right"
                    ,colorStart = "rgb(204,0,0)" # the color for the model and info tabs
                    ,colorMiddle = "rgb(204-0-0)"
                    ,colorEnd = "rgb(130-0-0)"
                    ,colorStartPos = 0
                    ,colorMiddlePos = 30
                    ,colorEndPos = 100
                  )
                  ,sidebarTabTextColorSelected = "rgb(0,0,0)" # the color of the model and info text
                  ,sidebarTabRadiusSelected = "0px 20px 20px 0px"
                  
                  ,sidebarTabBackColorHover = cssGradientThreeColors(
                    direction = "right"
                    ,colorStart = "rgb(204,0,0)" # the color when you hove over model and info
                    ,colorMiddle = "rgb(204-0-0)"
                    ,colorEnd = "rgb(130-0-0)"
                    ,colorStartPos = 0
                    ,colorMiddlePos = 30
                    ,colorEndPos = 100
                  )
                  ,sidebarTabTextColorHover = "rgb(50,50,50)"
                  ,sidebarTabBorderStyleHover = "none none solid none"
                  ,sidebarTabBorderColorHover = "rgb(130,0,0)"
                  ,sidebarTabBorderWidthHover = 1
                  ,sidebarTabRadiusHover = "0px 20px 20px 0px"
                  
                  ### boxes
                  ,boxBackColor = "rgb(255,255,255)"
                  ,boxBorderRadius = 5
                  ,boxShadowSize = "0px 0px 0px" # 0,0,0 gets rid of the border shadow
                  ,boxShadowColor = "rgb(255,255,55)" # the yellow border
                  ,boxTitleSize = 20 # the size of the "model predictions - read..."
                  ,boxDefaultColor = "rgba(44,222,235,1)"
                  ,boxPrimaryColor = "rgb(204-0-0)" # the color for "model predictions - read..." background
                  #,BoxTextColor = "rgb(255,255,255)"
                  ,boxInfoColor = "rgb(255,255,55)"
                  ,boxSuccessColor = "rgb(255,255,55)"
                  ,boxWarningColor = "rgb(255,255,55)"
                  ,boxDangerColor = "rgb(255,255,55)"
                  
                  ,tabBoxTabColor = "rgb(130-0-0)"
                  ,tabBoxTabTextSize = 14
                  ,tabBoxTabTextColor = "rgb(255,255,255)"
                  ,tabBoxTabTextColorSelected = "rgb(255,255,255)"
                  ,tabBoxBackColor = "rgb(255,255,255)"
                  ,tabBoxHighlightColor = "rgb(130-0-0)"
                  ,tabBoxBorderRadius = 5
                  
                  ### inputs
                  ,buttonBackColor = "rgb(130-0-0)"
                  ,buttonTextColor = "rgb(255,255,255)"
                  ,buttonBorderColor = "rgb(200,200,200)"
                  ,buttonBorderRadius = 5
                  
                  ,buttonBackColorHover = "rgb(235,235,235)"
                  ,buttonTextColorHover = "rgb(100,100,100)"
                  ,buttonBorderColorHover = "rgb(200,200,200)"
                  
                  ,textboxBackColor = "rgb(255,255,255)"
                  ,textboxBorderColor = "rgb(200,200,200)"
                  ,textboxBorderRadius = 5
                  ,textboxBackColorSelect = "rgb(245,245,245)"
                  ,textboxBorderColorSelect = "rgb(200,200,200)"
                  
                  ### tables
                  ,tableBackColor = "rgb(255,255,255)" # the color of the feature importance table
                  ,tableBorderColor = "rgb(240,240,240)"
                  ,tableBorderTopSize = 1
                  ,tableBorderRowSize = 1)
  
                ,
                useShinyjs(),
                uiOutput("ui_body") #ui_body
              )
 #)
 #)
              #)
              # )

ui <- dashboardPage(header, sidebar, body, skin = "blue")
