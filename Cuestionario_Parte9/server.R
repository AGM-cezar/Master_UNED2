#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
library(shiny)
library(rworldmap)
library(ggplot2)
library(data.table)
library(dplyr)
library(RCurl)

coords2country = function(points) {  
  countriesSP <- getMap(resolution='low')
  pointsSP = SpatialPoints(points, proj4string=CRS(proj4string(countriesSP)))  
  indices = over(pointsSP, countriesSP)
  indices$ADMIN  
}

meteoritos <- as.data.table(read.csv(text = getURL("https://raw.githubusercontent.com/AGM-cezar/Master_UNED2/master/Cuestionario_Parte9/Meteorite_Landings.csv")))
ImpactsUnfiltered <- na.omit(meteoritos[,.(Impact = name, Mass = mass..g./1000, Year = year, Latitude=reclat, Longitude=reclong)])
ImpactsUnfiltered[,Year := as.numeric(format(as.Date(substring(ImpactsUnfiltered[,Year],0,10), format="%d/%m/%Y"),"%Y"))]
ImpactsUnfiltered[,Century := ifelse(as.numeric(substring(Year,0,2))+1 > 21, NA, as.numeric(substring(Year,0,2))+1) ]
ImpactsUnfiltered[,Country := coords2country(data.frame(lon=ImpactsUnfiltered$Longitude, lat=ImpactsUnfiltered$Latitude))]
ImpactsCountryYear = unique(na.omit(ImpactsUnfiltered[Country != "Antarctica"][ , .(n_impacts = .N, TotalMass = sum(Mass), AverageMass = mean(Mass), Century), by = list(Country, Year) ]))
ImpactsCountryYearAnt = unique(na.omit(ImpactsUnfiltered[ , .(n_impacts = .N, TotalMass = sum(Mass), AverageMass = mean(Mass), Century), by = list(Country, Year) ]))
ImpactsCentury = unique(na.omit(ImpactsUnfiltered[ , .(n_impacts = .N, TotalMass = sum(Mass), AverageMass = mean(Mass)), by = Century ]))
ImpactsCountryAnt = unique(na.omit(ImpactsUnfiltered[ , .(n_impacts = .N, TotalMass = sum(Mass), AverageMass = mean(Mass)), by = Country ]))
ImpactsCountryAnt = head(arrange(ImpactsCountryAnt, desc(n_impacts)),5)

mapamundi <- fortify(getMap(resolution = "low"))

#-----------------------------------------------------------------------------------

shinyServer(function(input, output) {
   
  output$centuryboxes <- renderPlot({
    ggplot(ImpactsCentury[ , n_impacts, by = Century], aes(x=Century, y=n_impacts)) + geom_bar(stat="identity", fill="red")
  })
  
  output$scatterworld <- renderPlot({
    ggplot(ImpactsUnfiltered) + 
      geom_polygon(data = mapamundi, aes(x=mapamundi$long, y = mapamundi$lat, group = group), fill = NA, color = "grey") +
      geom_point(aes(x=ImpactsUnfiltered$Longitude, y=ImpactsUnfiltered$Latitude), col="red", size=0.1)
  })
  
  output$antarctica <- renderTable(ImpactsCountryAnt)
  
  output$Map <- renderPlot({
    graph = ggplot(ImpactsCountryYear[Year >= input$range_years[1] & Year <= input$range_years[2]]) +
      geom_polygon(data = mapamundi, aes(x=mapamundi$long, y = mapamundi$lat, group = group), fill = NA, color = "black") +
      expand_limits(x = mapamundi$long,
                    y = mapamundi$lat) +
      scale_fill_gradient(low = unlist(strsplit(input$color_i, "[|]"))[1], high = unlist(strsplit(input$color_i, "[|]"))[2])+
      scale_x_continuous(breaks = NULL) +
      scale_y_continuous(breaks = NULL) + 
      labs(list(x = "", y = "", fill = ""))
    if (input$variable=="Number of Impacts") {
      graph = graph + geom_map(aes(map_id = Country, fill=n_impacts), map = mapamundi, colour="black")+
        ggtitle("Number of impacts per year range")
    } else if (input$variable=="Total Mass") {
      graph = graph + geom_map(aes(map_id = Country, fill=TotalMass), map = mapamundi, colour="black")+
        ggtitle("Total mass of impacts per year range")
    } else if (input$variable=="Average Mass") {
      graph = graph + geom_map(aes(map_id = Country, fill=AverageMass), map = mapamundi, colour="black")+
        ggtitle("Average mass of impacts per year range")
    }
    graph
  })

  output$Bar <- renderPlot({
    
    if (input$variable=="Number of Impacts") {
      ggplot(ImpactsCountryYear[Year >= input$range_years[1] & Year <= input$range_years[2]][ , n_impacts, by = Year], aes(x=Year, y=n_impacts)) + geom_bar(stat="identity", fill=unlist(strsplit(input$color_i, "[|]"))[2])
    } else if (input$variable=="Total Mass") {
      ggplot(ImpactsCountryYear[Year >= input$range_years[1] & Year <= input$range_years[2]][ , TotalMass, by = Year], aes(x=Year, y=TotalMass)) + geom_bar(stat="identity", fill=unlist(strsplit(input$color_i, "[|]"))[2])
    } else if (input$variable=="Average Mass") {
      ggplot(ImpactsCountryYear[Year >= input$range_years[1] & Year <= input$range_years[2]][ , AverageMass, by = Year], aes(x=Year, y=AverageMass)) + geom_bar(stat="identity", fill=unlist(strsplit(input$color_i, "[|]"))[2])
    }
  })
})
