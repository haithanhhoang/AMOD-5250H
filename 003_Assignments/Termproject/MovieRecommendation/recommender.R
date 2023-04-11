library(recommenderlab)
library(logger)

# Train new model from scratch
init.recommender <- function(mode){
  data("MovieLense")
  rating.data <- MovieLense@data
  rating.data <- as(as.matrix(rating.data), "binaryRatingMatrix")
  recommender <- Recommender(rating.data, method=mode, parameter=list(k=64))
  return(recommender)
}

# Get recommender model from save file
# If file does not exist, train from scratch
get.recommender <- function(mode){
  log_info("Get {mode} recommender.")
  
  save.file <- c("POPULAR" = "recommender/model_popular.rds",
                 "UBCF" = "recommender/model_ubcf.rds",
                 "IBCF" = "recommender/model_ibcf.rds")
  
  # If mode is invalid, stop and report the incidence
  if(!is.element(mode, names(save.file))){
    log_error('Invalid mode {mode}.')
    stop('Invalid mode!')
  }
  
  log_info("Attempt to load model from {save.file[mode]}")
  
  tryCatch({
    recommender <- readRDS(save.file[mode])
    log_info('Loaded model from file!')
    },
    error = function(cond){
      log_info("Failed to load recommender from file, train new one.")
      recommender <- init.recommender(mode)
      saveRDS(recommender, save.file[mode])
      log_info('Saved new model to file!')
    })
  return(recommender)
}

# Get hybrid recommender from list of recommenders using "sum" strategy
get.hybrid.recommender <- function(..., weights){

  hybrid.rec <- HybridRecommender(..., 
                                  weights = weights, 
                                  aggregation_type = "sum")
  
  return (hybrid.rec)
}

# Get recommendation (prediction) from model
get.recommendation <- function(model, # model used to generate recommend
                               newdata, # user's binary rating matrix data
                               number.of.recommendation # number of movies to recommend
){
  rec <- recommenderlab::predict(model, 
                                 newdata=newdata, 
                                 n = number.of.recommendation)
  
  rec <- getList(rec, decode = F)[["0"]]
  
  # Remove all NAs
  rec <- rec[!is.na(rec)]
  print(rec)
  return(rec)
}