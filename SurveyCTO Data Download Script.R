
options(repos = c(CRAN = "https://cran.r-project.org"))

install.packages("jsonlite")
install.packages("httr")
install.packages("plyr")
install.packages("janitor")
install.packages("epiDisplay")

library(jsonlite)
library(httr)
library(plyr)
library(epiDisplay)
library(janitor)

#usethis::edit_r_environ()
readRenviron(".Renviron")

fetchcto  <- function(servername, formid, username, password, from_date = NULL) {
  # Construct URL
  url <- paste0("https://", servername, ".surveycto.com/api/v2/forms/data/wide/json/", formid)
  # Optional date filter (timestamp in seconds)
  if (!is.null(from_date)) {
    url <- paste0(url, "?date=", from_date)
  }
  # Make the API request
  request <- GET(url, authenticate(username, password))
  # Check for request success
  if (status_code(request) != 200) {
    stop("Request failed: ", status_code(request))
  }
  # Read and parse JSON
  data_text <- content(request, "text")
  data <- fromJSON(data_text, flatten = TRUE)
  # Clean column names
  colnames(data) <- janitor::make_clean_names(colnames(data))
  # Return cleaned dataframe
  message(paste("✅ Successfully downloaded", nrow(data), "rows from", formid))
  return(data)
}

R1_2024_CES_Com_v01 <- fetchcto (Sys.getenv('servername'), 'R1_2024_CES_Com_v01', Sys.getenv('username'), 
                                 Sys.getenv('password') ,from_date = 1716817171)