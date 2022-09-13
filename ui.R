library(shiny)
library(plotly)
library(leaflet)

shinyUI(fluidPage(
  titlePanel("各縣市AIDS分布"), 
  sidebarLayout(
    sidebarPanel(
      sliderInput("Years", "Years：", value = c(1985,2017), min = 1985, max = 2017),
      sliderInput("Months", "Months：", value = c(1,12), min = 1, max = 12),
      selectInput("age", "Age：",choices = c("All",unique(AIDS[,5]))),
      selectInput("Site", "地區:", choices = c("All",Counties[,1])),
      radioButtons("Type", label = "列表選擇",
                   choices = list("個案列表" = 1,
                                  "地區總數列表" = 2
                                  ), 
                   selected = 1),
      radioButtons("Choices", label = "圖表選擇",
                   choices = list("Pie Charts (地區比例分析)" = 1,
                                  "Bar Charts (地區總數分析)" = 2,
                                  "Bubble Charts(時間分析)" = 3), 
                   selected = 1),
      submitButton("Search"),
      br(),
      downloadButton("downloadData", "個案列表下載")
    ),   
    mainPanel(
      tabsetPanel(type = "tabs",
        tabPanel("列表", tableOutput("table")),
        tabPanel("圖表分析",plotlyOutput("plotly")),
        tabPanel("地圖展示",leafletOutput("map"))
      )       
    )
  )
))
