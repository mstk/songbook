$(document).ready(function(){
  
  var song_id = window.location.href.match(/\/(\d+)$/)[1] * 1;
  
  $('#ss-edit_song_link').attr('href','/edit_song/' + song_id);
  
});