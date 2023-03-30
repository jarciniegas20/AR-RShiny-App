
####--SERVER------------------------------------------------------------------------------------------------

shinyServer(function(input, output, session,options = options(warn = -1)) {

  # defining session variables
  Logged <- FALSE    # set this to FALSE to enable AD authentication, TRUE to disable AD authentication
  TwoFa <- FALSE     # set this to FALSE to enable 2FA, TRUE to disable 2FA
  LoginStatus <- 0   #0 = not logged in; 1 = logged in; -1 = failed login
  USER <- reactiveValues(Logged = Logged,
                         TwoFa = TwoFa,
                         TwoFaMsg = "",
                         IsAdmin = FALSE,
                         IsPHI = FALSE,
                         LoginStatus = LoginStatus)

  observe ({
    if (USER$Logged) {
      if (USER$TwoFa) { # if succesful login AND Duo 2FA
        shinyjs::hide("pnlLogin") # Unid login page
        shinyjs::hide("pnl2FA") # Duo2FA page
        shinyjs::show("pnlSidebar") # Sidebar
        shinyjs::show("pnlMain") #The main app with actual data
      } else {
        # # if succesful login but not passed Duo 2FA
        shinyjs::hide("pnlLogin")
        shinyjs::show("pnl2FA")
        shinyjs::hide("pnlSidebar") #sidebar
        shinyjs::hide("pnlMain")
      }
    } else {
      # user not logged in
      shinyjs::show("pnlLogin")
      shinyjs::hide("pnl2FA")
      shinyjs::hide("pnlSidebar") #sidebar
      shinyjs::hide("pnlMain")
    }
  })

  #######################
  # Global Functions
  ######################
  logDebug <- function(logData) {
    log4r::debug(logger, paste(USER$dbSession$sessionId,'>',logData))
  }

  logInfo <- function(logData) {
    log4r::info(logger, paste(USER$dbSession$sessionId,'>',logData))
  }

  logWarn <- function(logData) {
    log4r::warn(logger, paste(USER$dbSession$sessionId,'>',logData))
  }

  logError <- function(logData) {
    log4r::error(logger, paste(USER$dbSession$sessionId,'>',logData))
  }

  logFatal <- function(logData) {
    log4r::fatal(logger, paste(USER$dbSession$sessionId,'>',logData))
  }

  ###########################################
  # Login
  ###########################################

  observeEvent(input$btnLogin, {
    Unid <- isolate(input$userName)
    PassWord <- isolate(input$passwd)
    fullURL <- paste0(luigiBaseURL, "authen/authenticate")
    reqBody <- list(username = Unid, password = PassWord, appName = app_name, appEnv = app_env)
    reqBody <- toJSON(reqBody, auto_unbox = TRUE)
    r <- POST(fullURL, body = reqBody, encode = "json", content_type_json())
    if (r$status_code == 200) {
      jsonContent <- content(r, "parsed")
      if (length(jsonContent) > 0 && jsonContent$user$authenticated) {

        # check that a user is a member of AD group
        for (team in jsonContent$user$memberOf) {
          if (grepl("Group goes here", team, fixed = TRUE)) {
            USER$Logged <- TRUE
          }
        }

        # or just give everyone access who has a valid AD username/password
        #USER$Logged <- FALSE

        if (USER$Logged) {
          # ...AND the user is a member of an authorized group
          USER$LoginStatus <- 1
          USER$ldapUser <- jsonContent$user
          USER$dbSession <- jsonContent$session
          logInfo(paste0('Successful login for ', Unid, ";database session id: ", USER$dbSession$sessionId))
        } else {
          # ...BUT the user is NOT a member of an authorized group
          USER$LoginStatus <- -2
          logWarn(paste0('Unauthorized login for ', Unid))
        }

        USER$LoginStatus <- 1
        USER$ldapUser <- jsonContent$user
        USER$dbSession <- jsonContent$session
        logInfo(paste0('Successful login for ', Unid, ";database session id: ", USER$dbSession$sessionId))
      } else {
        # failed login
        USER$LoginStatus <- -1
        logError(paste0('Failed login for ', Unid))
      }
    } else {
      # HTTP status other than 200
      USER$LoginStatus <- -99
      logError(paste0("Error communicating with LuigiWS: ", luigiBaseURL,";HTTP status code:", r$status_code))
    }
  })

  output$userDisplayName <- renderText(USER$ldapUser$displayName)

  output$loginErrorMsg <- renderText({
    if (USER$LoginStatus == -99) {
      'Network Error - unable to communicate with auth service'
    } else if (USER$LoginStatus == -2) {
      'You are not authorized to use this application'
    } else if (USER$LoginStatus == -3) {
      'Two-factor authentication failed'
    } else if (USER$LoginStatus < 0) {
      'Invalid Unid or Password'
    }
  })

  observeEvent(input$btnLogout, {
    fullURL <- paste0(luigiBaseURL, "authen/logout?session_id=",USER$dbSession$sessionId,"&rand_int=",USER$dbSession$randomInt)
    r <- fromJSON(fullURL)
    if (r == "Successful logout") {
      logInfo(paste0('Successful logout for ', USER$ldapUser$username, "; database session id: ", USER$dbSession$sessionId))
      updateTextInput(session, "userName", value = "")
      updateTextInput(session, "passwd", value = "")
      updateTextInput(session, "duoPasscode", value = "")
      USER$Logged <- Logged
      USER$TwoFa <- TwoFa
      USER$LoginStatus <- 0
      USER$ldapUser <- NULL
      USER$dbSession <- NULL
    } else {
      logError(paste0("Error communicating with LuigiWS: ", luigiBaseURL,"; HTTP request result:", r))
    }
  })

  #######################
  # 2FA
  #######################
  observeEvent(input$btn2FaLogin, {
    duoPasscode <- isolate(input$duoPasscode)
    fullURL <- paste0(twoFaBaseURL, "v2/auth")
    reqBody <- list(appUsername = TwoFaAppUsername, appPassword = TwoFaAppPassword, username = USER$ldapUser$username, factor = "passcode", passcode = input$duoPasscode)
    reqBody <- toJSON(reqBody, auto_unbox = TRUE)
    r <- POST(fullURL, body = reqBody, encode = "json", content_type_json())
    process2FaReply(r)
  })

  observeEvent(input$btn2FaPush, {
    USER$TwoFaMsg <- 'A Push has been sent to your device'
    fullURL <- paste0(twoFaBaseURL, "v2/auth")
    reqBody <- list(appUsername = TwoFaAppUsername, appPassword = TwoFaAppPassword, username = USER$ldapUser$username, factor = "push", device = "auto")
    reqBody <- toJSON(reqBody, auto_unbox = TRUE)
    r <- POST(fullURL, body = reqBody, encode = "json", content_type_json())
    process2FaReply(r)
  })

  process2FaReply <- function(r) {
    ok <- FALSE
    if (r$status_code == 200) {
      replyJson <- content(r)
      if (replyJson$stat == "OK") {
        if (replyJson$response$status == "allow") {
          ok <- TRUE
        }
      }
    }

    if (ok) {
      USER$TwoFa <- TRUE
    } else {
      updateTextInput(session, "passwd", value = "")
      log4r::error(logger, paste('Failed two-factor authentication for', USER$ldapUser$username))
      USER$LoginStatus <- -3
      USER$Logged <- FALSE
    }
  }

  output$duoMsg <- renderText(USER$TwoFaMsg)
  
  

  ####--UI BLOCK----------------------------------------------------------------------------------------------
  default_tab = "model"
  current_version = "0.01"

  output$app_version <- renderUI({
    fluidRow(
      column(12, offset = 1,
             br(),
             h5(str_c("Version 0.01", current_version))#,
      )
    )
  })

                         
  output$ui_sidebar <- renderUI({
     shinyjs::hidden(
       div(id="pnlSidebar",
    sidebarMenu(id = "pnlSidebar",

                menuItem("Model",
                         tabName = "model"
                ),

                menuItem("Info",
                         tabName = "info",
                         icon = icon("question-circle")
                ),

                uiOutput("app_version")
    )
      )
    )
  })
  
  

    output$ui_body <- renderUI({

    updateTabsetPanel(session, "pnlSidebar", selected = "model")
       shinyjs::hidden(
       div(id="pnlMain",
          
    tabItems(
    tabItem_model,
    tabItem_info
    )
     )
   )
  })
  
  ####--SERVER BLOCK-----------------------------------------------------------------------------------------
  
  ## Constants
  
  ## ReactiveValues
  v <- reactiveValues(
    solu_slider_time = NULL
  )
  
  # Server modules 
  source('data_serv.R', local = TRUE)
  source('model_serv.R', local = TRUE)
  source('info_serv.R', local = TRUE)
  
})  