#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(googleAuthR)
library(googleAnalyticsR)
library(rmarkdown)
library(jsonlite)

clients <- read.csv("data/client_keys_2018_07_10.csv", 
                    fileEncoding = "UTF-8-BOM",
                    header = TRUE)

client_id <- fromJSON("client_id.json")

options(googleAuthR.client_id = client_id$installed$client_id)
options(googleAuthR.client_secret = client_id$installed$client_secret)

# Define server logic required to pull and process data
shinyServer(function(input, output) {
   
  #Establish the Google Service account as the Server to Server OAuth
  gar_auth_service(
    json_file = "ranney-sw-test-2018-06-22-ccfcdd77f262.json",
    scope = "https://www.googleapis.com/auth/analytics"
  )
  
  # Determine which client code to use from the input page
  client_code <- 
    reactive({(clients %>% 
      filter(client_name == input$client %>% as.character()) %>% 
        select(client_key) %>% 
        unique())$client_key})
  
  client <- reactive({dim_filter("customVarValue1", operator = "EXACT", client_code() %>% as.character(), not = FALSE)})
  
  ## construct filter objects
  fc <- reactive({filter_clause_ga4(list(client()), operator = "AND")})
  
  dataInput <- 
    reactive({
      withProgress(min = 0, max = 1, {
        incProgress(message = "Pulling data from Google Analytics servers", 
                    detail = "This may take a while...", amount = .1)
        google_analytics(viewId = "83057204", # Corresponds to SWP V5, filtered view , 
                         date_range = c(input$start_date, input$end_date), 
                         dimensions = c("customVarValue1", "city",  "dateHour"),
                         metrics = c("users", "newUsers", "entrances", "sessions", "sessionsPerUser", 
                                     "avgSessionDuration", "uniquePageViews"), 
                         dim_filters = fc(), 
                         max = -1) %>%
          rename(client_key = customVarValue1) %>%
          mutate(client_key = client_key %>% as.numeric(), 
                 date = substr(dateHour, 1, 8) %>% as.Date(format = "%Y%m%d"),
                 hour = substr(dateHour, 9, 10) %>% as.numeric(), 
                 city = ifelse(city == "(not set)", "NA", city), 
                 avg_session_duration_min = avgSessionDuration/60,
                 day_of_week = strftime(date, "%A"), 
                 day_of_week = factor(day_of_week, levels = c("Monday", "Tuesday", "Wednesday", 
                                                              "Thursday", "Friday", "Saturday", 
                                                              "Sunday")), 
                 existing_users = users - newUsers)
      })
    })
      

  output$generate <- downloadHandler(
    
    # This function returns a string which tells the client
    # browser what name to use when saving the file.
    filename = function() {
      paste0(input$client, "_", Sys.Date(), ".pdf") %>%
        gsub(" ", "_", .)
    },
    
    # This function should write data to a file given to it by
    # the argument 'file'.
    content = function(file) {
      
      withProgress(min = 0, max = 1, {
        incProgress(message = "Processing data into report", 
                    detail = "This may take a while...", amount = .1)
        params <- list(data = dataInput(), 
                       client = input$client)
        # Write to a file specified by the 'file' argument
        render("report/GA_report.Rmd", 
               output_format = "all",
               output_file = file, 
               params = params, 
               envir = new.env(parent = globalenv()), 
               clean = FALSE, 
               quiet = FALSE)
        })
    }
  )

})
