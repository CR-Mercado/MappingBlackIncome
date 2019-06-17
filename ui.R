
library(shiny)
library(readr)
library(leaflet)

state_county <- read_rds("state_county.rds")

shinyUI(fluidPage(
  title = "Mapping Black Income",
  h2("Black Household Income"),
  h4("Select a State and County to Begin!"),
  fluidRow(column(3, 
                  selectInput(inputId = "state_select",
                              label = "Select a State",
                              choices = state_county[,"State"],multiple = FALSE,selected = NULL)),
           column(3,uiOutput("county_selection")),
  fluidRow(column(3,actionButton("begin",label = "Map"))
           )
  ),
  tabsetPanel(
    tabPanel("Map",
             leafletOutput("map")),
    tabPanel("Table",
             dataTableOutput("tbl"))
  )
  
  )
)
