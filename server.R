

library(shiny)
library(tigris)
library(readr) 
library(sf)
library(leaflet) 
library(dplyr) # for %>% 

black_income <- read_rds("black_income.rds")
state_county <- read_rds("state_county.rds")
pal <- colorBin("Greens",domain = c(1:5))

shinyServer(function(input, output) {
# Render the UI for the State and County selection 
  
  selected_state <- reactive({ 
    input$state_select
    })
  output$county_selection <- renderUI({
    if(is.null(selected_state())){ 
      NULL 
      } else 
    selectInput(inputId = "county_select",
                label = "Select a County",
                choices = state_county[state_county$State == selected_state()
                                       ,"County"],multiple = FALSE,selected = NULL)
  })
  
# Accept the state and county selection to subset the data 
  
selected_black_income <- eventReactive(input$begin,{
 
  # select state, county, and relevant columns 
  temp. = black_income[black_income$State == input$state_select & 
                 black_income$County == input$county_select,c(
                   "GEO.id","GEO.id2","GEO.display.label","HD01_VD01",
                   "under15k","15k-40k", "40k-75k", "75k-125k", "125k+",            
                    "State","County") ]
  
  income_classes <- c("under15k","15k-40k", "40k-75k", "75k-125k", "125k+")

  # identify the income class of the median person 
  median_income_class = NULL
  for(i in 1:nrow(temp.)){ 
    t. = which(as.numeric(temp.[i,"HD01_VD01"])/2 <= cumsum(as.numeric(temp.[i,5:9])))[1]
    t. = income_classes[t.]
    median_income_class <- c(median_income_class, t.)
    
    }
  temp.[,"median_income_class"] <-  factor(median_income_class, levels = income_classes)
  temp.[,"MIC"] <- as.numeric(factor(temp.$median_income_class, levels = income_classes))
  temp.
  })  
  
output$tbl <- renderDataTable(selected_black_income())

# map the selection 
  # Attach the geometries 

selected_map_data <- eventReactive(input$begin, { 
g <-
 tracts(input$state_select,input$county_select)

g <- st_as_sf(g)
g <- merge(g[,"GEOID"],selected_black_income(),
           by.y = "GEO.id2", by.x = "GEOID", sort = FALSE, all.x = TRUE)
g
  })

output$map <- renderLeaflet({
  m <- selected_map_data() 
  
  labels <- sprintf(
    "Households: %s<br/> Median Income Class: %s <br/> Number of >75k Households: %s ",
    m$HD01_VD01, m$median_income_class, m$`75k-125k`+m$`125k+`
  ) %>% lapply(htmltools::HTML)
  
  leaflet(m) %>% addTiles()  %>% 
    addPolygons(fillColor = ~pal(MIC), weight = 2,opacity = 5, 
                fill = TRUE,
                fillOpacity = .8, label = labels, 
                labelOptions =labelOptions(
                  style = list("font-weight" = "normal", padding = "3px 8px"),
                  textsize = "15px",
                  direction = "auto")) 

  
})
  
})
