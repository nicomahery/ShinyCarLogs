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

BdataLabels <- c('Régime moteur', 'Consommation', 'Position accélérateur', 'Vitesse')
UdataLabels <- c('Régime moteur', 'Consommation', 'Position accélérateur', 'Vitesse', 'Style de conduite')

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Trips"),
   
     tabsetPanel(
       type = "tabs",
       tabPanel(
         "Données",
          fluidRow(
            #verbatimTextOutput(outputId = "CountText"),
            tableOutput(outputId = "contentTable")
          )
       ),
       tabPanel(
         "Analyse Bivariée",
         sidebarLayout(
           sidebarPanel(
             selectInput('Bxcol', 'Variable X', BdataLabels),
             selectInput('Bycol', 'Variable Y', BdataLabels, selected = BdataLabels[2])
           ),
           
           mainPanel(
             fluidRow(
               verbatimTextOutput(outputId = "BCorCovText"),
               plotOutput(outputId = "BVariatePoints"),
               plotOutput(outputId = "BVariateLine")
           )
         )
       )
      ),
      tabPanel(
        "Analyse Univariée",
        sidebarLayout(
          sidebarPanel(
            selectInput('Uvar', 'Variable', UdataLabels)
          ),
          
          mainPanel(
            fluidRow(
              verbatimTextOutput(outputId = "USummary"),
              plotOutput(outputId = "UPie"),
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
  
  #Get data via file
  dataSet <- data.frame(read.csv("./Datasets/CarLog1.csv", header = TRUE))
  
  #Get specific subset from reactive dataset
  ConRPM <- data.frame(
    timeRegister <- strptime(gsub('-', '.', dataSet$Device.Time), "%d/%m/%Y %H:%M:%OS"),
    rpm <-  as.numeric(dataSet$Engine.RPM.rpm.),
    consumption <- as.numeric(substr(dataSet$Fuel.flow.rate.minute.cc.min., 1, 5)),
    pedalPosition <- as.numeric(substr(dataSet$Accelerator.PedalPosition.D..., 1, 4)),
    speed <- as.numeric(dataSet$Speed..OBD..km.h.),
    drivingStyle <- as.character(dataSet$Driving.Style),
    longitude <- dataSet$Longitude,
    latitude <- dataSet$Latitude
  )
  colnames(ConRPM)[1] <- 'Temps'
  colnames(ConRPM)[2] <- 'Régime moteur'
  colnames(ConRPM)[3] <- 'Consommation'
  colnames(ConRPM)[4] <- 'Position accélérateur'
  colnames(ConRPM)[5] <- 'Vitesse'
  colnames(ConRPM)[6] <- 'Style de conduite'
  colnames(ConRPM)[7] <- 'Longitude'
  colnames(ConRPM)[8] <- 'Latitude'
  
  #BiVariate analysis retrieve selected variables
  selectedBivariate <- reactive({
    data.frame(ConRPM[, c(input$Bxcol, input$Bycol, "Style de conduite", "Temps")])
  })
  
  BMatrix <- reactive({
    data.frame(
      Covariance <- cov(x = as.numeric(selectedBivariate()[1][,1]), y = as.numeric(selectedBivariate()[2][,1]), use="complete.obs", method = "kendall"),
      Correlation <- cor(x = as.numeric(selectedBivariate()[1][,1]), y = as.numeric(selectedBivariate()[2][,1]),  use="complete.obs", method = "kendall")
    )
  })
    
  #UniVariate analysis retrieve selected variable
  selectedUnivariate <- reactive({
    data.frame(ConRPM[, c(input$Uvar, "Style de conduite", "Temps")])
  })
  
  #Correlation matrix
  CorMat <- reactive({
    meltedCM <- head(melt(head(round(cor(ConRPM, 2)))))
    print(meltedCM)
    return (meltedCM)
  })
  
  #Output data table
  output$contentTable <- renderTable({ ConRPM })
  
  output$BCorCovText <- renderText({
    paste(input$Bxcol, "\n", summary(selectedBivariate()[1][,1]), "\n")
    paste(input$Bycol, "\n", summary(selectedBivariate()[2][,1]), "\n")
    paste("Covariance : ", BMatrix()[1][,1], "\nCoeff. Correlation (Kendall) : ", BMatrix()[2][,1])
  })
  
  #Output BiVariate plot Points
  output$BVariatePoints <- renderPlot({
    chartTitle <- "Nuage de points en fonction du style de conduite"
    chartData <- selectedBivariate()
    ggplot(data = selectedBivariate()) + geom_point(mapping = aes(x = selectedBivariate()[1][,1], y = as.numeric(selectedBivariate()[2][,1]), color = selectedBivariate()[3][,1])) + labs(x = input$Bxcol, y = input$Bycol, color = "Driving Style") + scale_x_discrete()
  })
  
  
  #Output Bivariate Plot Lines
  output$BVariateLine <- renderPlot({
    
    ggplot(group = 1, data = selectedBivariate(), aes(x = selectedBivariate()[4][,1])) + geom_line(aes(y = as.numeric(selectedBivariate()[1][,1]), color = input$Bxcol)) + geom_line(aes(y = as.numeric(selectedBivariate()[2][,1]), color = input$Bycol)) + labs(x = "Temps", y = input$Bxcol) + scale_y_continuous(sec.axis = sec_axis(~.*1, name = input$Bycol)) + guides(fill=guide_legend(title="Légende")) 
  })
  
  #Output Pie for Univariate analysis
  output$UPie <- renderPlot({
    pie(selectedUnivariate(), x= table(selectedUnivariate()[1][,1]),labels= selectedUnivariate()[2][,1])
  })
  
  #Output Map
  output$TestMap <- renderLeaflet({
    leaflet(data = ConRPM) %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = 2.3522219, lat = 48.856614, zoom = 10) %>% addPolylines(lng = ~longitude, lat =~latitude)
  })
  
  #Summary for the Univariate Analysis
  output$USummary <- renderText({
    summary(selectedUnivariate()[1])
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

