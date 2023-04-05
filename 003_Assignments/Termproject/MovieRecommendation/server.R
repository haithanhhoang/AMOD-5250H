library(recommenderlab)
data("MovieLense")

movie.data <- MovieLenseMeta
movie.data$label <- movie.data$title
movie.data$value <- as.integer(rownames(movie.data))

movie.data.poster <- read.csv("../data/movie_poster.csv", 
                              header = F, 
                              col.names = c("id", "poster_url"))
movie.data <- merge(movie.data, 
                    movie.data.poster, 
                    by.x = "value", 
                    by.y = "id", 
                    all.x = T)
genres <- colnames(movie.data)[5:22]

server <- function(input, output, session) {
  
  updateSelectizeInput(session, 
                         'movie.list', 
                         choices = movie.data, 
                         server = TRUE)
  
  updateSelectizeInput(session, 
                       'movie.detail.select', 
                       choices = movie.data, 
                       server = TRUE)
  
  movie.detail <- reactiveValues(select=1)
  movie.10.nearest <- reactiveValues()
  
  observeEvent(input$movie.detail.select, {
    movie.detail$title <- movie.data[input$movie.detail.select,"title"]
    movie.detail$poster.url <- movie.data[input$movie.detail.select,"poster_url"]
    movie.detail$url <- movie.data[input$movie.detail.select,"url"]
    movie.detail$genres <- genres[which(movie.data[input$movie.detail.select, 5:22]==1)]
    index <- movie.data[input$movie.detail.select,"value"]
    movie.10.nearest$data <- movie.data[sapply(1:10, function(i)i+index),]
    session$sendInputMessage("movie.detail.select", list(value=index))
  })
  
  
  output$table <- renderTable({
      sort(movie.data[input$movie.list, "title"])
  }, colnames = F, )
  
  
  
  output$movie.detail.title <- renderText(movie.detail$title)
  output$movie.detail.poster <- renderText({c('<img src="', 
                                              movie.detail$poster.url, 
                                              '" height=300 ',
                                              'onerror="this.onerror=null; this.src=\'https://cdn.browshot.com/static/images/not-found.png\'"',
                                              '>')})
  
  
  output$movie.10.nearest <- renderText({
    sapply(1:10, function(i) {
      sprintf('<div class="row" style="margin-top: 10px">
                   <img class="top.10.thumbnail col-sm-4" 
                        value=%d 
                        src="%s" 
                        height=100 
                        onerror="this.onerror=null; 
                        this.src=\'https://cdn.browshot.com/static/images/not-found.png\'" 
                        onClick="set_movie(this)" 
                        role="button"/>
                   <a class="col-sm-8" 
                      style="margin-top: 30px" 
                      value=%d 
                      onClick="set_movie(this)"
                      role="button">
                      %s
                   </a>
              </div>',
              as.integer(movie.10.nearest$data[i,"value"]),
              movie.10.nearest$data[i,"poster_url"],
              as.integer(movie.10.nearest$data[i,"value"]),
              movie.10.nearest$data[i,"title"]
              )
      
    })})
  
  output$movie.detail.url <- renderText({
    sprintf('<a href="%s">%s</a>', movie.detail$url, movie.detail$url)
    })
  
  output$movie.detail.genres <- renderText({
    paste(movie.detail$genres, collapse = '; ')
  })
}




