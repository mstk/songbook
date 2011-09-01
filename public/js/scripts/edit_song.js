$(document).ready(function(){
  
  var log_table = { 1:0, 2:1, 4:2, 8:3, 16:4, 32:5 }
  
  var song_id = window.location.href.match(/\/(\d+)$/)[1] * 1;
  
  var display_info = function(info) {
    
    var info_boxes = $('#es-data');
    info_boxes.find('#song_title').val(info.title);
    info_boxes.find('#artist').val(info.artist);
    info_boxes.find('#key').val(info.key);
    info_boxes.find('#time_signature').val(info.time_signature);
    info_boxes.find('#comments').val(info.tags);
    info_boxes.find('#tags').val(info.comments);
    
  };
  
  var display_sections = function(sections) {
    var i,j;
    
    sections.forEach(function(section) {
      // alert(JSON.stringify(section));
      var dom_section = sections_list.add_section(section.title,false,true,true,true);
      
      var num_variations = section.lines[0].lyrics.length;
        
      for (i = 1; i < num_variations; i++) {
        dom_section.add_variation();
      }
      
      
      section.lines.forEach(function(line) {
        
        var dom_line = dom_section.add_line(line.chords.length - 1);
        var segments = dom_line.segments;
        
        for (j = 1; j < line.chords.length; j++) {
          segments[j].change_chord(line.chords[j]);
        }
        
        for (i = 0; i < num_variations; i++) {
          segments[0].change_lyrics(i,line.lyrics[i][0]);
          
          for (j = 1; j < line.chords.length; j++) {
            segments[j].change_lyrics(i,line.lyrics[i][j]);
          }
        }
        
      });
    });
    sections_list.build();
  };
  
  var display_structure = function(structure) {
  };
  
  var display_song = function(data) {
    if (data.info) {
      display_info(data.info);
    }
    if (data.sections) {
      display_sections(data.sections);
    }
    if (data.structure) {
      display_structure(data.structure);
    };
    
  };
  
  var load_song = function() {
    $.post( '/ajax/song_data', { id: song_id, info: true, sections: false, structure: false }, function(data) {
      display_song(data);
    }, 'json');
  };
  
  
  load_song();
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  sections_list.build();
  $('#es-add_section_link').click(function() { sections_list.add_section(); });
  
  
});