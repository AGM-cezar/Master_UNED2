#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

shinyUI(
  navbarPage("Shiny App",
    tabPanel("Analysis Description",
      mainPanel(
       h1("Advanced Visualization Module", align = "center"),
       h2("Created by Adrian GARCIA MARTINEZ", align = "center"),
       p("This is my solution to the Advanced Visualization Module of UNED Big Data's 
         masters degree."),
       p("It is a simple app organized in two main tabs, a description tab and an analysis tab that
         includes several sub layers with a map and a bars diagram to explore the NASA dataset on meteorite impacts."),
       p(""),
       h3("NASA Meteorite impacts dataset description"),
       p("This open data set contains information on incidents location, mass, composition and date.
         It is a large dataset that may be exploited in many ways. My analysis approach is simply to  
         explore the impact locations in the last century to try to draw conclusions on its behavior."),
       p("The exploration may be performed on the analysis tab by manipulation of the date range."),
       h4("Conclussions"),
       p("The first conclussion to which I converged was the fact that past data is too incomplete, from 
         a geopolitical point of view, to compare. That is why I decided to restrain the limits from 1900s to 2010s."),
       plotOutput("centuryboxes"),
       p("The second conclussion is that a scatter plot does not give much information because of the 
         cumulation of occurrences at similar coordinates. Specially in the Antarctica that may be maintained out of the comparison because of
         the large quantity of meteorite incidents registered. This is maybe due to the fact that its surface is larger
         and they are also easier to locate in Antarctica partly because of the contrast between dark rocks and white ice sheet."),
       plotOutput("scatterworld"),
       tableOutput("antarctica"),
       p("Without further study of this data I would say that the meteorite location is quite random and no country is
         more likeable to receive impacts that the others.")
       )
      ),
    tabPanel("Meteorite Analysis",  
      headerPanel(h1('Meteorite Incidents - An Interactive Shiny App', align = 'center')),
      #titlePanel("Control Panel"),
      sidebarLayout(
        sidebarPanel(
          h4("Control Panel",align = 'center'),
          sliderInput("range_years", "Range of years for visualization:",
                       min = 1900,
                       max = 2017,
                       value = c(1900, 2017)),
          selectInput("variable", 
                      label = "Parameter to be visualized:",
                      choices = c("Number of Impacts", 
                                  "Total Mass",
                                  "Average Mass"),
                      selected = "Number of Impacts"),
          radioButtons("color_i", label= "Color for the visualization:",
                       choiceNames = c("green","red", "blue"),
                       choiceValues = c("#edf8e9|#238b45", "#fee5d9|#cb181d", "#eff3ff|#2171b5")
                       )),
    
        mainPanel(
          tabsetPanel(
            tabPanel("World Map Location",
                     h4("Meteorites impact location by country"),
                     p("The following chart allows a fast visualization of the incident's location by using the coordinates of longitude and latitude. The advantage given by the use of maps polygons to delimitate the frontiers of countries, allows a clean visualization by color fill. This is easier to interpretate than a scatter plot of point locations."),
                     p("The recomended color to visualize these results is <red>."),
                     p("Although data is available for a larger range of years from the sixteen century, I have prefered to delimitate this data to avoid inequalties on the sources: In my understanding, last century data is the most complete available. Also, and for reasons out of the scope of this analysis, the Antarctica presents a large quantity of registered impacts that is not comparable to the rest of countries and thus, for comparison reasons, I have deleted it from the data set. "),
                     plotOutput("Map")), 
            tabPanel("Bars diagram per year",
                     h4("Meteorites impact time series"),
                     p("This bars diagram allows a time series visualization of the chosen variable. The interest being to complete the information given by the location chart."),
                     plotOutput("Bar"))
        ))
      )
    )
  )
)
