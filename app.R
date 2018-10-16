#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
options(shiny.maxRequestSize=800*1024^2) 
library(shiny)
library(leaflet)
library(geojsonio)
library(dplyr)
library(ggplot2)
library(reshape2)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Trips"),
   sidebarLayout(
     
     sidebarPanel(
       fileInput(inputId = "logFile", label = "Select file", accept = c(".csv"))
      ),
     
     mainPanel(
       tabsetPanel(
         type = "tabs",
         tabPanel(
           "Table",
            fluidRow(
              #verbatimTextOutput(outputId = "CountText"),
              tableOutput(outputId = "contentTable")
            )
         ),
         tabPanel(
           "Consumption with RPM",
           fluidRow(
             #verbatimTextOutput(outputId = "CountText"),
             plotOutput(outputId = "ConRPMGraph")
           )
         )
       )
     )
   )
   #leafletOutput("tripMap")
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  #output$tripMap <- renderLeaflet({
  #  inFile <- input$tripFile
  #  if(is.null(inFile)) return (NULL)
    #trip <- geojsonio::geojson_read("GeoJson/geo_trackLog-2018-sept.-04_07-28-47.geojson")
  #  trip <- geojsonio::geojson_read(inFile$datapath)
  #  leaflet(trip)
  #})
  
  #Get data via reactive
  dataSet <- reactive({
    inFile <- input$logFile
    if(is.null(inFile)) return (NULL)
    return (data.frame(read.csv(inFile$datapath, header = TRUE)))
  })
  
  #Get specific subset from reactive dataset
  ConRPMSet <- reactive({
    if(is.null(dataSet())) return (NULL)
    ConRPM <- data.frame(
      timeRegister <- dataSet()$Device.Time,
      rpm <-  as.numeric(dataSet()$Engine.RPM.rpm.),
      consumption <- as.numeric(dataSet()$Fuel.flow.rate.minute.cc.min.),
      pedalPosition <- as.numeric(dataSet()$Accelerator.PedalPosition.D...),
      speed <- as.numeric(dataSet()$Speed..OBD..km.h.),
      drivingStyle <- dataSet()$Driving.Style
    )
    colnames(ConRPM)[1] <- 'time'
    colnames(ConRPM)[2] <- 'rpm'
    colnames(ConRPM)[3] <- 'consumption'
    colnames(ConRPM)[4] <- 'pedalPosition'
    colnames(ConRPM)[5] <- 'speed'
    print(ConRPM)
    return (ConRPM)
  })
  
  #Correlation matrix
  CorMat <- reactive({
    meltedCM <- head(melt(head(round(cor(ConRPMSet(), 2)))))
    print(meltedCM)
    return (meltedCM)
  })
  
  #Output data table
  output$contentTable <- renderTable({ dataSet() })
  
  #Output count
  #output$CountText <- renderText({paste("Row count:", toString(nrow(ConRPMSet())), " Col count:",toString(ncol(ConRPMSet()))) })
  
  #Output plot
  output$ConRPMGraph <- renderPlot({
    chartTitle <- "Consumption with engine RPM"
    chartData <- ConRPMSet()
    ggplot(
      data = ConRPMSet()
    )
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

