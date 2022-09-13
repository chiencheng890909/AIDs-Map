library(shiny)
library(dplyr)
library(plotly)
library(ggplot2)
library(leaflet)

shinyServer(function(input, output){
  datasetInput <- reactive({
    Years = input$Years
    Months = input$Months
    x = AIDS %>% filter(AIDS診斷年份 >= Years[1]) %>% filter(AIDS診斷年份 <= Years[2])%>% 
        filter(AIDS診斷月份 >= Months[1]) %>% filter(AIDS診斷月份 <= Months[2])
    
    if(input$age != "All")
      x = x %>% filter(診斷年齡分組 == input$age)
    if(input$Site != "All")
      x = x %>% filter(縣市別 == input$Site)
    x = x[,-5]
    x
  })
  output$downloadData <- downloadHandler(
    filename = "AIDS.csv",
    content = function(file) {
      write.csv(datasetInput(), file, row.names = TRUE,fileEncoding = "UTF-8")
    }
  )
  output$table <- renderTable({
    x = datasetInput()
    if(input$Type == 1)
      x
    else if(input$Type == 2) {
      Total = unique(x[,3])
      Total = data.frame(縣市別 = Total,男性 = c(0),女性 = c(0))
      for (i in 1:nrow(Total)) {
        y = x %>% filter(縣市別 == Total[i,1])
        z = y %>% filter(性別 == "男")
        Total[i,2] = sum(z[,5])
        z = y %>% filter(性別 == "女")
        Total[i,3] = sum(z[,5])
      }
      Total[,2] = as.character(Total[,2])
      Total[,3] = as.character(Total[,3])
      Total
    }
  })
  output$plotly <- renderPlotly({
    if(input$Choices == 1) {
      p = plot_ly(data = datasetInput(), labels = ~縣市別, values = ~個案數,type = "pie") %>%
        layout(xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
               yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
    }
    else if(input$Choices == 2)
      p = plot_ly( data = datasetInput(),x = ~縣市別,y = ~個案數,name = "AIDs",type = "bar")
    else {
      p = plot_ly(data = datasetInput(), x = ~AIDS診斷年份, y = ~AIDS診斷月份,
                  type = 'scatter', mode = 'markers',text = ~個案數,
                  marker = list(size = ~個案數, opacity = 0.5))
    }
    p
  })
  output$map <- renderLeaflet({
    m = leaflet() %>% addTiles() %>% setView(120.58, 23.58, zoom = 7)
    x = datasetInput()
    Total = unique(x[,3])
    Total = data.frame("縣市別" = Total,Man = c(0),Woman = c(0))
    for (i in 1:nrow(Total)) {
      y = x %>% filter(縣市別 == Total[i,1])
      z = y %>% filter(性別 == "男")
      Total[i,2] = sum(z[,5])
      z = y %>% filter(性別 == "女")
      Total[i,3] = sum(z[,5])
    }
    Total = merge(x = Total,y = Counties, by="縣市別",all=FALSE)
    for(i in 1:nrow(Total)) {
      m = addMarkers(m, lng=Total[i,4], lat=Total[i,5],
                 popup=paste(Total[i,1],"男性：",Total[i,2],"女性：",Total[i,3]))
    }
    m
  })
})
