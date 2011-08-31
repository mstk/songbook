$(document).ready(function(){
  
  
  var new_section = function(title) {
    var section = $('<div/>').attr({ 'class':'section_entry' });
    var section_info = $('<div/>').attr( {'class': 'section_entry_info' } );
    
    
    var section_title = $('<span/>').attr( {'class': 'section_entry_title' } ).html(title);
    var section_title_editor = $('<input/>').attr({'class':'section_title_editor'}).css('display','none').val(title);
    
    section_title.click(function() {
      enable_section_title_editing(section);
    });
    section_title_editor.blur(function() {
      update_section_title(section);
    });
    
    
    // var common_section_titles = ["Verse","Chorus","PreChorus","PostChorus","Bridge","Tag","Intro","Outro"];
    
    // section_title_editor.autocomplete( { source: common_section_titles } );
    
    // section_title_editor.bind( 'autocompletechange', function(e,a) { update_section_title(section); } );
    
    section_info.append(section_title);
    section_info.append(section_title_editor);
    
    var section_lines = $('<div/>').attr( {'class':'section_entry_lines'} );
    
    var section_lines_list = $('<ul/>').attr( {'class': 'section_entry_lines_list'} );
    section_lines.append(section_lines_list);
    
    add_line(section_lines);
    
    var add_line_link = $('<a/>').attr({ 'href':'javascript:;', 'class':'add_line_link' }).html('Add Line').click(function() {
      add_line(section_lines);
    });
    
    section.append(section_info);
    section.append(section_lines);
    section.append(add_line_link);
    
    return section;
  };
  
  var enable_section_title_editing = function(section) {
    var title = section.find('.section_entry_title');
    var textbox = section.find('.section_title_editor');
    
    title.toggle();
    textbox.toggle();
    
    textbox.focus();
    textbox.select();
  };
  
  var update_section_title = function(section) {
    var title = section.find('.section_entry_title');
    var textbox = section.find('.section_title_editor');
    
    if (validate_section_title(textbox.val())) {
      title.html(textbox.val());
      
      title.toggle();
      textbox.toggle();
    } else {
      alert('hey that doesn\'t work noob');
      textbox.focus();
      textbox.select();
    }
    
    
    
  };
  
  var validate_section_title = function(title) {
    return (title != "New Title")
  };
  
  // make lines start with chords depending on time signature
  var new_line = function() {
    
    var line = $('<div/>').attr({ 'class':'line_entry' });
      
    var line_segments_list = $('<ul/>').attr( {'class': 'line_segments_entry_list'} );
    line.append(line_segments_list);
    
    add_line_segment(line,'p',true);
    
    for (var i=0;i<4;i++) {
      
      add_line_segment(line,i);
      
    }
    
    
    return line;
    
  };
  
  var new_line_segment = function(position,pickup,linked) {
    
    
    var line_segment = $('<div/>').attr({ 'class':'line_segment_entry' });
    
    var position = $('<input/>').attr({ 'type':'hidden', 'class':'line_segment_position' }).val(position);
    
    var chord_div = $('<div/>').attr({ 'class':'line_segment_chord_entry_container' });
    var lyrics_div = $('<div/>').attr({ 'class':'line_segment_lyrics_entry_container' });
    
    var chord_inp = $('<input/>').attr({ 'class':'line_segment_chord_entry' });
    var lyrics_inp = $('<input/>').attr({ 'class':'line_segment_lyrics_entry' });
    
    var split_link = $('<a/>').attr({ 'href':'javascript:;', 'class':'line_segment_split_link' }).html('Split').click(function() {
      split_line_segment(line_segment);
    });
    
    chord_div.append(chord_inp);
    chord_div.append(split_link);
    lyrics_div.append(lyrics_inp);
    
    line_segment.append(position);
    line_segment.append(chord_div);
    line_segment.append(lyrics_div);
    
    
    
    // Handling special cases (pickup, linked)
    if (pickup != null && pickup != false) {
      split_link.remove();
      chord_inp.css("display","none");
      var pickup_text = $('<span/>').attr({ 'class':'line_entry_pickup_display' }).html("(pickup)");
      chord_div.append(pickup_text);
    }
    if (linked != null && linked != false) {
      split_link.remove();
      chord_div.attr("disabled","disabled");
    }
    
    return line_segment;
    
  };
  
  // can only split line segment in half for now but... yeah.  don't expect to need anything else.
  // work on de-splitting/merging and displaying a split "grid", or some kind of tree nest to show timings?
  var split_line_segment = function(line_segment) {
    var old_position = line_segment.find('.line_segment_position').val();
    var first_new_position = old_position + "0";
    var second_new_position = old_position + "1";
    var line = line_segment.parentsUntil('.line_entry')
    
    first_new_segment = add_line_segment(line,first_new_position,false,line_segment);
    second_new_segment = add_line_segment(line,second_new_position,false,first_new_segment);
    
    var old_lyric = line_segment.find('.line_segment_lyrics_entry').val();
    var old_chord = line_segment.find('.line_segment_chord_entry').val();
    
    first_new_segment.find('.line_segment_lyrics_entry').val(old_lyric);
    first_new_segment.find('.line_segment_chord_entry').val(old_chord);
    second_new_segment.find('.line_segment_chord_entry').val(old_chord);
    
    line_segment.parent().remove();
    
  };
  
  
  var add_section = function() {
    
    var list_point = $('<li/>').attr({ 'class':'section_entry_point' });
    var ns = new_section("New Title");
    list_point.append(ns);
    
    $('#sections_entry_list').append(list_point);
    
    enable_section_title_editing(ns);
    
    return ns;
  };
  
  var add_line = function(section) {
    var list_point = $('<li/>').attr({ 'class':'line_entry_point' });
    var nl = new_line();
    
    list_point.append(nl);
    
    section.find('.section_entry_lines_list').append(list_point);
    
    return nl;
  };
  
  // duplicate line
  
  var add_line_segment = function(line,position,pickup,after_segment) {
    var list_point = $('<li/>').attr({ 'class':'line_entry_point' });
    var nls = new_line_segment(position,pickup);
    
    list_point.append(nls);
    if (after_segment == null) {
      line.find('.line_segments_entry_list').append(list_point);
    } else {
      // var to_add_after = line.find('.line_segment_position,value="' + after_pos + '"');
      // to_add_after.fadeOut('slow');
      // list_point.insertAfter();
      after_segment.parent().after(list_point);
    }
    
    return nls;
  };
  
  
  
  
  
  $('#ns-add_section_link').click(add_section);
  
});