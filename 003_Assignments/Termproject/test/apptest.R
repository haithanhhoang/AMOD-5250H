if(interactive()){
  texts <- c("p1", "p2", "", "p4", "p5")
  hrefs <- c("https://github.com/lz100/spsComps/blob/master/img/1.jpg?raw=true",
             "https://github.com/lz100/spsComps/blob/master/img/2.jpg?raw=true",
             "",
             "https://github.com/lz100/spsComps/blob/master/img/4.jpg?raw=true",
             "https://github.com/lz100/spsComps/blob/master/img/5.jpg?raw=true")
  images <- c("https://github.com/lz100/spsComps/blob/master/img/1.jpg?raw=true",
              "https://github.com/lz100/spsComps/blob/master/img/2.jpg?raw=true",
              "https://github.com/lz100/spsComps/blob/master/img/3.jpg?raw=true",
              "https://github.com/lz100/spsComps/blob/master/img/4.jpg?raw=true",
              "https://github.com/lz100/spsComps/blob/master/img/5.jpg?raw=true")
  library(shiny)
  library(spsComps)
  
  ui <- fluidPage(
    column(
      6,
      gallery(texts = texts, hrefs = hrefs, images = images, title = "Default gallery"),
      spsHr(),
      gallery(texts = texts, hrefs = hrefs, images = images,
              image_frame_size = 2, title = "Photo size"),
      spsHr(),
      gallery(texts = texts, hrefs = hrefs, images = images,
              enlarge = TRUE, title = "Inline enlarge"),
      spsHr(),
      gallery(
        texts = texts, hrefs = hrefs, images = images,
        enlarge = TRUE, title = "Modal enlarge",
        enlarge_method = "modal"
      )
    )
  )
  
  server <- function(input, output, session) {
    
  }
  
  shinyApp(ui, server)
}