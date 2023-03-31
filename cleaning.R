read_ar <- function(){ # function for loading in the data and cleaning
  
  df <- fread("Large dataset here")
  
  df_sub <- clean_names(df)
  
  df_sub$ar <-   gsub("[\\(]", "-", df_sub$ar) # replace accounting "(" with "-"
  
  df_sub$ar <- as.numeric(gsub("[\\$,)]", "", df_sub$ar)) # replace accounting ")" with ""
  
  # this ensures that I only see AR>=0 in this dataset
 df_sub <- df_sub %>%
  filter(df_sub$ar >= 0)
 
  # only look at ar>90 days
  df_sub_gr_90 <- df_sub %>% filter(df_sub$ar_grtr_than_90_yn == "Y")
  
  # converting the date into the right format
  df_sub_gr_90$snap_date <- as.Date(df_sub_gr_90$snap_date, format = "%m/%d/%Y")
  df_sub_gr_90$calc_max_snap_date <- as.Date(df_sub_gr_90$calc_max_snap_date, format = "%m/%d/%Y")
  
  # only keeping the last 12 weeks. it's still a lot of data, so training should still be good
  df_sub_gr_90 <- df_sub_gr_90 %>% 
    filter(snap_date >= calc_max_snap_date - weeks(12))

  # get rid of everything after the proc code numbers. ex. "99999 - something" will become "99999"
  df_sub_gr_90$proc_full <- sub(" -.*", "", df_sub_gr_90$proc_full)
  
  
  df_sub_gr_90$denied_yn <- factor(df_sub_gr_90$denied_yn)
  df_sub_gr_90$denial_class <- factor(df_sub_gr_90$denial_class)
  df_sub_gr_90$proc_full <- factor(df_sub_gr_90$proc_full)
  df_sub_gr_90$pos_name <- factor(df_sub_gr_90$pos_name)
  df_sub_gr_90$current_fin_class <- factor(df_sub_gr_90$current_fin_class)
  df_sub_gr_90$billing_group <- factor(df_sub_gr_90$billing_group)
  
  df_sub_gr_90 <- df_sub_gr_90 %>% # only keep instances of 10 or greater for this column
    group_by(current_payor) %>% 
    filter(n()>10)
  
  df_sub_gr_90 <- df_sub_gr_90 %>% # only keep instances of 10 or greater for this column
    group_by(prov_name) %>% 
    filter(n()>10)
  
  df_sub_gr_90 <- df_sub_gr_90 %>% # only keep instances of 10 or greater for this column
    group_by(bill_area) %>% 
    filter(n()>10)
  
  df_sub_gr_90 <- df_sub_gr_90 %>% # only keep instances of 10 or greater for this column
    group_by(pos_name) %>% 
    filter(n()>10)
  
  df_sub_gr_90 <- df_sub_gr_90 %>% # only keep instances of 10 or greater for this column
    group_by(proc_full) %>% 
    filter(n()>10)
  

  df_sub_gr_90 <- as.data.frame(df_sub_gr_90)
  
  df_sub_gr_90 <- df_sub_gr_90 %>% select(ar,everything()) # put ar variable first
  
  df_sub_gr_90 <- df_sub_gr_90 %>% rename(CPT = proc_full)
  
  variables <- c("ar","billing_group","billing_division",#"current_fin_class",
                 "current_payor","prov_name",
                 "bill_area",
                 "CPT","pos_name")
  
  df_sub_gr_90 <- df_sub_gr_90[variables]
  

  
}
