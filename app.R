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

BdataLabels <- c('rpm', 'consumption', 'pedalPosition', 'speed')
UdataLabels <- c('rpm', 'consumption', 'pedalPosition', 'speed', 'DrivingStyle')

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Trips"),
   
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
         "Bivariate Analysis",
         sidebarLayout(
           sidebarPanel(
             selectInput('Bxcol', 'Variable X', BdataLabels),
             selectInput('Bycol', 'Variable Y', BdataLabels, selected = BdataLabels[2])
           ),
           
           mainPanel(
             fluidRow(
               #verbatimTextOutput(outputId = "CountText"),
               plotOutput(outputId = "BVariatePoints"),
               plotOutput(outputId = "BVariateLine")
           )
         )
       )
      ),
      tabPanel(
        "Univariate Analysis",
        sidebarLayout(
          sidebarPanel(
            selectInput('Uvar', 'Variable', UdataLabels)
          ),
          
          mainPanel(
            fluidRow(
              #verbatimTextOutput(outputId = "CountText"),
              plotOutput(outputId = "UVariatePoints"),
              leafletOutput(outputId = "TestMap")
            )
          )
        )
      )
    )
)
   #leafletOutput("tripMap")

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
  dataSet <- data.frame(read.csv("./Datasets/CarLog1.csv", header = TRUE))
  
  #Get specific subset from reactive dataset
  ConRPM <- data.frame(
    timeRegister <- strptime(gsub('-', '.', dataSet$Device.Time), "%d/%m/%Y %H:%M:%OS"),
    rpm <-  dataSet$Engine.RPM.rpm.,
    consumption <- substr(dataSet$Fuel.flow.rate.minute.cc.min., 1, 5),
    pedalPosition <- substr(dataSet$Accelerator.PedalPosition.D..., 1, 4),
    speed <- dataSet$Speed..OBD..km.h.,
    drivingStyle <- as.character(dataSet$Driving.Style)
  )
  colnames(ConRPM)[1] <- 'time'
  colnames(ConRPM)[2] <- 'rpm'
  colnames(ConRPM)[3] <- 'consumption'
  colnames(ConRPM)[4] <- 'pedalPosition'
  colnames(ConRPM)[5] <- 'speed'
  colnames(ConRPM)[6] <- 'DrivingStyle'
  print(ConRPM)
  
  #BiVariate analysis retrieve selected variables
  selectedBivariate <- reactive({
    data.frame(ConRPM[, c(input$Bxcol, input$Bycol, "DrivingStyle", "time")])
  })
  
  #UniVariate analysis retrieve selected variable
  selectedUnivariate <- reactive({
    data.frame(ConRPM[, c(input$Uvar, "DrivingStyle")])
  })
  
  #Correlation matrix
  CorMat <- reactive({
    meltedCM <- head(melt(head(round(cor(ConRPM, 2)))))
    print(meltedCM)
    return (meltedCM)
  })
  
  #Output data table
  #output$contentTable <- renderTable({ dataSet })
  output$contentTable <- renderTable({ ConRPM })
  
  #Output BiVariate plot Points
  output$BVariatePoints <- renderPlot({
    chartTitle <- "Nuage de points en fonction du style de conduite"
    chartData <- selectedBivariate()
    ggplot(data = selectedBivariate()) + geom_point(mapping = aes(x = selectedBivariate()[1][,1], y = as.numeric(selectedBivariate()[2][,1]), color = selectedBivariate()[3][,1])) + labs(x = input$Bxcol, y = input$Bycol, color = "Driving Style") + scale_x_discrete()
  })
  
  
  #Output Bivariate Plot Lines
  output$BVariateLine <- renderPlot({
    #ggplot(data=selectedBivariate(), aes(x = ConRPM$time)) + geom_line(aes(y = selectedBivariate()[1][,1]), color="red") + geom_line(aes(y = selectedBivariate()[3][,1]), color="green")  + labs(x = ConRPM$time, y = input$Bycol) + scale_x_continuous() + scale_y_continuous()#+ geom_point()
    ggplot(group = 1, data = selectedBivariate(), aes(x = selectedBivariate()[4][,1])) + geom_line(aes(y = as.numeric(selectedBivariate()[1][,1])), color = "blue") + geom_line(aes(y = as.numeric(selectedBivariate()[2][,1])), color = "red") + labs(x = "Time", y = input$Bxcol)
  })
  
  #Output Map
  output$TestMap <- renderLeaflet({
    map <- leaflet() %>%
      addProviderTiles(providers$OpenStreetMap.France)
      setView(lng = 48.8566, lat = 2.3522, zoom = 12)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

