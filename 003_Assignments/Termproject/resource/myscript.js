function set_movie(img){
  
  Shiny.setInputValue('movie.detail.select', img.getAttribute("value"), {priority: "event"});
};

