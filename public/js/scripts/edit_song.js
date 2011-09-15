$(document).ready(function(){
  
  var utils = {
    is_instrumental: function(section) {
      var well_is_it = true;
      
      section.lines.forEach(function(line) {
        line.lyrics.forEach(function(variation) {
          variation.forEach(function(lyric) {
            if ($.trim(lyric) != '' ) {
              well_is_it = false;
            }
          });
        });
      });
      
      return well_is_it;
    }
  };
  
  var log_table = { 1:0, 2:1, 4:2, 8:3, 16:4, 32:5 }
  
  var song_id = window.location.href.match(/\/(\d+)$/)[1] * 1;
  
  var display_info = function(info) {
    var info_boxes = $('#es-data_grid');
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
      // alert(utils.is_instrumental(section));
      
      var is_instrumental = utils.is_instrumental(section);
      var dom_section = sections_list.add_section(section.title,is_instrumental,true,true,false);
      // alert(dom_section.instrumental);
      // alert("--");
      
      var num_variations = section.lines[0].lyrics.length;
        
      for (i = 1; i < num_variations; i++) {
        dom_section.add_variation();
      }
      
      
      section.lines.forEach(function(line,line_num) {
        
        var dom_line;
        if (line_num > 0) {
          dom_line = dom_section.add_line(line.chords.length - 1);
        } else {
          dom_line = dom_section.lines[0];
        }
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
        
        // merges the appropriate sections
        // does not work for non-4/4 sections as of yet.
        // that's a todo lol.
        var reduced_segments_array = segments.slice(1);
        
        while (reduced_segments_array.length > 1) {
          
          // alert(JSON.stringify($.map(reduced_segments_array,function (segment) { return (segment ? segment.chord : "") ;  })));
          
          var placeholder_array = [];
          
          var iters = Math.floor(reduced_segments_array.length/2);
          for (i=0;i<iters;i++) {
            var sample_1 = reduced_segments_array[2*i];
            var sample_2 = reduced_segments_array[2*i+1];
            
            if (sample_1 == null || sample_2 == null || sample_1.chord != sample_2.chord) {
              placeholder_array.push(null);
            } else {
              // alert(JSON.stringify([sample_1.position,sample_1.position.slice(0,-1)]));
              placeholder_array.push(dom_line.merge_segments(sample_1.position.slice(0,-1)));
            }
          }
          
          reduced_segments_array = placeholder_array;
          
        };
        
        
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