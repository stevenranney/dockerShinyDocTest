#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(googleAuthR)
library(dplyr)

clients <- read.csv("data/client_keys_2018_07_10.csv", 
                    header = TRUE)

# Define UI 
shinyUI(fluidPage(
  # Application title
  titlePanel("Staywell: Google Analytics Reporting"),
  
  #Adjust location of progress bars
  tags$head(tags$style(".shiny-notification {position: fixed; top: 25% ;left: 50%")),
  
# Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      selectInput("client", 
                  label = h4("Client"),
                  choices = clients %>% .$client_name %>% unique()),
      dateInput("start_date", label = h4("Start date"), value = "2017-06-30"), 
      dateInput("end_date", label = h4("End date")),
      downloadButton("generate", "Generate Report", #icon = icon("file"), 
                     style = "color: #fff; background-color: #337ab7; border-color: #2e6da4")
      ),
    
  # Show a plot of the generated distribution
    mainPanel(
      p("This app allows users to automatically generate a report using Google Analytics 
        data from the StayWell Portal for any of the clients in the dropdown menu 
        on the left. Clients in menu are from Josh Everson. Client lists can be updated easily."), 
      p("Login information to the Google Analytics account is provided by a 'service' 
        account and a Google Project. The Google project is tied to the Google Analytics Reporting API.")
    )
  )
))
