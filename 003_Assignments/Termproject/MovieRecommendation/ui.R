library(shiny)

# Define list_1
library(recommenderlab)
library(shinyjs)
data("MovieLense")

# Code for page 1
fluid.page1 <- fluidPage(
  titlePanel("Movie recommendation"),
  
  fluidRow(
    column(4, 
           selectizeInput('movie.list', 
                          'Choose movies you have seen', 
                          choices = NULL,
                          options = list(placeholder = 'Select interested movies',
                                         searchField = 'title',
                                         render = I("{
                                                      option: function(item, escape) {
                                                        return '<div>' + escape(item.title) +
                                                               '</div>';
                                                      }
                                                    }")),
                          multiple = T)
    ),
    column(4,
           h4("Selected movies:"),
           tableOutput('table')
    ),
    column(4,
           numericInput(
             'top.n', 
             'Choose number of recommendations', 
             value = 10, 
             min = 5,
             max = 40,
             step = 5
           ),
           actionButton("generate.recommend", 
                         "Generate Recommend"),
    )
  )
)

# Code for page 2
fluid.page2 <- fluidPage(
  titlePanel("Movie details"),
  
  fluidRow(
    column(3, 
           selectizeInput('movie.detail.select', 
                          'Choose movies you have seen', 
                          choices = NULL,
                          options = list(placeholder = 'Select interested movies',
                                         searchField = 'title',
                                         
                                         render = I("{
                                                      option: function(item, escape) {
                                                        return '<div>' + escape(item.title) +
                                                               '</div>';
                                                      }
                                                    }")),
                          multiple = F)
    ),
    column(6, align="center",
           htmlOutput('movie.detail.poster'),
           h3(textOutput('movie.detail.title')),
           div(align="left",
               h4("URL"),
               htmlOutput('movie.detail.url'),
               h4("Genres"),
               textOutput('movie.detail.genres'))
           
    ),
    column(3, align="left", 
           div(style='overflow-x: hidden;height:500px;overflow-y: scroll;',
               htmlOutput('movie.10.nearest')
               )
           )
    )
)

# Define UI
ui <- navbarPage("Movie Recommendation",
                 useShinyjs(),
                 includeScript("../resource/jquery-3.6.4.min.js"),
                 includeScript("../resource/myscript.js"),
                 tabPanel("Recommendation",
                          fluid.page1),
                 tabPanel("Movie detail", fluid.page2)
                 )
