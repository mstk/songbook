$(document).ready(function(){
  ['ns-title_inp','ns-artist_inp','ns-key_inp','ns-time_signature_inp','ns-comments_inp','ns-tags_inp'].forEach(function(field) {
    $(field).defaultValue();
  });
  
  $('#ns-form').submit(function(event) {
  
    event.preventDefault(); 
    
    // validate here or something idk
    
    $.post('/new_song', $('#ns-form').serialize(), function(data) {
      window.location.href = "/edit_song/" + data;
    });
    
  });
  
});