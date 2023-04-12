function set_movie(img){
  console.log(img.getAttribute("value"))
  Shiny.setInputValue('movie.img.clicked', img.getAttribute("value"), {priority: "event"});
};

