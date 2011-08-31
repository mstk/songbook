$(document).ready(function(){
  
  $('li.sl-song_li').each(function(i,song_li) {
    
    song_li.click(function() {
      
      song_li.find('a.sl-song_link').click();
      
    });
    
  });
  
});