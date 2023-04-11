library(recommenderlab)
source("recommender.R")

# global objects
data("MovieLense")

movie.data <- MovieLenseMeta
movie.data$label <- movie.data$title
movie.data$value <- as.integer(rownames(movie.data))
movie.choise <- movie.data[order(movie.data["title"]),]

# Load movie's poster url data
movie.data.poster <- read.csv("data/movie_poster.csv", 
                              header = F, 
                              col.names = c("id", "poster_url"))

# Load movie's imdb url data
movie.data.url <- read.csv("data/movie_url.csv", 
                              header = F, 
                              col.names = c("id", "imdb_url"))

movie.data <- merge(movie.data, 
                    movie.data.poster, 
                    by.x = "value", 
                    by.y = "id", 
                    all.x = T)

movie.data <- merge(movie.data, 
                    movie.data.url, 
                    by.x = "value", 
                    by.y = "id", 
                    all.x = T)

movie.data$url <- movie.data$imdb_url

genres <- colnames(movie.data)[5:22]

# movie thumbnail html
thumbnail_html <- '<div class="row" style="margin-top: 10px">
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
                      </div>'


# Get models
model.ibcf <- get.recommender("IBCF")
log_info('Loaded IBCF model.')

model.popular <- get.recommender("POPULAR")
log_info('Loaded POPULAR model.')

model.ubcf <- get.recommender("UBCF")
log_info('Loaded UBCF model.')

model.hybrid <- get.hybrid.recommender(model.ibcf, model.popular, model.ubcf, 
                                       weights = c(.4, .2, .4))
log_info('Created Hybrid model.')

# Create new user rating matrix row from item list
# u_i = 1 if user u saw the i_th movie, otherwise u_i = 0
get.user.binary.row <- function(item.list){
  new.user <- rep(0, length(movie.data$value))
  new.user[item.list] <- 1
  new.user.matrix <- matrix(new.user, 
                            nrow=1, 
                            dimnames=list(users=paste("u", 1, sep=''),
                                          items=movie.data$value))
  binari.matrix <- as(new.user.matrix, "binaryRatingMatrix")
  return(binari.matrix)
}

# Get top.N similar item
get.similar.item <- function(item.id, top.N){
  
  user.matrix <- get.user.binary.row(c(item.id))
  
  # Use item-based to generate nearest top N movies
  recommendation <- get.recommendation(model.ibcf, user.matrix, top.N)
  return(recommendation)
}

server <- function(input, output, session) {
  
  # Serversize UI input render
  updateSelectizeInput(session, 
                       'movie.list',
                       choices = movie.choise, 
                       options = list(valueField = 'value',
                                      labelField = 'title'),
                       server = TRUE)
  
  updateSelectizeInput(session, 
                       'movie.detail.select', 
                       choices = movie.choise,
                       options = list(valueField = 'value',
                                      labelField = 'title'),
                       selected = 1,
                       server = TRUE)
  
  # Reactive values
  movie.detail <- reactiveValues(select=1)
  movie.10.nearest <- reactiveValues()
  recommend.list <- reactiveValues()
  
  
  # Hander events
  
  ## Generate recommendations when user clicks on "Generate recommend" button
  observeEvent(input$generate.recommend, {
    if(input$recommend.method == "UBCF"){
      model <- model.ubcf
    }
    else if(input$recommend.method == "IBCF"){
      model <- model.ibcf
    }
    else if(input$recommend.method == "POPULAR"){
      model <- model.popular
    }
    else{
      model <- model.hybrid
    }
    
    top.n <- input$top.n
    if(length(input$movie.list)>0){
      # Create new user row
      user.matrix <- get.user.binary.row(item.list = as.integer(input$movie.list))
      
      # Get recommendation movie'id
      recommend.id <- get.recommendation(model, user.matrix, top.n)
      
      # From id, get coresponding movie objects
      recommendation <- movie.data[movie.data[["value"]] %in% recommend.id,] 
      
      # Render list html
      recommend.list$html <- sapply(1:nrow(recommendation), function(i) {
                                sprintf(thumbnail_html,
                                  as.integer(recommendation[i,"value"]),
                                  recommendation[i,"poster_url"],
                                  as.integer(recommendation[i,"value"]),
                                  recommendation[i,"title"]
                                  )
                                })

      
      
    }else{
      recommend.list$html <- '<div style="color:red"> 
                              Please select some movies you have seen first
                              </div>'
    }
  })
  
  
  ## Handle event that user clicked on movie poster, or movie name
  observeEvent(input$movie.img.clicked, {
    
    # Jump to movie detail panel
    updateTabsetPanel(session, "mainPage",
                      selected = "panel2")
    
    # Update user selected movie
    updateSelectizeInput(session, 
                         'movie.detail.select', 
                         choices = movie.choise,
                         options = list(valueField = 'value',
                                        labelField = 'title'),
                         selected = as.integer(input$movie.img.clicked),
                         server = TRUE)
    
  })
  
  
  ## Handle event that user change movie on detail panel
  observeEvent(input$movie.detail.select, {

    movie <- as.vector(movie.data[movie.data["value"] == input$movie.detail.select,])
    movie.detail$title <- movie[["title"]]
    movie.detail$poster.url <- movie[["poster_url"]]
    movie.detail$url <- movie[["url"]]
    movie.detail$genres <- genres[which(movie[5:22]==1)]
    index <- movie[["value"]]

    if(is.integer(index)){

      log_info('Get top 10 nearest movies for id {index}')
      top.10.nearest <- get.similar.item(index, 10)
      movie.10.nearest$data <- movie.data[movie.data[["value"]] %in% top.10.nearest,]
    }
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
    sapply(1:nrow(movie.10.nearest$data), function(i) {
      sprintf(thumbnail_html,
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
  
  
  output$recommend.list <- renderText({recommend.list$html})
  
  

}




