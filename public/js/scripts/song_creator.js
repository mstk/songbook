$(document).ready(function(){
  
  var sections_list = { build: $.noop() };
  
  // segment class
  var new_segment = function(line,position,chord,lyrics) {
    var segment = {
      line: line,
      position: position,
      chord: chord ? chord : "",
      lyrics: lyrics ? lyrics : [""],
      pickup: (position == 'p') ? true : false,
      clear_lyrics: function() {
        this.lyrics = $.map(this.lyrics, function(lyrics,i) { return ""; } );
      },
      add_variation: function() {
        this.lyrics.push("");
      },
      delete_variation: function(variation) {
        this.lyrics.splice(variation-1,1);
      },
      clone: function() {
        return new_segment(this.line,this.position,this.chord,this.lyrics.slice(0));
      },
      build: function(variation) {
        
        var segment_div = $('<div/>').attr('class','ns-segment');
        
        var chord_div = $('<div/>').attr('class','ns-chord');
        var lyrics_div = $('<div/>').attr('class','ns-lyrics');
        var options_div = $('<div/>').attr('class','ns-segment_opts');
        
        var lyrics_inp = $('<input/>').attr('class','ns-lyrics_inp').val(this.lyrics[variation]);
        
        segment_div.append(chord_div,lyrics_div,options_div);
        lyrics_div.append(lyrics_inp);
        
        if (this.pickup) {
          var pickup_text = $('<span/>').attr('class','ns-pickup_indicator').html("(pickup)");
          chord_div.append(pickup_text);
        } else {
          var chord_inp = $('<input/>').attr('class','ns-chord_inp').val(this.chord);
          chord_div.append(chord_inp);
          
          if (variation > 1) {
            chord_inp.attr('disabled','disabled');
          } else {
            chord_inp.change(function() { segment.change_chord(chord_inp.val(),chord_inp); });
            
            var split_link = $('<a/>').attr({ 'href':'javascript:;', 'class':'ns-split_segment_link' }).html('Split').click(function() {
              segment.line.split_segment(segment);
              sections_list.build();
            });
            options_div.append(split_link);
          }
        }
        
        lyrics_inp.change(function() { segment.change_lyrics(variation,lyrics_inp.val()); });
        
        return segment_div;
      },
      change_chord: function(new_chord,textbox) {
        if (false) {
          alert('Invalid chord.');
          textbox.focus();
          textbox.select();
        } else {
          this.chord = new_chord;
          // sections_list.build();
        }
      },
      change_lyrics: function(variation,new_lyrics) {
        this.lyrics[variation] = new_lyrics;
        // sections_list.build();
      }
    };
    return segment;
  };
  
  // line class
  var new_line = function(section) {
    var line = {
      section: section,
      segments: [],
      add_segment: function(pos) {
        this.segments.push(new_segment(this,pos));
      },
      split_segment: function(segment) {
        var segment_index = this.segments.indexOf(segment);
        var new_segment_1 = segment.clone();
        var new_segment_2 = segment.clone();
        
        new_segment_1.position += "0";
        new_segment_2.position += "1";
        
        new_segment_2.clear_lyrics();
        
        this.segments.splice(segment_index,1,new_segment_1,new_segment_2);
      },
      add_variation: function() {
        this.segments.forEach(function(segment) {
          segment.add_variation();
        });
      },
      delete_variation: function(variation) {
        this.segments.forEach(function(segment) {
          segment.delete_variation(variation);
        });
      },
      build: function(variation) {
        var line_div = $('<div/>').attr('class','ns-line');
        var segments_list = $('<ul/>').attr( {'class': 'ns-segments_ul'} );
        
        this.segments.forEach(function(segment) {
          var list_item = $('<li/>').attr({ 'class':'ns-segment_li' });
          var segment_div = segment.build(variation);
          
          list_item.append(segment_div);
          segments_list.append(list_item);
        });
        
        line_div.append(segments_list);
        
        var options_div = $('<div/>').attr('class','ns-line_opts');
        var this_line = this;
        
        
        if (this.section.lines.length > 1) {
          if (variation == 1)
          {
            var delete_line_link = $('<a/>').attr({ 'href':'javascript:;', 'class':'ns-delete_line_link' }).html('Delete Line').click(function() {
              this_line.section.delete_line(line);
              sections_list.build();
            });
            options_div.append(delete_line_link);
          }
        }
        
        line_div.append(options_div);
        
        return line_div;
      }
    };
    
    line.add_segment('p');
    
    // get from time signature or something
    line.add_segment('0');
    line.add_segment('1');
    line.split_segment(line.segments[0]);
    line.split_segment(line.segments[1]);
    
    return line;
  };
  
  // section class
  var new_section = function(title) {
    var section = {
      title: title ? title : "",
      variations_count: 1,
      lines: [],
      add_line: function() {
        this.lines.push(new_line(this));
      },
      delete_line: function(line) {
        var line_num = this.lines.indexOf(line);
        this.lines.splice(line_num,1);
      },
      add_variation: function() {
        this.lines.forEach(function(line) {
          line.add_variation();
        });
        this.variations_count += 1;
      },
      delete_variation: function(variation) {
        if (variation <= variations_count) {
          this.lines.forEach(function(line) {
            line.delete_variation(variation);
          });
          this.variations_count -= 1;
        }
      },
      build_variation: function(variation) {
        var variation_div = $('<div/>').attr('class','ns-variation');
        
        var title_div = $('<div/>').attr('class','ns-variation_title');
        var title_span = $('<span/>').attr('class','ns-variation_title_span').html(this.title + " " + (variation));
        
        title_div.append(title_span);
        variation_div.append(title_div);
        
        var lines_list = $('<ul/>').attr( {'class': 'ns-lines-ul'} );
        
        this.lines.forEach(function(line) {
          var list_item = $('<li/>').attr({ 'class':'ns-line_li' });
          var line_div = line.build(variation);
          
          list_item.append(line_div);
          lines_list.append(list_item);
        });
        
        variation_div.append(lines_list);
        
        var options_div = $('<div/>').attr('class','ns-variation_opts');
        
        if (variation==1) {
          
          var add_line_link = $('<a/>').attr({ 'href':'javascript:;', 'class':'ns-add_line_link' }).html('Add Line').click(function() {
            section.add_line();
            sections_list.build();
          });
          options_div.append(add_line_link);
          
        }
        if (this.variations_count == 1) {
          title_span.css('display','none');
        } else {
          
          var delete_variation_link = $('<a/>').attr({ 'href':'javascript:;', 'class':'ns-delete_variation_link' }).html('Delete Variation').click(function() {
            section.delete_variation(variation);
            sections_list.build();
          });
          options_div.append(add_line_link);
          
        }
        
        variation_div.append(options_div);
        
        
        return variation_div;
      },
      build: function() {
        var section_div = $('<div/>').attr('class','ns-section');
        
        var title_div = $('<div/>').attr('class','ns-section_title');
        // var title_span = $('<span/>').attr('class','ns-section_title_span').html(this.title);
        
        var title_inp = $('<input/>').attr({'class':'ns-section_title_inp', 'placeholder':'New Title'});
        title_inp.defaultValue();
        
        title_inp.val(this.title);
        
        title_div.append(title_inp);
        section_div.append(title_div);
        
        title_inp.change(function() { section.change_title(title_inp.val(),title_inp); });
        
        
        var variations_list = $('<ul/>').attr( {'class': 'ns-variations-ul'} );
        
        var i;
        for (i=0;i<this.variations_count;i++) {
          var list_item = $('<li/>').attr({ 'class':'ns-variation_li' });
          var variation_div = this.build_variation(i+1);
          
          list_item.append(variation_div);
          variations_list.append(list_item);
        }
        
        section_div.append(variations_list);
        
        var options_div = $('<div/>').attr('class','ns-section_opts');
        
        var add_var_link = $('<a/>').attr({ 'href':'javascript:;', 'class':'ns-add_variation_link' }).html('Add Variation').click(function() {
          section.add_variation();
          sections_list.build();
        });
        options_div.append(add_var_link);
        
        section_div.append(options_div);
        
        return section_div;
      },
      change_title: function(new_title,textbox) {
        if (false) {
          alert('Invalid Title');
          textbox.focus();
          textbox.select();
        } else {
          this.title = new_title;
        }
      }
    };
    
    section.add_line();
    
    return section;
    
  };
  
  
  // list of sections -- singleton
  sections_list = {
    sections: [],
    add_section: function(title) {
      this.sections.push(new_section(title));
      this.build();
      
      var new_section_title = $('.ns-section_title_inp').last();
      
      new_section_title.focus();
      new_section_title.select();
    },
    build: function() {
      var sections_list = $("#ns-sections_ul");
      
      sections_list.empty();
      
      this.sections.forEach(function(section) {
        var list_item = $('<li/>').attr({ 'class':'ns-section_li' });
        var section_div = section.build();
        
        list_item.append(section_div);
        sections_list.append(list_item);
        
      });
    }
  };

  $('#ns-add_section_link').click(function() { sections_list.add_section(); });
  
});