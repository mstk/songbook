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
    sections.forEach(function(section) {
      alert(JSON.stringify(section));
      var new_section = sections_list.add_section(section.title,true,true);
      
      curr_line = new_section.lines[0];
      
      section.lines.forEach(function(line) {
        // var repeat_structure = line.repeat_structure
        // var has_pickup = (line.chords[0] == "") ? true : false
        // alert(JSON.stringify(line));
        
        // if (has_pickup) {
          // curr_line.segments[0].change_lyrics(0,line.lyrics[0][0]);
        // }
        
        // hack to sum an array to var resolution
        // for(var resolution = 0, i = repeat_structure.length; i; resolution += repeat_structure[--i]);
        
        
        
        
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