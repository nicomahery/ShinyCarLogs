#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(fmsb)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Old Faithful Geyser Data"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput(outputId = "radarC")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
  data=as.data.frame(matrix( sample( 0:20 , 15 , replace=F) , ncol=5))
  colnames(data)=c("maths" , "anglais" , "svt" , "sport" , "physique" )
  rownames(data)=paste("Elève " , letters[1:3] , sep="-")
  data=rbind(rep(20,5) , rep(0,5) , data)
  
  
  colors_border=c( rgb(0.2,0.5,0.5,0.9), rgb(0.8,0.2,0.5,0.9) , rgb(0.7,0.5,0.1,0.9))
  colors_in=c( rgb(0.2,0.5,0.5,0.4), rgb(0.8,0.2,0.5,0.4) , rgb(0.7,0.5,0.1,0.4) )
  
  output$radarC <- renderPlot(radarchart(
    data,
    axistype=1,
    pcol=colors_border , pfcol=colors_in , plwd=4 , plty=1,
    vlcex=0.8
    ))
  output$legend <- legend(x=0.7, y=1, legend = rownames(data[-c(1,2),]), bty = "n", pch=20 , col=colors_in , text.col = "grey", cex=1.2, pt.cex=3)
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)

