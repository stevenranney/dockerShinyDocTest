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

# Define UI 
shinyUI(fluidPage(
  # Application title
  titlePanel("Test reporting app"),
  

# Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      numericInput("seed", 
                   label = "Set seed", 
                   value = 256),
      selectInput("algo", 
                  label = h4("RNG algorithm"),
                  choices = c("Wichmann-Hill", "Marsaglia-Multicarry", "Super Duper", 
                              "Mersenne-Twister", "Knuth-TAOCP-2002", 
                              "Knuth-TAOCP", "L'Ecuyer-CMRG")),
      numericInput("n", 
                   label = h4("Number of values to generate"),
                   value = 1000),
      textInput("client", 
                label = h4("Test for spaces issues"), 
                value = "Test client"),
      downloadButton("generate", "Generate Report", #icon = icon("file"), 
                     style = "color: #fff; background-color: #337ab7; border-color: #2e6da4")
      ),
    
  # Show a plot of the generated distribution
    mainPanel(
      p("Just trying to recreate beamer .pdf download issues with an app that doesn't have
        proprietary information.")
    )
  )
))
