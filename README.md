# AR-Shiny App

## Description
This model uses a machine learning method called XGBoost to determine what drives the amount of AR > 90days. The purpose is not to call out what is currently high, but rather what it has learned might contribute to a high $ amount of AR >90 days. For example, maybe a certain provider is in the top 10 features, indicating that they're predicted to have a high amount of $AR >90 days. This output (top features) will make these callouts based on the past 3 months of training data and allow the user to look into the root cause even further. 

With the billing group filter, the user can select "Department of Surgery", for example, and maybe catch a trend they might have missed or to validate a pattern they have been seeing with a provider, CPT, bill area, etc.

### Note
While the code is 100% accurate, this application will not run for any public user because of the login page as well as the absence of data.
