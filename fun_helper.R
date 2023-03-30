# Functions - common functions

save_and_run <- function(){
  #rstudioapi::documentSaveAll()
  shiny::runApp(launch.browser = TRUE)
}

# data.table approach to replace NA with zeros
replace_nas <- function(x) { for (j in seq_len(ncol(x)))
  set(x,which(is.na(x[[j]])),j,0) }
