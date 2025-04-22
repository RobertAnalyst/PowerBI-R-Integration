# PowerBI-R-Integration
# Fetch Data from SurveyCTO API into Power BI Using R Script

This project demonstrates how to use R to connect to the **SurveyCTO API**, pull data in real time, and import it into **Power BI** using the **R script** data source feature.

---

## 📦 Required R Packages

Ensure these packages are installed in your R environment (Power BI uses the system's R installation):

```r
options(repos = c(CRAN = "https://cran.r-project.org"))

install.packages("jsonlite")
install.packages("httr")
install.packages("plyr")
install.packages("janitor")
install.packages("epiDisplay")
```
---

## 🔐 Secure Your Credentials
Store your credentials in an .Renviron file to prevent hardcoding.
```r
# Sample .Renviron entries
servername=your_server_name
username=your_username
password=your_password
# Load them in your script:
readRenviron(".Renviron")
# **Note:** If running inside Power BI, hardcoding credentials might be temporarily required since .Renviron may not be recognized by the Power BI service.
```
---

## 🔁 Function: fetchcto()

This function retrieves data from a SurveyCTO form in JSON format and returns a clean data frame.

```r
fetchcto  <- function(servername, formid, username, password, from_date = NULL) {
  url <- paste0("https://", servername, ".surveycto.com/api/v2/forms/data/wide/json/", formid)
  
  if (!is.null(from_date)) {
    url <- paste0(url, "?date=", from_date)
  }

  request <- httr::GET(url, authenticate(username, password))

  if (status_code(request) != 200) {
    stop("Request failed: ", status_code(request))
  }

  data_text <- content(request, "text")
  data <- fromJSON(data_text, flatten = TRUE)
  colnames(data) <- janitor::make_clean_names(colnames(data))

  message(paste("✅ Successfully downloaded", nrow(data), "rows from", formid))
  return(data)
}
```
---

## ▶️ Running in Power BI
To run this in Power BI:

Open Power BI Desktop.

Go to Home > Get Data > More > Other > R Script.

Paste the script below into the R script window:

```r
options(repos = c(CRAN = "https://cran.r-project.org"))

install.packages("jsonlite")
install.packages("httr")
install.packages("plyr")
install.packages("janitor")
install.packages("epiDisplay")

library(jsonlite)
library(httr)
library(plyr)
library(janitor)
library(epiDisplay)

# Optional: readRenviron(".Renviron")

# Hardcode if needed for Power BI
servername <- "your_server"
username <- "your_username"
password <- "your_password"
formid <- "your_form_id"

# Optional: use a UNIX timestamp (in seconds)
from_date <- 1716817171  

# Define function
fetchcto  <- function(servername, formid, username, password, from_date = NULL) {
  url <- paste0("https://", servername, ".surveycto.com/api/v2/forms/data/wide/json/", formid)
  if (!is.null(from_date)) {
    url <- paste0(url, "?date=", from_date)
  }
  request <- GET(url, authenticate(username, password))
  if (status_code(request) != 200) {
    stop("Request failed: ", status_code(request))
  }
  data_text <- content(request, "text")
  data <- fromJSON(data_text, flatten = TRUE)
  colnames(data) <- janitor::make_clean_names(colnames(data))
  return(data)
}

# Run function
data <- fetchcto(servername, formid, username, password, from_date)

# Power BI expects a dataframe
data
```

Click OK.

Power BI will run the script and load the returned data into your model.

---

## 🧠 Author
Omondi Robert | 
📧 robertdon388@gmail.com

---
