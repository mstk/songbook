$(document).ready(function(){
  
  var new_section = function(title) {
    var section = $('<div/>').attr({ 'class':'section_entry' });
    var section_info = $('<div/>').attr( {'class': 'section_entry_title' } ).html(title);
    
    var section_lines = $('<div/>').attr( {'class':'section_entry_lines'} );
    
    var section_lines_list = $('<ul/>').attr( {'class': 'section_entry_lines_list'} );
    section_lines.append(section_lines_list);
    
    add_line(section_lines);
    
    section.append(section_info);
    section.append(section_lines);
    
    return section;
  };
  
  
  // make lines start with chords depending on time signature
  var new_line = function() {
    
    var line = $('<div/>').attr({ 'class':'line_entry' });
      
    var line_segments_list = $('<ul/>').attr( {'class': 'line_segments_entry_list'} );
    line.append(line_segments_list);
    
    for (var i=0;i<4;i++) {
      
      add_line_segment(line,i);
      
    }
    
    
    return line;
    
  };
  
  var new_line_segment = function(position) {
    
    var line_segment = $('<div/>').attr({ 'class':'line_segment_entry' });
    
    var position = $('<input/>').attr({ 'type':'hidden', 'class':'line_segment_position' }).val(position);
    
    var chord_div = $('<div/>').attr({ 'class':'line_segment_chord_entry_container' });
    var lyrics_div = $('<div/>').attr({ 'class':'line_segment_lyrics_entry_container' });
    
    var chord_inp = $('<input/>').attr({ 'class':'line_segment_chord_entry' });
    var lyrics_inp = $('<input/>').attr({ 'class':'line_segment_lyrics_entry' });
    
    var split_link = $('<a/>').html('Split').click(function() {
      split_line_segment(line_segment);
    });
    
    chord_div.append(chord_inp);
    chord_div.append(split_link);
    lyrics_div.append(lyrics_inp);
    
    line_segment.append(position);
    line_segment.append(chord_div);
    line_segment.append(lyrics_div);
    
    return line_segment;
    
  };
  
  // can only split line segment in half for now but... yeah.  don't expect to need anything else.
  var split_line_segment = function(line_segment) {
    var old_position = line_segment.find('.line_segment_position').val();
    var first_new_position = old_position + "0";
    var second_new_position = old_position + "1";
    var line = line_segment.parentsUntil('.line_entry')
    
    first_new_segment = add_line_segment(line,first_new_position,line_segment);
    second_new_segment = add_line_segment(line,second_new_position,first_new_segment);
    
    var old_lyric = line_segment.find('.line_segment_lyrics_entry').val();
    var old_chord = line_segment.find('.line_segment_chord_entry').val();
    
    first_new_segment.find('.line_segment_lyrics_entry').val(old_lyric);
    first_new_segment.find('.line_segment_chord_entry').val(old_chord);
    second_new_segment.find('.line_segment_chord_entry').val(old_chord);
    
    line_segment.parent().remove();
    
  };
  
  
  add_section = function() {
    
    var list_point = $('<li/>').attr({ 'class':'section_entry_point' });
    var ns = new_section("VERSE");
    list_point.append(ns);
    
    $('#sections_entry_list').append(list_point);
    
    return ns;
  };
  
  add_line = function(section) {
    var list_point = $('<li/>').attr({ 'class':'line_entry_point' });
    var nl = new_line();
    
    list_point.append(nl);
    
    section.find('ul').append(list_point);
    
    return nl;
  };
  
  add_line_segment = function(line,position,after_segment) {
    var list_point = $('<li/>').attr({ 'class':'line_entry_point' });
    var nls = new_line_segment(position);
    
    list_point.append(nls);
    if (after_segment == null) {
      line.find('ul').append(list_point);
    } else {
      // var to_add_after = line.find('.line_segment_position,value="' + after_pos + '"');
      // to_add_after.fadeOut('slow');
      // list_point.insertAfter();
      after_segment.parent().after(list_point);
    }
    
    return nls;
  };
  
});