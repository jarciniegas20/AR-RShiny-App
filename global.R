library(DT)
library(dashboardthemes)
library(data.table)
library(shinycssloaders)
library(shinydashboard)
library(shinyjs)
library(shinyWidgets)
library(stringr)
library(lubridate)
library(plotly)
library(dplyr)
library(caret)
library(xgboost)
library(janitor)
library(shiny)
library(log4r)
library(httr)
library(jsonlite)

 # defining application variables
 app_name <- "NAME HERE"
 app_env <- "ENV HERE"
 luigiBaseURL <- "URL_HERE"
 twoFaBaseURL <- "URL_HERE"

 TwoFaAppUsername <- "USERNAME HERE"
 TwoFaAppPassword <- "PASSWORD HERE"

 # define the application log file
 logger <- create.logger()
 logfile(logger) <- 'logs/app.log'
 level(logger) <- 'INFO'


source('fun_helper.R')
source('cleaning.R')
source('fun_plots.R')

source('model_ui.R')
source('info_ui.R')