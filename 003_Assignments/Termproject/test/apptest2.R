library(shiny)
# we will use .png files from shiny package
shiny_imgs <- list.files(path = system.file(package = "shiny"), pattern = ".png", recursive = TRUE, full.names = TRUE)

# here we create ui with a #img_list selector
# and an empty div where clickable images will be shown
ui <- fluidPage(selectInput(inputId = "img_list", label = "logo", choices = basename(shiny_imgs),
                            selected = basename(shiny_imgs)[1], multiple = FALSE),
                div(id = "img_placeholder"))
server <- function(input, output, session) {
  # observer on selector change
  observeEvent(input$img_list, {
    path_to_img = shiny_imgs[basename(shiny_imgs) == input$img_list]
    # the structure is 
    # div
    #   |_a
    #     |_img
    # first children a tag from #img_placeholder is removed 
    removeUI(selector = "#img_placeholder>a", multiple = TRUE, immediate = TRUE)
    # then we insert an image into a a tag into the div
    insertUI(selector = "#img_placeholder", where = "afterBegin", multiple = FALSE, immediate = TRUE,
             # the href could also be changed on selector change 
             # for instance if you want to link to an url on apple and another url on banana and another of lemon...
             ui = tags$a(href="https://community.rstudio.com/t/how-to-insert-an-clickable-image-in-shiny-r/111026?",
                         tags$img(height = 200, width = 200, 
                                  src = session$fileUrl(name = "logo", contentType = "data:image/png",
                                                        file = path_to_img))
             ))
  })
}
shinyApp(ui, server)