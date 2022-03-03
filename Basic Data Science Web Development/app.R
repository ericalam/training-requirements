# libraries
library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(ggthemes)
library(shinyWidgets)

# read in data
data0 <- read.csv(here::here("data", "gapminder_clean.csv"))

# remove 'X' column, remove NA cases, and rename the rest of columns for legibility
data <- data0 %>%
  select(-X) %>%
  rename(
    Country = Country.Name,
    'Agriculture, value added (% of GDP)' = Agriculture..value.added....of.GDP.,
    'CO2 emissions (metric tons per capita)' = CO2.emissions..metric.tons.per.capita.,
    'Domestic credit provided by financial sector (% of GDP)' = Domestic.credit.provided.by.financial.sector....of.GDP.,
    'Electric power consumption (kWh per capita)' = Electric.power.consumption..kWh.per.capita.,
    'Energy use (kg of oil equivalent per capita)' = Energy.use..kg.of.oil.equivalent.per.capita.,
    'Exports of goods and services (% of GDP)' = Exports.of.goods.and.services....of.GDP.,
    'Fertility rate, total (births per woman)' = Fertility.rate..total..births.per.woman.,
    'GDP growth (annual %)' = GDP.growth..annual...,
    'Imports of goods and services (% of GDP)' = Imports.of.goods.and.services....of.GDP.,
    'Industry, value added (% of GDP)' = Industry..value.added....of.GDP.,
    'Inflation, GDP deflator (annual %)' = Inflation..GDP.deflator..annual...,
    'Life expectancy at birth, total (years)' = Life.expectancy.at.birth..total..years.,
    'Population density (people per sq. km of land area)' = Population.density..people.per.sq..km.of.land.area.,
    'Services, etc., value added (% of GDP)' = Services..etc...value.added....of.GDP.,
    Population = pop,
    Continent = continent,
    'GDP per capita' = gdpPercap
  ) %>%
  na.omit()

# ui
ui <- fluidPage(
  titlePanel(p("Gapminder", style = "color:#1f3333; font-size:300px; letter-spacing:-45px;")),
  plotlyOutput("plot"),
  chooseSliderSkin("Flat"), # stylize sliderInput
  setSliderColor("DarkSlateGray", 1),
  setBackgroundColor("#fafafa"),
  
  fluidRow(
    column(12, align = "center",
           tags$style(type = "text/css", ".irs-grid-pol.small {height: 0px;}"), # removes minor ticks
           sliderInput(
             inputId = "yr",
             label = NULL, 
             min = 1962,
             max = 2007,
             step = 5,
             value = 1962,
             sep = "",
             width = "90%")
           )),
  
  fluidRow(
    column(6, align = "right", 
           prettyCheckbox( 
             inputId = "logX", 
             label = "Show x-axis in log10", 
             value = FALSE, 
             width = "100%",
             shape = "curve")),
    column(6, align = "left",
           prettyCheckbox(
             inputId = "logY", 
             label = "Show y-axis in log10", 
             value = FALSE, 
             width = "100%",
             shape = "curve"))
  ),
  
# change size of selectInput dropdown
  tags$head(
    tags$style(HTML("

      .selectize-input {
        height: 50px;
        width: 280px;
        font-size: 8.5pt;
      }

    "))
  ),
  
  fluidRow(
    column(6, align = "center",
           selectInput(
             inputId = "xvar",
             label = "X axis:",
             choices = names(dplyr::select(data, -c(Country, Year, Continent, Population))) 
           )),
    column(6, align = "center",
           selectInput(
             inputId = "yvar",
             label = "Y axis:",
             choices = names(dplyr::select(data, -c(Country, Year, Continent, Population))) 
           ))
  )
)

# server
server <- function(input, output, session) {
  
  data_selected <- reactive({
    data_selected <- data %>%
      dplyr::filter(Year == input$yr) 
  })
  
  output$plot <- renderPlotly({
    
    # stylize plot
    style <- theme_tufte(base_size = 8.5, base_family = "arial") + 
      theme(axis.line.x = element_line(color="#1f3333", size = .5),
            axis.line.y = element_line(color="#1f3333", size = .5),
            text = element_text(color="#1f3333"),
            panel.background = element_rect(fill = "#fafafa", color = "#fafafa"),
            plot.background = element_rect(fill = "#fafafa"))
    
    baseplot <- ggplot(data_selected(), aes(.data[[input$xvar]], .data[[input$yvar]], 
                                            color = Continent, size = Population, ids = Country)) + 
      geom_point(alpha = 0.4)
    
    ogplot <- ggplotly(baseplot + style)
                          
    # if log10 on x-axis is called
    if(input$logX)
      ogplot <- ggplotly(baseplot + style +
                           scale_x_log10())
    
    # if log10 on y-axis is called
    if(input$logY)
      ogplot <- ggplotly(baseplot + style +
                           scale_y_log10())
    
    # if log10 on both axes are called
    if(input$logX & input$logY)
      ogplot <- ggplotly(baseplot + style +
                           scale_x_log10() +
                           scale_y_log10())
    
    return(ogplot)
    
  })
  
}


shinyApp(ui, server)
