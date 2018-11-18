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

BdataLabels <- c('Régime moteur (tr/min)', 'Consommation (cc/min)', 'Position de la pédale accélérateur (%)', 'Vitesse (km/h)', 'Charge moteur (%)', 'Altitude (m)', 'Pression de l air en entrée (psi)', 
                 'Temperature de l air en entrée (C)', 'Puissance moteur (KW)', 'Temperature du liquide de refroidissement (C)', 'Position de l accélérateur au collecteur d admission (%)')
UdataLabels <- c('Régime moteur (tr/min)', 'Consommation (cc/min)', 'Position de la pédale accélérateur (%)', 'Vitesse (km/h)', 'Charge moteur (%)', 'Altitude (m)', 'Pression de l air en entrée (psi)',
                 'Temperature de l air en entrée (C)', 'Puissance moteur (KW)', 'Temperature du liquide de refroidissement (C)', 'Position de l accélérateur au collecteur d admission (%)', 'Style de conduite')

# Define UI for application that draws a histogram
ui <- fluidPage(
   
  #theme = "bootstrap.css",
   # Application title
   titlePanel("Trips"),
     tabsetPanel(
       type = "tabs",
       
       tabPanel(
         "Analyse",
         sidebarLayout(
           sidebarPanel(
             
           ),
           mainPanel(
            includeMarkdown("Analyse.md")
           )
         )
       ),
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
              leafletOutput(outputId = "TestMap", height = 600),
              plotOutput(outputId = "UVariateLine"),
              plotOutput(outputId = "UDist"),
              plotOutput(outputId = "UDens")
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
  dataSet <- data.frame(read.csv("./Datasets/CarLogs1.csv", header = TRUE))
  
  #Get specific subset from reactive dataset
  ConRPM <- data.frame(
    timeRegister <- strptime(gsub('-', '.', dataSet$Device.Time), "%d/%m/%Y %H:%M:%OS"),
    rpm <-  as.numeric(dataSet$Engine.RPM.rpm.),
    consumption <- as.numeric(substr(dataSet$Fuel.flow.rate.minute.cc.min., 1, 5)),
    pedalPosition <- as.numeric(substr(dataSet$Accelerator.PedalPosition.D..., 1, 4)),
    speed <- as.numeric(dataSet$Speed..OBD..km.h.),
    drivingStyle <- as.character(dataSet$Driving.Style),
    longitude <- dataSet$Longitude,
    latitude <- dataSet$Latitude,
    engineLoad <- as.numeric(substr(dataSet$Engine.Load..., 1, 5)),
    altitude <- as.numeric(substr(dataSet$Altitude, 1, 5)),
    intakAirPressure <- as.numeric(substr(dataSet$Intake.Manifold.Pressure.psi., 1, 5)),
    intakAirTemp <- as.numeric(substr(dataSet$Intake.Air.Temperature.Â.C., 1, 5)),
    puissanceMoteur <- as.numeric(substr(dataSet$Engine.kW..At.the.wheels..kW., 1, 5)),
    coolantTemp <- as.numeric(substr(dataSet$Engine.Coolant.Temperature.Â.C., 1, 5)),
    throttlePositionManifold <- as.numeric(substr(dataSet$Throttle.Position.Manifold...., 1, 5))
  )
  colnames(ConRPM)[1] <- 'Temps'
  colnames(ConRPM)[2] <- 'Régime moteur (tr/min)'
  colnames(ConRPM)[3] <- 'Consommation (cc/min)'
  colnames(ConRPM)[4] <- 'Position de la pédale accélérateur (%)'
  colnames(ConRPM)[5] <- 'Vitesse (km/h)'
  colnames(ConRPM)[6] <- 'Style de conduite'
  colnames(ConRPM)[7] <- 'Longitude'
  colnames(ConRPM)[8] <- 'Latitude'
  colnames(ConRPM)[9] <- 'Charge moteur (%)'
  colnames(ConRPM)[10] <- 'Altitude (m)'
  colnames(ConRPM)[11] <- 'Pression de l air en entrée (psi)'
  colnames(ConRPM)[12] <- 'Temperature de l air en entrée (C)'
  colnames(ConRPM)[13] <- 'Puissance moteur (KW)'
  colnames(ConRPM)[14] <- 'Temperature du liquide de refroidissement (C)'
  colnames(ConRPM)[15] <- 'Position de l accélérateur au collecteur d admission (%)'
  
  #BiVariate analysis retrieve selected variables
  selectedBivariate <- reactive({
    data.frame(ConRPM[, c(input$Bxcol, input$Bycol, "Style de conduite", "Temps")])
  })
  
  #Covariance and Correlation 
  BMatrix <- reactive({
    data.frame(
      Covariance <- cov(x = as.numeric(selectedBivariate()[1][,1]), y = as.numeric(selectedBivariate()[2][,1]), use="complete.obs", method = "kendall"),
      Correlation <- cor(x = as.numeric(selectedBivariate()[1][,1]), y = as.numeric(selectedBivariate()[2][,1]),  use="complete.obs", method = "kendall")
    )
  })
    
  #UniVariate analysis retrieve selected variable
  selectedUnivariate <- reactive({
    ddf <- data.frame(ConRPM[, c(input$Uvar, "Style de conduite", "Temps", "Longitude", "Latitude")])
    colnames(ddf)[1] <- 'var1'
    return (ddf)
  })
  
  pal <- reactive({
    createColor <-  colorRampPalette(c('blue', 'red'), length(selectedUnivariate()[complete.cases(selectedUnivariate()),][1][,1]))
    
    if (input$Uvar == 'Vitesse (km/h)') {
      result <- "FF0000"
    }
    else {
      ress <- colorNumeric(
        palette = createColor(selectedUnivariate()[complete.cases(selectedUnivariate()),][1][,1]),
        domain = selectedUnivariate()[complete.cases(selectedUnivariate()),][1][,1]
      )
      result <- ress(selectedUnivariate()[complete.cases(selectedUnivariate()),][1][,1])
    }
    return(result)
  })
  #Frequence dataframe for the univariate Analysis
  UFreq <- reactive({
    data.frame(table(selectedUnivariate))
  })
  
  #Output data table
  output$contentTable <- renderTable({ ConRPM })
  
  #Text output plot in order to print the cov and cor
  output$BCorCovText <- renderText({
    paste(input$Bxcol, "\n", summary(selectedBivariate()[1][,1]), "\n")
    paste(input$Bycol, "\n", summary(selectedBivariate()[2][,1]), "\n")
    paste("Covariance : ", BMatrix()[1][,1], "\nCoeff. Correlation (Kendall) : ", BMatrix()[2][,1])
  })
  
  #Output BiVariate plot Points
  output$BVariatePoints <- renderPlot({
    chartTitle <- "Nuage de points en fonction du style de conduite"
    chartData <- selectedBivariate()
    ggplot(data = selectedBivariate(), color = selectedBivariate()[1][,1]) + geom_point(mapping = aes(x = selectedBivariate()[1][,1], y = as.numeric(selectedBivariate()[2][,1]), color = selectedBivariate()[3][,1])) + labs(x = input$Bxcol, y = input$Bycol, color = "Style de conduite") + scale_x_discrete() + ggtitle(paste("Nuage de point: ", input$Bxcol, " en fonction de ", input$Bycol))
  })
  
  
  #Output Bivariate Plot Lines
  output$BVariateLine <- renderPlot({
    modifyForm <- 1
    if (input$Bycol == "Position accélérateur")
      modifyForm <- 1
    else
      modifyForm <- 1
    
    ggpl <- ggplot(group = 1, data = selectedBivariate(), aes(x = selectedBivariate()[4][,1])) + geom_line(aes(y = as.numeric(selectedBivariate()[1][,1]), color = input$Bxcol)) + labs(x = "Temps", y = input$Bxcol, color = "Style de conduite") + ggtitle(paste("Télémétrie du trajet: ", input$Bxcol, " avec ", input$Bycol)) + scale_y_continuous(sec.axis = sec_axis(~.*modifyForm, name = input$Bycol))  + geom_line(aes(y = as.numeric(selectedBivariate()[2][,1])*modifyForm, color = input$Bycol))
    
    return(ggpl)
  })
  
  #Output Bivariate Plot Lines
  output$UVariateLine <- renderPlot({
    ggplot(group = 1, data = selectedUnivariate(), aes(x = selectedUnivariate()[3][,1])) + geom_line(aes(y = as.numeric(selectedUnivariate()[1][,1]), color = input$Uvar)) + labs(x = "Temps", y = input$Uvar, color = "Légende") + ggtitle(paste("Valeurs du trajet pour la variable ", input$Uvar))
  })
  
  #Output Distribution for Univariate analysis hist
  output$UDist <- renderPlot({
    if (input$Uvar != "Style de conduite")
    ggplot(data = selectedData, aes(selectedUnivariate()[1][,1], color = selectedUnivariate()[2][,1])) + geom_histogram() + labs(x= input$Uvar, color = "Style de conduite") + ggtitle(paste("Fréquence de ", input$Uvar, " en fonction du style de conduite"))
  })
  
  #Output Distribution for Univariate analysis line
  output$UDens <- renderPlot({
    if (input$Uvar != "Style de conduite")
      ggplot(data = selectedData, aes(selectedUnivariate()[1][,1], color = selectedUnivariate()[2][,1])) + geom_density() + labs(x= input$Uvar, color = "Style de conduite") + ggtitle(paste("Densité de ", input$Uvar, " en fonction du style de conduite"))
  })
  
  
  #Output Map
  output$TestMap <- renderLeaflet({
    leaflet(data = selectedUnivariate()) %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = 2.3522219, lat = 48.856614, zoom = 11) %>% addPolylines(lng = ~longitude, lat =~latitude) %>%
      addCircleMarkers(radius = 2, color = pal(), label = ~as.character(var1)) #%>%
      #addLegend("bottomright", pal = pal(), values = ~as.character(var1),
      #          title = input$Uvar,
      #          opacity = 1)
  })
  
  #Summary for the Univariate Analysis
  output$USummary <- renderText({
    summary(selectedUnivariate()[1])
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

