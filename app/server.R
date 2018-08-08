#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(rmarkdown)

# Define server logic required to pull and process data
shinyServer(function(input, output) {


  dat <- 
    reactive({
      set.seed(input$seed, input$algo)
      data.frame(x = rnorm(input$n), 
                 y = rnorm(input$n))
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
        params <- list(data = dat())
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
