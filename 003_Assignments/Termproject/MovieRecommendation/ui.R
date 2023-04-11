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
                                         valueField = 'value',
                                         labelField = c('title'),
                                         render = I("{
                                                      option: function(item, escape) {
                                                        return '<div>' + escape(item.title) +
                                                               '</div>';
                                                      }
                                                    }")),
                          multiple = T)
    ),
    column(4,
           sliderInput(
             'top.n', 
             'Choose number of recommendations', 
             value = 20, 
             min = 5,
             max = 40,
             step = 5
           ),
           radioButtons(inputId = 'recommend.method',
                        label='What would you prefer to base recommendation on?',
                        choices = c("Users with the same taste as your." = "UBCF",
                                    "Movies that similar to your selected ones." = "IBCF",
                                    "Popular movies that you might have not seen." = "POPULAR",
                                    "Based on all of above." = "HYBRID"
                                    )),
           actionButton("generate.recommend", 
                        "Generate Recommend")
    ),
    column(4,
           div(p("Your movie recommendation")),
           div(style='overflow-x: hidden;height:400px;overflow-y: scroll;',
               htmlOutput('recommend.list')
           )
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
                                         valueField = 'value',
                                         labelField = c('title'),
                                         render = I("{
                                                      option: function(item, escape) {
                                                        return '<div>' + escape(item.title) +
                                                               '</div>';
                                                      }
                                                    }")),
                          multiple = F)
    ),
    column(5, align="center",
           htmlOutput('movie.detail.poster'),
           h3(textOutput('movie.detail.title')),
           div(align="left",
               h4("URL"),
               htmlOutput('movie.detail.url'),
               h4("Genres"),
               textOutput('movie.detail.genres'))
           
    ),
    column(4, align="left", 
           div(p("Similar movies")),
           div(style='overflow-x: hidden;height:500px;overflow-y: scroll;',
               htmlOutput('movie.10.nearest')
               )
           )
    )
)

# Define UI
ui <- navbarPage("Movie Recommendation",
                 id = 'mainPage',
                 useShinyjs(),
                 includeScript("resource/jquery-3.6.4.min.js"),
                 includeScript("resource/myscript.js"),
                 tabPanel("Recommendation",
                          value = 'panel1',
                          fluid.page1),
                 tabPanel("Movie detail", 
                          value = 'panel2',
                          fluid.page2)
                 )
